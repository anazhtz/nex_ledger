import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/services/license_service.dart';
import 'package:nex_ledger/features/license/providers/license_provider.dart';

/// Settings card: who this copy is licensed to and on which computer.
class LicenseInfoCard extends ConsumerWidget {
  const LicenseInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(licenseProvider);
    if (s.gate != LicenseGate.active || s.key.isEmpty) {
      return const SizedBox.shrink(); // developer / test runs
    }
    String masked(String k) => k.length <= 8
        ? k
        : '${k.substring(0, 4)}••••${k.substring(k.length - 4)}';
    Widget line(String label, String value) => Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Row(children: [
            SizedBox(
              width: 150.w,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF64748B))),
            ),
            Expanded(
              child: Text(value,
                  style:
                      TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ),
          ]),
        );

    return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.verified_user_rounded,
                      color: const Color(0xFF059669), size: 22.sp),
                  SizedBox(width: 10.w),
                  Text('License',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w800)),
                ]),
                SizedBox(height: 8.h),
                line(
                    'Licensed to', s.companyName.isEmpty ? '—' : s.companyName),
                line('License key', masked(s.key)),
                line('This computer', s.deviceName),
                line('Computers in use', '${s.deviceCount} of ${s.maxDevices}'),
                if (s.viaOfflineGrace)
                  line('Status', 'Working offline for a short time'),
              ],
            ),
          ),
        ));
  }
}
