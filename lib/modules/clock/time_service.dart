import "dart:async";

import "package:flutter/widgets.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";

class TimeService extends Service {
  late Logger logger;

  late final ValueNotifier<DateTime> time;
  late final Timer _timer;

  TimeService._();

  static registerService(RegisterServiceCallback registerService) {
    registerService<TimeService>(TimeService._);
  }

  @override
  Future<void> init(Logger logger) async {
    this.logger = logger;
    time = ValueNotifier(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time.value = DateTime.now();
    });
  }

  @override
  Future<void> dispose() async {
    _timer.cancel(); // TODO: 1 maybe the registry should do this so we don't have to ?
    await logger.destroy();
  }
}
