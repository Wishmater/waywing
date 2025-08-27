import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:xdg_icons/xdg_icons.dart";

class BatteryIndicator extends StatefulWidget {
  final BatteryValues battery;
  final ProfileValues profile;

  const BatteryIndicator({super.key, required this.battery, required this.profile});

  @override
  State<BatteryIndicator> createState() => BatteryIndicatorState();
}

class BatteryIndicatorState extends State<BatteryIndicator> {
  BatteryValues get battery => widget.battery;
  ProfileValues get profile => widget.profile;

  @override
  Widget build(BuildContext context) {
    if (!battery.isPresent.value) {
      return SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: battery.iconName,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: XdgIcon(name: battery.iconName.value, size: (mainConfig.barSize)),
        );
      },
    );
  }
}
