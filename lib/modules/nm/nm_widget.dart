import "dart:async";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:nm/nm.dart";
import "package:tronco/tronco.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/string_utils.dart";

class NetworkManagerWidget extends StatefulWidget {
  final NetworkManagerService service;
  final NetworkManagerDevice device;
  final Logger logger;

  NetworkManagerDeviceWireless get wifi => device.wireless!;

  const NetworkManagerWidget({super.key, required this.service, required this.device, required this.logger});

  @override
  State<NetworkManagerWidget> createState() => _NetworkManagerState();
}

class _NetworkManagerState extends State<NetworkManagerWidget> {
  late final NMObjectListener wifiListener;
  late final TxRxWatcher txRxWatcher;
  OwnedNullableListener<NMObjectListener> activeAccessPointListener = OwnedNullableListener(null);

  NetworkManagerDeviceWireless get wifiDevice => widget.wifi;
  NetworkManagerAccessPoint? get activeAccessPoint => wifiDevice.activeAccessPoint;

  @override
  void initState() {
    super.initState();
    txRxWatcher = TxRxWatcher(widget.device.statistics!);
    txRxWatcher.init();
    _setActiveAccessPointListener();

    wifiListener = NMObjectListener(wifiDevice.propertiesChanged, {
      "ActiveAccessPoint": _setActiveAccessPointListener,
    });
  }

  void _setActiveAccessPointListener() {
    if (wifiDevice.activeAccessPoint != null) {
      activeAccessPointListener.listener = NMObjectListener(wifiDevice.activeAccessPoint!.propertiesChanged, {
        "Strength": null,
      });
    } else {
      activeAccessPointListener.listener = null;
    }
  }

  @override
  void dispose() {
    wifiListener.dispose();
    activeAccessPointListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: activeAccessPointListener,
      builder: (context, child) {
        if (activeAccessPoint != null) {
          return Row(
            children: [
              _Connected(
                name: activeAccessPoint!.ssid.toUtf8(),
                strength: activeAccessPoint!.strength,
              ),
              child!,
            ],
          );
        } else {
          return _NotConnected();
        }
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([txRxWatcher.rxRate, txRxWatcher.txRate]),
        builder: (context, _) {
          return Text(" up: ${txRxWatcher.rxRate.value}kB/s : down: ${txRxWatcher.rxRate.value}kB/s");
        },
      ),
    );
  }
}

class NetworkManagerPopover extends StatefulWidget {
  final NetworkManagerService service;
  final NetworkManagerDevice device;
  final Logger logger;

  NetworkManagerDeviceWireless get wifi => device.wireless!;

  const NetworkManagerPopover({super.key, required this.service, required this.device, required this.logger});

  @override
  State<NetworkManagerPopover> createState() => _NetworkManagerPopoverState();
}

class _NetworkManagerPopoverState extends State<NetworkManagerPopover> {
  late final NMObjectListener accessPointsListener;

  NetworkManagerDevice get device => widget.device;
  NetworkManagerDeviceWireless get wifiDevice => widget.wifi;
  List<NetworkManagerAccessPoint> get accessPoints => wifiDevice.accessPoints;
  Logger get logger => widget.logger;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();

    accessPointsListener = NMObjectListener(wifiDevice.propertiesChanged, {
      "AccessPoints": null,
      "LastScan": () => isScanning ? setState(() => isScanning = false) : null,
      "ActiveAccessPoint": null,
    });
  }

  Future<void> connect(NetworkManagerAccessPoint accessPoint) async {
    final response = await widget.service.connect(device, accessPoint);
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
    await widget.service.connect(device, accessPoint, userPassword: password);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 200,
        maxWidth: 400,
      ),
      child: ListenableBuilder(
        listenable: accessPointsListener,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      await widget.service.requestScan(wifiDevice);
                      setState(() => isScanning = true);
                    },
                    child: Text("Scan wifi ${isScanning ? 'scanning' : ''}"),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final ap in accessPoints)
                              _AvailableAccessPoint(
                                ap,
                                wifiDevice.activeAccessPoint == ap,
                                connect,
                                () => widget.service.disconnect(device),
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

/// Class to manage a nullable listener.
///
/// Owns the listener, which means that will dispose the previous listener on a change
class OwnedNullableListener<T extends ChangeNotifier> with ChangeNotifier {
  T? _listener;
  T? get listener => _listener;

  set listener(T? newListener) {
    if (_listener != newListener) {
      _listener?.dispose();
      _listener = newListener;
      notifyListeners();
      _listener?.addListener(notifyListeners);
    }
  }

  OwnedNullableListener(this._listener);

  @override
  void dispose() {
    listener?.dispose();
    super.dispose();
  }
}

/// class Utility to react to NMObject changedProperties stream
class NMObjectListener extends BatchChangeNotifier {
  Stream<List<String>> stream;
  final Map<String, VoidCallback?> properties;
  late final StreamSubscription<List<String>> _subscription;
  Timer? _automaticNotifierTimer;

  NMObjectListener(
    this.stream,
    this.properties, {
    Duration? automaticNotifier,
  }) {
    _subscription = stream.listen((propertiesChanged) {
      for (final changed in propertiesChanged) {
        if (properties.containsKey(changed)) {
          // instead of spamming notifyListener calls (which can be some what expensive)
          // use markAsDirty to allow BatchChangeNotifier to efficiently call notifyListener
          markAsDirty();
          final cb = properties[changed];
          if (cb != null) {
            cb();
          }
        }
      }
    });
    if (automaticNotifier != null) {
      _automaticNotifierTimer = Timer.periodic(automaticNotifier, (_) => markAsDirty());
    }
  }

  @override
  void dispose() {
    _automaticNotifierTimer?.cancel();
    _subscription.cancel().then((_) => super.dispose());
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(covariant NMObjectListener other) {
    return stream == other.stream && _propertiesEquality(other.properties);
  }

  bool _propertiesEquality(Map<String, VoidCallback?> other) {
    if (other == properties) {
      return true;
    }
    if (properties.length != other.length) {
      return false;
    }
    final otherKeys = other.keys.iterator;
    final keys = properties.keys.iterator;
    while (keys.moveNext()) {
      otherKeys.moveNext();
      if (keys.current != otherKeys.current) {
        return false;
      }
      if (properties[keys.current] != other[otherKeys.current]) {
        return false;
      }
    }
    return true;
  }
}
