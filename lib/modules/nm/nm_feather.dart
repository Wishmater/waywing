import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:nm/nm.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/widgets/nm_indicator.dart";
import "package:waywing/modules/nm/widgets/nm_popover.dart";
import "package:waywing/modules/nm/service/nm_service.dart";
import "package:waywing/modules/nm/widgets/nm_tooltip.dart";
import "package:waywing/util/derived_value_notifier.dart";

class NetworkManagerFeather extends Feather<NetworkManagerConfig> {
  late NetworkManagerService service;

  NetworkManagerFeather._();

  static void registerFeather(RegisterFeatherCallback<NetworkManagerFeather, NetworkManagerConfig> registerFeather) {
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
  late final ValueListenable<List<FeatherComponent>> components = DerivedValueNotifier(
    dependencies: [service.devices],
    derive: () {
      final result = <FeatherComponent>[];
      for (final device in service.devices.value) {
        result.add(
          FeatherComponent(
            isIndicatorVisible: device.deviceType == NetworkManagerDeviceType.wifi
                ? DummyValueNotifier(true)
                : device.isConnected,
            buildIndicators: (context, popover) {
              return [
                NetworkManagerIndicator(config: config, device: device, popover: popover),
              ];
            },
            isTooltipEnabled: device.isConnected,
            buildTooltip: (context) {
              return NetworkManagerTooltip(config: config, device: device);
            },
            isPopoverEnabled: DummyValueNotifier(device.deviceType == NetworkManagerDeviceType.wifi),
            buildPopover: (context) {
              return NetworkManagerPopover(config: config, device: device as NMServiceWifiDevice);
            },
          ),
        );
      }
      return result;
    },
  );
}
