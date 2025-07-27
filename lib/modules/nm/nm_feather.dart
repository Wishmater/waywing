
import "package:flutter/cupertino.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/modules/nm/nm_widget.dart";

class NetworkManagerFeather extends Feather {
  NetworkManagerFeather._();

  @override
  List<FeatherComponent> get components => [networkManagerComponent];

  late NetworkManagerService service;


  @override
  Future<void> init(BuildContext context) async {
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
        NetworkManagerWidget(service: service),
      ];
    },
  );
}
