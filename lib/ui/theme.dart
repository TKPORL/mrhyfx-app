import 'package:flutter/material.dart';

/// 颜色集中在这里，深浅色切换时整站跟着换
class T {
  static bool light = false;

  static Color get bg => light ? const Color(0xFFF5F5F7) : const Color(0xFF0B0B0C);
  static Color get card => light ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1E);
  static Color get card2 => light ? const Color(0xFFEFEFF2) : const Color(0xFF2C2C2E);
  static Color get tx => light ? const Color(0xFF111114) : const Color(0xFFF5F5F7);
  static Color get tx2 => light ? const Color(0x9E111114) : const Color(0x99EBEBF5);
  static Color get tx3 => light ? const Color(0x61111114) : const Color(0x57EBEBF5);
  static Color get line => light ? const Color(0x14000000) : const Color(0x14FFFFFF);
  static const ac = Color(0xFFFF9F0A);

  /// 底部栏/浮层这类半透明表面
  static Color get sheet => light ? const Color(0xF7FFFFFF) : const Color(0xF2161618);
  static Color get glass => light ? const Color(0xF2FFFFFF) : const Color(0xF21C1C1E);
}
