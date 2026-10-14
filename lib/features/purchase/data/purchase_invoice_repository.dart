import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/financial_year.dart';
import 'package:nex_ledger/core/utils/gst_calculator.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';

/// One item row typed on the invoice form.
class InvoiceLineDraft {
  /// The existing purchase row when editing an invoice (null for new rows).
  final int? purchaseId;
  final String item;
  final String? specification;
  final String? hsn;
  final String? unit;
  final double qty;
  final double rate;
  final double discountPercent;
  final double gstRate;
  final String? materialCategory;

  const InvoiceLineDraft({
    this.purchaseId,
    required this.item,
    this.specification,
    this.hsn,
    this.unit,
    required this.qty,
    required this.rate,
    this.discountPercent = 0,
    this.gstRate = 0,
    this.materialCategory,
  });

  GstLineInput get input => GstLineInput(
        qty: qty,
        rate: rate,
        discountPercent: discountPercent,
        gstRate: gstRate,
      );
}

/// Everything entered on the invoice form.
class PurchaseInvoiceDraft {
  final DateTime date;
  final String? invoiceNo;
  final DateTime? invoiceDate;
  final int vendorId;
  final int projectId;
  final String? supplierGstin;
  final String? supplierState;
  final String? supplierAddress;
  final bool interState;
  final int creditDays;
  final String? transportBy;
  final String? vehicleNo;
  final String? remarks;
  final bool isAdvanceStock;
  final List<InvoiceLineDraft> lines;

  /// Charges added on top of the items (no GST on these).
  final double freight;
  final double loading;
  final double otherCharges;
  final bool roundOff;

  /// Payment made when the bill is entered (create only).
  final double paidNow;
  final PaymentMode? paymentMode;
  final int? bankAccountId;
  final String? paymentReference;

  const PurchaseInvoiceDraft({
    required this.date,
    this.invoiceNo,
    this.invoiceDate,
    required this.vendorId,
    required this.projectId,
    this.supplierGstin,
    this.supplierState,
    this.supplierAddress,
    this.interState = false,
    this.creditDays = 0,
    this.transportBy,
    this.vehicleNo,
    this.remarks,
    this.isAdvanceStock = false,
    required this.lines,
    this.freight = 0,
    this.loading = 0,
    this.otherCharges = 0,
    this.roundOff = true,
    this.paidNow = 0,
    this.paymentMode,
    this.bankAccountId,
    this.paymentReference,
  });
}

/// A saved invoice with its rows and how much has been paid.
class InvoiceDetail {
  final PurchaseInvoice invoice;
  final Vendor vendor;
  final Project project;

  /// Item rows first, then charge rows.
  final List<PurchaseDetail> lines;
  final double paid;

  const InvoiceDetail({
    required this.invoice,
    required this.vendor,
    required this.project,
    required this.lines,
    required this.paid,
  });

  /// What the supplier is owed for this invoice (sum of its rows).
  double get total =>
      lines.fold<double>(0.0, (s, l) => s + l.transaction.amount);

  double get balance {
    final b = total - paid;
    return b > 0.005 ? b : 0.0;
  }

  DateTime? get dueDate => invoice.creditDays > 0
      ? invoice.date.add(Duration(days: invoice.creditDays))
      : null;

  PaymentStatus get status {
    if (balance <= 0.005) return PaymentStatus.paid;
    return paid > 0.005 ? PaymentStatus.partial : PaymentStatus.pending;
  }
}

const String kFreightLabel = 'Transport / Freight';
const String kLoadingLabel = 'Loading / Unloading';
const String kOtherChargeLabel = 'Other Charges';

class PurchaseInvoiceRepository {
  final AppDatabase _db;
  PurchaseInvoiceRepository(this._db);

  // ─── Numbering ─────────────────────────────────────────────────────────────

  /// Next purchase number for [date]'s financial year, e.g. PUR/26-27/00048.
  Future<String> nextPurchaseNo(DateTime date) async {
    final prefix = 'PUR/${financialYearShort(date)}/';
    final rows = await (_db.select(_db.purchaseInvoices)
          ..where((i) => i.purchaseNo.like('$prefix%')))
        .get();
    var maxSeq = 0;
    for (final r in rows) {
      final n = int.tryParse(r.purchaseNo.substring(prefix.length)) ?? 0;
      if (n > maxSeq) maxSeq = n;
    }
    return '$prefix${(maxSeq + 1).toString().padLeft(5, '0')}';
  }

  // ─── Calculation shared by create and edit ────────────────────────────────

  _Calculated _calculate(PurchaseInvoiceDraft d) {
    final items = d.lines.where((l) => l.item.trim().isNotEmpty).toList();
    if (items.isEmpty) {
      throw ArgumentError('Add at least one item to the invoice.');
    }
    for (final l in items) {
      if (l.qty <= 0) {
        throw ArgumentError('Quantity must be more than zero for "${l.item}".');
      }
      if (l.rate < 0) {
        throw ArgumentError('Rate cannot be negative for "${l.item}".');
      }
      if (l.gstRate < 0 || l.gstRate > 100) {
        throw ArgumentError(
            'GST rate must be between 0 and 100 for "${l.item}".');
      }
      if (l.discountPercent < 0 || l.discountPercent > 100) {
        throw ArgumentError(
            'Discount must be between 0 and 100 for "${l.item}".');
      }
    }
    final results = [
      for (final l in items) calcGstLine(l.input, interState: d.interState),
    ];
    final charges = <({String label, double amount})>[
      (label: kFreightLabel, amount: d.freight),
      (label: kLoadingLabel, amount: d.loading),
      (label: kOtherChargeLabel, amount: d.otherCharges),
    ].where((c) => c.amount > 0).toList();

    final totals = calcGstInvoice(
      results,
      charges: [for (final c in charges) c.amount],
      roundOff: d.roundOff,
    );
    if (totals.grandTotal <= 0) {
      throw ArgumentError('The invoice total must be more than zero.');
    }
    return _Calculated(items, results, charges, totals);
  }

  // ─── Create ────────────────────────────────────────────────────────────────

  Future<int> createInvoice(PurchaseInvoiceDraft d) async {
    final calc = _calculate(d);
    if (d.paidNow < 0 || d.paidNow > calc.totals.grandTotal + 0.005) {
      throw ArgumentError('Amount paid cannot be more than the invoice total.');
    }

    return _db.transaction(() async {
      final purchaseNo = await nextPurchaseNo(d.date);
      final invoiceId = await _db.into(_db.purchaseInvoices).insert(
            PurchaseInvoicesCompanion.insert(
              purchaseNo: purchaseNo,
              date: d.date,
              invoiceNo: Value(_clean(d.invoiceNo)),
              invoiceDate: Value(d.invoiceDate),
              vendorId: d.vendorId,
              projectId: d.projectId,
              supplierGstin: Value(_gstin(d.supplierGstin)),
              supplierState: Value(_clean(d.supplierState)),
              isInterState: Value(d.interState),
              creditDays: Value(d.creditDays < 0 ? 0 : d.creditDays),
              transportBy: Value(_clean(d.transportBy)),
              vehicleNo: Value(_clean(d.vehicleNo)),
              remarks: Value(_clean(d.remarks)),
              isAdvanceStock: Value(d.isAdvanceStock),
              taxableValue: Value(calc.totals.taxable),
              cgstAmount: Value(calc.totals.cgst),
              sgstAmount: Value(calc.totals.sgst),
              igstAmount: Value(calc.totals.igst),
              otherCharges: Value(calc.totals.otherCharges),
              roundOff: Value(calc.totals.roundOff),
              grandTotal: Value(calc.totals.grandTotal),
            ),
          );

      await _insertRows(invoiceId, d, calc);

      if (d.paidNow > 0.005) {
        await _insertPayment(
          invoiceId: invoiceId,
          purchaseNo: purchaseNo,
          projectId: d.projectId,
          date: d.date,
          amount: d.paidNow,
          mode: d.paymentMode,
          bankAccountId: d.bankAccountId,
          reference: d.paymentReference ?? _clean(d.invoiceNo),
        );
      }
      await _reallocate(invoiceId);
      await _rememberItems(calc.items);
      await _saveVendorGst(d);
      return invoiceId;
    });
  }

  /// Inserts one purchase row (and its bill transaction) per item and charge.
  /// The round-off is folded into the last row so the rows add up exactly to
  /// the invoice grand total.
  Future<void> _insertRows(
      int invoiceId, PurchaseInvoiceDraft d, _Calculated calc) async {
    final rows = <_RowToWrite>[
      for (var i = 0; i < calc.items.length; i++)
        _RowToWrite.item(calc.items[i], calc.results[i]),
      for (final c in calc.charges) _RowToWrite.charge(c.label, c.amount),
    ];
    final roundP = toPaise(calc.totals.roundOff);
    for (var i = 0; i < rows.length; i++) {
      final isLast = i == rows.length - 1;
      await _writeRow(
        invoiceId: invoiceId,
        d: d,
        row: rows[i],
        extraPaise: isLast ? roundP : 0,
      );
    }
  }

  Future<int> _writeRow({
    required int invoiceId,
    required PurchaseInvoiceDraft d,
    required _RowToWrite row,
    required int extraPaise,
    int? existingPurchaseId,
    int? existingTransactionId,
  }) async {
    final amount = fromPaise(toPaise(row.total) + extraPaise);
    final txnCompanion = TransactionsCompanion(
      projectId: Value(d.projectId),
      date: Value(d.date),
      type: const Value(TransactionType.purchase),
      affectsPnl: Value(!d.isAdvanceStock),
      // Bill rows only record what is owed. Cash moves through the separate
      // payment entries, so editing or deleting an invoice never has to flip
      // flags on the bill rows.
      affectsCash: const Value(false),
      amount: Value(amount),
      narration: Value(_clean(d.remarks)),
      referenceNo: Value(_clean(d.invoiceNo)),
      invoiceId: Value(invoiceId),
    );

    int txnId;
    if (existingTransactionId != null) {
      await (_db.update(_db.transactions)
            ..where((t) => t.id.equals(existingTransactionId)))
          .write(txnCompanion);
      txnId = existingTransactionId;
    } else {
      txnId = await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              projectId: d.projectId,
              date: d.date,
              type: TransactionType.purchase,
              affectsPnl: Value(!d.isAdvanceStock),
              affectsCash: const Value(false),
              amount: amount,
              narration: Value(_clean(d.remarks)),
              referenceNo: Value(_clean(d.invoiceNo)),
              invoiceId: Value(invoiceId),
            ),
          );
    }

    final l = row.line;
    final purchaseCompanion = PurchasesCompanion(
      transactionId: Value(txnId),
      vendorId: Value(d.vendorId),
      itemDescription: Value(row.description),
      quantity: Value(l?.qty ?? 1.0),
      unitRate: Value(l?.rate ?? row.total),
      unit: Value(_clean(l?.unit)),
      materialCategory: Value(
          row.isCharge ? 'Freight & Handling' : _clean(l?.materialCategory)),
      isAdvanceStock: Value(d.isAdvanceStock),
      invoiceId: Value(invoiceId),
      hsn: Value(_clean(l?.hsn)),
      specification: Value(_clean(l?.specification)),
      discountPercent: Value(l?.discountPercent ?? 0.0),
      gstRate: Value(l?.gstRate ?? 0.0),
      taxableAmount: Value(row.result?.taxable ?? row.total),
      cgstAmount: Value(row.result?.cgst ?? 0.0),
      sgstAmount: Value(row.result?.sgst ?? 0.0),
      igstAmount: Value(row.result?.igst ?? 0.0),
      isOtherCharge: Value(row.isCharge),
    );

    if (existingPurchaseId != null) {
      await (_db.update(_db.purchases)
            ..where((p) => p.id.equals(existingPurchaseId)))
          .write(purchaseCompanion);
      return existingPurchaseId;
    }
    return _db.into(_db.purchases).insert(PurchasesCompanion.insert(
          transactionId: txnId,
          vendorId: d.vendorId,
          itemDescription: row.description,
          paymentStatus: PaymentStatus.pending,
          quantity: purchaseCompanion.quantity,
          unitRate: purchaseCompanion.unitRate,
          unit: purchaseCompanion.unit,
          materialCategory: purchaseCompanion.materialCategory,
          isAdvanceStock: purchaseCompanion.isAdvanceStock,
          invoiceId: purchaseCompanion.invoiceId,
          hsn: purchaseCompanion.hsn,
          specification: purchaseCompanion.specification,
          discountPercent: purchaseCompanion.discountPercent,
          gstRate: purchaseCompanion.gstRate,
          taxableAmount: purchaseCompanion.taxableAmount,
          cgstAmount: purchaseCompanion.cgstAmount,
          sgstAmount: purchaseCompanion.sgstAmount,
          igstAmount: purchaseCompanion.igstAmount,
          isOtherCharge: purchaseCompanion.isOtherCharge,
        ));
  }

  // ─── Payments ──────────────────────────────────────────────────────────────

  Future<void> _insertPayment({
    required int invoiceId,
    required String purchaseNo,
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? mode,
    int? bankAccountId,
    String? reference,
  }) async {
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            projectId: projectId,
            date: date,
            type: TransactionType.purchasePayment,
            affectsPnl: const Value(false), // cost was booked with the bill
            affectsCash: const Value(true), // cash moves now
            amount: amount,
            paymentMode: Value(mode),
            bankAccountId: Value(bankAccountId),
            // Deliberately NOT the supplier's name: the supplier ledger links
            // loose payments to a supplier by name, which would double-count.
            narration: Value('Payment for invoice $purchaseNo'),
            referenceNo: Value(_clean(reference)),
            invoiceId: Value(invoiceId),
          ),
        );
  }

  /// Records a payment against the whole invoice. Returns the new balance.
  Future<double> recordInvoicePayment({
    required int invoiceId,
    required double amount,
    required DateTime date,
    PaymentMode? paymentMode,
    int? bankAccountId,
    String? referenceNo,
  }) async {
    return _db.transaction(() async {
      final detail = await getInvoice(invoiceId);
      if (detail == null) throw StateError('Invoice $invoiceId not found');
      if (amount <= 0) {
        throw ArgumentError('Payment must be more than zero.');
      }
      if (amount > detail.balance + 0.005) {
        throw ArgumentError(
            'Payment is more than the balance due on this invoice.');
      }
      await _insertPayment(
        invoiceId: invoiceId,
        purchaseNo: detail.invoice.purchaseNo,
        projectId: detail.invoice.projectId,
        date: date,
        amount: amount,
        mode: paymentMode,
        bankAccountId: bankAccountId,
        reference: referenceNo,
      );
      await _reallocate(invoiceId);
      return (await getInvoice(invoiceId))!.balance;
    });
  }

  /// Spreads the invoice's total payments over its rows (items first, then
  /// charges) and updates each row's paid amount and status.
  Future<void> _reallocate(int invoiceId) async {
    final rows = await _linesOf(invoiceId);
    final paid = await _paidOf(invoiceId);
    final alloc =
        allocatePaidInOrder(paid, [for (final r in rows) r.transaction.amount]);
    for (var i = 0; i < rows.length; i++) {
      final amount = rows[i].transaction.amount;
      final a = alloc[i];
      final status = a >= amount - 0.005
          ? PaymentStatus.paid
          : (a > 0.005 ? PaymentStatus.partial : PaymentStatus.pending);
      await (_db.update(_db.purchases)
            ..where((p) => p.id.equals(rows[i].purchase.id)))
          .write(PurchasesCompanion(
        paidAmount: Value(a),
        paymentStatus: Value(status),
      ));
    }
  }

  Future<double> _paidOf(int invoiceId) async {
    final pays = await (_db.select(_db.transactions)
          ..where((t) => t.invoiceId.equals(invoiceId))
          ..where((t) => t.type.equals(TransactionType.purchasePayment.name)))
        .get();
    var p = 0;
    for (final t in pays) {
      p += toPaise(t.amount);
    }
    return fromPaise(p);
  }

  // ─── Reading ───────────────────────────────────────────────────────────────

  Future<List<PurchaseDetail>> _linesOf(int invoiceId) async {
    final query = _db.select(_db.purchases).join([
      innerJoin(_db.transactions,
          _db.transactions.id.equalsExp(_db.purchases.transactionId)),
      innerJoin(_db.vendors, _db.vendors.id.equalsExp(_db.purchases.vendorId)),
      innerJoin(
          _db.projects, _db.projects.id.equalsExp(_db.transactions.projectId)),
    ])
      ..where(_db.purchases.invoiceId.equals(invoiceId))
      ..orderBy([
        OrderingTerm.asc(_db.purchases.isOtherCharge),
        OrderingTerm.asc(_db.purchases.id),
      ]);
    final rows = await query.get();
    return [
      for (final r in rows)
        PurchaseDetail(
          r.readTable(_db.purchases),
          r.readTable(_db.transactions),
          r.readTable(_db.vendors),
          r.readTable(_db.projects),
        ),
    ];
  }

  Future<InvoiceDetail?> getInvoice(int invoiceId) async {
    final inv = await (_db.select(_db.purchaseInvoices)
          ..where((i) => i.id.equals(invoiceId)))
        .getSingleOrNull();
    if (inv == null) return null;
    final vendor = await (_db.select(_db.vendors)
          ..where((v) => v.id.equals(inv.vendorId)))
        .getSingle();
    final project = await (_db.select(_db.projects)
          ..where((p) => p.id.equals(inv.projectId)))
        .getSingle();
    return InvoiceDetail(
      invoice: inv,
      vendor: vendor,
      project: project,
      lines: await _linesOf(invoiceId),
      paid: await _paidOf(invoiceId),
    );
  }

  /// All invoices, newest first, each with its rows and paid amount.
  Stream<List<InvoiceDetail>> watchInvoices() {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            _db.purchaseInvoices,
            _db.purchases,
            _db.transactions,
            _db.vendors,
            _db.projects,
          },
        )
        .watch()
        .asyncMap((_) async {
          final invoices = await (_db.select(_db.purchaseInvoices)
                ..orderBy([
                  (i) => OrderingTerm.desc(i.date),
                  (i) => OrderingTerm.desc(i.id),
                ]))
              .get();
          final result = <InvoiceDetail>[];
          for (final i in invoices) {
            final d = await getInvoice(i.id);
            if (d != null) result.add(d);
          }
          return result;
        });
  }

  // ─── Edit ──────────────────────────────────────────────────────────────────

  Future<void> updateInvoice(int invoiceId, PurchaseInvoiceDraft d) async {
    final calc = _calculate(d);
    await _db.transaction(() async {
      final existing = await getInvoice(invoiceId);
      if (existing == null) throw StateError('Invoice $invoiceId not found');
      if (existing.lines.any((l) => l.purchase.allocatedAmount > 0.005)) {
        throw StateError(
            'Stock from this invoice has already been allocated to projects, so it cannot be edited.');
      }
      if (calc.totals.grandTotal < existing.paid - 0.005) {
        throw StateError(
            'The new total is less than the ₹${existing.paid.toStringAsFixed(2)} already paid. Reduce the payments first.');
      }

      await (_db.update(_db.purchaseInvoices)
            ..where((i) => i.id.equals(invoiceId)))
          .write(PurchaseInvoicesCompanion(
        date: Value(d.date),
        invoiceNo: Value(_clean(d.invoiceNo)),
        invoiceDate: Value(d.invoiceDate),
        vendorId: Value(d.vendorId),
        projectId: Value(d.projectId),
        supplierGstin: Value(_gstin(d.supplierGstin)),
        supplierState: Value(_clean(d.supplierState)),
        isInterState: Value(d.interState),
        creditDays: Value(d.creditDays < 0 ? 0 : d.creditDays),
        transportBy: Value(_clean(d.transportBy)),
        vehicleNo: Value(_clean(d.vehicleNo)),
        remarks: Value(_clean(d.remarks)),
        isAdvanceStock: Value(d.isAdvanceStock),
        taxableValue: Value(calc.totals.taxable),
        cgstAmount: Value(calc.totals.cgst),
        sgstAmount: Value(calc.totals.sgst),
        igstAmount: Value(calc.totals.igst),
        otherCharges: Value(calc.totals.otherCharges),
        roundOff: Value(calc.totals.roundOff),
        grandTotal: Value(calc.totals.grandTotal),
      ));

      // Charge rows are rebuilt every time; item rows are updated in place so
      // their ids (and anything pointing at them) survive.
      final oldItems =
          existing.lines.where((l) => !l.purchase.isOtherCharge).toList();
      final oldCharges =
          existing.lines.where((l) => l.purchase.isOtherCharge).toList();
      final keepIds = {
        for (final l in calc.items)
          if (l.purchaseId != null) l.purchaseId!
      };
      for (final old in [
        ...oldCharges,
        ...oldItems.where((o) => !keepIds.contains(o.purchase.id)),
      ]) {
        await (_db.delete(_db.purchases)
              ..where((p) => p.id.equals(old.purchase.id)))
            .go();
        await (_db.delete(_db.transactions)
              ..where((t) => t.id.equals(old.transaction.id)))
            .go();
      }
      final oldById = {for (final o in oldItems) o.purchase.id: o};

      final rows = <_RowToWrite>[
        for (var i = 0; i < calc.items.length; i++)
          _RowToWrite.item(calc.items[i], calc.results[i]),
        for (final c in calc.charges) _RowToWrite.charge(c.label, c.amount),
      ];
      final roundP = toPaise(calc.totals.roundOff);
      for (var i = 0; i < rows.length; i++) {
        final r = rows[i];
        final old =
            r.line?.purchaseId != null ? oldById[r.line!.purchaseId] : null;
        await _writeRow(
          invoiceId: invoiceId,
          d: d,
          row: r,
          extraPaise: i == rows.length - 1 ? roundP : 0,
          existingPurchaseId: old?.purchase.id,
          existingTransactionId: old?.transaction.id,
        );
      }

      // Payments follow the invoice if it moved to another project.
      await (_db.update(_db.transactions)
            ..where((t) => t.invoiceId.equals(invoiceId))
            ..where((t) => t.type.equals(TransactionType.purchasePayment.name)))
          .write(TransactionsCompanion(projectId: Value(d.projectId)));

      await _reallocate(invoiceId);
      await _rememberItems(calc.items);
      await _saveVendorGst(d);
    });
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  /// Removes the invoice, all its rows and every payment made against it.
  Future<void> deleteInvoice(int invoiceId) async {
    await _db.transaction(() async {
      final d = await getInvoice(invoiceId);
      if (d == null) return;
      if (d.lines.any((l) => l.purchase.allocatedAmount > 0.005)) {
        throw StateError(
            'Stock from this invoice has already been allocated to projects, so it cannot be deleted.');
      }
      await (_db.delete(_db.purchases)
            ..where((p) => p.invoiceId.equals(invoiceId)))
          .go();
      await (_db.delete(_db.transactions)
            ..where((t) => t.invoiceId.equals(invoiceId)))
          .go();
      await (_db.delete(_db.purchaseInvoices)
            ..where((i) => i.id.equals(invoiceId)))
          .go();
    });
  }

  // ─── Remembered item defaults & supplier GST ──────────────────────────────

  Stream<List<ItemDefault>> watchItemDefaults() => (_db.select(_db.itemDefaults)
        ..orderBy([(i) => OrderingTerm.asc(i.itemName)]))
      .watch();

  Future<void> _rememberItems(List<InvoiceLineDraft> items) async {
    for (final l in items) {
      final name = l.item.trim();
      final key = name.toLowerCase();
      if (key.isEmpty) continue;
      // drift's insertOnConflictUpdate only reacts to the primary key, not to
      // our unique item name, so look the item up first.
      final values = ItemDefaultsCompanion(
        itemName: Value(name),
        hsn: Value(_clean(l.hsn)),
        gstRate: Value(l.gstRate),
        unit: Value(_clean(l.unit)),
        updatedAt: Value(DateTime.now()),
      );
      final existing = await (_db.select(_db.itemDefaults)
            ..where((i) => i.itemKey.equals(key)))
          .getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.itemDefaults)
              ..where((i) => i.id.equals(existing.id)))
            .write(values);
      } else {
        await _db.into(_db.itemDefaults).insert(
              values.copyWith(itemKey: Value(key)),
            );
      }
    }
  }

  Future<void> _saveVendorGst(PurchaseInvoiceDraft d) async {
    final gstin = _gstin(d.supplierGstin);
    final state = _clean(d.supplierState);
    final address = _clean(d.supplierAddress);
    if (gstin == null && state == null && address == null) return;
    await (_db.update(_db.vendors)..where((v) => v.id.equals(d.vendorId)))
        .write(VendorsCompanion(
      gstin: gstin != null ? Value(gstin) : const Value.absent(),
      state: state != null ? Value(state) : const Value.absent(),
      address: address != null ? Value(address) : const Value.absent(),
    ));
  }

  // ─── helpers ───────────────────────────────────────────────────────────────

  static String? _clean(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  static String? _gstin(String? s) {
    final g = GstUtils.normalize(s);
    return g.isEmpty ? null : g;
  }
}

class _Calculated {
  final List<InvoiceLineDraft> items;
  final List<GstLineResult> results;
  final List<({String label, double amount})> charges;
  final GstInvoiceTotals totals;
  _Calculated(this.items, this.results, this.charges, this.totals);
}

class _RowToWrite {
  final InvoiceLineDraft? line;
  final GstLineResult? result;
  final String description;
  final double total;
  final bool isCharge;

  _RowToWrite.item(InvoiceLineDraft l, GstLineResult r)
      : line = l,
        result = r,
        description = l.item.trim(),
        total = r.total,
        isCharge = false;

  _RowToWrite.charge(String label, double amount)
      : line = null,
        result = null,
        description = label,
        total = amount,
        isCharge = true;
}
