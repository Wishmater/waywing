import "package:flutter/cupertino.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/modules/nm/nm_widget.dart";
import "package:waywing/widgets/winged_flat_button.dart";

class NetworkManagerFeather extends Feather {
  late Logger logger;
  NetworkManagerFeather._();

  @override
  List<FeatherComponent> get components => [networkManagerComponent];

  late NetworkManagerService service;

  @override
  Future<void> init(BuildContext context, Logger logger) async {
    this.logger = logger;
    service = await serviceRegistry.requestService<NetworkManagerService>(this);
  }

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather("NetworkManager", NetworkManagerFeather._);
  }

  @override
  String get name => "NetworkManager";

  late final networkManagerComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        WingedFlatButton(
          onTap: () => popover!.togglePopover(),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: NetworkManagerWidget(service: service, wifi: service.getWirelessDevice()!),
          ),
        ),
      ];
    },

    buildPopover: (context) => NetworkManagerPopover(service: service, wifi: service.getWirelessDevice()!),
  );
}
