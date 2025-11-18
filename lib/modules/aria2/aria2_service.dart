import "dart:async";
import "dart:convert";

import "package:aria2c/aria2cWebSocketRPC.dart";
import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/foundation.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/aria2/models/task.dart";
import "package:waywing/util/derived_value_notifier.dart";

part "aria2_service.config.dart";

class Aria2Service extends Service<Aria2ServiceConfig> {
  late final Aria2cWebSocketRPC _rpc;
  late final Timer _timer;

  ValueListenable<int> get downloadSpeed => _downloadSpeed;
  late final ValueNotifier<int> _downloadSpeed;
  ValueListenable<int> get uploadSpeed => _uploadSpeed;
  late final ValueNotifier<int> _uploadSpeed;

  ValueListenable<int> get numActive => _numActive;
  late final ValueNotifier<int> _numActive;
  ValueListenable<int> get numWaiting => _numWaiting;
  late final ValueNotifier<int> _numWaiting;
  ValueListenable<int> get numStopped => _numStopped;
  late final ValueNotifier<int> _numStopped;
  ValueListenable<int> get numStoppedTotal => _numStoppedTotal;
  late final ValueNotifier<int> _numStoppedTotal;

  ValueListenable<List<Aria2Task>> get activeTasks => _activeTasks;
  late final ManualValueNotifier<List<Aria2Task>> _activeTasks;
  ValueListenable<List<Aria2Task>> get waitingTasks => _waitingTasks;
  late final ManualValueNotifier<List<Aria2Task>> _waitingTasks;
  ValueListenable<List<Aria2Task>> get stoppedTasks => _stoppedTasks;
  late final ManualValueNotifier<List<Aria2Task>> _stoppedTasks;
  ValueListenable<List<Aria2Task>> get allTasks => _allTasks;
  late final LazyManualValueNotifier<List<Aria2Task>> _allTasks;

  Aria2Service._();

  static registerService(RegisterServiceCallback registerService) {
    registerService<Aria2Service, dynamic>(
      ServiceRegistration(
        constructor: Aria2Service._,
        schemaBuilder: () => Aria2ServiceConfig.schema,
        configBuilder: Aria2ServiceConfig.fromBlock,
      ),
    );
  }

  @override
  Future<void> init() async {
    _rpc = Aria2cWebSocketRPC(
      Uri.parse(config.rpcUri),
      rpcSecret: config.rpcSecret ?? "",
    );
    await _rpc.connect();

    // get initial values
    final globalStatResponse = await _rpc.getGlobalStat();
    if (globalStatResponse["result"] == null) {
      final formattedResponse = JsonEncoder.withIndent("    ").convert(globalStatResponse);
      throw Exception("Received error response from aria2 rpc:\n$formattedResponse");
    }
    final globalStat = globalStatResponse["result"] as Map;
    _downloadSpeed = ValueNotifier(int.parse(globalStat["downloadSpeed"]));
    _uploadSpeed = ValueNotifier(int.parse(globalStat["uploadSpeed"]));
    _numActive = ValueNotifier(int.parse(globalStat["numActive"]));
    _numWaiting = ValueNotifier(int.parse(globalStat["numWaiting"]));
    _numStopped = ValueNotifier(int.parse(globalStat["numStopped"]));
    _numStoppedTotal = ValueNotifier(int.parse(globalStat["numStoppedTotal"]));
    _activeTasks = ManualValueNotifier(await _getActiveTasks());
    _waitingTasks = ManualValueNotifier(await _getWaitingTasks());
    _stoppedTasks = ManualValueNotifier(await _getStoppedTasks());
    _allTasks = LazyManualValueNotifier(
      // dependencies: [_activeTasks, _waitingTasks, _stoppedTasks], // we don't want this to listen to single lists, so we can know when UI is listening
      () => [..._activeTasks.value, ..._waitingTasks.value, ..._stoppedTasks.value],
    );

    // initialize timer to update values
    // TODO: 2 add an option to set update timer delay
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      final globalStatResponse = await _rpc.getGlobalStat();
      if (globalStatResponse["result"] == null) {
        final formattedResponse = JsonEncoder.withIndent("    ").convert(globalStatResponse);
        throw Exception("Received error response from aria2 rpc:\n$formattedResponse");
      }
      final globalStat = globalStatResponse["result"] as Map;
      logger.trace("GlobalStat: $globalStat");
      _downloadSpeed.value = int.parse(globalStat["downloadSpeed"]);
      _uploadSpeed.value = int.parse(globalStat["uploadSpeed"]);
      _numActive.value = int.parse(globalStat["numActive"]);
      _numWaiting.value = int.parse(globalStat["numWaiting"]);
      _numStopped.value = int.parse(globalStat["numStopped"]);
      _numStoppedTotal.value = int.parse(globalStat["numStoppedTotal"]);
      // ignore: invalid_use_of_protected_member
      if (_activeTasks.hasListeners) {
        _activeTasks.value = await _getActiveTasks();
        _activeTasks.manualNotifyListeners();
        _allTasks.manualNotifyListeners();
      }
      // ignore: invalid_use_of_protected_member
      if (_activeTasks.hasListeners) {
        _waitingTasks.value = await _getWaitingTasks();
        _waitingTasks.manualNotifyListeners();
        _allTasks.manualNotifyListeners();
      }
      // ignore: invalid_use_of_protected_member
      if (_activeTasks.hasListeners) {
        _stoppedTasks.value = await _getStoppedTasks();
        _stoppedTasks.manualNotifyListeners();
        _allTasks.manualNotifyListeners();
      }
    });
  }

  Future<List<Aria2Task>> _getActiveTasks() async {
    final query = await _rpc.tellActive();
    return (query["result"] as List).map((e) => Aria2Task.fromJson(e)).toList();
  }

  Future<List<Aria2Task>> _getWaitingTasks() async {
    final query = await _rpc.tellWaiting(0, 999999999);
    return (query["result"] as List).map((e) => Aria2Task.fromJson(e)).toList();
  }

  Future<List<Aria2Task>> _getStoppedTasks() async {
    final query = await _rpc.tellStopped(0, 999999999);
    return (query["result"] as List).map((e) => Aria2Task.fromJson(e)).toList();
  }

  @override
  Future<void> dispose() async {
    _timer.cancel();
    // TODO: 2 there is no method to dispose the socket??
  }
}

@Config()
mixin Aria2ServiceConfigBase on Aria2ServiceConfigI {
  static const _rpcUri = StringField();
  static const _rpcSecret = StringField(nullable: true);
}
