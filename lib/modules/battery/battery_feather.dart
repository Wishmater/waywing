import "package:flutter/cupertino.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/modules/battery/battery_widget.dart";

class BatteryFeather extends Feather {
  late BatteryService service;


  BatteryFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "Battery",
      FeatherRegistration(
        constructor: BatteryFeather._,
      ),
    );
  }

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<BatteryService>(this);
  }

  @override
  String get name => "Battery";

  @override
  List<FeatherComponent> get components => [batteryComponent];

  late final batteryComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [BatteryWidget(values: BatteryValues(service.displayDevice))];
    }
  );
}
