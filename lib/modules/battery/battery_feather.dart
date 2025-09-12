import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/modules/battery/battery_widget.dart";
import "package:waywing/util/derived_value_notifier.dart";

class BatteryFeather extends Feather {
  late BatteryService service;

  BatteryFeather._();

  static void registerFeather(RegisterFeatherCallback<BatteryFeather, void> registerFeather) {
    registerFeather(
      "Battery",
      FeatherRegistration(
        constructor: BatteryFeather._,
      ),
    );
  }

  @override
  String get name => "Battery";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<BatteryService>(this);
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([batteryComponent]);

  late final batteryComponent = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        BatteryWidget(values: BatteryValues(service.displayDevice)),
      ];
    },
  );
}
