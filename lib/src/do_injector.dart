/// Dependency Injection — like Get.put / Get.find
///
/// ```dart
/// Do.put(MyService());          // register
/// Do.find<MyService>().doWork() // retrieve
/// Do.delete<MyService>()        // remove
/// ```
class DoInjector {
  DoInjector._();

  static final _registry = <Object, Object>{};

  /// Register an instance. Optionally pass [tag] to allow multiple instances
  /// of the same type.
  static T put<T extends Object>(T instance, {String? tag}) {
    _registry[_key<T>(tag)] = instance;
    return instance;
  }

  /// Retrieve a previously registered instance.
  ///
  /// Throws [StateError] if not found.
  static T find<T extends Object>({String? tag}) {
    final instance = _registry[_key<T>(tag)];
    if (instance == null) {
      throw StateError(
        'DoInjector: No instance of $T found. '
        'Did you call Do.put<$T>() first?',
      );
    }
    return instance as T;
  }

  /// Returns `true` if an instance of [T] is registered.
  static bool isRegistered<T extends Object>({String? tag}) =>
      _registry.containsKey(_key<T>(tag));

  /// Remove a registered instance.
  static void delete<T extends Object>({String? tag}) =>
      _registry.remove(_key<T>(tag));

  /// Remove all registered instances.
  static void reset() => _registry.clear();

  static Object _key<T>(String? tag) => tag == null ? T : '$T/$tag';
}
