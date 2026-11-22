import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 外观模式：system / light / dark
class ThemeCtrl {
  static final ValueNotifier<ThemeMode> mode = ValueNotifier<ThemeMode>(ThemeMode.dark);
  static const _key = 'theme_mode';

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_key) ?? 'dark';
    mode.value = v == 'light'
        ? ThemeMode.light
        : v == 'system'
            ? ThemeMode.system
            : ThemeMode.dark;
  }

  static Future<void> set(ThemeMode m) async {
    mode.value = m;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key,
        m == ThemeMode.light ? 'light' : m == ThemeMode.system ? 'system' : 'dark');
  }
}
