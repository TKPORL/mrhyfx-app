import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cache.dart';

class Api {
  static const repo = 'TKPORL/mrhyfx';
  static const appRepo = 'TKPORL/mrhyfx-app';

  static Uri _raw(String repo, String path) => Uri.parse(
      'https://raw.githubusercontent.com/$repo/main/$path?cb=${DateTime.now().millisecondsSinceEpoch}');

  static Future<Map<String, dynamic>?> json(String repo, String path) async {
    try {
      final res = await http.get(_raw(repo, path)).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final body = utf8.decode(res.bodyBytes);
      final v = jsonDecode(body);
      return v is Map<String, dynamic> ? v : null;
    } catch (_) {
      return null;
    }
  }

  /// 先读磁盘缓存（默认 6 小时），过期或缺失才走网络并回写
  static Future<dynamic> cachedRawJson(String repo, String path,
      {Duration ttl = const Duration(hours: 6), bool force = false}) async {
    final key = '${repo.replaceAll('/', '_')}__${path.replaceAll('/', '_')}';
    if (!force) {
      final hit = await Cache.read(key, ttl: ttl);
      if (hit != null) return hit;
    }
    final fresh = await rawJson(repo, path);
    if (fresh != null) await Cache.write(key, fresh);
    if (fresh != null) return fresh;
    // 网络失败：退回任意年龄的旧缓存，总比空列表好
    return Cache.read(key, ttl: const Duration(days: 3650));
  }

  static Future<dynamic> rawJson(String repo, String path) async {
    try {
      final res = await http.get(_raw(repo, path)).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      return null;
    }
  }
}
