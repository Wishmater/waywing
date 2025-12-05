import "package:upower/upower.dart";
import "package:waywing/modules/battery/interfaces/battery_service_interfaces.dart";
import "package:waywing/util/dbus_utils.dart";

class BatteryValuesImpl extends BatteryValues {
  final UPowerDevice device;

  @override
  final DBusPropertyValueNotifier<bool> isPresent;

  @override
  final DBusPropertyValueNotifier<double> percentage;

  @override
  final DBusPropertyValueNotifier<double> temperature;

  @override
  final DBusPropertyValueNotifier<int> timeToEmpty;

  @override
  final DBusPropertyValueNotifier<int> timeToFull;

  @override
  final DBusPropertyValueNotifier<String> iconName;

  @override
  final DBusPropertyValueNotifier<UPowerDeviceState> state;

  @override
  final DBusPropertyValueNotifier<double> energy;

  @override
  final DBusPropertyValueNotifier<double> energyEmpty;

  @override
  final DBusPropertyValueNotifier<double> energyFull;

  @override
  final DBusPropertyValueNotifier<double> energyFullDesign;

  @override
  final DBusPropertyValueNotifier<double> energyRate;

  @override
  final DBusPropertyValueNotifier<bool> powerSupply;

  BatteryValuesImpl(this.device)
    : isPresent = DBusPropertyValueNotifier(
        name: "IsPresent",
        callback: () => device.isPresent,
        stream: device.propertiesChanged,
      ),
      percentage = DBusPropertyValueNotifier(
        name: "Percentage",
        callback: () => device.percentage,
        stream: device.propertiesChanged,
      ),
      temperature = DBusPropertyValueNotifier(
        name: "Temperature",
        callback: () => device.temperature,
        stream: device.propertiesChanged,
      ),
      timeToEmpty = DBusPropertyValueNotifier(
        name: "TimeToEmpty",
        callback: () => device.timeToEmpty,
        stream: device.propertiesChanged,
      ),
      timeToFull = DBusPropertyValueNotifier(
        name: "TimeToFull",
        callback: () => device.timeToFull,
        stream: device.propertiesChanged,
      ),
      iconName = DBusPropertyValueNotifier(
        name: "IconName",
        callback: () => device.iconName,
        stream: device.propertiesChanged,
      ),
      state = DBusPropertyValueNotifier(
        name: "State",
        callback: () => device.state,
        stream: device.propertiesChanged,
      ),
      energy = DBusPropertyValueNotifier(
        name: "Energy",
        callback: () => device.energy,
        stream: device.propertiesChanged,
      ),
      energyEmpty = DBusPropertyValueNotifier(
        name: "EnergyEmpty",
        callback: () => device.energyEmpty,
        stream: device.propertiesChanged,
      ),
      energyFull = DBusPropertyValueNotifier(
        name: "EnergyFull",
        callback: () => device.energyFull,
        stream: device.propertiesChanged,
      ),
      energyFullDesign = DBusPropertyValueNotifier(
        name: "EnergyFullDesign",
        callback: () => device.energyFullDesign,
        stream: device.propertiesChanged,
      ),
      energyRate = DBusPropertyValueNotifier(
        name: "EnergyRate",
        callback: () => device.energyRate,
        stream: device.propertiesChanged,
      ),
      powerSupply = DBusPropertyValueNotifier(
        name: "PowerSupply",
        callback: () => device.powerSupply,
        stream: device.propertiesChanged,
      );

  @override
  Future<void> dispose() async {
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

abstract class BatteryServiceBase {
  BatteryValuesImpl get battery;
}

class ProfileValuesImpl extends ProfileValues {
  final UPowerProfile profile;

  @override
  final DBusPropertyValueNotifier<String> activeProfile;

  @override
  final DBusPropertyValueNotifier<UPowerProfilePerformanceDegraded> performanceDegraded;

  @override
  final DBusPropertyValueNotifier<List<UPowerProfileProfile>> profiles;

  @override
  final DBusPropertyValueNotifier<List<String>> actions;

  @override
  final DBusPropertyValueNotifier<List<UPowerProfileActionInfo>> actionsInfo;

  @override
  final DBusPropertyValueNotifier<List<UPowerProfileActiveProfileHolds>> activeProfileHolds;

  @override
  final DBusPropertyValueNotifier<String> version;

  @override
  final DBusPropertyValueNotifier<bool> batteryAware;

  /// This signal will be emitted if the profile is released because the "ActiveProfile" was manually changed.
  /// The signal will only be emitted to the process that originally called "HoldProfile".
  Stream<int> get profileReleased => profile.profileReleased;

  ProfileValuesImpl(this.profile)
    : actions = DBusPropertyValueNotifier(
        name: "Actions",
        stream: profile.propertiesChanged,
        callback: () => profile.actions,
      ),
      profiles = DBusPropertyValueNotifier(
        name: "Profiles",
        stream: profile.propertiesChanged,
        callback: () => profile.profiles,
      ),
      performanceDegraded = DBusPropertyValueNotifier(
        name: "PerformanceDegraded",
        stream: profile.propertiesChanged,
        callback: () => profile.performanceDegraded,
      ),
      activeProfile = DBusPropertyValueNotifier(
        name: "ActiveProfile",
        stream: profile.propertiesChanged,
        callback: () => profile.activeProfile,
      ),
      actionsInfo = DBusPropertyValueNotifier(
        name: "ActionsInfo",
        stream: profile.propertiesChanged,
        callback: () => profile.actionsInfo,
      ),
      activeProfileHolds = DBusPropertyValueNotifier(
        name: "ActiveProfileHolds",
        stream: profile.propertiesChanged,
        callback: () => profile.activeProfileHolds,
      ),
      version = DBusPropertyValueNotifier(
        name: "Version",
        stream: profile.propertiesChanged,
        callback: () => profile.version,
      ),
      batteryAware = DBusPropertyValueNotifier(
        name: "BatteryAware",
        stream: profile.propertiesChanged,
        callback: () => profile.batteryAware,
      );

  @override
  Future<void> setActionEnabled(String action, bool enabled) {
    return profile.setActionEnabled(action, enabled);
  }

  @override
  void setActiveProfile(String newProfile) {
    profile.activeProfile = newProfile;
  }

  @override
  Future<void> dispose() async {
    batteryAware.dispose();
    version.dispose();
    activeProfileHolds.dispose();
    actionsInfo.dispose();
    activeProfile.dispose();
    performanceDegraded.dispose();
    profiles.dispose();
    actions.dispose();
  }
}
