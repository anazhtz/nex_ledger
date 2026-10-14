import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/features/reports/providers/ledger_providers.dart';

/// One entry in the Reports Center.
class ReportEntry {
  final IconData icon;
  final String title;

  /// One plain sentence: what the user will learn from this report.
  final String description;
  final String route;

  /// Opens a specific tab of the Ledgers hub when set.
  final LedgerType? ledger;

  /// Extra words people may search for ("shop", "rent", "inventory"...).
  final List<String> keywords;

  const ReportEntry({
    required this.icon,
    required this.title,
    required this.description,
    required this.route,
    this.ledger,
    this.keywords = const [],
  });
}

class ReportGroup {
  final String title;
  final IconData icon;
  final Color color;
  final List<ReportEntry> entries;
  const ReportGroup({
    required this.title,
    required this.icon,
    required this.color,
    required this.entries,
  });
}

/// Every report in the app, grouped by the question a person is asking.
const List<ReportGroup> kReportGroups = [
  ReportGroup(
    title: 'Projects & Profit',
    icon: Icons.apartment_rounded,
    color: Color(0xFF1F5FBF),
    entries: [
      ReportEntry(
        icon: Icons.receipt_rounded,
        title: 'Input GST by Project',
        description:
            'GST you paid on purchases, subcontractor bills, machinery rent and expenses, added up for each project. Excel for your accountant.',
        route: '/reports/input-gst',
        keywords: [
          'gst',
          'input gst',
          'input tax credit',
          'itc',
          'tax paid',
          'cgst',
          'sgst',
          'igst',
          'project',
          'accountant'
        ],
      ),
      ReportEntry(
        icon: Icons.assessment_rounded,
        title: 'Project P&L',
        description: 'Income, costs and profit for one project.',
        route: '/reports/project-pnl',
        keywords: ['profit', 'loss', 'pnl', 'site'],
      ),
      ReportEntry(
        icon: Icons.stacked_bar_chart_rounded,
        title: 'All Projects P&L',
        description: 'Profit of every project side by side.',
        route: '/reports/consolidated',
        keywords: ['consolidated', 'company', 'total'],
      ),
      ReportEntry(
        icon: Icons.pie_chart_outline_rounded,
        title: 'Budget vs Actual',
        description: 'Planned cost against what has really been spent.',
        route: '/budgets',
        keywords: ['budget', 'variance', 'overrun'],
      ),
    ],
  ),
  ReportGroup(
    title: 'Purchases & Shops',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFFEA580C),
    entries: [
      ReportEntry(
        icon: Icons.table_chart_rounded,
        title: 'Purchase Register',
        description:
            'Every purchase bill with filters for project, shop, date and paid or pending. Export to Excel.',
        route: '/reports/purchase-register',
        keywords: [
          'purchase',
          'bills',
          'unpaid',
          'pending',
          'payable',
          'buy',
          'register',
          'excel'
        ],
      ),
      ReportEntry(
        icon: Icons.account_balance_rounded,
        title: 'GST Purchase Register',
        description:
            'GST on every purchase invoice (CGST, SGST, IGST) by invoice, rate and supplier. Excel for your accountant.',
        route: '/reports/gst-purchases',
        keywords: [
          'gst',
          'tax',
          'cgst',
          'sgst',
          'igst',
          'gstin',
          'hsn',
          'input credit',
          'itc',
          'return',
          'accountant'
        ],
      ),
      ReportEntry(
        icon: Icons.store_mall_directory_rounded,
        title: 'Shop-wise Purchases',
        description:
            'Total bought from each shop, how much is paid and how much you still owe.',
        route: '/reports/shop-wise',
        keywords: ['shop', 'vendor', 'supplier', 'owe', 'balance', 'party'],
      ),
      ReportEntry(
        icon: Icons.receipt_long_rounded,
        title: 'Purchase Bills',
        description: 'Add, edit and pay purchase bills.',
        route: '/purchases',
        keywords: ['enter', 'edit', 'mark paid', 'new purchase'],
      ),
      ReportEntry(
        icon: Icons.storefront_rounded,
        title: 'Shop / Supplier Ledger',
        description:
            'What you bought from one shop and what you still owe them.',
        route: '/ledgers',
        ledger: LedgerType.supplier,
        keywords: ['vendor', 'supplier', 'shop', 'outstanding', 'owe'],
      ),
    ],
  ),
  ReportGroup(
    title: 'Stock & Materials',
    icon: Icons.inventory_2_rounded,
    color: Color(0xFF0F766E),
    entries: [
      ReportEntry(
        icon: Icons.inventory_rounded,
        title: 'Material Register',
        description:
            'Material bought and used on each project (stock statement).',
        route: '/materials',
        keywords: [
          'stock',
          'inventory',
          'material',
          'cement',
          'steel',
          'consumption'
        ],
      ),
    ],
  ),
  ReportGroup(
    title: 'Labour',
    icon: Icons.groups_rounded,
    color: Color(0xFF7C3AED),
    entries: [
      ReportEntry(
        icon: Icons.badge_rounded,
        title: 'Worker Ledger',
        description:
            'Days worked, wages earned, paid and balance for each worker.',
        route: '/ledgers',
        ledger: LedgerType.labour,
        keywords: ['worker', 'wages', 'attendance', 'overtime', 'ot', 'salary'],
      ),
    ],
  ),
  ReportGroup(
    title: 'Subcontractors',
    icon: Icons.handshake_rounded,
    color: Color(0xFFB45309),
    entries: [
      ReportEntry(
        icon: Icons.engineering_rounded,
        title: 'Contractor Ledger',
        description:
            'Work billed by a contractor, payments made and balance to pay.',
        route: '/ledgers',
        ledger: LedgerType.subcontractor,
        keywords: ['contractor', 'subcontractor', 'piece rate', 'work order'],
      ),
      ReportEntry(
        icon: Icons.assignment_rounded,
        title: 'Work Orders',
        description:
            'All subcontract work orders with measurement bills and payments.',
        route: '/subcontracts',
        keywords: ['work order', 'measurement', 'contract'],
      ),
    ],
  ),
  ReportGroup(
    title: 'Machinery & Rental',
    icon: Icons.precision_manufacturing_rounded,
    color: Color(0xFF475569),
    entries: [
      ReportEntry(
        icon: Icons.local_shipping_rounded,
        title: 'Machinery & Rental',
        description:
            'Each machine: hours or days used, rent, fuel and payments.',
        route: '/equipment',
        keywords: [
          'equipment',
          'jcb',
          'crane',
          'rent',
          'rental',
          'fuel',
          'hire'
        ],
      ),
    ],
  ),
  ReportGroup(
    title: 'Money',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF059669),
    entries: [
      ReportEntry(
        icon: Icons.today_rounded,
        title: 'Daily Day-Book',
        description: 'Everything that happened on one day, in one list.',
        route: '/reports/day-book',
        keywords: ['daybook', 'daily', 'today', 'transactions'],
      ),
      ReportEntry(
        icon: Icons.account_balance_outlined,
        title: 'Bank & Cash Book',
        description:
            'Money in and out of each bank account and the cash drawer.',
        route: '/ledgers',
        ledger: LedgerType.bankCash,
        keywords: ['bank', 'cash', 'statement', 'balance'],
      ),
      ReportEntry(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Petty Cash',
        description:
            'Cash given to supervisors, vouchers spent and cash left with them.',
        route: '/petty-cash',
        keywords: ['supervisor', 'float', 'imprest', 'voucher'],
      ),
      ReportEntry(
        icon: Icons.savings_outlined,
        title: 'Deposits',
        description:
            'Security deposits paid and received, and what is still held.',
        route: '/reports/deposit-ledger',
        keywords: ['emd', 'security deposit', 'refund'],
      ),
      ReportEntry(
        icon: Icons.person_pin_rounded,
        title: 'Investor / Owner Ledger',
        description:
            'Capital put in and withdrawn by each investor or partner.',
        route: '/ledgers',
        ledger: LedgerType.personal,
        keywords: [
          'investor',
          'partner',
          'capital',
          'drawings',
          'owner',
          'personal'
        ],
      ),
    ],
  ),
  ReportGroup(
    title: 'Clients',
    icon: Icons.business_center_rounded,
    color: Color(0xFFDB2777),
    entries: [
      ReportEntry(
        icon: Icons.request_quote_rounded,
        title: 'Client Ledger',
        description:
            'Bills raised to a client, payments received and amount to receive.',
        route: '/ledgers',
        ledger: LedgerType.client,
        keywords: [
          'client',
          'customer',
          'receivable',
          'receive',
          'outstanding'
        ],
      ),
      ReportEntry(
        icon: Icons.description_rounded,
        title: 'Client Bills (RA Bills)',
        description:
            'Progress bills certified to the client and the receipts against them.',
        route: '/client-billing',
        keywords: ['ra bill', 'invoice', 'receipt', 'retention', 'tds'],
      ),
    ],
  ),
];

/// Returns the groups with only the entries matching [query]
/// (title, description, group name or keywords). Empty query = everything.
List<ReportGroup> filterReportGroups(String query,
    {List<ReportGroup> groups = kReportGroups}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return groups;
  final result = <ReportGroup>[];
  for (final g in groups) {
    final hits = g.entries.where((e) {
      final haystack = [
        e.title,
        e.description,
        g.title,
        ...e.keywords,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
    if (hits.isNotEmpty) {
      result.add(ReportGroup(
          title: g.title, icon: g.icon, color: g.color, entries: hits));
    }
  }
  return result;
}

/// One page that lists every report, grouped by what the user wants to know.
class ReportsCenterScreen extends ConsumerStatefulWidget {
  const ReportsCenterScreen({super.key});

  @override
  ConsumerState<ReportsCenterScreen> createState() =>
      _ReportsCenterScreenState();
}

class _ReportsCenterScreenState extends ConsumerState<ReportsCenterScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _open(ReportEntry e) {
    if (e.ledger != null) {
      ref.read(activeLedgerTabProvider.notifier).state = e.ledger!;
    }
    context.go(e.route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = filterReportGroups(_query);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports Center',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              'Every report in one place. Pick what you want to know.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: 480,
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText:
                      'Find a report: shop, contractor, rent, stock, profit...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(() {
                            _searchCtrl.clear();
                            _query = '';
                          }),
                        ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(height: 20.h),
            if (groups.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Center(
                  child: Text(
                    'No report matches "$_query". Try a shorter word, like "shop" or "rent".',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            for (final g in groups) ...[
              Row(
                children: [
                  Icon(g.icon, size: 20, color: g.color),
                  const SizedBox(width: 8),
                  Text(
                    g.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final e in g.entries)
                    _ReportCard(
                      entry: e,
                      color: g.color,
                      onTap: () => _open(e),
                    ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportEntry entry;
  final Color color;
  final VoidCallback onTap;
  const _ReportCard(
      {required this.entry, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(entry.icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.description,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
