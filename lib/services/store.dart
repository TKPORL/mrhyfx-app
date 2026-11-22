import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static SharedPreferences? _p;
  static Future<SharedPreferences> get _prefs async =>
      _p ??= await SharedPreferences.getInstance();

  static Future<Set<int>> favs() async {
    final p = await _prefs;
    final raw = p.getString('favs');
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as List).map((e) => (e as num).toInt()).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveFavs(Set<int> v) async {
    final p = await _prefs;
    await p.setString('favs', jsonEncode(v.toList()));
  }

  static Future<List<int>> recent() async {
    final p = await _prefs;
    final raw = p.getString('recent');
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> pushRecent(int id) async {
    final list = await recent();
    list.remove(id);
    list.insert(0, id);
    final p = await _prefs;
    await p.setString('recent', jsonEncode(list.take(20).toList()));
  }

  static Future<void> setRecent(List<int> v) async {
    final p = await _prefs;
    await p.setString('recent', jsonEncode(v));
  }

  static Future<String?> avatarPath() async => (await _prefs).getString('avatar');
  static Future<void> setAvatarPath(String v) async => (await _prefs).setString('avatar', v);

  static Future<String> name() async => (await _prefs).getString('name') ?? 'Tsinho';
  static Future<void> setName(String v) async => (await _prefs).setString('name', v);
}
