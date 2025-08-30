import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:waywing/modules/clock/clock_config.dart";
import "package:waywing/modules/clock/time_service.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

class ClockIndicator extends StatelessWidget {
  final ClockConfig config;
  final TimeService service;
  final WingedPopoverController popover;

  const ClockIndicator({
    required this.config,
    required this.service,
    required this.popover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.time,
      builder: (context, time, _) {
        // TODO: 3 PERFORMANCE this is apparently being rebuilt every second, even though we only care about minutes
        return LayoutBuilder(
          builder: (context, constraints) {
            final isVertical = constraints.maxHeight > constraints.maxWidth;
            String value;
            if (isVertical) {
              value = DateFormat("${config.use24HourFormat ? "HH" : "hh"}\nmm").format(time);
            } else {
              value = DateFormat("${config.use24HourFormat ? "HH" : "hh"}:mm").format(time);
            }
            return WingedButton(
              onTap: () {
                popover.togglePopover();
              },
              child: Text(value),
            );
          },
        );
      },
    );
  }
}
