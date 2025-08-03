import "dart:convert";

import "package:dartx/dartx_io.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:nm/nm.dart";

class NetworkManagerService extends Service {
  late Logger logger;
  final NetworkManagerClient client;

  NetworkManagerService._() : client = NetworkManagerClient();

  static registerService(RegisterServiceCallback registerService) {
    registerService<NetworkManagerService>(NetworkManagerService._);
  }

  @override
  Future<void> dispose() async {
    await client.close();
    await logger.destroy();
  }

  @override
  Future<void> init(Logger logger) async {
    this.logger = logger;
    await client.connect();
    await listConnections();
  }

  NetworkManagerDevice? getWirelessDevice() {
    // TODO what happens if there is more than one wifi device
    final device = client.devices.firstOrNullWhere((e) => e.deviceType == NetworkManagerDeviceType.wifi);
    return device;
  }

  Future<void> listConnections() async {
    // client.settings.addConnection();
    for (final conn in client.settings.connections) {
      final settings = await conn.getSettings();
      for (final e in settings.entries) {
        print("${e.key}: ${e.value}");
      }
      print("\n");
    }
  }

  Future<void> connect(
    NetworkManagerDevice device,
    NetworkManagerAccessPoint ap, {
    bool autoconnect = false,
  }) async {
    print("CONNECTING TO ${device.driver} ${utf8.decode(ap.ssid)}");
    await client.addAndActivateConnection(device: device, accessPoint: ap);
  }

  Future<void> disconnect(NetworkManagerDevice device) async {
    print("DISCONNECTING FROM ${device.driver}");
    await device.disconnect();
  }
}
