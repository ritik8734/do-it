import 'package:flutter/widgets.dart';

/// Holds a reactive value. Pass it to [Do] to rebuild only the wrapped widget.
///
/// ```dart
/// final count = DoState(0);
///
/// // update triggers rebuild in any Do() listening to this state
/// count.set((n) => n + 1);
///
/// // or set directly
/// count.value = 42;
/// ```
class DoState<T> extends ValueNotifier<T> {
  /// Creates a [DoState] with an initial [value].
  DoState(super.value);

  /// Mutates the value via [updater] and notifies listeners.
  ///
  /// ```dart
  /// count.set((n) => n + 1);
  /// ```
  void set(T Function(T current) updater) {
    value = updater(value);
  }
}
