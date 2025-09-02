import "dart:async";

import "package:flutter/material.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/notification/notification_config.dart";
import "package:waywing/modules/notification/notification_service.dart";
import "package:waywing/modules/notification/notification_widget.dart";

class NotificationsWing extends Wing<NotificationsConfig> {
  late NotificationService service;

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
    service = await serviceRegistry.requestService<NotificationService>(this);
  }

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    // TODO: 1 apply rerservedSpace in Notifications
    return Positioned(
      width: 300,
      left: 10,
      top: 30,
      child: NotificationsWidget(service: service),
    );
  }
}
