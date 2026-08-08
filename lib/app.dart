import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/auth/presentation/login_screen.dart';
import 'package:nex_ledger/features/auth/providers/auth_provider.dart';
import 'package:nex_ledger/features/dashboard/presentation/dashboard_screen.dart';
import 'package:nex_ledger/features/projects/presentation/project_list_screen.dart';
import 'package:nex_ledger/features/projects/presentation/project_form_screen.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_list_screen.dart';
import 'package:nex_ledger/features/cash_book/presentation/cash_book_entry_form.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_list_screen.dart';
import 'package:nex_ledger/features/purchase/presentation/purchase_form_screen.dart';
import 'package:nex_ledger/features/labour/presentation/attendance_screen.dart';
import 'package:nex_ledger/features/labour/presentation/labour_payment_screen.dart';
import 'package:nex_ledger/features/labour/presentation/workers_list_screen.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_list_screen.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_entry_form.dart';
import 'package:nex_ledger/features/reports/presentation/project_pnl_screen.dart';
import 'package:nex_ledger/features/reports/presentation/deposit_ledger_screen.dart';
import 'package:nex_ledger/features/reports/presentation/consolidated_pnl_screen.dart';
import 'package:nex_ledger/features/settings/presentation/settings_screen.dart';
import 'package:nex_ledger/features/maintenance/presentation/maintenance_screen.dart';
import 'package:nex_ledger/features/maintenance/providers/maintenance_provider.dart';
import 'package:nex_ledger/shared/widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final maintenanceState = ref.watch(maintenanceProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isMaintenanceRoute = state.matchedLocation == '/maintenance';

      if (maintenanceState.isUnderMaintenance) {
        if (!isMaintenanceRoute) {
          return '/maintenance';
        }
        return null;
      }

      if (isMaintenanceRoute) {
        return '/';
      }

      final isLoggingIn = state.matchedLocation == '/login';
      if (!authState.isUnlocked && !isLoggingIn) {
        return '/login';
      }
      if (authState.isUnlocked && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/maintenance',
        builder: (c, s) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (c, s) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
          GoRoute(
            path: '/projects',
            builder: (c, s) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (c, s) => const ProjectFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (c, s) => ProjectFormScreen(
                  projectId: int.parse(s.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/cash-book',
            builder: (c, s) => const CashBookListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (c, s) => const CashBookEntryForm(),
              ),
            ],
          ),
          GoRoute(
            path: '/purchases',
            builder: (c, s) => const PurchaseListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (c, s) => const PurchaseFormScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/labour/attendance',
            builder: (c, s) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/labour/payments',
            builder: (c, s) => const LabourPaymentScreen(),
          ),
          GoRoute(
            path: '/labour/workers',
            builder: (c, s) => const WorkersListScreen(),
          ),
          GoRoute(
            path: '/deposits',
            builder: (c, s) => const DepositListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (c, s) => const DepositEntryForm(),
              ),
            ],
          ),
          GoRoute(
            path: '/reports/project-pnl',
            builder: (c, s) => const ProjectPnlScreen(),
          ),
          GoRoute(
            path: '/reports/deposit-ledger',
            builder: (c, s) => const DepositLedgerScreen(),
          ),
          GoRoute(
            path: '/reports/consolidated',
            builder: (c, s) => const ConsolidatedPnlScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (c, s) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class NexLedgerApp extends ConsumerWidget {
  const NexLedgerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'NexLedger',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: router,
        );
      },
    );
  }
}
