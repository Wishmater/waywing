import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waywing/widgets/winged_flat_button.dart';
import 'package:waywing/core/feather.dart';
import 'package:waywing/core/config.dart';
import 'package:waywing/util/derived_value_notifier.dart';

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
  late final List<FeatherComponent> components = [clockComponent];

  late final clockComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        ValueListenableBuilder(
          valueListenable: timeString,
          builder: (context, value, _) {
            final isBarVertical = config.isBarVertical;
            return SizedBox(
              width: !isBarVertical ? config.barItemSize : null,
              height: isBarVertical ? config.barItemSize : null,
              child: WingedFlatButton(
                onTap: () {
                  popover!.toggle();
                },
                child: Center(child: Text(value)),
              ),
            );
          },
        ),
      ];
    },

    buildTooltip: (context) {
      return ValueListenableBuilder(
        valueListenable: time,
        builder: (context, value, _) {
          final isBarVertical = config.isBarVertical;
          return SizedBox(
            width: !isBarVertical ? config.barItemSize : null,
            height: isBarVertical ? config.barItemSize : null,
            child: WingedFlatButton(
              onTap: () {},
              child: Center(child: Text(value.toString())),
            ),
          );
        },
      );
    },

    buildPopover: (context) {
      return ValueListenableBuilder(
        valueListenable: time,
        builder: (context, value, _) {
          return SizedBox(
            width: 512,
            height: 512,
            child: WingedFlatButton(
              onTap: () {},
              child: Center(child: Text(value.toString())),
            ),
          );
        },
      );
    },
  );
}
