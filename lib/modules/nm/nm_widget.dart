import "dart:convert";

import "package:flutter/material.dart";
import "package:nm/nm.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/util/string_utils.dart";

class NetworkManagerWidget extends StatefulWidget {
  final NetworkManagerService service;
  const NetworkManagerWidget({super.key, required this.service});

  @override
  State<NetworkManagerWidget> createState() => _NetworkManagerState();
}

class _NetworkManagerState extends State<NetworkManagerWidget> {
  late final WifiManager wifiDevice;

  @override
  void initState() {
    super.initState();

    final device = widget.service.getWirelessDevice();
    wifiDevice = WifiManager(device!);
  }

  @override
  void dispose() {
    wifiDevice.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wifiDevice.activeAccessPoint,
      builder: (context, _) {
        if (wifiDevice.activeAccessPoint.value != null) {
          return _Connected(wifiDevice.activeAccessPoint.value!);
        } else {
          return _NotConnected();
        }
      },
    );
  }
}

class NetworkManagerPopover extends StatefulWidget {
  final WifiManager service;
  const NetworkManagerPopover({super.key, required this.service});

  @override
  State<NetworkManagerPopover> createState() => _NetworkManagerPopoverState();
}

class _NetworkManagerPopoverState extends State<NetworkManagerPopover> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 200,
        maxWidth: 400,
      ),
      child: ListenableBuilder(
        listenable: widget.service.accessPoints,
        builder: (context, _) {
          return ListView(
            shrinkWrap: true,
            children: [for (final ap in widget.service.accessPoints.value) _AvailableAccessPoint(ap)],
          );
        },
      ),
    );
  }
}

class _AvailableAccessPoint extends StatelessWidget {
  final NetworkManagerAccessPoint accessPoint;

  const _AvailableAccessPoint(this.accessPoint);

  @override
  Widget build(BuildContext context) {
    final secured = accessPoint.wpaFlags.isNotEmpty || accessPoint.rsnFlags.isNotEmpty;
    final children = <Widget>[];
    if (secured) {
      children.add(Icon(Icons.lock, size: 12));
      children.add(SizedBox(width: 2));
    }

    final iconStrength = switch (accessPoint.strength) {
      < 10 => Icons.wifi_off_rounded,
      < 40 => Icons.wifi_1_bar_rounded,
      < 70 => Icons.wifi_2_bar_rounded,
      _ => Icons.wifi_rounded,
    };
    children.add(Icon(iconStrength, size: 15));
    children.add(SizedBox(width: 2));

    children.add(Text(accessPoint.ssid.toUtf8()));

    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _NotConnected extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Icon(Icons.wifi_off_rounded);
}

class _Connected extends StatelessWidget {
  final NetworkManagerAccessPoint accessPoint;

  const _Connected(this.accessPoint);

  @override
  Widget build(BuildContext context) {
    final icon = switch (accessPoint.strength) {
      < 10 => Icons.wifi_off_rounded,
      < 40 => Icons.wifi_1_bar_rounded,
      < 70 => Icons.wifi_2_bar_rounded,
      _ => Icons.wifi_rounded,
    };
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 2),
        Text(accessPoint.ssid.toUtf8()),
      ],
    );
  }
}
