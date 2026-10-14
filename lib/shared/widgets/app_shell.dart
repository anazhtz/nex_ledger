import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/auth/providers/auth_provider.dart';
import 'package:nex_ledger/features/cash_book/providers/cash_book_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/keyboard_shortcuts_dialog.dart';

/// Navigation item model with section grouping
class NavItem {
  final IconData icon;
  final String label;
  final String path;
  final String section;

  /// Other routes that belong to this item (keeps it highlighted on
  /// sub-screens, e.g. a vendor page under Purchases).
  final List<String> extraPrefixes;

  const NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.section,
    this.extraPrefixes = const [],
  });
}

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isCollapsed = false;

  /// Grouped by the job a person is doing, not by accounting term.
  /// A section with a single item is shown without a header.
  static const List<NavItem> _navItems = [
    NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      path: '/',
      section: 'HOME',
    ),

    // Sites
    NavItem(
      icon: Icons.folder_copy_rounded,
      label: 'Projects',
      path: '/projects',
      section: 'SITES',
    ),
    NavItem(
      icon: Icons.pie_chart_outline_rounded,
      label: 'Project Budgets',
      path: '/budgets',
      section: 'SITES',
    ),

    // Buying & stock
    NavItem(
      icon: Icons.shopping_bag_rounded,
      label: 'Purchases',
      path: '/purchases',
      section: 'BUY & STOCK',
      extraPrefixes: ['/vendors'],
    ),
    NavItem(
      icon: Icons.inventory_2_rounded,
      label: 'Materials & Stock',
      path: '/materials',
      section: 'BUY & STOCK',
    ),
    NavItem(
      icon: Icons.precision_manufacturing_rounded,
      label: 'Machinery & Rental',
      path: '/equipment',
      section: 'BUY & STOCK',
    ),

    // Labour & subcontract
    NavItem(
      icon: Icons.assignment_turned_in_rounded,
      label: 'Attendance',
      path: '/labour/attendance',
      section: 'LABOUR & SUBCONTRACT',
    ),
    NavItem(
      icon: Icons.payments_rounded,
      label: 'Labour Pay',
      path: '/labour/payments',
      section: 'LABOUR & SUBCONTRACT',
    ),
    NavItem(
      icon: Icons.people_alt_rounded,
      label: 'Workers',
      path: '/labour/workers',
      section: 'LABOUR & SUBCONTRACT',
    ),
    NavItem(
      icon: Icons.handshake_rounded,
      label: 'Subcontracts',
      path: '/subcontracts',
      section: 'LABOUR & SUBCONTRACT',
    ),

    // Money
    NavItem(
      icon: Icons.menu_book_rounded,
      label: 'Cash Book',
      path: '/cash-book',
      section: 'MONEY',
    ),
    NavItem(
      icon: Icons.business_center_rounded,
      label: 'Client Billing',
      path: '/client-billing',
      section: 'MONEY',
    ),
    NavItem(
      icon: Icons.account_balance_outlined,
      label: 'Bank & Accounts',
      path: '/bank-accounts',
      section: 'MONEY',
    ),
    NavItem(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Petty Cash',
      path: '/petty-cash',
      section: 'MONEY',
    ),
    NavItem(
      icon: Icons.savings_outlined,
      label: 'Deposits',
      path: '/deposits',
      section: 'MONEY',
    ),

    // One place for every report
    NavItem(
      icon: Icons.assessment_rounded,
      label: 'Reports Center',
      path: '/reports',
      section: 'REPORTS',
      extraPrefixes: ['/ledgers'],
    ),

    NavItem(
      icon: Icons.settings_rounded,
      label: 'Settings & Backup',
      path: '/settings',
      section: 'SETTINGS',
    ),
  ];

  /// Sections the user has expanded. The section holding the current page
  /// is opened automatically (see [_buildNavGroups]).
  final Set<String> _openSections = {};
  String? _lastActiveSection;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    var best = 0;
    var bestLen = -1;
    for (var i = 0; i < _navItems.length; i++) {
      final item = _navItems[i];
      for (final prefix in [item.path, ...item.extraPrefixes]) {
        final matches = prefix == '/'
            ? location == '/'
            : (location == prefix || location.startsWith('$prefix/'));
        if (matches && prefix.length > bestLen) {
          best = i;
          bestLen = prefix.length;
        }
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIdx = _selectedIndex(context);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isAutoCollapsed = screenWidth < 900;
    final effectiveCollapsed = _isCollapsed || isAutoCollapsed;
    final sidebarWidth = effectiveCollapsed ? 76.0 : 250.0;

    void lockApp() {
      ref.read(authProvider.notifier).lock();
      context.go('/login');
    }

    return CallbackShortcuts(
      bindings: {
        // Quick Entry Actions
        const SingleActivator(LogicalKeyboardKey.keyN, alt: true): () =>
            context.go('/cash-book/new'),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            context.go('/cash-book/new'),
        const SingleActivator(LogicalKeyboardKey.keyP, alt: true): () =>
            context.go('/purchases/new'),
        const SingleActivator(LogicalKeyboardKey.keyA, alt: true): () =>
            context.go('/labour/attendance'),
        const SingleActivator(LogicalKeyboardKey.keyW, alt: true): () =>
            context.go('/labour/payments'),
        const SingleActivator(LogicalKeyboardKey.keyJ, alt: true): () =>
            context.go('/projects/new'),

        // Gateway Navigation
        const SingleActivator(LogicalKeyboardKey.keyD, alt: true): () =>
            context.go('/'),
        const SingleActivator(LogicalKeyboardKey.keyC, alt: true): () =>
            context.go('/cash-book'),
        const SingleActivator(LogicalKeyboardKey.keyM, alt: true): () =>
            context.go('/materials'),
        const SingleActivator(LogicalKeyboardKey.keyB, alt: true): () =>
            context.go('/bank-accounts'),
        const SingleActivator(LogicalKeyboardKey.keyR, alt: true): () =>
            context.go('/reports/project-pnl'),
        const SingleActivator(LogicalKeyboardKey.keyY, alt: true): () =>
            context.go('/reports/day-book'),
        const SingleActivator(LogicalKeyboardKey.keyS, alt: true): () =>
            context.go('/settings'),

        // Security & Help
        const SingleActivator(LogicalKeyboardKey.keyL, control: true): lockApp,
        const SingleActivator(LogicalKeyboardKey.keyL, meta: true): lockApp,
        const SingleActivator(LogicalKeyboardKey.f1): () =>
            KeyboardShortcutsDialog.show(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              // Modern Sidebar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: sidebarWidth,
                decoration: const BoxDecoration(color: AppTheme.navy),
                child: Column(
                  children: [
                    // App Logo & Header
                    _buildHeader(theme, effectiveCollapsed),

                    Divider(
                        height: 1, color: Colors.white.withValues(alpha: 0.12)),

                    // Navigation List
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 10.w,
                        ),
                        children: _buildNavGroups(
                            context, selectedIdx, theme, effectiveCollapsed),
                      ),
                    ),

                    Divider(
                        height: 1, color: Colors.white.withValues(alpha: 0.12)),

                    // Sidebar Footer (Collapse Toggle & Status)
                    _buildFooter(theme, effectiveCollapsed),
                  ],
                ),
              ),

              // Main Page Content Area with Global Active Project Top Bar
              Expanded(
                child: Container(
                  color: AppTheme.surfaceBg,
                  child: Column(
                    children: [
                      // Top Global Active Project Context Bar
                      _buildTopProjectHeader(theme),

                      // Active Screen Child
                      Expanded(child: widget.child),

                      _buildStatusBar(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Global Top Bar with Active Project Selector & Live Cash Balance Indicator
  Widget _buildTopProjectHeader(ThemeData theme) {
    final projectsAsync = ref.watch(projectListProvider);
    final selectedId = ref.watch(selectedProjectIdProvider);
    final cashBalanceAsync = ref.watch(cashBalanceProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FB),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.domain_rounded,
                          size: 18.sp,
                          color: const Color(0xFF1F5FBF),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Active Context:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Global Active Project Selector Dropdown
                      projectsAsync.when(
                        loading: () => SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (projects) {
                          final validSelectedId =
                              projects.any((p) => p.id == selectedId)
                                  ? selectedId
                                  : null;

                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF1FB),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFBFD4EE),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                value: validSelectedId,
                                isDense: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF1F5FBF),
                                  size: 20,
                                ),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F5FBF),
                                ),
                                onChanged: (int? newId) {
                                  ref
                                      .read(selectedProjectIdProvider.notifier)
                                      .state = newId;
                                },
                                items: [
                                  DropdownMenuItem<int?>(
                                    value: null,
                                    child: Row(
                                      children: [
                                        Icon(Icons.border_all_rounded,
                                            size: 16.sp,
                                            color: const Color(0xFF1F5FBF)),
                                        SizedBox(width: 6.w),
                                        const Text(
                                            'All Projects (Company Overview)'),
                                      ],
                                    ),
                                  ),
                                  ...projects.map((p) {
                                    return DropdownMenuItem<int?>(
                                      value: p.id,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1F5FBF)
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              p.code,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1F5FBF),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          ConstrainedBox(
                                            constraints:
                                                BoxConstraints(maxWidth: 160.w),
                                            child: Text(p.name,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: 24.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Live Cash Balance Pill
                      cashBalanceAsync.when(
                        data: (bal) => Tooltip(
                          message:
                              'Click to manage Bank & Cash Accounts (Alt+B)',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8.r),
                            onTap: () => context.go('/bank-accounts'),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: bal >= 0
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                    color: bal >= 0
                                        ? const Color(0xFFA7F3D0)
                                        : const Color(0xFFFCA5A5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 15.sp,
                                    color: bal >= 0
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFDC2626),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Cash Balance: ',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(bal),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: bal >= 0
                                          ? const Color(0xFF047857)
                                          : const Color(0xFFB91C1C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      SizedBox(width: 14.w),

                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 7.w,
                              height: 7.h,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              selectedId == null ? 'All Entries' : 'Filtered',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Keyboard Shortcuts Guide Button
                      IconButton(
                        onPressed: () => KeyboardShortcutsDialog.show(context),
                        icon: Icon(
                          Icons.keyboard_rounded,
                          size: 18.sp,
                          color: const Color(0xFF64748B),
                        ),
                        tooltip: 'NexLedger Keyboard Shortcuts (F1)',
                      ),
                      SizedBox(width: 4.w),

                      // Lock App Quick Button
                      IconButton(
                        onPressed: () {
                          ref.read(authProvider.notifier).lock();
                          context.go('/login');
                        },
                        icon: Icon(
                          Icons.lock_rounded,
                          size: 18.sp,
                          color: const Color(0xFF64748B),
                        ),
                        tooltip: 'Lock Financial Ledger (PIN Security)',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isCollapsed) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 38.r,
              height: 38.r,
              fit: BoxFit.cover,
            ),
          ),
          if (!isCollapsed) ...[
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXLEDGER',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Builders ERP',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Indian financial year label, e.g. 2026-27 (April to March).
  String get _financialYear {
    final now = DateTime.now();
    final start = now.month >= 4 ? now.year : now.year - 1;
    return '$start-${((start + 1) % 100).toString().padLeft(2, '0')}';
  }

  Widget _buildStatusBar() {
    final style = TextStyle(fontSize: 11.5.sp, color: AppTheme.textMuted);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          Text('Financial Year : $_financialYear', style: style),
          SizedBox(width: 24.w),
          Text('User : Admin', style: style),
          const Spacer(),
          Container(
            width: 7.r,
            height: 7.r,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.successGreen),
          ),
          SizedBox(width: 6.w),
          Text('Offline · data stored on this computer', style: style),
        ],
      ),
    );
  }

  List<Widget> _buildNavGroups(
    BuildContext context,
    int selectedIdx,
    ThemeData theme,
    bool isCollapsed,
  ) {
    final widgets = <Widget>[];

    // Keep the section of the current page open (once per page change).
    final activeSection = _navItems[selectedIdx].section;
    if (_lastActiveSection != activeSection) {
      _lastActiveSection = activeSection;
      _openSections.add(activeSection);
    }

    final sectionSize = <String, int>{};
    for (final item in _navItems) {
      sectionSize[item.section] = (sectionSize[item.section] ?? 0) + 1;
    }

    String? currentSection;
    for (int i = 0; i < _navItems.length; i++) {
      final item = _navItems[i];
      final isSingle = sectionSize[item.section] == 1;

      if (item.section != currentSection) {
        currentSection = item.section;
        if (isCollapsed) {
          // Icon-only rail: just a gap between groups.
          widgets.add(SizedBox(height: 8.h));
        } else if (!isSingle) {
          widgets.add(_buildSectionHeader(item.section));
        } else {
          widgets.add(SizedBox(height: 6.h));
        }
      }

      final visible =
          isCollapsed || isSingle || _openSections.contains(item.section);
      if (!visible) continue;

      widgets.add(
        _buildNavTile(
          context: context,
          item: item,
          isSelected: i == selectedIdx,
          theme: theme,
          isCollapsed: isCollapsed,
        ),
      );
    }

    return widgets;
  }

  Widget _buildSectionHeader(String section) {
    final open = _openSections.contains(section);
    return InkWell(
      borderRadius: BorderRadius.circular(4.r),
      onTap: () => setState(() {
        if (open) {
          _openSections.remove(section);
        } else {
          _openSections.add(section);
        }
      }),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 6.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                section,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
            AnimatedRotation(
              turns: open ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16.sp,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required NavItem item,
    required bool isSelected,
    required ThemeData theme,
    required bool isCollapsed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Tooltip(
        message: isCollapsed ? item.label : '',
        waitDuration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.r),
          child: InkWell(
            onTap: () => context.go(item.path),
            borderRadius: BorderRadius.circular(4.r),
            hoverColor: Colors.white.withValues(alpha: 0.07),
            splashColor: Colors.white.withValues(alpha: 0.12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 14.w,
                vertical: 11.h,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.navyActive : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    size: 20.sp,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                  if (!isCollapsed) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.88),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, bool isCollapsed) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (!isCollapsed) ...[
            CircleAvatar(
              radius: 15.r,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              child:
                  Icon(Icons.person_rounded, size: 18.sp, color: Colors.white),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Single-user mode',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
          IconButton(
            onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
            icon: Icon(
              isCollapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 22.sp,
            ),
            tooltip: isCollapsed ? 'Expand Menu' : 'Collapse Menu',
          ),
        ],
      ),
    );
  }
}
