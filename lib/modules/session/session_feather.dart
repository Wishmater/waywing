import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/session/os_info_service.dart";
import "package:waywing/modules/session/session_service.dart";
import "package:waywing/widgets/icons/text_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class SessionFeather extends Feather {
  late SessionService service;
  late OsInfoService osInfoService;

  SessionFeather._();

  static void registerFeather(RegisterFeatherCallback<SessionFeather, void> registerFeather) {
    registerFeather(
      "Session",
      FeatherRegistration(constructor: SessionFeather._),
    );
  }

  @override
  String get name => "Session";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<SessionService>(this);
    osInfoService = await serviceRegistry.requestService<OsInfoService>(this);
  }

  @override
  ValueListenable<List<FeatherComponent>> get components => ValueNotifier([sessionComponent]);

  late final sessionComponent = FeatherComponent(
    buildIndicators: (context, popover) {
      final allowFlutterFallback = mainConfig.theme.iconPriority.contains(IconType.flutter);
      final priorities = [
        ...mainConfig.theme.iconPriority.where((e) => e != IconType.flutter),
        if (allowFlutterFallback) IconType.flutter, // make sure flutter is the last option for this
      ];
      return [
        WingedButton(
          onTap: () => popover!.togglePopover(),
          child: WingedIcon(
            iconNames: ["distributor-logo-${osInfoService.osId}"],
            textIcon: osInfoService.osIcon,
            flutterIcon: SymbolsVaried.power_settings_new,
            iconPriorities: priorities,
            // TODO: 3 won't this override the fallback mechanism if the text glyph is not found?
            textIconBuilder: (context) => TextIcon(
              text: osInfoService.osIcon!,
              alignment: Alignment.centerLeft, // assumes the icons are aspectRatio=1
            ),
          ),
        ),
      ];
    },
    buildPopover: (context) {
      final children = <Widget>[];
      if (service.canLock) {
        children.add(
          WingedButton(
            child: WingedIcon(
              flutterIcon: SymbolsVaried.lock,
              iconNames: ["system-lock-screen"],
              textIcon: "󰌾", // nf-md-lock
            ),
            onTap: () => service.lock(),
          ),
        );
      }
      if (service.canSleep.canDo) {
        children.add(
          WingedButton(
            child: WingedIcon(
              flutterIcon: SymbolsVaried.do_not_disturb_on,
              iconNames: ["system-suspend"],
              textIcon: "󰒲", // nf-md-sleep
            ),
            onTap: () => {}, // service.sleep(),
          ),
        );
      }
      if (service.canSuspend.canDo) {
        children.add(
          WingedButton(
            child: WingedIcon(
              flutterIcon: SymbolsVaried.mode_standby,
              iconNames: ["system-suspend-hibernate"],
              textIcon: "", // nf-fa-circle_dot
            ),
            onTap: () => {}, // service.suspend(),
          ),
        );
      }
      if (service.canPowerOff.canDo) {
        children.add(
          WingedButton(
            child: WingedIcon(
              flutterIcon: SymbolsVaried.mode_off_on,
              iconNames: ["system-shutdown"],
              textIcon: "󰐥", // nf-md-power
            ),
            onTap: () => {}, // service.powerOff(),
          ),
        );
      }
      return SizedBox(height: 200, width: 200, child: Column(children: children));
    },
  );
}
