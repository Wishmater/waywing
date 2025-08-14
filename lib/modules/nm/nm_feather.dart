import "package:flutter/cupertino.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/nm_indicator.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/modules/nm/nm_widget.dart";

class NetworkManagerFeather extends Feather<NetworkManagerConfig> {
  late NetworkManagerService service;

  NetworkManagerFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "NetworkManager",
      FeatherRegistration(
        constructor: NetworkManagerFeather._,
        schemaBuilder: () => NetworkManagerConfig.schema,
        configBuilder: NetworkManagerConfig.fromMap,
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
        NetworkManagerIndicator(config: config, service: service, popover: popover!),
      ];
    },
    buildPopover: (context) {
      return NetworkManagerPopover(logger: logger, service: service);
    },
  );
}
