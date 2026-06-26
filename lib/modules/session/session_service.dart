import "dart:async";
import "dart:convert";
import "dart:io" as io;

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dbus/dbus.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/session/specs/login1.dart";
import "package:waywing/modules/session/specs/login1.session.dart";

part "session_service.config.dart";

enum CanAction {
  yes,
  challenge,
  no,
  na;

  bool get canDo => this == yes || this == challenge;

  static CanAction fromString(String response) {
    return switch (response) {
      "yes" => yes,
      "challenge" => challenge,
      "no" => no,
      "na" => na,
      String() => na,
    };
  }
}

enum SleepState { sleeping, awaking }

class SessionService extends Service<SessionServiceConfig> {
  final StreamController<SleepState> _preparingForSleepController;
  late final StreamSubscription<OrgFreedesktopLogin1ManagerPrepareForSleep> _prepareForSleepSubscription;
  Stream<SleepState> get preparingForSleep => _preparingForSleepController.stream;

  SessionService._() : _preparingForSleepController = StreamController.broadcast();

  static registerService(RegisterServiceCallback registerService) {
    registerService<SessionService, SessionServiceConfig>(
      ServiceRegistration(
        constructor: SessionService._,
        configBuilder: SessionServiceConfig.fromBlock,
        schemaBuilder: () => SessionServiceConfig.schema,
      ),
    );
  }

  late DBusClient _client;
  late final OrgFreedesktopLogin1Manager _manager;
  OrgFreedesktopLogin1Session? _session;

  late final String name;

  late CanAction canLock;

  late CanAction canSleep;
  late CanAction canReboot;
  late CanAction canPowerOff;

  @override
  Future<void> init() async {
    _client = DBusClient.system();
    _manager = OrgFreedesktopLogin1Manager(
      _client,
      "org.freedesktop.login1",
      DBusObjectPath("/org/freedesktop/login1"),
    );

    canLock = await _canLockSession();
    canSleep = config.sleepCommand == null ? CanAction.fromString(await _manager.callCanSleep()) : CanAction.yes;
    canReboot = config.rebootCommand == null ? CanAction.fromString(await _manager.callCanReboot()) : CanAction.yes;
    canPowerOff = config.poweroffCommand != null
        ? CanAction.fromString(await _manager.callCanPowerOff())
        : CanAction.yes;

    _prepareForSleepSubscription = _manager.prepareForSleep.listen((v) {
      logger.debug("Prepare for sleep event with value $v");
      _preparingForSleepController.add(v.start ? SleepState.sleeping : SleepState.awaking);
    });
  }

  Future<CanAction> _canLockSession() async {
    if (config.lockCommand != null) {
      return CanAction.yes;
    }
    try {
      final sessionPath = await _getSessionPath();
      _session = OrgFreedesktopLogin1Session(_client, "org.freedesktop.login1", sessionPath);
      if (await _session!.getCanLock()) {
        return CanAction.yes;
      } else {
        return CanAction.no;
      }
    } catch (e) {
      logger.warning("Error while getting logind session", error: e);
      return CanAction.no;
    }
  }

  Future<DBusObjectPath> _getSessionPath() async {
    final methods = <(String, Future<DBusObjectPath> Function())>[
      ("GetSessionByPID", () async => _manager.callGetSessionByPID(io.pid)),
      ("XDG_SESSION_ID", _tryXdgSessionId),
      ("ListSessions", _tryListSessions),
    ];

    final errors = <String, Object>{};
    for (final (name, method) in methods) {
      try {
        final path = await method();
        logger.trace("Got logind session via $name");
        return path;
      } catch (e) {
        errors[name] = e;
      }
    }

    final parts = errors.entries.map((e) => "${e.key}: ${e.value}").join("; ");
    throw Exception("All logind session methods failed: $parts");
  }

  Future<DBusObjectPath> _tryXdgSessionId() async {
    final sessionId = io.Platform.environment["XDG_SESSION_ID"];
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception("XDG_SESSION_ID not set");
    }
    return _manager.callGetSession(sessionId);
  }

  Future<DBusObjectPath> _tryListSessions() async {
    final user = io.Platform.environment["USER"] ?? io.Platform.environment["LOGNAME"];
    if (user == null || user.isEmpty) {
      throw Exception("USER/LOGNAME environment variable not set");
    }

    final sessions = await _manager.callListSessions();
    for (final session in sessions) {
      if (session.length >= 3 && session[2].asString() == user) {
        return session[4].asObjectPath();
      }
    }
    throw Exception("No session found for user $user");
  }

  @override
  Future<void> dispose() async {
    await Future.wait([
      _preparingForSleepController.close(),
      _prepareForSleepSubscription.cancel(),
      _client.close(),
    ]);
  }

  Future<void> lock() async {
    if (canLock == CanAction.na || canLock == CanAction.no) {
      return;
    }
    if (config.lockCommand != null) {
      await _runCmd(config.lockCommand!, "lock");
    } else {
      await _session!.callLock();
    }
  }

  Future<void> sleep() async {
    if (canSleep == CanAction.na || canSleep == CanAction.no) {
      return;
    }
    if (config.sleepCommand != null) {
      await _runCmd(config.sleepCommand!, "sleep");
    } else {
      await _manager.callSleep(0);
    }
  }

  Future<void> reboot() async {
    if (canReboot == CanAction.na || canReboot == CanAction.no) {
      return;
    }
    if (config.rebootCommand != null) {
      await _runCmd(config.rebootCommand!, "reboot");
    } else {
      await _manager.callReboot(true);
    }
  }

  Future<void> powerOff() async {
    logger.trace("called powerOff()");
    if (canPowerOff == CanAction.na || canPowerOff == CanAction.no) {
      logger.trace("called powerOff() but no action was taken");
      return;
    }
    if (config.poweroffCommand != null) {
      await _runCmd(config.poweroffCommand!, "poweroff");
    } else {
      await _manager.callPowerOff(true);
    }
  }

  Future<void> _runCmd(List<String> cmd, String label) async {
    assert(cmd.isNotEmpty);
    final io.ProcessResult result;
    if (cmd.length == 1) {
      result = await io.Process.run(cmd[0], [], stdoutEncoding: utf8, stderrEncoding: utf8);
    } else {
      result = await io.Process.run(cmd[0], cmd.sublist(1), stdoutEncoding: utf8, stderrEncoding: utf8);
    }
    if (result.exitCode != 0) {
      logger.error(
        "Running command ${cmd.join(' ')} for $label but exit code was ${result.exitCode}",
        error: (result.stderr as String).isNotEmpty ? result.stderr : result.stdout,
      );
    }
  }
}

@Config()
mixin SessionServiceConfigBase {
  /// The command used to lock the screen, if this is not set then the
  /// systemd integration will be used
  static const _lockCommand = ListField(StringField(), nullable: true);

  /// The command used to put the device to sleep, if this is not set then the
  /// systemd integration will be used
  static const _sleepCommand = ListField(StringField(), nullable: true);

  /// The command used to reboot the device, if this is not set then the
  /// systemd integration will be used
  static const _rebootCommand = ListField(StringField(), nullable: true);

  /// The command used to shutdown the device, if this is not set then the
  /// systemd integration will be used
  static const _poweroffCommand = ListField(StringField(), nullable: true);
}
