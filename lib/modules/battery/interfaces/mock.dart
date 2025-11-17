import "dart:math";

import "package:flutter/widgets.dart" show ValueNotifier;
import "package:upower/upower.dart"
    show
        UPowerDeviceState,
        UPowerProfileActionInfo,
        UPowerProfileActiveProfileHolds,
        UPowerProfilePerformanceDegraded,
        UPowerProfileProfile;
import "package:waywing/util/derived_value_notifier.dart";
import "battery_service_interfaces.dart";

class BatteryValuesMock extends BatteryValues {
  BatteryValuesMock() {
    startAutomaticValueUpdates();
  }

  bool isRunning = true;

  Future<void> startAutomaticValueUpdates() async {
    energy.value = 200_000.0;
    energyEmpty.value = 0.0;
    energyFull.value = 1_000_000.0;
    energyFullDesign.value = 2_000_000.0;
    energyRate.value = 1_000.0;
    powerSupply.value = false;
    state.value = UPowerDeviceState.empty;
    temperature.value = 0;

    var doState = UPowerDeviceState.discharging;
    while (isRunning) {
      switch (doState) {
        case UPowerDeviceState.charging:
          state.value = UPowerDeviceState.charging;
          energy.value = min(energy.value + energyRate.value, energyFull.value);
        case UPowerDeviceState.discharging:
          state.value = UPowerDeviceState.discharging;
          energy.value = max(energy.value - energyRate.value, energyEmpty.value);
        case UPowerDeviceState.unknown:
        case UPowerDeviceState.empty:
        case UPowerDeviceState.fullyCharged:
        case UPowerDeviceState.pendingCharge:
        case UPowerDeviceState.pendingDischarge:
          throw UnimplementedError();
      }
      if (energy.value <= energyEmpty.value) {
        state.value = UPowerDeviceState.empty;
        doState = UPowerDeviceState.charging;
      } else if (energy.value >= energyFull.value) {
        state.value = UPowerDeviceState.fullyCharged;
        doState = UPowerDeviceState.discharging;
      }
      await Future.delayed(Duration(milliseconds: 50));
    }
  }

  @override
  Future<void> dispose() async {
    isRunning = false;
  }

  @override
  final ValueNotifier<double> energy = ValueNotifier(0.0);

  @override
  final ValueNotifier<double> energyEmpty = ValueNotifier(0.0);

  @override
  final ValueNotifier<double> energyFull = ValueNotifier(0.0);

  @override
  final ValueNotifier<double> energyFullDesign = ValueNotifier(0.0);

  @override
  final ValueNotifier<double> energyRate = ValueNotifier(0.0);

  @override
  ValueNotifier<String> get iconName => ValueNotifier("");

  @override
  final ValueNotifier<bool> isPresent = ValueNotifier(true);

  @override
  final ValueNotifier<double> percentage = ValueNotifier(0.0);

  @override
  final ValueNotifier<bool> powerSupply = ValueNotifier(false);

  @override
  final ValueNotifier<UPowerDeviceState> state = ValueNotifier(UPowerDeviceState.unknown);

  @override
  final ValueNotifier<double> temperature = ValueNotifier(0.0);

  @override
  late final DerivedValueNotifier<int> timeToEmpty = DerivedValueNotifier(
    dependencies: [energy, energyEmpty, energyRate],
    derive: () => ((energy.value - energyEmpty.value) / (energyRate.value.abs() * 20)).floor(),
  );

  @override
  late final DerivedValueNotifier<int> timeToFull = DerivedValueNotifier(
    dependencies: [energy, energyFull, energyRate],
    derive: () => ((energyFull.value - energy.value) / (energyRate.value.abs() * 20)).floor(),
  );
}

class ProfileValuesMock extends ProfileValues {
  @override
  final ValueNotifier<List<String>> actions = ValueNotifier([
    "Action 1",
    "Action 2",
    "Action 3",
  ]);

  @override
  final ManualValueNotifier<List<UPowerProfileActionInfo>> actionsInfo = ManualValueNotifier([
    UPowerProfileActionInfo(
      name: "Action 1",
      description: "Description 1",
      enabled: true,
    ),
    UPowerProfileActionInfo(
      name: "Action 2",
      description: "Description 2",
      enabled: false,
    ),
    UPowerProfileActionInfo(
      name: "Action 1",
      description: "Description 3",
      enabled: true,
    ),
  ]);

  @override
  final ValueNotifier<String> activeProfile = ValueNotifier("balance");

  @override
  final ValueNotifier<List<UPowerProfileActiveProfileHolds>> activeProfileHolds = ValueNotifier([]);

  @override
  final ValueNotifier<bool> batteryAware = ValueNotifier(false);

  @override
  Future<void> dispose() async {}

  @override
  final ValueNotifier<UPowerProfilePerformanceDegraded> performanceDegraded = ValueNotifier(
    UPowerProfilePerformanceDegraded.unrecognized,
  );

  @override
  final ValueNotifier<List<UPowerProfileProfile>> profiles = ValueNotifier([
    UPowerProfileProfile(
      driver: "driver 2",
      profile: "power-saver",
    ),
    UPowerProfileProfile(
      driver: "driver 1",
      profile: "balance",
    ),
    UPowerProfileProfile(
      driver: "driver 3",
      profile: "performance",
    ),
  ]);

  @override
  Future<void> setActionEnabled(String action, bool enabled) async {
    actionsInfo.value.indexed.firstWhere((indexAction) {
      if (indexAction.$2.name == action) {
        actionsInfo.value[indexAction.$1] = UPowerProfileActionInfo(
          name: indexAction.$2.name,
          description: indexAction.$2.description,
          enabled: enabled,
        );
        return true;
      } else {
        return false;
      }
    });
    actionsInfo.manualNotifyListeners();
  }

  @override
  void setActiveProfile(String newProfile) {
    activeProfile.value = newProfile;
  }

  @override
  final ValueNotifier<String> version = ValueNotifier("1.0.0");
}
