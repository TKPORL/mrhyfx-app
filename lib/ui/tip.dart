import 'package:flutter/material.dart';
import 'theme.dart';

/// 轻量浮层提示：默认在屏幕上方 1/3，2 秒自动消失，不挡底部栏
class Tip {
  static OverlayEntry? _entry;

  static void show(BuildContext context, String msg) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (_) => _TipBody(msg: msg),
    );
    overlay.insert(_entry!);
    Future.delayed(const Duration(milliseconds: 1800), () {
      _entry?.remove();
      _entry = null;
    });
  }
}

class _TipBody extends StatefulWidget {
  final String msg;
  const _TipBody({required this.msg});
  @override
  State<_TipBody> createState() => _TipBodyState();
}

class _TipBodyState extends State<_TipBody> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 180))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: size.height * 0.18,
      left: 28,
      right: 28,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _c,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0xF21C1C1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: T.line, width: 0.5),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8))],
                ),
                child: Text(widget.msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: T.tx, height: 1.4)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
