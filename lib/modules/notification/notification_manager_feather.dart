import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/notification/notification_manager_popover.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/icons/composed_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_context_menu.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

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
          NotificationManagerIndicator(
            service: service,
            popover: popoverCtr,
          ),
        ];
      },
      buildPopover: (context) {
        return NotificationManagerPopover(service: service);
      },
    ),
  ]);
}

class NotificationManagerIndicator extends StatelessWidget {
  final NotificationsService service;
  final WingedPopoverController? popover;

  const NotificationManagerIndicator({
    required this.service,
    required this.popover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WingedContextMenu(
      itemsBuilder: (context) => [
        WingedContextMenuItem(
          icon: WingedIcon(
            flutterIcon: SymbolsVaried.notifications,
            iconNames: ["notifications"],
          ),
          child: Text("Active"),
          onTap: (menu, _, _) {
            service.status.value = NotificationsStatus.active;
            menu!.hidePopover();
          },
        ),
        WingedContextMenuItem(
          icon: ComposedIcon(
            subiconSize: 0.65,
            subiconAlignment: Alignment.topRight,
            subicon: WingedIcon(
              flutterIcon: SymbolsVaried.do_not_disturb_on,
              iconNames: ["audio-volume-muted"],
            ),
            child: WingedIcon(
              flutterIcon: SymbolsVaried.notifications,
              iconNames: ["notifications"],
            ),
          ),
          child: Text("Silenced"),
          onTap: (menu, _, _) {
            service.status.value = NotificationsStatus.silenced;
            menu!.hidePopover();
          },
        ),
        WingedContextMenuItem(
          icon: ComposedIcon(
            subiconSize: 0.65,
            subiconAlignment: Alignment.topRight,
            subicon: WingedIcon(
              flutterIcon: SymbolsVaried.do_not_disturb_alt,
              iconNames: ["media-playback-stop"],
            ),
            child: WingedIcon(
              flutterIcon: SymbolsVaried.notifications,
              iconNames: ["notifications"],
            ),
          ),
          child: Text("Do not disturb"),
          onTap: (menu, _, _) {
            service.status.value = NotificationsStatus.dnd;
            menu!.hidePopover();
          },
        ),
      ],
      builder: (context, menu, child) {
        return WingedButton(
          onTap: (_, _) => popover?.togglePopover(),
          onSecondaryTap: (downDetails, upDetails) => menu.togglePopover(localPosition: upDetails.localPosition),
          child: ValueListenableBuilder(
            valueListenable: service.status,
            builder: (context, status, _) {
              // TODO: 3 add linux/text icon varieties
              // TODO: 2 ANIMATIONS: add animation to icon change
              // TODO: 2 show a different icon when there are unread notifications?
              return switch (status) {
                NotificationsStatus.active => WingedIcon(
                  flutterIcon: SymbolsVaried.notifications,
                  iconNames: ["notifications"],
                ),
                NotificationsStatus.silenced => ComposedIcon(
                  subiconSize: 0.65,
                  subiconAlignment: Alignment.topRight,
                  subicon: WingedIcon(
                    flutterIcon: SymbolsVaried.do_not_disturb_on,
                    iconNames: ["audio-volume-muted"],
                  ),
                  child: WingedIcon(
                    flutterIcon: SymbolsVaried.notifications,
                    iconNames: ["notifications"],
                  ),
                ),
                NotificationsStatus.dnd => ComposedIcon(
                  subiconSize: 0.65,
                  subiconAlignment: Alignment.topRight,
                  subicon: WingedIcon(
                    flutterIcon: SymbolsVaried.do_not_disturb_alt,
                    iconNames: ["media-playback-stop"],
                  ),
                  child: WingedIcon(
                    flutterIcon: SymbolsVaried.notifications,
                    iconNames: ["notifications"],
                  ),
                ),
              };
            },
          ),
        );
      },
    );
  }
}
