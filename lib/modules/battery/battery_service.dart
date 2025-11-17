import "package:dbus/dbus.dart";
import "package:waywing/core/service.dart";
import "package:upower/upower.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/battery/battery_config.dart";
import "package:waywing/modules/battery/interfaces/battery_service_interfaces.dart";
import "package:waywing/modules/battery/interfaces/mock.dart";
import "package:waywing/modules/battery/interfaces/uprofile_impl.dart";

class BatteryService extends Service<BatteryServiceConfig> {
  BatteryService._() : _bus = DBusClient.system();

  final DBusClient _bus;
  late final UPowerClient _client;
  UPowerProfile? _profile;

  late final BatteryValues battery;
  late final ProfileValues? profile;

  static registerService(RegisterServiceCallback registerService) {
    registerService<BatteryService, dynamic>(
      ServiceRegistration(
        constructor: BatteryService._,
        configBuilder: BatteryServiceConfig.fromBlock,
        schemaBuilder: () => BatteryServiceConfig.schema,
      ),
    );
  }

  @override
  Future<void> init() async {
    if (config.useMock) {
      battery = BatteryValuesMock();
      profile = null;
    } else {
      _client = UPowerClient(bus: _bus);
      await _client.connect();
      _profile = UPowerProfile(bus: _bus);
      try {
        await _profile!.connect();
      } catch (_) {
        _profile = null;
      }
      await _client.connect();

      battery = BatteryValuesImpl(_client.displayDevice);
      profile = _profile != null ? ProfileValuesImpl(_profile!) : null;
    }
  }

  @override
  Future<void> dispose() async {
    await Future.wait([_client.close(), ?_profile?.close()]);
    await _bus.close();
  }

  UPowerDevice get displayDevice => _client.displayDevice;
}
