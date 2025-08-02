import "package:flutter/material.dart";
import "package:nm/nm.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/util/string_utils.dart";

class NetworkManagerWidget extends StatefulWidget {
  final NetworkManagerService service;
  final NetworkManagerDeviceWireless wifi;
  const NetworkManagerWidget({super.key, required this.service, required this.wifi});

  @override
  State<NetworkManagerWidget> createState() => _NetworkManagerState();
}

class _NetworkManagerState extends State<NetworkManagerWidget> {
  late final NMObjectListener wifiListener;
  OwnedNullableListener<NMObjectListener> activeAccessPointListener = OwnedNullableListener(null);

  NetworkManagerDeviceWireless get wifiDevice => widget.wifi;
  NetworkManagerAccessPoint? get activeAccessPoint => wifiDevice.activeAccessPoint;

  @override
  void initState() {
    super.initState();
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
      builder: (context, _) {
        if (activeAccessPoint != null) {
          return _Connected(
            name: activeAccessPoint!.ssid.toUtf8(),
            strength: activeAccessPoint!.strength,
          );
        } else {
          return _NotConnected();
        }
      },
    );
  }
}

class NetworkManagerPopover extends StatefulWidget {
  final NetworkManagerService service;
  final NetworkManagerDeviceWireless wifi;

  const NetworkManagerPopover({super.key, required this.service, required this.wifi});

  @override
  State<NetworkManagerPopover> createState() => _NetworkManagerPopoverState();
}

class _NetworkManagerPopoverState extends State<NetworkManagerPopover> {
  late final NMObjectListener accessPointsListener;

  NetworkManagerDeviceWireless get wifiDevice => widget.wifi;
  List<NetworkManagerAccessPoint> get accessPoints => wifiDevice.accessPoints;

  @override
  void initState() {
    super.initState();

    accessPointsListener = NMObjectListener(wifiDevice.propertiesChanged, {"AccessPoints": null});
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Connect to wifi"),
                SingleChildScrollView(
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final ap in accessPoints)
                          _AvailableAccessPoint(ap, wifiDevice.activeAccessPoint == ap, (e) {}),
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
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 2),
        Text(name),
      ],
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

class NMObjectListener with ChangeNotifier {
  Stream<List<String>> stream;
  final Map<String, VoidCallback?> properties;

  NMObjectListener(this.stream, this.properties) {
    stream.listen((propertiesChanged) {
      for (final changed in propertiesChanged) {
        if (properties.containsKey(changed)) {
          notifyListeners();
          final cb = properties[changed];
          if (cb != null) {
            cb();
          }
        }
      }
    });
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
