import "package:waywing/core/service.dart";
import "package:upower/upower.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/dbus_utils.dart";

class BatteryService extends Service {
  BatteryService._();

  late final UPowerClient _client;

  static registerService(RegisterServiceCallback registerService) {
    registerService<BatteryService, dynamic>(
      ServiceRegistration(
        constructor: BatteryService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    _client = UPowerClient();
    await _client.connect();
  }

  @override
  Future<void> dispose() async {
    await _client.close();
  }

  UPowerDevice get displayDevice => _client.displayDevice;
}

class BatteryValues {
  final UPowerDevice device;

  /// True if there is a battery in the bay. Only applicable for [UPowerDeviceType.battery].
  DBusProperyValueNotifier<bool> isPresent;

  /// Amount of energy left in this source as a percentage.
  DBusProperyValueNotifier<double> percentage;

  /// Temperature of this device in degrees Celcius. Only applicable for [UPowerDeviceType.battery].
  DBusProperyValueNotifier<double> temperature;

  /// Estimated time until this source is empty, in seconds.
  DBusProperyValueNotifier<int> timeToEmpty;

  /// Estimated time until this source is full, in seconds.
  DBusProperyValueNotifier<int> timeToFull;

  /// An icon to show for this device.
  DBusProperyValueNotifier<String> iconName;

  /// The battery power state. Only applicable for [UPowerDeviceType.battery].
  DBusProperyValueNotifier<UPowerDeviceState> state;

  /// Amount of energy available in Wh. Only applicable for [UPowerDeviceType.battery].
  DBusProperyValueNotifier<double> energy;

  /// Amount of energy available in Wh when this battery is considered empty. Only applicable for [UPowerDeviceType.battery].
  DBusProperyValueNotifier<double> energyEmpty;

  /// Amount of energy available in Wh when this battery is considered full. Only applicable for [UPowerDeviceType.battery].
  DBusProperyValueNotifier<double> energyFull;

  /// Amount of energy available in Wh this battery is designed to hold when full. Only applicable for [UPowerDeviceType.battery].
  DBusProperyValueNotifier<double> energyFullDesign;

  /// Amount of energy being drained from this source in Watts.
  DBusProperyValueNotifier<double> energyRate;

  /// True if this device is used to supply power to the system.
  DBusProperyValueNotifier<bool> powerSupply;

  BatteryValues(this.device)
    : isPresent = DBusProperyValueNotifier(
        name: "IsPresent",
        callback: () => device.isPresent,
        stream: device.propertiesChanged,
      ),
      percentage = DBusProperyValueNotifier(
        name: "Percentage",
        callback: () => device.percentage,
        stream: device.propertiesChanged,
      ),
      temperature = DBusProperyValueNotifier(
        name: "Temperature",
        callback: () => device.temperature,
        stream: device.propertiesChanged,
      ),
      timeToEmpty = DBusProperyValueNotifier(
        name: "TimeToEmpty",
        callback: () => device.timeToEmpty,
        stream: device.propertiesChanged,
      ),
      timeToFull = DBusProperyValueNotifier(
        name: "TimeToFull",
        callback: () => device.timeToFull,
        stream: device.propertiesChanged,
      ),
      iconName = DBusProperyValueNotifier(
        name: "IconName",
        callback: () => device.iconName,
        stream: device.propertiesChanged,
      ),
      state = DBusProperyValueNotifier(
        name: "State",
        callback: () => device.state,
        stream: device.propertiesChanged,
      ),
      energy = DBusProperyValueNotifier(
        name: "Energy",
        callback: () => device.energy,
        stream: device.propertiesChanged,
      ),
      energyEmpty = DBusProperyValueNotifier(
        name: "EnergyEmpty",
        callback: () => device.energyEmpty,
        stream: device.propertiesChanged,
      ),
      energyFull = DBusProperyValueNotifier(
        name: "EnergyFull",
        callback: () => device.energyFull,
        stream: device.propertiesChanged,
      ),
      energyFullDesign = DBusProperyValueNotifier(
        name: "EnergyFullDesign",
        callback: () => device.energyFullDesign,
        stream: device.propertiesChanged,
      ),
      energyRate = DBusProperyValueNotifier(
        name: "EnergyRate",
        callback: () => device.energyRate,
        stream: device.propertiesChanged,
      ),
      powerSupply = DBusProperyValueNotifier(
        name: "PowerSupply",
        callback: () => device.powerSupply,
        stream: device.propertiesChanged,
      );

  void dispose() {
    isPresent.dispose();
    percentage.dispose();
    temperature.dispose();
    timeToEmpty.dispose();
    timeToFull.dispose();
    iconName.dispose();
    state.dispose();
    energy.dispose();
    energyEmpty.dispose();
    energyFull.dispose();
    energyFullDesign.dispose();
    energyRate.dispose();
    powerSupply.dispose();
  }
}
