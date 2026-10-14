import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/services/license_service.dart';

import 'helpers/fake_firestore.dart';

void main() {
  late Directory dir;
  late FakeFirestore fs;
  var clock = DateTime.utc(2026, 10, 14, 9);

  LicenseService service({
    Directory? directory,
    String name = 'OFFICE-PC',
    String version = '1.0.9',
  }) =>
      LicenseService(
        client: fs.client,
        projectId: 'test',
        apiKey: 'k',
        directory: directory ?? dir,
        now: () => clock,
        deviceNameOverride: name,
        osOverride: 'windows',
        appVersion: version,
      );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('license_test');
    fs = FakeFirestore();
    clock = DateTime.utc(2026, 10, 14, 9);
    fs.docs['licenses/NEX-AAAA'] = {
      'companyName': 'Builder One',
      'status': 'active',
      'maxDevices': 1,
    };
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('no saved key: asks for a key', () async {
    expect((await service().verify()).gate, LicenseGate.needsKey);
  });

  test('wrong key is refused and not saved', () async {
    final r = await service().activate('nex-zzzz');
    expect(r.gate, LicenseGate.invalidKey);
    expect((await service().verify()).gate, LicenseGate.needsKey);
  });

  test('good key: active, key saved, this computer registered', () async {
    final r = await service().activate(' nex-aaaa ');
    expect(r.gate, LicenseGate.active);
    expect(r.companyName, 'Builder One');
    final devices = fs.docs['licenses/NEX-AAAA']!['devices'] as Map;
    expect(devices.length, 1);
    final d = devices.values.single as Map;
    expect(d['name'], 'OFFICE-PC');
    expect(d['os'], 'windows');
    expect(d['appVersion'], '1.0.9');
    expect(d['firstSeen'], isNotEmpty);
    // next start uses the saved key
    expect((await service().verify()).gate, LicenseGate.active);
  });

  test('"last used" is refreshed only about once an hour', () async {
    await service().activate('NEX-AAAA');
    final after1 = fs.patches;
    clock = clock.add(const Duration(minutes: 10));
    await service().verify();
    expect(fs.patches, after1, reason: 'too soon, no extra write');
    clock = clock.add(const Duration(hours: 2));
    await service().verify();
    expect(fs.patches, after1 + 1);
    final d =
        (fs.docs['licenses/NEX-AAAA']!['devices'] as Map).values.single as Map;
    expect(d['lastSeen'], clock.toIso8601String());
  });

  test('a new app version is recorded straight away', () async {
    await service(version: '1.0.9').activate('NEX-AAAA');
    await service(version: '1.1.0').verify();
    final d =
        (fs.docs['licenses/NEX-AAAA']!['devices'] as Map).values.single as Map;
    expect(d['appVersion'], '1.1.0');
  });

  test('blocked company is locked out with its message', () async {
    await service().activate('NEX-AAAA');
    fs.docs['licenses/NEX-AAAA']!['status'] = 'blocked';
    fs.docs['licenses/NEX-AAAA']!['blockedMessage'] = 'Pay your dues.';
    final r = await service().verify();
    expect(r.gate, LicenseGate.blocked);
    expect(r.message, 'Pay your dues.');
    fs.docs['licenses/NEX-AAAA']!['status'] = 'active';
    expect((await service().verify()).gate, LicenseGate.active);
  });

  test('blocked with no message shows a default one', () async {
    await service().activate('NEX-AAAA');
    fs.docs['licenses/NEX-AAAA']!['status'] = 'blocked';
    final r = await service().verify();
    expect(r.gate, LicenseGate.blocked);
    expect(r.message, contains('suspended'));
  });

  test('maintenance for one company, and for everyone', () async {
    await service().activate('NEX-AAAA');
    fs.docs['licenses/NEX-AAAA']!['maintenance'] = true;
    fs.docs['licenses/NEX-AAAA']!['maintenanceMessage'] = 'Back at 6 pm';
    var r = await service().verify();
    expect(r.gate, LicenseGate.maintenance);
    expect(r.message, 'Back at 6 pm');

    fs.docs['licenses/NEX-AAAA']!['maintenance'] = false;
    fs.docs['config/global'] = {
      'maintenance': true,
      'maintenanceMessage': 'Server upgrade'
    };
    r = await service().verify();
    expect(r.gate, LicenseGate.maintenance);
    expect(r.message, 'Server upgrade');

    fs.docs['config/global'] = {'maintenance': false};
    expect((await service().verify()).gate, LicenseGate.active);
  });

  test('second computer is locked when only one is allowed', () async {
    await service().activate('NEX-AAAA'); // office PC, first
    clock = clock.add(const Duration(days: 1));
    final other = Directory.systemTemp.createTempSync('license_test2');
    addTearDown(() => other.deleteSync(recursive: true));
    final r = await service(directory: other, name: 'FRIEND-LAPTOP')
        .activate('NEX-AAAA');
    expect(r.gate, LicenseGate.deviceLimit);
    expect((fs.docs['licenses/NEX-AAAA']!['devices'] as Map).length, 2,
        reason: 'the attempt is recorded so the owner can see it');
    // the first computer is still fine
    expect((await service().verify()).gate, LicenseGate.active);
  });

  test('two computers allowed: both work, a third is locked', () async {
    fs.docs['licenses/NEX-AAAA']!['maxDevices'] = 2;
    final dirs = [dir];
    Future<LicenseResult> join(String name) async {
      final d = Directory.systemTemp.createTempSync('license_multi');
      addTearDown(() => d.deleteSync(recursive: true));
      dirs.add(d);
      clock = clock.add(const Duration(hours: 1));
      return service(directory: d, name: name).activate('NEX-AAAA');
    }

    expect((await join('PC-1')).gate, LicenseGate.active);
    expect((await join('PC-2')).gate, LicenseGate.active);
    expect((await join('PC-3')).gate, LicenseGate.deviceLimit);
  });

  test('freeing a computer lets a newer one take its place', () async {
    await service().activate('NEX-AAAA');
    clock = clock.add(const Duration(days: 1));
    final other = Directory.systemTemp.createTempSync('license_swap');
    addTearDown(() => other.deleteSync(recursive: true));
    expect(
        (await service(directory: other, name: 'NEW-PC').activate('NEX-AAAA'))
            .gate,
        LicenseGate.deviceLimit);
    // owner removes the old computer in the admin page
    final devices = fs.docs['licenses/NEX-AAAA']!['devices'] as Map;
    devices.removeWhere((k, v) => (v as Map)['name'] == 'OFFICE-PC');
    expect((await service(directory: other, name: 'NEW-PC').verify()).gate,
        LicenseGate.active);
  });

  group('offline', () {
    test('no internet: locked (strict, no grace)', () async {
      await service().activate('NEX-AAAA');
      fs.offline = true;
      final r = await service().verify();
      expect(r.gate, LicenseGate.offline);
      expect(r.message, contains('internet'));
    });

    test('a server error is treated the same as offline', () async {
      await service().activate('NEX-AAAA');
      fs.forceStatus = 500;
      expect((await service().verify()).gate, LicenseGate.offline);
    });

    test('offline grace: allowed after a good check, then expires', () async {
      fs.docs['config/global'] = {'offlineGraceHours': 24};
      await service().activate('NEX-AAAA');
      fs.offline = true;
      clock = clock.add(const Duration(hours: 5));
      var r = await service().verify();
      expect(r.gate, LicenseGate.active);
      expect(r.viaOfflineGrace, isTrue);
      clock = clock.add(const Duration(hours: 25));
      r = await service().verify();
      expect(r.gate, LicenseGate.offline);
    });

    test('grace is never given after a blocked answer', () async {
      fs.docs['config/global'] = {'offlineGraceHours': 24};
      await service().activate('NEX-AAAA');
      fs.docs['licenses/NEX-AAAA']!['status'] = 'blocked';
      expect((await service().verify()).gate, LicenseGate.blocked);
      fs.offline = true;
      expect((await service().verify()).gate, LicenseGate.offline);
    });

    test('activating while offline fails and saves nothing', () async {
      fs.offline = true;
      expect((await service().activate('NEX-AAAA')).gate, LicenseGate.offline);
      fs.offline = false;
      expect((await service().verify()).gate, LicenseGate.needsKey);
    });
  });

  test('computer id stays the same between starts', () async {
    final a = await service().activate('NEX-AAAA');
    final b = await service().verify();
    expect(b.deviceId, a.deviceId);
    expect(a.deviceId, startsWith('d'));
  });

  test('key deleted by the owner: asks for a key again', () async {
    await service().activate('NEX-AAAA');
    fs.docs.remove('licenses/NEX-AAAA');
    final r = await service().verify();
    expect(r.gate, LicenseGate.invalidKey);
    expect((await service().verify()).gate, LicenseGate.needsKey);
  });
}
