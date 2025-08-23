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
  onConfigUpdated(VolumeConfig oldConfig) {
    super.onConfigUpdated(oldConfig);
    if (oldConfig.showSeparateMicIndicator != config.showSeparateMicIndicator) {
      _components.value = _buildComponents();
      _components._manualNotifyListeners();
    }
  }

  @override
  ValueListenable<List<FeatherComponent>> get components => _components;
  late final _components = _ManualValueNotifier(_buildComponents());

  List<FeatherComponent> _buildComponents() {
    if (config.showSeparateMicIndicator) {
      return [
        _buildComponent(VolumeIndicatorType.input),
        _buildComponent(VolumeIndicatorType.output),
      ];
    } else {
      return [_buildComponent(VolumeIndicatorType.single)];
    }
  }

  FeatherComponent _buildComponent(VolumeIndicatorType type) {
    return FeatherComponent(
      buildIndicators: (context, popover, tooltip) {
        return [
          VolumeIndicator(
            config: config,
            service: service,
            popover: popover!,
            type: type,
          ),
        ];
      },
      buildTooltip: (context) {
        return VolumeTooltip(
          service: service,
          config: config,
          type: type,
        );
      },
      buildPopover: (context) {
        return VolumePopover(
          service: service,
          config: config,
          type: type,
        );
      },
    );
  }
}

class _ManualValueNotifier<T> extends ValueNotifier<T> {
  _ManualValueNotifier(super.value);

  void _manualNotifyListeners() {
    notifyListeners();
  }
}
