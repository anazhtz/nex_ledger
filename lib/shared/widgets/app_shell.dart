import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
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

  const NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.section,
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

  static const List<NavItem> _navItems = [
    // Overview & Operations
    NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      path: '/',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.folder_copy_rounded,
      label: 'Projects',
      path: '/projects',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.menu_book_rounded,
      label: 'Cash Book',
      path: '/cash-book',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.shopping_bag_rounded,
      label: 'Purchases',
      path: '/purchases',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.business_center_rounded,
      label: 'Client Billing',
      path: '/client-billing',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.handshake_rounded,
      label: 'Subcontracts',
      path: '/subcontracts',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.pie_chart_outline_rounded,
      label: 'Project Budgets',
      path: '/budgets',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.precision_manufacturing_rounded,
      label: 'Machinery & Equipment',
      path: '/equipment',
      section: 'OVERVIEW',
    ),
    NavItem(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Petty Cash & Floats',
      path: '/petty-cash',
      section: 'OVERVIEW',
    ),

    // Labour Management
    NavItem(
      icon: Icons.assignment_turned_in_rounded,
      label: 'Attendance',
      path: '/labour/attendance',
      section: 'LABOUR',
    ),
    NavItem(
      icon: Icons.payments_rounded,
      label: 'Labour Pay',
      path: '/labour/payments',
      section: 'LABOUR',
    ),
    NavItem(
      icon: Icons.people_alt_rounded,
      label: 'Workers Master',
      path: '/labour/workers',
      section: 'LABOUR',
    ),

    // Financials & Settings
    NavItem(
      icon: Icons.account_balance_outlined,
      label: 'Bank & Accounts',
      path: '/bank-accounts',
      section: 'FINANCIALS',
    ),
    NavItem(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Deposits',
      path: '/deposits',
      section: 'FINANCIALS',
    ),
    NavItem(
      icon: Icons.menu_book_rounded,
      label: 'All Ledgers',
      path: '/ledgers',
      section: 'FINANCIALS',
    ),
    NavItem(
      icon: Icons.assessment_rounded,
      label: 'Reports & P&L',
      path: '/reports/project-pnl',
      section: 'FINANCIALS',
    ),
    NavItem(
      icon: Icons.today_rounded,
      label: 'Daily Day-Book',
      path: '/reports/day-book',
      section: 'FINANCIALS',
    ),
    NavItem(
      icon: Icons.settings_rounded,
      label: 'Settings & Backup',
      path: '/settings',
      section: 'FINANCIALS',
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = _navItems.length - 1; i >= 0; i--) {
      if (location.startsWith(_navItems[i].path)) return i;
    }
    return 0;
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
        const SingleActivator(LogicalKeyboardKey.keyN, alt: true): () => context.go('/cash-book/new'),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () => context.go('/cash-book/new'),
        const SingleActivator(LogicalKeyboardKey.keyP, alt: true): () => context.go('/purchases/new'),
        const SingleActivator(LogicalKeyboardKey.keyA, alt: true): () => context.go('/labour/attendance'),
        const SingleActivator(LogicalKeyboardKey.keyW, alt: true): () => context.go('/labour/payments'),
        const SingleActivator(LogicalKeyboardKey.keyJ, alt: true): () => context.go('/projects/new'),

        // Gateway Navigation
        const SingleActivator(LogicalKeyboardKey.keyD, alt: true): () => context.go('/'),
        const SingleActivator(LogicalKeyboardKey.keyC, alt: true): () => context.go('/cash-book'),
        const SingleActivator(LogicalKeyboardKey.keyB, alt: true): () => context.go('/bank-accounts'),
        const SingleActivator(LogicalKeyboardKey.keyR, alt: true): () => context.go('/reports/project-pnl'),
        const SingleActivator(LogicalKeyboardKey.keyY, alt: true): () => context.go('/reports/day-book'),
        const SingleActivator(LogicalKeyboardKey.keyS, alt: true): () => context.go('/settings'),

        // Security & Help
        const SingleActivator(LogicalKeyboardKey.keyL, control: true): lockApp,
        const SingleActivator(LogicalKeyboardKey.keyL, meta: true): lockApp,
        const SingleActivator(LogicalKeyboardKey.f1): () => KeyboardShortcutsDialog.show(context),
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
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    right: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // App Logo & Header
                    _buildHeader(theme, effectiveCollapsed),

                    const Divider(height: 1),

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

                    const Divider(height: 1),

                    // Sidebar Footer (Collapse Toggle & Status)
                    _buildFooter(theme, effectiveCollapsed),
                  ],
                ),
              ),

              // Main Page Content Area with Global Active Project Top Bar
              Expanded(
                child: Container(
                  color: theme.colorScheme.surfaceContainerLowest,
                  child: Column(
                    children: [
                      // Top Global Active Project Context Bar
                      _buildTopProjectHeader(theme),

                      // Active Screen Child
                      Expanded(child: widget.child),
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
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.domain_rounded,
                          size: 18.sp,
                          color: const Color(0xFF4F46E5),
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
                          child: const CircularProgressIndicator(strokeWidth: 2),
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
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: const Color(0xFFC7D2FE),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                value: validSelectedId,
                                isDense: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF4F46E5),
                                  size: 20,
                                ),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4F46E5),
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
                                            color: const Color(0xFF4F46E5)),
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
                                              color: const Color(0xFF4F46E5)
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              p.code,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          ConstrainedBox(
                                            constraints: BoxConstraints(maxWidth: 160.w),
                                            child: Text(p.name, overflow: TextOverflow.ellipsis),
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
                          message: 'Click to manage Bank & Cash Accounts (Alt+B)',
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 36.r,
              height: 36.r,
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
                    'NexLedger',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Mini ERP Desktop',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
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

  List<Widget> _buildNavGroups(
    BuildContext context,
    int selectedIdx,
    ThemeData theme,
    bool isCollapsed,
  ) {
    final List<Widget> widgets = [];
    String? currentSection;

    for (int i = 0; i < _navItems.length; i++) {
      final item = _navItems[i];
      final isSelected = i == selectedIdx;

      // Add section header when section changes
      if (item.section != currentSection) {
        currentSection = item.section;
        if (!isCollapsed) {
          widgets.add(
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 6.h),
              child: Text(
                currentSection,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ),
            ),
          );
        } else {
          widgets.add(SizedBox(height: 8.h));
        }
      }

      // Add Nav Tile
      widgets.add(
        _buildNavTile(
          context: context,
          item: item,
          isSelected: isSelected,
          theme: theme,
          isCollapsed: isCollapsed,
        ),
      );
    }

    return widgets;
  }

  Widget _buildNavTile({
    required BuildContext context,
    required NavItem item,
    required bool isSelected,
    required ThemeData theme,
    required bool isCollapsed,
  }) {
    final activeBg = theme.colorScheme.primaryContainer.withOpacity(0.6);
    final activeFg = theme.colorScheme.primary;
    final inactiveFg = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Tooltip(
        message: isCollapsed ? item.label : '',
        waitDuration: const Duration(milliseconds: 300),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          child: InkWell(
            onTap: () => context.go(item.path),
            borderRadius: BorderRadius.circular(10.r),
            hoverColor: theme.colorScheme.primary.withOpacity(0.06),
            splashColor: theme.colorScheme.primary.withOpacity(0.12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 12.w : 14.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
                border: isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    size: 20.sp,
                    color: isSelected ? activeFg : inactiveFg,
                  ),
                  if (!isCollapsed) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? activeFg
                              : theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeFg,
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
            icon: Icon(
              isCollapsed
                  ? Icons.chevron_right_rounded
                  : Icons.chevron_left_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22.sp,
            ),
            tooltip: isCollapsed ? 'Expand Menu' : 'Collapse Menu',
          ),
          if (!isCollapsed) ...[
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Offline Mode',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SQLite Local Engine',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
