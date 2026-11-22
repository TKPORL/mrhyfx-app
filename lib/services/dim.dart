import 'package:flutter/foundation.dart';

/// 画面暗度：0 = 最亮，0.6 = 最暗（只作用于 App 内容，不改系统亮度）
class Dim {
  static final ValueNotifier<double> value = ValueNotifier<double>(0);
}
