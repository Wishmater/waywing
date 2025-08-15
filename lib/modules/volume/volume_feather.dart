import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/volume/volume_widget.dart";
import "package:waywing/modules/volume/voulme_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_button.dart";

class VolumeFeather extends Feather {
  late VolumeService service;
  VolumeFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "Volume",
      FeatherRegistration(
        constructor: VolumeFeather._,
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
        WingedButton(
          onTap: () => popover!.togglePopover(),
          child: VolumeWidget(service: service),
        ),
      ];
    },
    buildPopover: (context) {
      return VolumePopover(service: service);
    },
  );
}
