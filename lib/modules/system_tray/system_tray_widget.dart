import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/widgets/winged_button.dart";

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
  late final StatusNotifierItemsValues values;

  @override
  void initState() {
    super.initState();
    values = widget.service.values;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: !config.isBarVertical ? config.barItemSize : null,
      height: config.isBarVertical ? config.barItemSize : null,
      child: WingedButton(
        child: Center(
          child: ListenableBuilder(
            listenable: values.items,
            builder: (context, _) {
              if (values.items.value.isEmpty) {
                return Text("emtpyzzzzzzzzzzzzzz");
              }
              return Text(values.items.value.map((e) => e.title.value).join(" - "));
            },
          ),
          // child: Text(widget.service.items.isEmpty ? "empty" : widget.service.items.reduce((e, v) => "$e, $v")),
        ),
      ),
    );
  }
}
