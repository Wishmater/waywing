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
  }

  @override
  Future<void> init(Logger logger) async {
    this.logger = logger;
    await client.connect();
    await logger.destroy();
  }

  NetworkManagerDeviceWireless? getWirelessDevice() {
    // TODO what happens if there is more than one wifi device
    final device = client.devices.firstOrNullWhere((e) => e.deviceType == NetworkManagerDeviceType.wifi);
    return device?.wireless;
  }
}
