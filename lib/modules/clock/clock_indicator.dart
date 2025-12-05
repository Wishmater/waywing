import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:waywing/modules/clock/clock_config.dart";
import "package:waywing/modules/clock/time_service.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

class ClockIndicator extends StatefulWidget {
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
  State<ClockIndicator> createState() => _ClockIndicatorState();
}

class _ClockIndicatorState extends State<ClockIndicator> {
  bool? isVertical;
  String? value;

  @override
  void initState() {
    super.initState();
    widget.service.time.addListener(updateValue);
  }

  @override
  void didUpdateWidget(covariant ClockIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.service.time != oldWidget.service.time) {
      oldWidget.service.time.removeListener(updateValue);
      widget.service.time.addListener(updateValue);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.service.time.removeListener(updateValue);
  }

  void updateValue({bool doSetState = true}) {
    if (isVertical == null) {
      return;
    }
    String newValue;
    if (isVertical!) {
      newValue = DateFormat("${widget.config.militar ? "HH" : "hh"}\nmm").format(widget.service.time.value);
    } else {
      newValue = DateFormat("${widget.config.militar ? "HH" : "hh"}:mm").format(widget.service.time.value);
    }
    if (value != newValue) {
      value = newValue;
      if (doSetState) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        isVertical = constraints.maxHeight > constraints.maxWidth;
        if (value == null) {
          updateValue(doSetState: false);
        }

        return WingedButton(
          onTap: (_, _) {
            widget.popover.togglePopover();
          },
          child: Text(
            value!,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.2),
          ),
        );
      },
    );
  }
}
