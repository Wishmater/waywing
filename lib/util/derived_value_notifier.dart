import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";

typedef DeriveCallback<T> = T Function();

class DerivedValueNotifier<T> extends ValueNotifier<T> {
  final List<Listenable> dependencies;
  final DeriveCallback<T> derive;

  DerivedValueNotifier({
    required List<Listenable> dependencies,
    required this.derive,
  }) : dependencies = List.unmodifiable(dependencies),
       super(derive()) {
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
