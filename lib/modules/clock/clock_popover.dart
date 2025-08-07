import "package:flutter/material.dart";
import "package:waywing/modules/clock/time_service.dart";

class ClockPopover extends StatelessWidget {
  final TimeService service;

  const ClockPopover({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.time,
      // TODO: 2 PERFORMANCE this is gonna rebuild every second, which is stupid
      builder: (context, time, _) {
        return Container(
          width: 320,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: CalendarDatePicker(
            initialDate: time,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            onDateChanged: (_) {},
          ),
        );
      },
    );
  }
}
