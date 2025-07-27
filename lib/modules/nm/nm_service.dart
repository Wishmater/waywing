import "dart:async" show StreamSubscription;

import "package:dartx/dartx_io.dart";
import "package:flutter/material.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:nm/nm.dart";
import "package:waywing/util/slice.dart";

class NetworkManagerService extends Service {
  final NetworkManagerClient _client;

  NetworkManagerService._() : _client = NetworkManagerClient();

  static registerService(RegisterServiceCallback registerService) {
    registerService<NetworkManagerService>(NetworkManagerService._);
  }

  @override
  Future<void> dispose() async {
    await _client.close();
  }

  @override
  Future<void> init() async {
    await _client.connect();
  }

  NetworkManagerDeviceWireless? getWirelessDevice() {
    // TODO what happens if there is more than one wifi device
    final device = _client.devices.firstOrNullWhere((e) => e.deviceType == NetworkManagerDeviceType.wifi);
    return device?.wireless;
  }
}

class WifiManager {
  final NetworkManagerDeviceWireless device;
  late final StreamSubscription<List<String>> _subscription;

  WifiManager(this.device) {
    _subscription = device.propertiesChanged.listen((properties) {
      print("WIFI MANAGER PROPERTIES CHANGED $properties");
      if (properties.contains("LastScan")) {
        isScanning.value = false;
      }
      if (properties.contains("AccessPoints")) {
        _updateAccessPoints();
      }
      if (properties.contains("ActiveAccessPoint")) {
        _updateActiveAccessPoint();
      }
    });
    accessPoints.value = Slice(device.accessPoints);
    activeAccessPoint.value = device.activeAccessPoint;
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    isScanning.dispose();
    accessPoints.dispose();
  }

  final ValueNotifier<NetworkManagerAccessPoint?> activeAccessPoint = ValueNotifier(null);
  void _updateActiveAccessPoint() {
    activeAccessPoint.value = device.activeAccessPoint;
  }

  final ValueNotifier<Slice<NetworkManagerAccessPoint>> accessPoints = ValueNotifier(
    Slice([]),
  );
  void _updateAccessPoints() {
    accessPoints.value = Slice(device.accessPoints);
  }

  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  void requestScan() {
    device.requestScan();
    isScanning.value = true;
  }
}
