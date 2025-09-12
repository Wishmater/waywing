import "dart:async";

import "package:flutter/foundation.dart";

class DBusProperyValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final String _name;
  final T Function() _callback;
  T _value;

  @override
  T get value => _value;

  StreamSubscription<List<String>>? _subscription;

  DBusProperyValueNotifier({
    required String name,
    required Stream<List<String>>? stream,
    required T Function() callback,
  }) : _name = name,
       _callback = callback,
       _value = callback() {
    _subscription = stream?.listen(onStreamData);
  }

  set stream(Stream<List<String>>? stream) {
    _subscription?.cancel();
    _subscription = stream?.listen(onStreamData);
  }

  void onStreamData(List<String> changedProperties) {
    if (changedProperties.contains(_name)) {
      _value = _callback();
      notifyListeners();
    }
  }

  void triggerCallback() {
    _value = _callback();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
