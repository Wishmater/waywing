import "package:waywing/core/service.dart";
import "package:upower/upower.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/derived_value_notifier.dart";

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
        value: device.isPresent,
        name: "IsPresent",
        stream: device.propertiesChanged,
        callback: () => device.isPresent,
      ),
      percentage = DBusProperyValueNotifier(
        value: device.percentage,
        name: "Percentage",
        stream: device.propertiesChanged,
        callback: () => device.percentage,
      ),
      temperature = DBusProperyValueNotifier(
        value: device.temperature,
        name: "Temperature",
        stream: device.propertiesChanged,
        callback: () => device.temperature,
      ),
      timeToEmpty = DBusProperyValueNotifier(
        value: device.timeToEmpty,
        name: "TimeToEmpty",
        stream: device.propertiesChanged,
        callback: () => device.timeToEmpty,
      ),
      timeToFull = DBusProperyValueNotifier(
        value: device.timeToFull,
        name: "TimeToFull",
        stream: device.propertiesChanged,
        callback: () => device.timeToFull,
      ),
      iconName = DBusProperyValueNotifier(
        value: device.iconName,
        name: "IconName",
        stream: device.propertiesChanged,
        callback: () => device.iconName,
      ),
      state = DBusProperyValueNotifier(
        value: device.state,
        name: "State",
        stream: device.propertiesChanged,
        callback: () => device.state,
      ),
      energy = DBusProperyValueNotifier(
        value: device.energy,
        name: "Energy",
        stream: device.propertiesChanged,
        callback: () => device.energy,
      ),
      energyEmpty = DBusProperyValueNotifier(
        value: device.energyEmpty,
        name: "EnergyEmpty",
        stream: device.propertiesChanged,
        callback: () => device.energyEmpty,
      ),
      energyFull = DBusProperyValueNotifier(
        value: device.energyFull,
        name: "EnergyFull",
        stream: device.propertiesChanged,
        callback: () => device.energyFull,
      ),
      energyFullDesign = DBusProperyValueNotifier(
        value: device.energyFullDesign,
        name: "EnergyFullDesign",
        stream: device.propertiesChanged,
        callback: () => device.energyFullDesign,
      ),
      energyRate = DBusProperyValueNotifier(
        value: device.energyRate,
        name: "EnergyRate",
        stream: device.propertiesChanged,
        callback: () => device.energyRate,
      ),
      powerSupply = DBusProperyValueNotifier(
        value: device.powerSupply,
        name: "PowerSupply",
        stream: device.propertiesChanged,
        callback: () => device.powerSupply,
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
