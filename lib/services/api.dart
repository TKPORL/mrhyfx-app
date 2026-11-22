import 'dart:convert';
import 'package:http/http.dart' as http;

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
