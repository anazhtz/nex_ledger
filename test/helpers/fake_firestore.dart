import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A tiny in-memory stand-in for the Firestore REST interface.
class FakeFirestore {
  /// docPath -> decoded fields (plain Dart values)
  final Map<String, Map<String, dynamic>> docs = {};
  bool offline = false;
  int? forceStatus;
  int patches = 0;

  MockClient get client => MockClient((req) async {
        if (offline) throw const SocketException('no internet');
        if (forceStatus != null) return http.Response('{}', forceStatus!);
        final path = Uri.decodeFull(req.url.path)
            .split('/documents/')
            .last; // licenses/KEY
        if (req.method == 'GET') {
          final d = docs[path];
          if (d == null) return http.Response('{"error":{}}', 404);
          return http.Response(jsonEncode({'fields': _encode(d)}), 200);
        }
        if (req.method == 'PATCH') {
          patches++;
          final doc = docs[path];
          if (doc == null) return http.Response('{}', 404);
          final body = jsonDecode(req.body) as Map<String, dynamic>;
          final sent = _decode(body['fields'] as Map<String, dynamic>);
          final masks = req.url.queryParametersAll['updateMask.fieldPaths']!;
          for (final m in masks) {
            final parts = m.split('.'); // devices.<id>.<field>
            final devices = (doc['devices'] ??= <String, dynamic>{}) as Map;
            final dev = (devices[parts[1]] ??= <String, dynamic>{}) as Map;
            dev[parts[2]] = (sent['devices'] as Map)[parts[1]][parts[2]];
          }
          return http.Response('{}', 200);
        }
        return http.Response('{}', 405);
      });

  static Map<String, dynamic> _encode(Map<String, dynamic> m) =>
      {for (final e in m.entries) e.key: _enc(e.value)};
  static Map<String, dynamic> _enc(dynamic v) {
    if (v is String) return {'stringValue': v};
    if (v is bool) return {'booleanValue': v};
    if (v is int) return {'integerValue': '$v'};
    if (v is Map) {
      return {
        'mapValue': {'fields': _encode(Map<String, dynamic>.from(v))}
      };
    }
    throw ArgumentError('$v');
  }

  static Map<String, dynamic> _decode(Map<String, dynamic> f) =>
      {for (final e in f.entries) e.key: _dec(e.value as Map<String, dynamic>)};
  static dynamic _dec(Map<String, dynamic> v) {
    if (v.containsKey('stringValue')) return v['stringValue'];
    if (v.containsKey('mapValue')) {
      return _decode(
          ((v['mapValue'] as Map)['fields'] as Map).cast<String, dynamic>());
    }
    return null;
  }
}
