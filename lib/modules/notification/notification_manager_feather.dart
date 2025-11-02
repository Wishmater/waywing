import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/notification/notification_manager_popover.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class NotificationsManagerFeather extends Feather {
  late final NotificationsService service;

  NotificationsManagerFeather._();

  static void registerFeather(RegisterFeatherCallback<NotificationsManagerFeather, dynamic> registerFeather) {
    registerFeather(
      "NotificationManager",
      FeatherRegistration(
        constructor: NotificationsManagerFeather._,
      ),
    );
  }

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<NotificationsService>(this);
  }

  @override
  String get name => "NotificationManager";

  @override
  ValueListenable<List<FeatherComponent>> get components => DummyValueNotifier([
    FeatherComponent(
      buildIndicators: (context, popoverCtr) {
        return [
          WingedButton(
            child: WingedIcon(
              flutterIcon: SymbolsVaried.notifications,
              iconNames: ["notifications"],
            ),
            onTap: () => popoverCtr?.togglePopover(),
          ),
        ];
      },
      buildPopover: (context) {
        return NotificationManagerPopover(service: service);
      },
    ),
  ]);
}
