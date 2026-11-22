import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 磁盘缓存：命中且未过期就直接用，避免每次启动重下 3.8MB
class Cache {
  static Future<File> _file(String key) async {
    final dir = await getApplicationSupportDirectory();
    final f = File('${dir.path}/$key.json');
    if (!await f.parent.exists()) await f.parent.create(recursive: true);
    return f;
  }

  static Future<dynamic> read(String key, {Duration ttl = const Duration(hours: 6)}) async {
    try {
      final f = await _file(key);
      if (!await f.exists()) return null;
      final st = await f.stat();
      if (DateTime.now().difference(st.modified) > ttl) return null;
      return jsonDecode(await f.readAsString());
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String key, dynamic data) async {
    try {
      final f = await _file(key);
      await f.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      final dir = await getApplicationSupportDirectory();
      for (final e in await dir.list()) {
        if (e is File && e.path.endsWith('.json')) await e.delete();
      }
    } catch (_) {}
  }
}
