import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/hyprland/hyprland_service.dart";
import "package:waywing/modules/workspace_switcher/workspace_switcher_indicator.dart";
import "package:waywing/modules/workspace_switcher/workspace_switcher_provider.dart";
import "package:waywing/util/derived_value_notifier.dart";

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

  late final IWorkspaceSwitcherProvider provider;

  @override
  Future<void> init(BuildContext _) async {
    // TODO: check if we are on hyprland
    final hyprlandService = await serviceRegistry.requestService<HyprlandService>(this);
    provider = HyprlandWorkspaceSwitcherProvider(hyprlandService);
  }

  @override
  // TODO: implement components
  late ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([
    FeatherComponent(
      buildIndicators: (context, _) {
        return [WorkspaceSwitcherIndicator(provider: provider)];
      },
    ),
  ]);
}
