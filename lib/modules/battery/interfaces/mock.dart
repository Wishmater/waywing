import "dart:math";

import "package:flutter/widgets.dart" show ValueNotifier;
import "package:upower/upower.dart" show UPowerDeviceState;
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
    derive: () => ((energy.value - energyEmpty.value) / energyRate.value.abs()).floor(),
  );

  @override
  late final DerivedValueNotifier<int> timeToFull = DerivedValueNotifier(
    dependencies: [energy, energyFull, energyRate],
    derive: () => ((energy.value - energyEmpty.value) / energyRate.value.abs()).floor(),
  );
}
