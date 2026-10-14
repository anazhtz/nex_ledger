import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/reports/data/input_gst.dart';

final purchaseInvoiceRepositoryProvider =
    Provider<PurchaseInvoiceRepository>((ref) {
  return PurchaseInvoiceRepository(ref.watch(appDatabaseProvider));
});

/// All GST purchase invoices with their rows and amounts paid, newest first.
final invoiceListProvider = StreamProvider<List<InvoiceDetail>>((ref) {
  return ref.watch(purchaseInvoiceRepositoryProvider).watchInvoices();
});

/// HSN / GST rate / unit remembered per material.
final itemDefaultsProvider = StreamProvider<List<ItemDefault>>((ref) {
  return ref.watch(purchaseInvoiceRepositoryProvider).watchItemDefaults();
});

/// The company's own GSTIN (Settings), or null when not set.
final companyGstinProvider = StreamProvider<String?>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .watchSetting(AppDatabase.settingCompanyGstin);
});

/// State code chosen in Settings for a company that has no GSTIN.
final companyStateSettingProvider = StreamProvider<String?>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .watchSetting(AppDatabase.settingCompanyState);
});

/// The company's 2-digit state code: from its GSTIN, else the Settings choice.
final companyStateCodeProvider = Provider<String?>((ref) {
  final gstin = ref.watch(companyGstinProvider).asData?.value;
  final chosen = ref.watch(companyStateSettingProvider).asData?.value;
  return GstUtils.stateCodeOf(gstin) ?? chosen;
});

/// Every bill that carries GST (purchases, subcontract, machinery rent,
/// expenses) for the Input GST report.
final inputGstEntriesProvider = StreamProvider<List<InputGstEntry>>((ref) {
  return InputGstRepository(ref.watch(appDatabaseProvider)).watchEntries();
});
