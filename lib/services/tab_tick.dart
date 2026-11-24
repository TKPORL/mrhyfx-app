import 'package:flutter/foundation.dart';

/// 每次切换底部页签就 +1，列表卡片监听它重播入场动效
class TabTick {
  static final ValueNotifier<int> value = ValueNotifier<int>(0);
  static void bump() => value.value++;
}
