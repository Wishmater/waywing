import "dart:async" show StreamSubscription;

import "package:dartx/dartx_io.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:nm/nm.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/util/slice.dart";

class NetworkManagerService extends Service {
  final NetworkManagerClient client;

  NetworkManagerService._() : client = NetworkManagerClient();

  static registerService(RegisterServiceCallback registerService) {
    registerService<NetworkManagerService>(NetworkManagerService._);
  }

  @override
  Future<void> dispose() async {
    await client.close();
  }

  @override
  Future<void> init() async {
    await client.connect();
  }

  NetworkManagerDeviceWireless? getWirelessDevice() {
    // TODO what happens if there is more than one wifi device
    final device = client.devices.firstOrNullWhere((e) => e.deviceType == NetworkManagerDeviceType.wifi);
    return device?.wireless;
  }
}

class WifiManagerService {
  final NetworkManagerClient client;
  late final NetworkManagerDevice device;
  late final NetworkManagerDeviceWireless wireless;
  late final StreamSubscription<List<String>> _subscription;

  WifiManagerService(this.client) {
    device = client.devices.firstWhere((e) => e.deviceType == NetworkManagerDeviceType.wifi);
    wireless = device.wireless!;
    _subscription = wireless.propertiesChanged.listen(_listener);

    activeAccessPoint.value = wireless.activeAccessPoint;
    accessPoints.value = wireless.accessPoints;
  }

  void _listener(List<String> properties) {
    print("WIFI MANAGER PROPERTIES CHANGED $properties");
    if (properties.contains("LastScan")) {
      isScanning.value = false;
    }
    if (properties.contains("AccessPoints")) {
      accessPoints.markAsDirty();
    }
    if (properties.contains("ActiveAccessPoint")) {
      _updateAccessPoint();
    }
  }

  final BatchChangeNotifier<NetworkManagerAccessPoint?> activeAccessPoint = BatchChangeNotifier(null);
  final BatchChangeNotifier<List<NetworkManagerAccessPoint>> accessPoints = BatchChangeNotifier([]);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);

  void requestScan() {
    wireless.requestScan().then((_) => isScanning.value = true);
  }

  void _updateAccessPoint() {
    activeAccessPoint.value = wireless.activeAccessPoint;
    activeAccessPoint.value?.propertiesChanged.listen(
      (properties) {
      activeAccessPoint.markAsDirty();
      },
      onDone: () => print("activeAccessPoint.propertiesChanged ON DONE")
    );
  }

  Future<void> activate(NetworkManagerAccessPoint accessPoint) async {
    await client.activateConnection(device: device, accessPoint: accessPoint);
  }

  Future<void> dispose() async {
    _subscription.cancel();
  }
}
