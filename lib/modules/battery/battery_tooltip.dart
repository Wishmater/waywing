import "package:flutter/widgets.dart";
import "package:upower/upower.dart";
import "package:waywing/modules/battery/battery_config.dart";
import "package:waywing/modules/battery/battery_service.dart";

class BatteryTooltip extends StatelessWidget {
  final BatteryConfig config;
  final BatteryService service;

  const BatteryTooltip({super.key, required this.config, required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ValueListenableBuilder(
        valueListenable: service.battery.state,
        builder: (context, state, _) {
          if (state == UPowerDeviceState.fullyCharged) {
            return Text("charged");
          }
          if (state == UPowerDeviceState.charging) {
            return ValueListenableBuilder(
              valueListenable: service.battery.timeToFull,
              builder: (context, timeToFull, _) {
                return _SecondsWidget("charging:", timeToFull);
              },
            );
          }
          if (state == UPowerDeviceState.discharging) {
            return ValueListenableBuilder(
              valueListenable: service.battery.timeToEmpty,
              builder: (context, timeToEmpty, _) {
                return _SecondsWidget("discharging:", timeToEmpty);
              },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class _SecondsWidget extends StatelessWidget {
  final int seconds;
  final String message;
  const _SecondsWidget(this.message, this.seconds);

  @override
  Widget build(BuildContext context) {
    String unit;
    double time;
    if (seconds > 3600) {
      unit = "h";
      time = seconds.toDouble() / 3600.0;
    } else if (seconds > 60) {
      unit = "m";
      time = seconds.toDouble() / 60.0;
    } else {
      unit = "s";
      time = seconds.toDouble();
    }
    return Text("$message ${time.toStringAsFixed(2)}$unit");
  }
}
