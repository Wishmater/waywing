
import "package:flutter/material.dart";
import "package:waywing/modules/system_tray/service/idbus_menu.dart";

class DBusMenuWidget extends StatefulWidget {
  final DBusMenuValues menu;

  const DBusMenuWidget({super.key, required this.menu});

  @override
  State<DBusMenuWidget> createState() => DBusMenuWidgetState();
}

class DBusMenuWidgetState extends State<DBusMenuWidget> {
  DBusMenuValues get menu => widget.menu;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
