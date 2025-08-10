import "package:flutter/cupertino.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/modules/nm/nm_widget.dart";
import "package:waywing/widgets/winged_button.dart";

class NetworkManagerFeather extends Feather {
  late NetworkManagerService service;

  NetworkManagerFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "NetworkManager",
      FeatherRegistration(
        constructor: NetworkManagerFeather._,
      ),
    );
  }

  @override
  String get name => "NetworkManager";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<NetworkManagerService>(this);
  }

  @override
  List<FeatherComponent> get components => [nmComponent];

  late final nmComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        WingedButton(
          onTap: () => popover!.togglePopover(),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: NetworkManagerWidget(
              logger: logger,
              service: service,
            ),
          ),
        ),
      ];
    },

    buildPopover: (context) => NetworkManagerPopover(
      logger: logger,
      service: service,
    ),
  );
}
