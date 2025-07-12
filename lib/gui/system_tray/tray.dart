import 'package:flutter/material.dart';
import 'package:waywing/services/system_tray.dart';

class SystemTrayWidget extends StatefulWidget {
  const SystemTrayWidget({super.key});

  @override
  State<SystemTrayWidget> createState() => _SystemTrayWidgetState();
}

class _SystemTrayWidgetState extends State<SystemTrayWidget> {
  @override
  void initState() {
    super.initState();
    systemTray.ensureInitialized();
  }

  // TODO: dispose system tray

  @override
  Widget build(BuildContext context) {
    return Text(systemTray.items.isEmpty ? 'empty' : systemTray.items.reduce((e, v) => '$e, $v'));
  }
}
