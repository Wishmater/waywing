import "dart:async";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:nm/nm.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/util/string_utils.dart";
import "package:xdg_icons/xdg_icons.dart";

class NetworkManagerWidget extends StatefulWidget {
  final NetworkManagerService service;
  final Logger logger;

  const NetworkManagerWidget({super.key, required this.service, required this.logger});

  @override
  State<NetworkManagerWidget> createState() => _NetworkManagerState();
}

class _NetworkManagerState extends State<NetworkManagerWidget> {
  late final TxRxWatcher txRxWatcher;
  late WifiDeviceValues wifi;
  late List<EthernetDeviceValues> ethernet;

  @override
  void initState() {
    super.initState();
    wifi = widget.service.getWifiDeviceValuesFirst();
    ethernet = widget.service.ethernetDevicesValues;

    txRxWatcher = TxRxWatcher(wifi.device.statistics!);
    txRxWatcher.init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wifi.activeAccessPoint,
      builder: (context, child) {
        final activeAP = wifi.activeAccessPoint.value;
        if (activeAP != null) {
          return Row(
            children: [
              _EtherenetWidget(ethernet),
              _Connected(
                name: activeAP.ssid.toUtf8(),
                strength: activeAP.strength,
              ),
              child!,
            ],
          );
        } else {
          return Row(children: [_EtherenetWidget(ethernet), _NotConnected()]);
        }
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([txRxWatcher.rxRate, txRxWatcher.txRate]),
        builder: (context, _) {
          return Text(" up: ${txRxWatcher.txRate.value}kB/s : down: ${txRxWatcher.rxRate.value}kB/s");
        },
      ),
    );
  }
}

class NetworkManagerPopover extends StatefulWidget {
  final NetworkManagerService service;
  final Logger logger;

  const NetworkManagerPopover({super.key, required this.service, required this.logger});

  @override
  State<NetworkManagerPopover> createState() => _NetworkManagerPopoverState();
}

class _NetworkManagerPopoverState extends State<NetworkManagerPopover> {
  late WifiDeviceValues wifi;
  Logger get logger => widget.logger;

  @override
  void initState() {
    super.initState();
    wifi = widget.service.getWifiDeviceValuesFirst();
  }

  Future<void> connect(NetworkManagerAccessPoint accessPoint) async {
    final response = await widget.service.connect(wifi.device, accessPoint);
    if (response != ConnectResponse.needsPassword) {
      return;
    }
    if (!context.mounted) {
      logger.warning("connect needs password but context is not mounted and cannot ask for password");
      return;
    }
    if (!mounted) {
      logger.warning("connect needs password but state is not mounted and cannot ask for password");
      return;
    }
    final password = await showDialog<String>(
      context: context,
      requestFocus: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return _AskPassword();
      },
    );
    if (password == null) {
      return;
    }
    await widget.service.connect(wifi.device, accessPoint, userPassword: password);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 200,
        maxWidth: 400,
      ),
      child: ListenableBuilder(
        listenable: Listenable.merge([wifi.accessPoints, wifi.isScanning]),
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      await wifi.requestScan();
                    },
                    child: Text("Scan wifi ${wifi.isScanning.value ? 'scanning' : ''}"),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final ap in wifi.accessPoints.value)
                              _AvailableAccessPoint(
                                ap,
                                wifi.wirelessDevice.activeAccessPoint == ap,
                                connect,
                                () => widget.service.disconnect(wifi.device),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
  final void Function() disconnect;

  const _AvailableAccessPoint(this.accessPoint, this.isActive, this.activate, this.disconnect);

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
          disconnect();
        } else {
          activate(accessPoint);
        }
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
  final String name;
  final int strength;

  const _Connected({required this.name, required this.strength});

  @override
  Widget build(BuildContext context) {
    final icon = switch (strength) {
      < 10 => Icons.wifi_off_rounded,
      < 40 => Icons.wifi_1_bar_rounded,
      < 70 => Icons.wifi_2_bar_rounded,
      _ => Icons.wifi_rounded,
    };
    return IntrinsicWidth(
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 2),
          Expanded(child: Text(name)),
        ],
      ),
    );
  }
}

class _AskPassword extends StatefulWidget {
  @override
  State<_AskPassword> createState() => _AskPasswordState();
}

class _AskPasswordState extends State<_AskPassword> {
  late final TextEditingController controller;
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InputRegion(
        child: Material(
          clipBehavior: Clip.antiAlias,
          type: MaterialType.card,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: SizedBox(
            height: 150,
            width: 300,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 5,
                children: [
                  Text("Write password"),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          autofocus: true,
                          obscureText: obscureText,
                        ),
                      ),
                      IconButton(
                        icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, size: 20),
                        onPressed: () => setState(() => obscureText = !obscureText),
                      ),
                    ],
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(controller.text),
                    child: Text("OK"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EtherenetWidget extends StatelessWidget {
  final List<EthernetDeviceValues> values;

  const _EtherenetWidget(this.values);

  Widget render(EthernetDeviceValues value) {
    return ListenableBuilder(
      listenable: value.isConnected,
      builder: (context, _) {
        return value.isConnected.value ? XdgIcon(name: "network-wired", size: 64) : SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = [for (final value in values) render(value)];
    if (config.isBarVertical) {
      return Column(children: children);
    } else {
      return Row(children: children);
    }
  }
}
