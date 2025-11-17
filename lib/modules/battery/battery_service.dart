import "dart:async";

import "package:dbus/dbus.dart";
import "package:mutex/mutex.dart";
import "package:waywing/core/service.dart";
import "package:upower/upower.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/battery/battery_config.dart";
import "package:waywing/modules/battery/interfaces/battery_service_interfaces.dart";
import "package:waywing/modules/battery/interfaces/mock.dart";
import "package:waywing/modules/battery/interfaces/uprofile_impl.dart";
import "package:waywing/modules/notification/notification_models.dart";
import "package:waywing/modules/notification/spec/notifications_client.dart";

class BatteryService extends Service<BatteryServiceConfig> {
  BatteryService._() : _bus = DBusClient.system();

  final DBusClient _bus;
  UPowerClient? _client;
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
      profile = ProfileValuesMock();
    } else {
      _client = UPowerClient(bus: _bus);
      await _client!.connect();
      _profile = UPowerProfile(bus: _bus);
      try {
        await _profile!.connect();
      } catch (_) {
        _profile = null;
      }
      await _client!.connect();

      battery = BatteryValuesImpl(_client!.displayDevice);
      profile = _profile != null ? ProfileValuesImpl(_profile!) : null;
    }
    battery.energy.addListener(_notifyOnLowBattery);
  }

  Notification? notification;
  final Mutex _mutex = Mutex();
  void _notifyOnLowBattery() {
    final energy = battery.energy.value;
    final energyFull = battery.energyFull.value;
    final state = battery.state.value;
    final isChargingOrEnoughBattery = energy > 0.1 * energyFull || state != UPowerDeviceState.discharging;

    if (isChargingOrEnoughBattery || notification != null) {
      if (notification != null && isChargingOrEnoughBattery) {
        unawaited(NotificationsClient.instance.close(notification!));
      }
      return;
    }
    _mutex.protect(() async {
      notification = await NotificationsClient.instance.notify(
        Notification.clientNew(
          appName: "waywing",
          appIcon: "",
          summary: "Low battery level",
          body: "",
          actions: Actions([]),
          hints: NotificationHints.clientNew(
            urgency: NotificationUrgency.critical,
            soundName: "dialog-error",
          ),
          timeout: 0,
        ),
        (event) => event is ClientNotificationEventClose ? notification = null : null,
      );
    });
  }

  @override
  Future<void> dispose() async {
    battery.energy.removeListener(_notifyOnLowBattery);

    await Future.wait([battery.dispose(), ?profile?.dispose(), ?_client?.close(), ?_profile?.close()]);
    await _bus.close();
  }
}
