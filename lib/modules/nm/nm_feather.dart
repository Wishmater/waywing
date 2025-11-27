import "package:dartx/dartx_io.dart";
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
import "package:waywing/util/state_positioning.dart";

class NetworkManagerFeather extends Feather<NetworkManagerConfig> {
  late NetworkManagerService service;
  late ManualNotifier configChangeNotifier;

  NetworkManagerFeather._();

  static void registerFeather(RegisterFeatherCallback<NetworkManagerFeather, NetworkManagerConfig> registerFeather) {
    registerFeather(
      "NetworkManager",
      FeatherRegistration(
        constructor: NetworkManagerFeather._,
        schemaBuilder: () => NetworkManagerConfig.schema,
        configBuilder: NetworkManagerConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "NetworkManager";

  @override
  Future<void> init(BuildContext context) async {
    configChangeNotifier = ManualNotifier();
    service = await serviceRegistry.requestService<NetworkManagerService>(this);
  }

  @override
  Future<void> dispose() async {
    configChangeNotifier.dispose();
    super.dispose();
  }

  @override
  void onConfigUpdated(NetworkManagerConfig _) {
    configChangeNotifier.manualNotifyListeners();
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DerivedValueNotifier(
    dependencies: [service.devices, configChangeNotifier],
    derive: () {
      final result = <FeatherComponent>[];
      final seenDeviceCounts = <NetworkManagerDeviceType, int>{};
      for (final device in service.devices.value) {
        if (config.deviceTypeFilter.contains(device.deviceType.name)) {
          continue;
        }
        String deviceUniqueId = device.path;
        if (deviceUniqueId.isBlank) {
          final seenCount = seenDeviceCounts[device.deviceType] ?? 0;
          deviceUniqueId = "${device.deviceType.name}[$seenCount]";
          seenDeviceCounts[device.deviceType] = seenCount + 1;
        }
        result.add(
          FeatherComponent(
            uniqueIdentifier: "$uniqueId - $deviceUniqueId",
            isIndicatorEnabled: device.deviceType == NetworkManagerDeviceType.wifi
                ? DummyValueNotifier(true)
                : device.isConnected,
            buildIndicators: (context, popover) {
              return [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isVertical = constraints.maxHeight > constraints.maxWidth;
                    return RepaintBoundary(
                      child: RememberMaxSize(
                        constraints: constraints,
                        alignment: isVertical ? Alignment.topCenter : Alignment.centerLeft,
                        child: NetworkManagerIndicator(
                          service: service,
                          config: config,
                          device: device,
                          popover: popover,
                        ),
                      ),
                    );
                  },
                ),
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
