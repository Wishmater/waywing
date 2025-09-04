import "dart:async";

import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/notification/notification_config.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/notification_widget.dart";
import "package:waywing/widgets/motion_widgets/motion_align.dart";
import "package:waywing/widgets/motion_widgets/motion_positioned.dart";

class NotificationsWing extends Wing<NotificationsConfig> {
  late NotificationsService service;

  NotificationsWing._();

  static void registerFeather(RegisterFeatherCallback registerFeather) {
    registerFeather(
      "Notifications",
      FeatherRegistration(
        constructor: NotificationsWing._,
        schemaBuilder: () => NotificationsConfig.schema,
        configBuilder: NotificationsConfig.fromMap,
      ),
    );
  }

  @override
  String get name => "Notifications";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<NotificationsService>(this);
  }

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    final motion = mainConfig.motions.expressive.spatial.slow;
    return MotionPositioned(
      motion: motion,
      left: config.marginLeft + rerservedSpace.left,
      top: config.marginTop + rerservedSpace.top - NotificationsWidget.spacing / 2,
      right: config.marginRight + rerservedSpace.right,
      bottom: config.marginBottom + rerservedSpace.bottom - NotificationsWidget.spacing / 2,
      child: MotionAlign(
        motion: motion,
        alignment: config.alignment,
        child: SizedBox(
          width: 256 * 1.5,
          child: NotificationsWidget(
            service: service,
            config: config,
          ),
        ),
      ),
    );
  }
}
