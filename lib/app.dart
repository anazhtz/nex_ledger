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
import 'package:nex_ledger/features/labour/presentation/worker_detail_screen.dart';
import 'package:nex_ledger/features/labour/presentation/workers_list_screen.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_list_screen.dart';
import 'package:nex_ledger/features/deposits/presentation/deposit_entry_form.dart';
import 'package:nex_ledger/features/purchase/presentation/vendor_detail_screen.dart';
import 'package:nex_ledger/features/reports/presentation/project_pnl_screen.dart';
import 'package:nex_ledger/features/reports/presentation/deposit_ledger_screen.dart';
import 'package:nex_ledger/features/reports/presentation/consolidated_pnl_screen.dart';
import 'package:nex_ledger/features/reports/presentation/day_book_screen.dart';
import 'package:nex_ledger/features/reports/presentation/ledgers_hub_screen.dart';
import 'package:nex_ledger/features/bank_accounts/presentation/bank_accounts_screen.dart';
import 'package:nex_ledger/features/settings/presentation/settings_screen.dart';
import 'package:nex_ledger/features/maintenance/presentation/maintenance_screen.dart';
import 'package:nex_ledger/features/maintenance/providers/maintenance_provider.dart';
import 'package:nex_ledger/features/subcontract/presentation/subcontract_hub_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/work_order_form_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/measurement_bill_form_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/subcontract_payment_form_screen.dart';
import 'package:nex_ledger/features/subcontract/presentation/work_order_detail_screen.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_billing_hub_screen.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_ra_bill_form_screen.dart';
import 'package:nex_ledger/features/client_billing/presentation/client_receipt_form_screen.dart';
import 'package:nex_ledger/features/budgets/presentation/project_budget_variance_hub_screen.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_hub_screen.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_form_screen.dart';
import 'package:nex_ledger/features/equipment/presentation/equipment_log_form_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_hub_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_voucher_form_screen.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_wallet_form_screen.dart';
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
              GoRoute(
                path: ':id/edit',
                builder: (c, s) => CashBookEntryForm(
                  transactionId: int.parse(s.pathParameters['id']!),
                ),
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
              GoRoute(
                path: ':id/edit',
                builder: (c, s) => PurchaseFormScreen(
                  purchaseId: int.parse(s.pathParameters['id']!),
                ),
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
            path: '/labour/workers/:id',
            builder: (c, s) => WorkerDetailScreen(
              workerId: int.parse(s.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/subcontracts',
            builder: (c, s) => const SubcontractHubScreen(),
            routes: [
              GoRoute(
                path: 'work-orders/new',
                builder: (c, s) => const WorkOrderFormScreen(),
              ),
              GoRoute(
                path: 'work-orders/:id',
                builder: (c, s) => WorkOrderDetailScreen(
                  workOrderId: int.parse(s.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'work-orders/:id/edit',
                builder: (c, s) => WorkOrderFormScreen(
                  workOrderId: int.parse(s.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'measurement/new',
                builder: (c, s) => MeasurementBillFormScreen(
                  initialWorkOrderId: int.tryParse(
                      s.uri.queryParameters['workOrderId'] ?? ''),
                ),
              ),
              GoRoute(
                path: 'payment/new',
                builder: (c, s) => SubcontractPaymentFormScreen(
                  initialSubcontractorId: int.tryParse(
                      s.uri.queryParameters['subcontractorId'] ?? ''),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/client-billing',
            builder: (c, s) => const ClientBillingHubScreen(),
            routes: [
              GoRoute(
                path: 'ra-bills/new',
                builder: (c, s) => ClientRaBillFormScreen(
                  initialProjectId: int.tryParse(
                      s.uri.queryParameters['projectId'] ?? ''),
                ),
              ),
              GoRoute(
                path: 'receipt/new',
                builder: (c, s) => ClientReceiptFormScreen(
                  initialProjectId: int.tryParse(
                      s.uri.queryParameters['projectId'] ?? ''),
                  initialRaBillId: int.tryParse(
                      s.uri.queryParameters['raBillId'] ?? ''),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/budgets',
            builder: (c, s) => const ProjectBudgetVarianceHubScreen(),
          ),
          GoRoute(
            path: '/equipment',
            builder: (c, s) => const EquipmentHubScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (c, s) => const EquipmentFormScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (c, s) => EquipmentFormScreen(
                  equipmentId: int.parse(s.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'logs/new',
                builder: (c, s) => EquipmentLogFormScreen(
                  initialEquipmentId: int.tryParse(
                      s.uri.queryParameters['equipmentId'] ?? ''),
                  initialProjectId: int.tryParse(
                      s.uri.queryParameters['projectId'] ?? ''),
                ),
              ),
              GoRoute(
                path: 'logs/:id/edit',
                builder: (c, s) => EquipmentLogFormScreen(
                  logId: int.parse(s.pathParameters['id']!),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/petty-cash',
            builder: (c, s) => const PettyCashHubScreen(),
            routes: [
              GoRoute(
                path: 'wallets/new',
                builder: (c, s) => const PettyCashWalletFormScreen(),
              ),
              GoRoute(
                path: 'wallets/:id/edit',
                builder: (c, s) => PettyCashWalletFormScreen(
                  walletId: int.parse(s.pathParameters['id']!),
                ),
              ),
              GoRoute(
                path: 'vouchers/new',
                builder: (c, s) => PettyCashVoucherFormScreen(
                  initialWalletId: int.tryParse(
                      s.uri.queryParameters['walletId'] ?? ''),
                  initialProjectId: int.tryParse(
                      s.uri.queryParameters['projectId'] ?? ''),
                ),
              ),
            ],
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
            path: '/vendors/:id',
            builder: (c, s) => VendorDetailScreen(
              vendorId: int.parse(s.pathParameters['id']!),
            ),
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
            path: '/reports/day-book',
            builder: (c, s) => const DayBookScreen(),
          ),
          GoRoute(
            path: '/ledgers',
            builder: (c, s) => const LedgersHubScreen(),
          ),
          GoRoute(
            path: '/bank-accounts',
            builder: (c, s) => const BankAccountsScreen(),
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
