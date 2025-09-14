import "package:dbus/dbus.dart";
import "package:waywing/core/service.dart";
import "package:upower/upower.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/dbus_utils.dart";

class BatteryService extends Service {
  BatteryService._() : _bus = DBusClient.system();

  final DBusClient _bus;
  late final UPowerClient _client;
  late final UPowerProfile _profile;

  late final BatteryValues battery;
  late final ProfileValues profile;

  static registerService(RegisterServiceCallback registerService) {
    registerService<BatteryService, dynamic>(
      ServiceRegistration(
        constructor: BatteryService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    _client = UPowerClient(bus: _bus);
    _profile = UPowerProfile(bus: _bus);
    await Future.wait([_client.connect(), _profile.connect()]);
    battery = BatteryValues(_client.displayDevice);
    profile = ProfileValues(_profile);
  }

  @override
  Future<void> dispose() async {
    await Future.wait([_client.close(), _profile.close()]);
    await _bus.close();
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

class ProfileValues {
  final UPowerProfile profile;

  /// The type of the currently active profile. It might change automatically if a profile is held,
  /// using the "HoldProfile" function.
  final DBusProperyValueNotifier<String> activeProfile;

  /// This will be set if the performance power profile is running in degraded mode,
  /// with the value being used to identify the reason for that degradation.
  /// As new reasons can be added, it is recommended that front-ends show a generic reason
  /// if they do not recognize the value
  final DBusProperyValueNotifier<UPowerProfilePerformanceDegraded> performanceDegraded;

  /// An array of key-pair values representing each profile. The key named "Driver" (s) identifies
  /// the power-profiles-daemon backend code used to implement the profile.
  ///
  /// The key named "Profile" (s) will be one of:
  /// - "power-saver" (battery saving profile)
  /// - "balanced" (the default profile)
  /// - "performance" (a profile that does not care about noise or battery consumption)
  ///
  /// Only one of each type of profile will be listed, with the daemon choosing the more
  /// appropriate "driver" for each profile type.
  ///
  /// This list is guaranteed to be sorted in the same order that the profiles are listed above.
  final DBusProperyValueNotifier<List<UPowerProfileProfile>> profiles;

  /// An array of strings listing each one of the "actions" implemented in the running daemon.
  /// This is used by API users to figure out whether particular functionality is available in a version
  /// of the daemon.
  final DBusProperyValueNotifier<List<String>> actions;

  /// An array of key-pair values representing each action. The key named "Description" (s)
  /// is a human-readable description of the action. The key named "Action" (s) is the name of the action.
  /// The key named "Enabled" (b) is a boolean indicating whether the action is enabled or not.
  final DBusProperyValueNotifier<List<UPowerProfileActionInfo>> actionsInfo;

  /// A list of dictionaries representing the current profile holds.
  /// The keys in the dict are "ApplicationId", "Profile" and "Reason", and correspond to
  /// the "application_id", "profile" and "reason" arguments passed to the HoldProfile() method.
  final DBusProperyValueNotifier<List<UPowerProfileActiveProfileHolds>> activeProfileHolds;

  /// The version of the power-profiles-daemon software.
  final DBusProperyValueNotifier<String> version;

  /// Whether the daemon is using upower to detect battery and AC adapter changes.
  final DBusProperyValueNotifier<bool> batteryAware;

  /// This signal will be emitted if the profile is released because the "ActiveProfile" was manually changed.
  /// The signal will only be emitted to the process that originally called "HoldProfile".
  Stream<int> get profileReleased => profile.profileReleased;

  ProfileValues(this.profile)
    : actions = DBusProperyValueNotifier(
        name: "Actions",
        stream: profile.propertiesChanged,
        callback: () => profile.actions,
      ),
      profiles = DBusProperyValueNotifier(
        name: "Profiles",
        stream: profile.propertiesChanged,
        callback: () => profile.profiles,
      ),
      performanceDegraded = DBusProperyValueNotifier(
        name: "PerformanceDegraded",
        stream: profile.propertiesChanged,
        callback: () => profile.performanceDegraded,
      ),
      activeProfile = DBusProperyValueNotifier(
        name: "ActiveProfile",
        stream: profile.propertiesChanged,
        callback: () => profile.activeProfile,
      ),
      actionsInfo = DBusProperyValueNotifier(
        name: "ActionsInfo",
        stream: profile.propertiesChanged,
        callback: () => profile.actionsInfo,
      ),
      activeProfileHolds = DBusProperyValueNotifier(
        name: "ActiveProfileHolds",
        stream: profile.propertiesChanged,
        callback: () => profile.activeProfileHolds,
      ),
      version = DBusProperyValueNotifier(
        name: "Version",
        stream: profile.propertiesChanged,
        callback: () => profile.version,
      ),
      batteryAware = DBusProperyValueNotifier(
        name: "BatteryAware",
        stream: profile.propertiesChanged,
        callback: () => profile.batteryAware,
      );

  /// This sets a particular action to be enabled or disabled. The daemon will only allow the action
  /// to be executed on power state changes if it is enabled.
  Future<void> setActionEnabled(String action, bool enabled) {
    return profile.setActionEnabled(action, enabled);
  }

  void setActiveProfile(String newProfile) {
    profile.activeProfile = newProfile;
  }
}
