
import "package:flutter/foundation.dart";
import "package:upower/upower.dart";

abstract class BatteryValues {
  /// True if there is a battery in the bay. Only applicable for [UPowerDeviceType.battery].
  ValueListenable<bool> get isPresent;

  /// Amount of energy left in this source as a percentage.
  ValueListenable<double> get percentage;

  /// Temperature of this device in degrees Celcius. Only applicable for [UPowerDeviceType.battery].
  ValueListenable<double> get temperature;

  /// Estimated time until this source is empty, in seconds.
  ValueListenable<int> get timeToEmpty;

  /// Estimated time until this source is full, in seconds.
  ValueListenable<int> get timeToFull;

  /// An icon to show for this device.
  ValueListenable<String> get iconName;

  /// The battery power state. Only applicable for [UPowerDeviceType.battery].
  ValueListenable<UPowerDeviceState> get state;

  /// Amount of energy available in Wh. Only applicable for [UPowerDeviceType.battery].
  ValueListenable<double> get energy;

  /// Amount of energy available in Wh when this battery is considered empty. Only applicable for [UPowerDeviceType.battery].
  ValueListenable<double> get energyEmpty;

  /// Amount of energy available in Wh when this battery is considered full. Only applicable for [UPowerDeviceType.battery].
  ValueListenable<double> get energyFull;

  /// Amount of energy available in Wh this battery is designed to hold when full. Only applicable for [UPowerDeviceType.battery].
  ValueListenable<double> get energyFullDesign;

  /// Amount of energy being drained from this source in Watts.
  ValueListenable<double> get energyRate;

  /// True if this device is used to supply power to the system.
  ValueListenable<bool> get powerSupply;

  Future<void> dispose();
}

abstract class ProfileValues {
  /// The type of the currently active profile. It might change automatically if a profile is held,
  /// using the "HoldProfile" function.
  ValueListenable<String> get activeProfile;

  /// This will be set if the performance power profile is running in degraded mode,
  /// with the value being used to identify the reason for that degradation.
  /// As new reasons can be added, it is recommended that front-ends show a generic reason
  /// if they do not recognize the value
  ValueListenable<UPowerProfilePerformanceDegraded> get performanceDegraded;

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
  ValueListenable<List<UPowerProfileProfile>> get profiles;

  /// An array of strings listing each one of the "actions" implemented in the running daemon.
  /// This is used by API users to figure out whether particular functionality is available in a version
  /// of the daemon.
  ValueListenable<List<String>> get actions;

  /// An array of key-pair values representing each action. The key named "Description" (s)
  /// is a human-readable description of the action. The key named "Action" (s) is the name of the action.
  /// The key named "Enabled" (b) is a boolean indicating whether the action is enabled or not.
  ValueListenable<List<UPowerProfileActionInfo>> get actionsInfo;

  /// A list of dictionaries representing the current profile holds.
  /// The keys in the dict are "ApplicationId", "Profile" and "Reason", and correspond to
  /// the "application_id", "profile" and "reason" arguments passed to the HoldProfile() method.
  ValueListenable<List<UPowerProfileActiveProfileHolds>> get activeProfileHolds;

  /// The version of the power-profiles-daemon software.
  ValueListenable<String> get version;

  /// Whether the daemon is using upower to detect battery and AC adapter changes.
  ValueListenable<bool> get batteryAware;

  /// This sets a particular action to be enabled or disabled. The daemon will only allow the action
  /// to be executed on power state changes if it is enabled.
  Future<void> setActionEnabled(String action, bool enabled);

  /// Change the current profile
  void setActiveProfile(String newProfile);

  Future<void> dispose();
}
