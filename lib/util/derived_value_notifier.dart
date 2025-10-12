import "package:flutter/foundation.dart";

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

class LazyValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final List<Listenable> dependencies;
  final DeriveCallback<T> derive;
  bool _isDirty = true;
  late T _value;

  LazyValueNotifier({
    required List<Listenable> dependencies,
    required this.derive,
  }) : dependencies = List.unmodifiable(dependencies) {
    for (final e in dependencies) {
      e.addListener(_update);
    }
  }

  void _update() {
    _isDirty = true;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final e in dependencies) {
      e.removeListener(_update);
    }
    super.dispose();
  }

  @override
  T get value {
    if (_isDirty) {
      _value = derive();
      _isDirty = false;
    }
    return _value;
  }
}

class DummyValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  @override
  T value;
  DummyValueNotifier(this.value);
}

class ManualValueNotifier<T> extends DummyValueNotifier<T> {
  ManualValueNotifier(super.value);

  void manualNotifyListeners() {
    notifyListeners();
  }
}

class DerivedManualValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final DeriveCallback<T> derive;
  T _value;

  DerivedManualValueNotifier(this.derive) : _value = derive();

  void manualNotifyListeners() {
    _value = derive();
    notifyListeners();
  }

  @override
  T get value => _value;
}

class LazyManualValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final DeriveCallback<T> derive;
  bool _isDirty = true;
  late T _value;

  LazyManualValueNotifier(this.derive);

  void manualNotifyListeners() {
    _isDirty = true;
    notifyListeners();
  }

  @override
  T get value {
    if (_isDirty) {
      _value = derive();
      _isDirty = false;
    }
    return _value;
  }
}

class ManualNotifier extends ChangeNotifier {
  void manualNotifyListeners() {
    notifyListeners();
  }
}

// class FutureValueNotifier<T> extends ChangeNotifier implements ValueListenable<AsyncSnapshot<T>> {
//   final Future<T> future;
//   FutureValueNotifier(this.future) {
//     _listenToFuture();
//   }
//
//   /// An object that identifies the currently active callbacks. Used to avoid
//   /// calling setState from stale callbacks, e.g. after disposal of this state,
//   /// or after widget reconfiguration to a new Future.
//   Object? _activeCallbackIdentity;
//   late AsyncSnapshot<T> _snapshot;
//
//   Future<void> _listenToFuture() async {
//     _snapshot = AsyncSnapshot<T>.nothing();
//     final Object callbackIdentity = Object();
//     _activeCallbackIdentity = callbackIdentity;
//     future.then<void>(
//       (T data) {
//         if (_activeCallbackIdentity == callbackIdentity) {
//           _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, data);
//           notifyListeners();
//         }
//       },
//       onError: (Object error, StackTrace stackTrace) {
//         if (_activeCallbackIdentity == callbackIdentity) {
//           _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, error, stackTrace);
//           notifyListeners();
//         }
//       },
//     );
//     // An implementation like `SynchronousFuture` may have already called the
//     // .then closure. Do not overwrite it in that case.
//     if (_snapshot.connectionState != ConnectionState.done) {
//       _snapshot = _snapshot.inState(ConnectionState.waiting);
//       notifyListeners();
//     }
//   }
//
//   @override
//   AsyncSnapshot<T> get value => _snapshot;
//
//   @override
//   void dispose() {
//     _activeCallbackIdentity = null;
//     super.dispose();
//   }
// }
