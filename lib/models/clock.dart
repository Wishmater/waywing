import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waywing/gui/widgets/winged_flat_button.dart';
import 'package:waywing/models/_feather.dart';
import 'package:waywing/util/config.dart';
import 'package:waywing/util/derived_value_notifier.dart';

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
        final hour = DateFormat('HH').format(time.value);
        final minute = DateFormat('mm').format(time.value);
        return '$hour\n$minute';
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
        return SizedBox(
          width: !isBarVertical ? config.barItemSize : null,
          height: isBarVertical ? config.barItemSize : null,
          child: WingedFlatButton(
            onTap: () {},
            child: Center(child: Text(value)),
          ),
        );
      },
    );
  }
}
