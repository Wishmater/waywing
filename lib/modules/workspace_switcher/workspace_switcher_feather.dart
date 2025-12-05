import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/services/compositors/compositor.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "workspace_switcher_indicator.dart";

class WorkspaceSwitcherFeather extends Feather {
  WorkspaceSwitcherFeather._();

  static void registerFeather(RegisterFeatherCallback<WorkspaceSwitcherFeather, dynamic> registerFeather) {
    registerFeather(
      "WorkspaceSwitcher",
      FeatherRegistration(
        constructor: WorkspaceSwitcherFeather._,
      ),
    );
  }

  @override
  String get name => "WorkspaceSwitcher";

  late final CompositorService service;

  @override
  Future<void> init(BuildContext _) async {
    service = await serviceRegistry.requestService<CompositorService>(this);
    if (!service.supportWorkspaces) throw Exception("workspaces not supported by ${service.runtimeType}");
  }

  @override
  // TODO: implement components
  late ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      buildIndicators: (context, _) {
        return [WorkspaceSwitcherIndicator(service: service)];
      },
    ),
  ]);
}
