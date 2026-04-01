import 'package:flutter/material.dart';

import 'reactive_state.dart';

/// Theme manager — switch light/dark/custom themes reactively.
///
/// Setup:
/// ```dart
/// MaterialApp(
///   theme: DoTheme.light,
///   darkTheme: DoTheme.dark,
///   themeMode: DoTheme.mode.value,   // reactive
/// )
/// ```
///
/// Or wrap MaterialApp with [DoThemeBuilder] to auto-rebuild on theme change:
/// ```dart
/// DoThemeBuilder(builder: (themeMode) => MaterialApp(themeMode: themeMode))
/// ```
///
/// Toggle:
/// ```dart
/// Do.toggleTheme();          // light ↔ dark
/// Do.setTheme(ThemeMode.dark);
/// ```
class DoTheme {
  DoTheme._();

  /// Reactive theme mode — listen to this for rebuilds.
  static final mode = DoState<ThemeMode>(ThemeMode.system);

  /// Default light theme. Override by setting [DoTheme.light] before runApp.
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  );

  /// Default dark theme. Override by setting [DoTheme.dark] before runApp.
  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  /// Toggle between [ThemeMode.light] and [ThemeMode.dark].
  static void toggle() {
    mode.value =
        mode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Set a specific [ThemeMode].
  static void setMode(ThemeMode value) => mode.value = value;

  /// `true` if current mode is dark.
  static bool get isDark => mode.value == ThemeMode.dark;
}

/// Wraps [MaterialApp] and rebuilds it when [DoTheme.mode] changes.
///
/// ```dart
/// DoThemeBuilder(
///   builder: (themeMode) => MaterialApp(
///     theme: DoTheme.light,
///     darkTheme: DoTheme.dark,
///     themeMode: themeMode,
///     home: const HomePage(),
///   ),
/// )
/// ```
class DoThemeBuilder extends StatelessWidget {
  const DoThemeBuilder({super.key, required this.builder});

  final Widget Function(ThemeMode themeMode) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: DoTheme.mode,
      builder: (_, mode, __) => builder(mode),
    );
  }
}
