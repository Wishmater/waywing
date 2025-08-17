import "dart:io" as io;

import "package:dbus/dbus.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/session/specs/login1.dart";
import "package:waywing/modules/session/specs/login1.session.dart";

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

class SessionService extends Service {
  SessionService._();

  static registerService(RegisterServiceCallback registerService) {
    registerService<SessionService, dynamic>(
      ServiceRegistration(
        constructor: SessionService._,
      ),
    );
  }

  late DBusClient _client;
  late final OrgFreedesktopLogin1Manager _manager;
  late final OrgFreedesktopLogin1Session _session;
  // late final OrgFreedesktopLogin1User _user;

  late final String name;

  late bool canLock;

  late CanAction canHalt;
  late CanAction canHibernate;
  late CanAction canSleep;
  late CanAction canSuspend;
  late CanAction canReboot;
  late CanAction canPowerOff;
  late CanAction canHybridSleep;

  @override
  Future<void> init() async {
    _client = DBusClient.system();
    _manager = OrgFreedesktopLogin1Manager(
      _client,
      "org.freedesktop.login1",
    DBusObjectPath("/org/freedesktop/login1"),
    );
    final sessionPath = await _manager.callGetSessionByPID(io.pid);
    // final userPath = await _manager.callGetSessionByPID(pid);
    _session = OrgFreedesktopLogin1Session(_client, "org.freedesktop.login1", sessionPath);
    // _user = OrgFreedesktopLogin1User(_client, "org.freedesktop.login1", userPath);

    name = await _session.getName();

    canLock = await _session.getCanLock();

    canHalt = CanAction.fromString(await _manager.callCanHalt());
    canHibernate = CanAction.fromString(await _manager.callCanHibernate());
    canSleep = CanAction.fromString(await _manager.callCanSleep());
    canSuspend = CanAction.fromString(await _manager.callCanSuspend());
    canReboot = CanAction.fromString(await _manager.callCanReboot());
    canPowerOff = CanAction.fromString(await _manager.callCanPowerOff());
    canHybridSleep = CanAction.fromString(await _manager.callCanHybridSleep());
  }

  @override
  Future<void> dispose() async {
    _client.close();
  }

  Future<void> lock() async {
    if (!canLock) {
      return;
    }
    await _session.callLock();
  }

  Future<void> halt() async {
    if (canHalt == CanAction.na || canHalt == CanAction.no) {
      return;
    }
    _manager.callHalt(true);
  }

  Future<void> hibernate() async {
    if (canHibernate == CanAction.na || canHibernate == CanAction.no) {
      return;
    }
  }

  Future<void> sleep() async {
    if (canSleep == CanAction.na || canSleep == CanAction.no) {
      return;
    }
    await _manager.callSleep(0);
  }

  Future<void> suspend() async {
    if (canSuspend == CanAction.na || canSuspend == CanAction.no) {
      return;
    }
    await _manager.callSuspend(true);
  }

  Future<void> reboot() async {
    if (canReboot == CanAction.na || canReboot == CanAction.no) {
      return;
    }
    await _manager.callReboot(true);
  }

  Future<void> powerOff() async {
    if (canPowerOff == CanAction.na || canPowerOff == CanAction.no) {
      return;
    }
    await _manager.callPowerOff(true);
  }

  Future<void> hybridSleep() async {
    if (canHybridSleep == CanAction.na || canHybridSleep == CanAction.no) {
      return;
    }
    await _manager.callHybridSleep(true);
  }

}
