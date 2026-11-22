import 'package:flutter/material.dart';
import 'ui/home_shell.dart';
import 'services/dim.dart';

void main() => runApp(const TsinhoApp());

class TsinhoApp extends StatelessWidget {
  const TsinhoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0B0C);
    final base = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      title: 'Tsinho 游戏库',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: base.colorScheme.copyWith(
          primary: const Color(0xFFFF9F0A),
          surface: const Color(0xFF1C1C1E),
        ),
        textTheme: base.textTheme.apply(
          bodyColor: const Color(0xFFF5F5F7),
          displayColor: const Color(0xFFF5F5F7),
        ),
      ),
      builder: (ctx, child) => ValueListenableBuilder<double>(
        valueListenable: Dim.value,
        builder: (c, v, w) => Stack(
          children: [
            if (w != null) w,
            if (v > 0.001)
              Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Colors.black.withOpacity(v)))),
          ],
        ),
        child: child,
      ),
      home: const HomeShell(),
    );
  }
}
