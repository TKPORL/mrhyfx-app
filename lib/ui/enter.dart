import 'dart:async';
import 'package:flutter/material.dart';

/// 入场动效：卡片错位淡入 + 轻微上浮（只对前 12 项生效，长列表不拖慢）
class EnterFade extends StatefulWidget {
  final Widget child;
  final int index;
  const EnterFade({super.key, required this.child, required this.index});

  @override
  State<EnterFade> createState() => _EnterFadeState();
}

class _EnterFadeState extends State<EnterFade> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  static const _maxStagger = 12;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.index >= _maxStagger) {
      _c.value = 1;
      return;
    }
    // 第 0 项立刻出现，之后每项错峰 26ms，最多 12 项
    _timer = Timer(Duration(milliseconds: 26 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    final offset = Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: offset, child: widget.child),
    );
  }
}
