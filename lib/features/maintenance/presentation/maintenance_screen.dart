import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/maintenance/providers/maintenance_provider.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maintenanceProvider);
    final notifier = ref.read(maintenanceProvider.notifier);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E1B4B), // Indigo 950
              Color(0xFF090D16), // Deep Dark
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glowing background graphics
            Positioned(
              top: -100.h,
              right: -100.w,
              child: Container(
                width: 450.w,
                height: 450.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      blurRadius: 120.r,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -120.h,
              left: -120.w,
              child: Container(
                width: 500.w,
                height: 500.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                      blurRadius: 140.r,
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Container
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 580.w),
                  padding: EdgeInsets.all(40.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lock & Maintenance Icon Badge
                      Container(
                        width: 90.w,
                        height: 90.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_clock_rounded,
                          size: 44.sp,
                          color: const Color(0xFFFB7185),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // Status Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBE123C).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFB7185),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'ACCESS SUSPENDED / MAINTENANCE MODE',
                              style: TextStyle(
                                color: const Color(0xFFFECDD3),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Dynamic Remote Title
                      Text(
                        state.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Dynamic Remote Message
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Information Banner Box
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF334155),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: const Color(0xFF38BDF8),
                              size: 22.sp,
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                'If you believe this is an error or have settled your account, click below to check live server status.',
                                style: TextStyle(
                                  color: const Color(0xFFCBD5E1),
                                  fontSize: 12.sp,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Primary Action: Refresh Remote Config
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: FilledButton.icon(
                          onPressed: state.isChecking
                              ? null
                              : () async {
                                  await notifier.checkStatus();
                                  if (context.mounted && !ref.read(maintenanceProvider).isUnderMaintenance) {
                                    context.go('/');
                                  }
                                },
                          icon: state.isChecking
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.refresh_rounded, size: 20.sp),
                          label: Text(
                            state.isChecking
                                ? 'Checking Remote Status...'
                                : 'Check Status Again',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryIndigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),

                      // Local Debug Toggle (only visible during debug mode for easy local verification)
                      if (kDebugMode) ...[
                        SizedBox(height: 20.h),
                        TextButton.icon(
                          onPressed: () {
                            notifier.toggleLocalOverride(false);
                            if (context.mounted) {
                              context.go('/');
                            }
                          },
                          icon: const Icon(Icons.developer_mode, color: Color(0xFF64748B)),
                          label: const Text(
                            '[Debug Mode] Deactivate Maintenance Mode',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
