import 'dart:async';
import 'package:flutter/material.dart';
import '../services/tab_tick.dart';

/// 卡片入场：iOS 那种带一点回弹的缩放入场，切换页签会重播
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
    duration: const Duration(milliseconds: 380),
  );
  static const _maxStagger = 12;
  Timer? _timer;
  int _lastTick = 0;

  @override
  void initState() {
    super.initState();
    _lastTick = TabTick.value.value;
    TabTick.value.addListener(_onTick);
    _play();
  }

  void _onTick() {
    if (_lastTick == TabTick.value.value) return;
    _lastTick = TabTick.value.value;
    if (!mounted) return;
    _c.value = 0;
    _play();
  }

  void _play() {
    if (widget.index >= _maxStagger) {
      _c.value = 1;
      return;
    }
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 22 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    TabTick.value.removeListener(_onTick);
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 缩放带回弹，透明度用平滑曲线（避免 opacity 超过 1）
    final scale = Tween<double>(begin: 0.90, end: 1)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));
    final opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return ScaleTransition(
      scale: scale,
      child: FadeTransition(opacity: opacity, child: widget.child),
    );
  }
}
