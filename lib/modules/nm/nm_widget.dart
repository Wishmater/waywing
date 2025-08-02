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
  late final WifiManagerService wifiDevice;

  @override
  void initState() {
    super.initState();

    wifiDevice = WifiManagerService(widget.service.client, widget.service.logger);
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
  final WifiManagerService service;
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("HELLO WIFI"),
                SingleChildScrollView(
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final ap in widget.service.accessPoints.value)
                          _AvailableAccessPoint(
                            ap,
                            widget.service.activeAccessPoint.value == ap,
                            widget.service.activate,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AvailableAccessPoint extends StatelessWidget {
  final NetworkManagerAccessPoint accessPoint;
  final bool isActive;
  final void Function(NetworkManagerAccessPoint) activate;

  const _AvailableAccessPoint(this.accessPoint, this.isActive, this.activate);

  @override
  Widget build(BuildContext context) {
    final secured = accessPoint.wpaFlags.isNotEmpty || accessPoint.rsnFlags.isNotEmpty;
    final children = <Widget>[];
    if (secured) {
      children.add(
        Icon(Icons.lock, size: 12, color: isActive ? Colors.green : null),
      );
      children.add(SizedBox(width: 2));
    }

    final iconStrength = switch (accessPoint.strength) {
      < 10 => Icons.wifi_off_rounded,
      < 40 => Icons.wifi_1_bar_rounded,
      < 70 => Icons.wifi_2_bar_rounded,
      _ => Icons.wifi_rounded,
    };
    children.add(
      Icon(
        iconStrength,
        size: 15,
        color: isActive ? Colors.green : null,
      ),
    );
    children.add(SizedBox(width: 2));

    children.add(Text(accessPoint.ssid.toUtf8(), style: TextStyle(color: isActive ? Colors.green : null)));

    return MaterialButton(
      onPressed: () {
        if (isActive) {
          return;
        }
        activate(accessPoint);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
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
