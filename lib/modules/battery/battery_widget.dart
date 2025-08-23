import "package:flutter/cupertino.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:xdg_icons/xdg_icons.dart";

class BatteryWidget extends StatefulWidget {
  final BatteryValues values;

  const BatteryWidget({super.key, required this.values});

  @override
  State<BatteryWidget> createState() => BatteryWidgetState();
}

class BatteryWidgetState extends State<BatteryWidget> {
  BatteryValues get values => widget.values;

  @override
  Widget build(BuildContext context) {
    if (!values.isPresent.value) {
      return SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: values.iconName,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: XdgIcon(name: values.iconName.value, size: (mainConfig.barSize)),
        );
      },
    );
  }
}
