import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/session/session_service.dart";
import "package:waywing/widgets/winged_button.dart";

class SessionFeather extends Feather {
  late SessionService service;

  SessionFeather._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
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
  }

  @override
  ValueListenable<List<FeatherComponent>> get components => ValueNotifier([sessionComponent]);

  late final sessionComponent = FeatherComponent(
    buildIndicators: (context, popover, tooltip) {
      return [
        WingedButton(
          onTap: () => popover!.togglePopover(),
          child: Icon(Icons.supervised_user_circle),
        ),
      ];
    },
    buildPopover: (context) {
      final children = <Widget>[];
      if (service.canLock) {
        children.add(
          IconButton(
            icon: Icon(Icons.lock),
            onPressed: () => service.lock(),
          ),
        );
      }
      if (service.canSleep.canDo) {
        children.add(
          IconButton(
            icon: Icon(Icons.do_not_disturb_on_total_silence_sharp),
            onPressed: () => {} // service.sleep(),
          ),
        );
      }
      if (service.canSuspend.canDo) {
        children.add(
          IconButton(
            icon: Icon(Icons.low_priority),
            onPressed: () => {} // service.suspend(),
          ),
        );
      }
      if (service.canPowerOff.canDo) {
        children.add(
          IconButton(
            icon: Icon(Icons.power_off),
            onPressed: () => {} // service.powerOff(),
          ),
        );
      }
      return SizedBox(height: 200, width: 200, child: Column(children: children));
    },
  );
}
