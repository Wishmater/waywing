import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:waywing/modules/clock/clock_config.dart";
import "package:waywing/modules/clock/time_service.dart";

class ClockTooltip extends StatelessWidget {
  final ClockConfig config;
  final TimeService service;

  const ClockTooltip({
    required this.config,
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.time,
      builder: (context, time, _) {
        final timeFormat = config.use24HourFormat ? DateFormat.Hms() : DateFormat.jms();
        final value = "${DateFormat.yMMMMEEEEd().format(time)} - ${timeFormat.format(time)}";
        return IntrinsicHeight(
          child: IntrinsicWidth(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(value.toString()),
            ),
          ),
        );
      },
    );
  }
}
