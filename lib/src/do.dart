import 'package:flutter/material.dart';

import 'reactive_state.dart';
import 'do_injector.dart';
import 'do_router.dart';
import 'do_theme.dart';
import 'do_api.dart';

export 'do_api.dart' show DoApi, DoResult, DoSuccess, DoError;
export 'do_injector.dart' show DoInjector;
export 'do_router.dart' show DoRouter;
export 'do_theme.dart' show DoTheme, DoThemeBuilder;

/// The single entry point for do_it_kit.
///
/// ─── Reactive widget ────────────────────────────────────────────────────────
/// ```dart
/// final count = DoState(0);
/// Do(count, (v) => Text('$v'))   // only this widget rebuilds
/// ```
///
/// ─── DI ─────────────────────────────────────────────────────────────────────
/// ```dart
/// Do.put(MyService());
/// Do.find<MyService>().doWork();
/// ```
///
/// ─── Named routes (no context needed) ───────────────────────────────────────
/// ```dart
/// DoRouter.define('/', () => HomePage());
/// Do.to('/detail', args: {'id': 1});
/// Do.back();
/// ```
///
/// ─── Context navigation ──────────────────────────────────────────────────────
/// ```dart
/// Do.push(context, () => DetailPage());
/// Do.pop(context);
/// ```
///
/// ─── Theme ───────────────────────────────────────────────────────────────────
/// ```dart
/// Do.toggleTheme();
/// Do.setTheme(ThemeMode.dark);
/// ```
///
/// ─── API ─────────────────────────────────────────────────────────────────────
/// ```dart
/// Do.api.baseUrl = 'https://api.example.com';
/// final result = await Do.api.get('/users');
/// ```
///
/// ─── Screen size ─────────────────────────────────────────────────────────────
/// ```dart
/// Do.width(context)
/// Do.widthPercent(context, 50)
/// ```
class Do<T> extends StatelessWidget {
  /// Wraps a widget — only this widget rebuilds when [state] changes.
  const Do(this.state, this.builder, {super.key});

  final DoState<T> state;
  final Widget Function(T value) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: state,
      builder: (_, value, __) => builder(value),
    );
  }

  // ─── Dependency Injection ─────────────────────────────────────────────────

  /// Register a dependency. Like Get.put().
  /// ```dart
  /// Do.put(ApiService());
  /// Do.put(AuthService(), tag: 'admin');
  /// ```
  static T put<T extends Object>(T instance, {String? tag}) =>
      DoInjector.put<T>(instance, tag: tag);

  /// Retrieve a registered dependency. Like Get.find().
  /// ```dart
  /// Do.find<ApiService>().fetchUsers();
  /// ```
  static T find<T extends Object>({String? tag}) =>
      DoInjector.find<T>(tag: tag);

  /// Remove a registered dependency.
  static void delete<T extends Object>({String? tag}) =>
      DoInjector.delete<T>(tag: tag);

  // ─── Named Route Navigation (no context) ─────────────────────────────────

  /// Navigate to a named route. No context needed.
  /// ```dart
  /// Do.to('/detail', args: {'id': 1});
  /// ```
  static Future<R?> to<R>(String name, {Object? args}) =>
      DoRouter.to<R>(name, args: args);

  /// Replace current route with a named route.
  static Future<R?> off<R>(String name, {Object? args}) =>
      DoRouter.off<R>(name, args: args);

  /// Push named route and clear the entire stack.
  static Future<R?> offAll<R>(String name, {Object? args}) =>
      DoRouter.offAll<R>(name, args: args);

  /// Pop the current route. No context needed.
  static void back<R>([R? result]) => DoRouter.back<R>(result);

  // ─── Context Navigation ───────────────────────────────────────────────────

  /// Push a page using a builder. Context required.
  /// ```dart
  /// Do.push(context, () => DetailPage());
  /// ```
  static Future<R?> push<R>(
    BuildContext context,
    Widget Function() page, {
    bool fullscreenDialog = false,
  }) =>
      Navigator.push<R>(
        context,
        MaterialPageRoute(
          builder: (_) => page(),
          fullscreenDialog: fullscreenDialog,
        ),
      );

  /// Replace current page with a builder page.
  static Future<R?> pushReplace<R>(
    BuildContext context,
    Widget Function() page,
  ) =>
      Navigator.pushReplacement<R, dynamic>(
        context,
        MaterialPageRoute(builder: (_) => page()),
      );

  /// Push and clear the stack.
  static Future<R?> pushAndClear<R>(
    BuildContext context,
    Widget Function() page,
  ) =>
      Navigator.pushAndRemoveUntil<R>(
        context,
        MaterialPageRoute(builder: (_) => page()),
        (_) => false,
      );

  /// Pop with context.
  static void pop<R>(BuildContext context, [R? result]) =>
      Navigator.pop<R>(context, result);

  // ─── Theme ────────────────────────────────────────────────────────────────

  /// Toggle light ↔ dark theme.
  static void toggleTheme() => DoTheme.toggle();

  /// Set a specific [ThemeMode].
  static void setTheme(ThemeMode mode) => DoTheme.setMode(mode);

  /// `true` if dark mode is active.
  static bool get isDark => DoTheme.isDark;

  // ─── API ──────────────────────────────────────────────────────────────────

  /// Global API client. Configure once:
  /// ```dart
  /// Do.api.baseUrl = 'https://api.example.com';
  /// Do.api.headers['Authorization'] = 'Bearer $token';
  /// ```
  static final api = DoApi();

  // ─── Screen Size ──────────────────────────────────────────────────────────

  /// Full screen width in logical pixels.
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  /// Full screen height in logical pixels.
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// [percent]% of screen width (0–100).
  static double widthPercent(BuildContext context, double percent) =>
      MediaQuery.sizeOf(context).width * (percent / 100);

  /// [percent]% of screen height (0–100).
  static double heightPercent(BuildContext context, double percent) =>
      MediaQuery.sizeOf(context).height * (percent / 100);

  /// `true` if screen width >= 600.
  static bool isTablet(BuildContext context) => width(context) >= 600;

  /// `true` if screen width >= 1200.
  static bool isDesktop(BuildContext context) => width(context) >= 1200;

  /// `true` if landscape.
  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;
}
