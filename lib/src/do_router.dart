import 'package:flutter/material.dart';

/// Named route manager — define routes once, navigate anywhere without context.
///
/// Setup in MaterialApp:
/// ```dart
/// MaterialApp(
///   navigatorKey: DoRouter.key,
///   onGenerateRoute: DoRouter.onGenerateRoute,
///   initialRoute: '/',
/// )
/// ```
///
/// Register routes:
/// ```dart
/// DoRouter.define('/', () => HomePage());
/// DoRouter.define('/detail', () => DetailPage());
/// ```
///
/// Navigate (no context needed):
/// ```dart
/// Do.to('/detail', args: {'id': 1});
/// Do.back();
/// Do.offAll('/login');
/// ```
class DoRouter {
  DoRouter._();

  /// Global navigator key — attach to [MaterialApp.navigatorKey].
  static final key = GlobalKey<NavigatorState>();

  static final _routes = <String, Widget Function(Object? args)>{};

  /// Register a named route with a page builder.
  ///
  /// ```dart
  /// DoRouter.define('/detail', (args) => DetailPage(id: args['id']));
  /// // or without args:
  /// DoRouter.define('/', () => HomePage());
  /// ```
  static void define(String name, Widget Function([Object? args]) builder) {
    _routes[name] = builder;
  }

  /// [MaterialApp.onGenerateRoute] handler — pass this directly.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name];
    if (builder == null) return null;
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => builder(settings.arguments),
    );
  }

  static NavigatorState get _nav {
    final state = key.currentState;
    assert(state != null,
        'DoRouter: navigatorKey is not attached to MaterialApp.');
    return state!;
  }

  /// Push a named route.
  static Future<T?> to<T>(String name, {Object? args}) =>
      _nav.pushNamed<T>(name, arguments: args);

  /// Replace current route with a named route.
  static Future<T?> off<T>(String name, {Object? args}) =>
      _nav.pushReplacementNamed<T, dynamic>(name, arguments: args);

  /// Push and remove all previous routes.
  static Future<T?> offAll<T>(String name, {Object? args}) =>
      _nav.pushNamedAndRemoveUntil<T>(name, (_) => false, arguments: args);

  /// Pop the current route.
  static void back<T>([T? result]) => _nav.pop<T>(result);

  /// Whether the navigator can pop.
  static bool get canBack => _nav.canPop();
}
