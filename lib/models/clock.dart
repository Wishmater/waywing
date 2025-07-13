import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waywing/models/_feather.dart';
import 'package:waywing/util/config.dart';

// TODO: 1 how should Feather initialization be handled?
// Ideally they are singletons, it doesn't really make sense for them to be instatiated twice.
// If they are singletons, we still need to be able to dispose/remove them only from Feathers service.
final clock = Clock();

class Clock extends Feather {
  @override
  String get name => 'Clock';

  // TODO: 2 add this to a TimeService
  late final ValueNotifier<DateTime> time;
  late final ValueNotifier<String> timeString;
  late final Timer _timer;

  @override
  Future<void> init(BuildContext context) async {
    time = ValueNotifier(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time.value = DateTime.now();
    });
    timeString = DerivedValueNotifier(
      dependencies: [time],
      derive: () {
        return '${time.value.hour}\n${time.value.minute}';
      },
    );
  }

  @override
  Future<void> dispose() async {
    _timer.cancel();
    timeString.dispose();
    time.dispose();
  }

  @override
  Widget? buildBarWidget(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: timeString,
      builder: (context, value, _) {
        final isBarVertical = config.isBarVertical;
        return Container(
          color: Colors.red,
          width: !isBarVertical ? config.barItemSize : null,
          height: isBarVertical ? config.barItemSize : null,
          child: Center(child: Text(value)),
        );
      },
    );
  }
}

// TODO: 2 move this to a utils file
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
