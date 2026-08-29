import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/features/reports/models/ledger_models.dart';
import 'package:nex_ledger/features/reports/providers/ledger_providers.dart';
import 'package:nex_ledger/features/subcontract/providers/subcontract_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

class LedgersHubScreen extends ConsumerStatefulWidget {
  const LedgersHubScreen({super.key});

  @override
  ConsumerState<LedgersHubScreen> createState() => _LedgersHubScreenState();
}

class _LedgersHubScreenState extends ConsumerState<LedgersHubScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _exporting = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _setDateRange(DateTimeRange? range) {
    ref.read(ledgerDateRangeProvider.notifier).state = range;
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: ref.read(ledgerDateRangeProvider),
    );
    if (picked != null) {
      _setDateRange(picked);
    }
  }

  Future<void> _exportActiveLedger({
    required String ledgerTitle,
    required LedgerSummary summary,
    required List<LedgerEntry> entries,
  }) async {
    setState(() => _exporting = true);
    try {
      final range = ref.read(ledgerDateRangeProvider);
      final filePath = await ExcelExportService.exportLedgerStatement(
        ledgerTitle: ledgerTitle,
        summary: summary,
        entries: entries,
        dateRange: range,
      );
      if (!mounted) return;
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ledger statement exported: $filePath'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeTab = ref.watch(activeLedgerTabProvider);
    final dateRange = ref.watch(ledgerDateRangeProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Top Actions ──────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Ledgers & Statements',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Running debit/credit statements for Suppliers, Labour, Bank & Cash Accounts, and Personal Equity',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );

                final actionButtons = Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Quick Date Filter Menu
                    PopupMenuButton<String>(
                      tooltip: 'Filter Period',
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 16.sp, color: const Color(0xFF475569)),
                            SizedBox(width: 8.w),
                            Text(
                              dateRange != null
                                  ? '${DateFormatter.format(dateRange.start)} - ${DateFormatter.format(dateRange.end)}'
                                  : 'All Time Period',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_drop_down,
                                size: 18.sp, color: const Color(0xFF64748B)),
                          ],
                        ),
                      ),
                      onSelected: (val) {
                        final now = DateTime.now();
                        if (val == 'all') {
                          _setDateRange(null);
                        } else if (val == 'this_month') {
                          _setDateRange(DateTimeRange(
                            start: DateTime(now.year, now.month, 1),
                            end: DateTime(now.year, now.month + 1, 0),
                          ));
                        } else if (val == 'last_month') {
                          _setDateRange(DateTimeRange(
                            start: DateTime(now.year, now.month - 1, 1),
                            end: DateTime(now.year, now.month, 0),
                          ));
                        } else if (val == 'this_year') {
                          _setDateRange(DateTimeRange(
                            start: DateTime(now.year, 1, 1),
                            end: DateTime(now.year, 12, 31),
                          ));
                        } else if (val == 'custom') {
                          _pickCustomDateRange();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'all', child: Text('All Time (Full Ledger)')),
                        const PopupMenuItem(value: 'this_month', child: Text('This Month')),
                        const PopupMenuItem(value: 'last_month', child: Text('Last Month')),
                        const PopupMenuItem(value: 'this_year', child: Text('This Financial Year')),
                        const PopupMenuDivider(),
                        const PopupMenuItem(value: 'custom', child: Text('Custom Date Range...')),
                      ],
                    ),

                    if (activeTab == LedgerType.personal) ...[
                      FilledButton.icon(
                        onPressed: () => _showOwnerTransactionDialog(context, isCapital: true),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('+ Inject Capital'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showOwnerTransactionDialog(context, isCapital: false),
                        icon: const Icon(Icons.remove_rounded, size: 16),
                        label: const Text('- Owner Drawings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                        ),
                      ),
                    ],
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      SizedBox(height: 12.h),
                      actionButtons,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleColumn),
                    SizedBox(width: 16.w),
                    actionButtons,
                  ],
                );
              },
            ),
            SizedBox(height: 20.h),

            // ─── Main Ledger Tabs (Segmented Button) ─────────────────────────
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<LedgerType>(
                segments: const [
                  ButtonSegment<LedgerType>(
                    value: LedgerType.client,
                    label: Text('Clients / Revenue'),
                    icon: Icon(Icons.business_center_rounded, size: 18),
                  ),
                  ButtonSegment<LedgerType>(
                    value: LedgerType.supplier,
                    label: Text('Suppliers / Vendors'),
                    icon: Icon(Icons.business_rounded, size: 18),
                  ),
                  ButtonSegment<LedgerType>(
                    value: LedgerType.subcontractor,
                    label: Text('Subcontractors / Piece-Rate'),
                    icon: Icon(Icons.handshake_rounded, size: 18),
                  ),
                  ButtonSegment<LedgerType>(
                    value: LedgerType.labour,
                    label: Text('Labour & Workers'),
                    icon: Icon(Icons.engineering_rounded, size: 18),
                  ),
                  ButtonSegment<LedgerType>(
                    value: LedgerType.bankCash,
                    label: Text('Bank & Cash Statements'),
                    icon: Icon(Icons.account_balance_rounded, size: 18),
                  ),
                  ButtonSegment<LedgerType>(
                    value: LedgerType.personal,
                    label: Text('Personal / Owner Equity'),
                    icon: Icon(Icons.person_pin_rounded, size: 18),
                  ),
                ],
                selected: {activeTab},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) {
                    ref.read(activeLedgerTabProvider.notifier).state = set.first;
                  }
                },
              ),
            ),
            SizedBox(height: 20.h),

            // ─── Active Tab Content ──────────────────────────────────────────
            switch (activeTab) {
              LedgerType.client => _buildClientLedger(context, theme),
              LedgerType.supplier => _buildSupplierLedger(context, theme),
              LedgerType.subcontractor => _buildSubcontractorLedger(context, theme),
              LedgerType.labour => _buildLabourLedger(context, theme),
              LedgerType.bankCash => _buildBankCashLedger(context, theme),
              LedgerType.personal => _buildPersonalLedger(context, theme),
            },
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 0. CLIENT / CUSTOMER CONTRACT LEDGER TAB
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildClientLedger(BuildContext context, ThemeData theme) {
    final projectsAsync = ref.watch(projectListProvider);
    final selectedProjectId = ref.watch(selectedLedgerClientProjectIdProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading projects: $e'),
      data: (projects) {
        final clientProjects = projects
            .where((p) => p.type == ProjectType.project)
            .toList();

        if (clientProjects.isEmpty) {
          return const _EmptyLedgerCard(
            title: 'No Client Projects Found',
            subtitle: 'Create projects and configure client contracts to view statement of accounts.',
          );
        }

        final effectiveProjectId =
            selectedProjectId ?? clientProjects.first.id;
        final ledgerDataAsync =
            ref.watch(clientLedgerProvider(effectiveProjectId));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar: Project / Client Selector
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 380.w,
                      child: DropdownButtonFormField<int>(
                        value: effectiveProjectId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Project & Client Contract',
                          prefixIcon: Icon(Icons.business_center_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: clientProjects
                            .map((p) => DropdownMenuItem<int>(
                                  value: p.id,
                                  child: Text(
                                    '${p.code} — ${p.name} (Client: ${p.clientName ?? 'Direct'})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (id) {
                          if (id != null) {
                            ref.read(selectedLedgerClientProjectIdProvider.notifier).state = id;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Ledger Statement View
            ledgerDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading ledger: $e'),
              data: (data) => _buildStatementContent(
                context: context,
                theme: theme,
                title: 'Client Statement of Account',
                summary: data.summary,
                entries: data.entries,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. SUPPLIER / VENDOR LEDGER TAB
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSupplierLedger(BuildContext context, ThemeData theme) {
    final vendorsAsync = ref.watch(vendorListProvider);
    final selectedVendorId = ref.watch(selectedLedgerVendorIdProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final selectedProjectId = ref.watch(ledgerProjectFilterProvider);

    return vendorsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading suppliers: $e'),
      data: (vendors) {
        if (vendors.isEmpty) {
          return const _EmptyLedgerCard(
            title: 'No Suppliers / Vendors Found',
            subtitle: 'Add vendors while recording material purchases to see their running ledgers.',
          );
        }

        // Auto-select first vendor if none selected
        final effectiveVendorId = selectedVendorId ?? vendors.first.id;
        final ledgerDataAsync = ref.watch(vendorLedgerProvider(effectiveVendorId));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar: Vendor Selector & Project Filter
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Vendor Dropdown
                    SizedBox(
                      width: 280.w,
                      child: DropdownButtonFormField<int>(
                        value: effectiveVendorId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Supplier / Vendor',
                          prefixIcon: Icon(Icons.business_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: vendors
                            .map((v) => DropdownMenuItem<int>(
                                  value: v.id,
                                  child: Text(
                                    v.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (id) {
                          if (id != null) {
                            ref.read(selectedLedgerVendorIdProvider.notifier).state = id;
                          }
                        },
                      ),
                    ),

                    // Project Filter Dropdown
                    projectsAsync.maybeWhen(
                      data: (projects) => SizedBox(
                        width: 240.w,
                        child: DropdownButtonFormField<int?>(
                          value: selectedProjectId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            prefixIcon: Icon(Icons.folder_outlined, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Projects', overflow: TextOverflow.ellipsis),
                            ),
                            ...projects.map((p) => DropdownMenuItem<int?>(
                                  value: p.id,
                                  child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (pId) {
                            ref.read(ledgerProjectFilterProvider.notifier).state = pId;
                          },
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Ledger Statement View
            ledgerDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading ledger: $e'),
              data: (data) => _buildStatementContent(
                context: context,
                theme: theme,
                title: 'Supplier Statement',
                summary: data.summary,
                entries: data.entries,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1b. SUBCONTRACTOR / PIECE-RATE LEDGER TAB
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSubcontractorLedger(BuildContext context, ThemeData theme) {
    final subsAsync = ref.watch(subcontractorListProvider);
    final selectedSubId = ref.watch(selectedLedgerSubcontractorIdProvider);
    final projectsAsync = ref.watch(projectListProvider);

    return subsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading subcontractors: $e'),
      data: (subs) {
        if (subs.isEmpty) {
          return const _EmptyLedgerCard(
            title: 'No Subcontractors Found',
            subtitle: 'Add subcontractors and piece-rate work orders to see their running measurement & payment ledgers.',
          );
        }

        final effectiveSubId = selectedSubId ?? subs.first.id;
        final ledgerDataAsync = ref.watch(subcontractorLedgerProvider(effectiveSubId));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Subcontractor Dropdown
                    SizedBox(
                      width: 280.w,
                      child: DropdownButtonFormField<int>(
                        value: effectiveSubId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Subcontractor / Gang',
                          prefixIcon: Icon(Icons.handshake_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: subs
                            .map((s) => DropdownMenuItem<int>(
                                  value: s.id,
                                  child: Text(
                                    '${s.name} (${s.trade})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (id) {
                          if (id != null) {
                            ref.read(selectedLedgerSubcontractorIdProvider.notifier).state = id;
                          }
                        },
                      ),
                    ),

                    // Project Filter Dropdown
                    projectsAsync.maybeWhen(
                      data: (projects) => SizedBox(
                        width: 240.w,
                        child: DropdownButtonFormField<int?>(
                          value: ref.watch(ledgerProjectFilterProvider),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            prefixIcon: Icon(Icons.folder_outlined, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Projects', overflow: TextOverflow.ellipsis),
                            ),
                            ...projects.map((p) => DropdownMenuItem<int?>(
                                  value: p.id,
                                  child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (pId) {
                            ref.read(ledgerProjectFilterProvider.notifier).state = pId;
                          },
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Ledger Statement View
            ledgerDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading ledger: $e'),
              data: (data) => _buildStatementContent(
                context: context,
                theme: theme,
                title: 'Subcontractor Statement',
                summary: data.summary,
                entries: data.entries,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. LABOUR / WORKER LEDGER TAB
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLabourLedger(BuildContext context, ThemeData theme) {
    final workersAsync = ref.watch(workerListProvider);
    final selectedWorkerId = ref.watch(selectedLedgerWorkerIdProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final selectedProjectId = ref.watch(ledgerProjectFilterProvider);

    return workersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading workers: $e'),
      data: (workers) {
        if (workers.isEmpty) {
          return const _EmptyLedgerCard(
            title: 'No Workers Found',
            subtitle: 'Add workers in Labour Master to view individual attendance and running wage statements.',
          );
        }

        final effectiveWorkerId = selectedWorkerId ?? workers.first.id;
        final ledgerDataAsync = ref.watch(workerLedgerProvider(effectiveWorkerId));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Worker Dropdown
                    SizedBox(
                      width: 300.w,
                      child: DropdownButtonFormField<int>(
                        value: effectiveWorkerId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Labour / Worker',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: workers
                            .map((w) => DropdownMenuItem<int>(
                                  value: w.id,
                                  child: Text(
                                    '${w.name} (${w.trade ?? 'General'}) • ₹${w.dailyRate.toInt()}/d',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (id) {
                          if (id != null) {
                            ref.read(selectedLedgerWorkerIdProvider.notifier).state = id;
                          }
                        },
                      ),
                    ),

                    // Project Filter Dropdown
                    projectsAsync.maybeWhen(
                      data: (projects) => SizedBox(
                        width: 240.w,
                        child: DropdownButtonFormField<int?>(
                          value: selectedProjectId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            prefixIcon: Icon(Icons.folder_outlined, size: 20),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Projects', overflow: TextOverflow.ellipsis),
                            ),
                            ...projects.map((p) => DropdownMenuItem<int?>(
                                  value: p.id,
                                  child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (pId) {
                            ref.read(ledgerProjectFilterProvider.notifier).state = pId;
                          },
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Ledger Statement View
            ledgerDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading worker ledger: $e'),
              data: (data) => _buildStatementContent(
                context: context,
                theme: theme,
                title: 'Labour Wage Statement',
                summary: data.summary,
                entries: data.entries,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. BANK & CASH ACCOUNTS LEDGER TAB
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildBankCashLedger(BuildContext context, ThemeData theme) {
    final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);
    final selectedBankAccountId = ref.watch(selectedLedgerBankAccountIdProvider);
    final ledgerDataAsync = ref.watch(accountLedgerProvider(selectedBankAccountId));

    return accountsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading accounts: $e'),
      data: (accounts) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Bar: Account Dropdown
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 340.w,
                      child: DropdownButtonFormField<int?>(
                        value: selectedBankAccountId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Account / Drawer',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('💵 Physical Cash Drawer / Cash in Hand', overflow: TextOverflow.ellipsis),
                          ),
                          ...accounts.map((acc) => DropdownMenuItem<int?>(
                                value: acc.account.id,
                                child: Text(
                                  '${acc.account.accountName}${acc.account.accountNumber != null ? ' (${acc.account.accountNumber})' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                        ],
                        onChanged: (id) {
                          ref.read(selectedLedgerBankAccountIdProvider.notifier).state = id;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Ledger Statement View
            ledgerDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading account ledger: $e'),
              data: (data) => _buildStatementContent(
                context: context,
                theme: theme,
                title: 'Account Statement',
                summary: data.summary,
                entries: data.entries,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. PERSONAL / OWNER LEDGER TAB
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildPersonalLedger(BuildContext context, ThemeData theme) {
    final ledgerDataAsync = ref.watch(personalLedgerProvider);

    return ledgerDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading personal ledger: $e'),
      data: (data) => _buildStatementContent(
        context: context,
        theme: theme,
        title: 'Owner Personal Equity Statement',
        summary: data.summary,
        entries: data.entries,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // REUSABLE STATEMENT CONTENT COMPONENT
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildStatementContent({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required LedgerSummary summary,
    required List<LedgerEntry> entries,
  }) {
    final isPayableNegative = summary.closingBalance > 0 && summary.isPayable;
    final isCreditBalance = summary.closingBalance >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 3 KPI Stat Cards ────────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 32.w) / 3;
            final isNarrow = constraints.maxWidth < 750;

            final card1 = StatCard(
              label: summary.creditLabel,
              value: CurrencyFormatter.format(summary.totalCredit),
              icon: Icons.trending_up_rounded,
              iconColor: const Color(0xFF059669),
              subtitle: 'Credits / Inflows / Billed',
            );

            final card2 = StatCard(
              label: summary.debitLabel,
              value: CurrencyFormatter.format(summary.totalDebit),
              icon: Icons.trending_down_rounded,
              iconColor: const Color(0xFFDC2626),
              subtitle: 'Debits / Outflows / Paid',
            );

            final card3 = StatCard(
              label: summary.balanceLabel,
              value: CurrencyFormatter.format(summary.closingBalance.abs()),
              icon: summary.closingBalance >= 0
                  ? Icons.account_balance_wallet_rounded
                  : Icons.warning_amber_rounded,
              iconColor: isPayableNegative
                  ? const Color(0xFFEA580C)
                  : (isCreditBalance ? const Color(0xFF4F46E5) : const Color(0xFFDC2626)),
              subtitle: summary.closingBalance >= 0 ? 'Balance (Credit)' : 'Overdrawn (Debit)',
            );

            if (isNarrow) {
              return Column(
                children: [
                  card1,
                  SizedBox(height: 12.h),
                  card2,
                  SizedBox(height: 12.h),
                  card3,
                ],
              );
            }

            return Row(
              children: [
                SizedBox(width: cardWidth, child: card1),
                SizedBox(width: 16.w),
                SizedBox(width: cardWidth, child: card2),
                SizedBox(width: 16.w),
                SizedBox(width: cardWidth, child: card3),
              ],
            );
          },
        ),
        SizedBox(height: 20.h),

        // ─── Statement Data Table Card ───────────────────────────────────────
        DataTableCard(
          title: '${summary.entityName} — Statement of Account',
          action: OutlinedButton.icon(
            onPressed: _exporting
                ? null
                : () => _exportActiveLedger(
                      ledgerTitle: title,
                      summary: summary,
                      entries: entries,
                    ),
            icon: _exporting
                ? SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded, size: 16),
            label: Text(_exporting ? 'Exporting...' : 'Export Excel (.xlsx)'),
          ),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Ref / Bill No')),
            DataColumn(label: Text('Particulars / Narration')),
            DataColumn(label: Text('Project')),
            DataColumn(label: Text('Debit (₹ Out)', style: TextStyle(color: Color(0xFFDC2626)))),
            DataColumn(label: Text('Credit (₹ In)', style: TextStyle(color: Color(0xFF059669)))),
            DataColumn(label: Text('Running Balance (₹)')),
          ],
          rows: entries.asMap().entries.map((item) {
            final idx = item.key + 1;
            final e = item.value;

            return DataRow(
              cells: [
                DataCell(Text(idx.toString(), style: const TextStyle(color: Color(0xFF94A3B8)))),
                DataCell(Text(DateFormatter.format(e.date))),
                DataCell(Text(e.referenceNo ?? '—', style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (e.subtitle != null)
                      Text(
                        e.subtitle!,
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                )),
                DataCell(Text(
                  e.projectCode != null ? '${e.projectCode}' : '—',
                  style: TextStyle(
                    color: e.projectCode != null ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                )),
                DataCell(Text(
                  e.debit > 0 ? CurrencyFormatter.format(e.debit) : '—',
                  style: TextStyle(
                    color: e.debit > 0 ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
                    fontWeight: e.debit > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                )),
                DataCell(Text(
                  e.credit > 0 ? CurrencyFormatter.format(e.credit) : '—',
                  style: TextStyle(
                    color: e.credit > 0 ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                    fontWeight: e.credit > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                )),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.format(e.runningBalance.abs()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: e.runningBalance >= 0 ? const Color(0xFF0F172A) : const Color(0xFFDC2626),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: e.runningBalance >= 0 ? const Color(0xFFEEF2FF) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        e.balanceType,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: e.runningBalance >= 0 ? const Color(0xFF4F46E5) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // OWNER CAPITAL / DRAWINGS QUICK ENTRY DIALOG
  // ─────────────────────────────────────────────────────────────────────────────

  void _showOwnerTransactionDialog(BuildContext context, {required bool isCapital}) {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final narrationCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    DateTime date = DateTime.now();
    PaymentMode paymentMode = isCapital ? PaymentMode.bank : PaymentMode.cash;
    int? selectedBankAccountId;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isCapital ? Icons.add_circle_outline_rounded : Icons.remove_circle_outline_rounded,
                    color: isCapital ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                  SizedBox(width: 10.w),
                  Text(isCapital ? 'Inject Owner Capital' : 'Record Owner Drawings'),
                ],
              ),
              content: SizedBox(
                width: 460.w,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCapital
                              ? 'Record personal funds injected into business accounts. This increases business cash without affecting P&L revenue.'
                              : 'Record money withdrawn from business funds for personal use. This decreases business cash without affecting P&L expenses.',
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                        ),
                        SizedBox(height: 16.h),

                        // Amount & Date Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: amountCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Amount (₹) *',
                                  prefixText: '₹ ',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Required';
                                  final n = double.tryParse(v);
                                  if (n == null || n <= 0) return 'Enter positive amount';
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: dialogCtx,
                                    initialDate: date,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setDialogState(() => date = picked);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    suffixIcon: Icon(Icons.calendar_today, size: 16),
                                  ),
                                  child: Text(DateFormatter.format(date)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // Target Bank Account / Cash Drawer
                        Consumer(
                          builder: (context, ref, _) {
                            final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);
                            return accountsAsync.maybeWhen(
                              data: (accounts) => DropdownButtonFormField<int?>(
                                value: selectedBankAccountId,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: isCapital ? 'Deposit Into Account' : 'Withdraw From Account',
                                  prefixIcon: const Icon(Icons.account_balance_rounded, size: 18),
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('💵 Physical Cash Drawer / Cash in Hand'),
                                  ),
                                  ...accounts.map((acc) => DropdownMenuItem<int?>(
                                        value: acc.account.id,
                                        child: Text(
                                            '${acc.account.accountName}${acc.account.accountNumber != null ? ' (${acc.account.accountNumber})' : ''}'),
                                      )),
                                ],
                                onChanged: (id) => setDialogState(() => selectedBankAccountId = id),
                              ),
                              orElse: () => const SizedBox.shrink(),
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // Payment Mode & Reference
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<PaymentMode>(
                                value: paymentMode,
                                isExpanded: true,
                                decoration: const InputDecoration(labelText: 'Mode'),
                                items: PaymentMode.values
                                    .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m.displayName),
                                        ))
                                    .toList(),
                                onChanged: (m) {
                                  if (m != null) setDialogState(() => paymentMode = m);
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextFormField(
                                controller: refCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Ref / Cheque No',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        TextFormField(
                          controller: narrationCtrl,
                          decoration: InputDecoration(
                            labelText: 'Narration / Reason',
                            hintText: isCapital ? 'e.g. Added working capital' : 'e.g. Household drawings',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final amt = double.parse(amountCtrl.text.trim());
                    final repo = ref.read(ledgerRepositoryProvider);

                    if (isCapital) {
                      await repo.recordOwnerCapital(
                        amount: amt,
                        date: date,
                        bankAccountId: selectedBankAccountId,
                        paymentMode: paymentMode,
                        narration: narrationCtrl.text,
                        referenceNo: refCtrl.text,
                      );
                    } else {
                      await repo.recordOwnerDrawings(
                        amount: amt,
                        date: date,
                        bankAccountId: selectedBankAccountId,
                        paymentMode: paymentMode,
                        narration: narrationCtrl.text,
                        referenceNo: refCtrl.text,
                      );
                    }

                    if (dialogCtx.mounted) {
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isCapital
                              ? '₹${amt.toStringAsFixed(0)} capital injected successfully.'
                              : '₹${amt.toStringAsFixed(0)} drawings recorded successfully.'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: isCapital ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                  child: Text(isCapital ? 'Save Capital' : 'Save Drawings'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyLedgerCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyLedgerCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(48.r),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_rounded, size: 54.sp, color: const Color(0xFF94A3B8)),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
