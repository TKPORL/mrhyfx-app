import 'package:flutter/material.dart';
import 'services/dim.dart';
import 'services/theme_ctrl.dart';
import 'ui/home_shell.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeCtrl.load();
  runApp(const TsinhoApp());
}

class TsinhoApp extends StatelessWidget {
  const TsinhoApp({super.key});

  ThemeData _theme(Brightness b) {
    final isLight = b == Brightness.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: isLight ? const Color(0xFFF5F5F7) : const Color(0xFF0B0B0C),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFFFF9F0A),
        surface: isLight ? Colors.white : const Color(0xFF1C1C1E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? const Color(0xFFF5F5F7) : const Color(0xFF0B0B0C),
        foregroundColor: isLight ? const Color(0xFF111114) : const Color(0xFFF5F5F7),
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: isLight ? const Color(0xFF111114) : const Color(0xFFF5F5F7),
        displayColor: isLight ? const Color(0xFF111114) : const Color(0xFFF5F5F7),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? Colors.white : const Color(0xFF1C1C1E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeCtrl.mode,
      builder: (c, m, _) => MaterialApp(
        title: 'Tsinho 黄油站',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: m,
        builder: (ctx, child) {
          T.light = Theme.of(ctx).brightness == Brightness.light;
          return ValueListenableBuilder<double>(
            valueListenable: Dim.value,
            builder: (c2, v, w) => Stack(
              children: [
                if (w != null) w,
                if (v > 0.001)
                  Positioned.fill(
                      child: IgnorePointer(child: ColoredBox(color: Colors.black.withOpacity(v)))),
              ],
            ),
            child: child,
          );
        },
        home: const HomeShell(),
      ),
    );
  }
}
