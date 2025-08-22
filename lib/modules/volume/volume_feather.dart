import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/volume/volume_config.dart";
import "package:waywing/modules/volume/volume_indicator.dart";
import "package:waywing/modules/volume/volume_popover.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/modules/volume/volume_tooltip.dart";
import "package:waywing/util/derived_value_notifier.dart";

class VolumeFeather extends Feather<VolumeConfig> {
  late VolumeService service;
  VolumeFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "Volume",
      FeatherRegistration(
        constructor: VolumeFeather._,
        schemaBuilder: () => VolumeConfig.schema,
        configBuilder: VolumeConfig.fromMap,
      ),
    );
  }

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<VolumeService>(this);
  }

  @override
  String get name => "Volume";

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([volumeComponent]);

  late final volumeComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        // TODO: 1 implement optional separated indicators for volume and microphone
        VolumeIndicator(config: config, service: service, popover: popover!),
      ];
    },
    buildTooltip: (context) {
      return VolumeTooltip(service: service);
    },
    buildPopover: (context) {
      return VolumePopover(service: service);
    },
  );
}
