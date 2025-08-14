import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";

typedef DeriveCallback<T> = T Function();

class DerivedValueNotifier<T> extends ValueNotifier<T> {
  final List<Listenable> dependencies;
  final DeriveCallback<T> derive;

  DerivedValueNotifier({
    required List<Listenable> dependencies,
    required this.derive,
    T? defaultsTo,
  }) : dependencies = List.unmodifiable(dependencies),
       super(defaultsTo ?? derive()) {
    for (final e in dependencies) {
      e.addListener(_update);
    }
  }

  void _update() {
    value = derive();
  }

  @override
  void dispose() {
    for (final e in dependencies) {
      e.removeListener(_update);
    }
    super.dispose();
  }
}

/// Allows to call markAsDirty as much as needed without hitting performance because
/// it batches the calls to notifyListeners
class BatchChangeNotifier with ChangeNotifier {
  bool _isDirty = false;
  BatchChangeNotifier();

  /// This function will mark the value as dirty and notify all listeners
  void markAsDirty() {
    if (!_isDirty) {
      _isDirty = true;
      SchedulerBinding.instance.scheduleTask(
        () {
          notifyListeners();
          _isDirty = false;
        },
        Priority.animation,
      );
    }
  }
}

class DBusProperyValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  T _value;

  @override
  T get value => _value;

  late final StreamSubscription<List<String>> _subscription;

  DBusProperyValueNotifier({
    required T value,
    required Stream<List<String>> stream,
    required String name,
    required FutureOr<T> Function() callback,
  }): _value = value {
    _subscription = stream.listen((changedProperties) async {
      if (changedProperties.contains(name)) {
        _value = await callback();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
