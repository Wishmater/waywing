import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/system_tray/system_tray_service.dart";
import "package:waywing/widgets/winged_flat_button.dart";

class SystemTrayWidget extends StatefulWidget {
  final SystemTrayService service;

  const SystemTrayWidget({
    required this.service,
    super.key,
  });

  @override
  State<SystemTrayWidget> createState() => _SystemTrayWidgetState();
}

class _SystemTrayWidgetState extends State<SystemTrayWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: !config.isBarVertical ? config.barItemSize : null,
      height: config.isBarVertical ? config.barItemSize : null,
      child: WingedFlatButton(
        child: Center(
          child: Text(widget.service.items.isEmpty ? "empty" : widget.service.items.reduce((e, v) => "$e, $v")),
        ),
      ),
    );
  }
}
