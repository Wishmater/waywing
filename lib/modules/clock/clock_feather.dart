import "dart:async";

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/widgets/winged_flat_button.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/derived_value_notifier.dart";

class ClockFeather extends Feather {
  late Logger logger;

  ClockFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather("Clock", ClockFeather._);
  }

  @override
  String get name => "Clock";

  // TODO: 2 add this to a TimeService
  late final ValueNotifier<DateTime> time;
  late final ValueNotifier<String> timeString;
  late final Timer _timer;

  @override
  Future<void> init(BuildContext context, Logger logger) async {
    this.logger = logger;
    time = ValueNotifier(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time.value = DateTime.now();
    });
    timeString = DerivedValueNotifier(
      dependencies: [time],
      derive: () {
        final hour = DateFormat("HH").format(time.value);
        final minute = DateFormat("mm").format(time.value);
        return "$hour\n$minute";
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
                  popover!.togglePopover();
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
          return IntrinsicWidth(
            child: Container(
              width: !config.isBarVertical ? config.barItemSize : null,
              height: config.isBarVertical ? config.barItemSize : null,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(value.toString()),
            ),
          );
        },
      );
    },

    buildPopover: (context) {
      return ValueListenableBuilder(
        valueListenable: time,
        builder: (context, value, _) {
          return Container(
            width: 320,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: CalendarDatePicker(
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (_) {},
            ),
          );
        },
      );
    },
  );
}
