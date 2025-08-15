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

class DummyValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  @override
  final T value;
  DummyValueNotifier(this.value);
}
