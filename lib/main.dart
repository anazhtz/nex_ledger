import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/app.dart';
import 'package:nex_ledger/core/services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RemoteConfigService.instance.initialize();

  runApp(
    const ProviderScope(
      child: NexLedgerApp(),
    ),
  );
}
