import "dart:async";

import "package:flutter/widgets.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";

class TimeService extends Service {
  late final ValueNotifier<DateTime> time;
  late final Timer _timer;

  TimeService._();

  static registerService(RegisterServiceCallback registerService) {
    registerService<TimeService, dynamic>(
      ServiceRegistration(
        constructor: TimeService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    time = ValueNotifier(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time.value = DateTime.now();
    });
  }

  @override
  Future<void> dispose() async {
    _timer.cancel();
  }
}
