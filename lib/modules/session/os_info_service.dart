import "dart:async";
import "dart:io";

import "package:dartx/dartx.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";

class OsInfoService extends Service {
  OsInfoService._();

  String? osId;
  String? osName;
  String? osIcon;
  String? logo;

  static registerService(RegisterServiceCallback registerService) {
    registerService<OsInfoService, dynamic>(
      ServiceRegistration(
        constructor: OsInfoService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    List<String> lines;
    try {
      lines = await File("/etc/os-release").readAsLines();
    } catch (e, st) {
      logger.log(Level.error, "Failed to reas file /etc/os-release", error: e, stackTrace: st);
      return;
    }

    // get osId
    final idLine = lines.firstOrNullWhere((l) => l.startsWith("ID="));
    if (idLine != null && idLine.contains("=")) {
      osId = idLine.split("=")[1];
    } else {
      logger.log(Level.warning, "Failed to parse osId");
    }

    // get osIcon
    if (osId != null && osIconsMap.containsKey(osId)) {
      osIcon = osIconsMap[osId]!;
    } else {
      String? osIdLike = lines.firstOrNullWhere((l) => l.startsWith("ID_LIKE="));
      if (osIdLike != null) {
        for (final id in osIdLike.split(" ")) {
          if (osIconsMap.containsKey(id)) {
            osIcon = osIconsMap[id]!;
            break;
          }
        }
      }
    }
    if (osIcon == null) {
      logger.log(Level.warning, "Failed to parse osIcon for osId: $osId");
    }

    // get osName
    String? nameLine = lines.firstOrNullWhere((l) => l.startsWith("PRETTY_NAME="));
    if (nameLine == null || nameLine.isEmpty) {
      logger.log(Level.info, "Couldn't find line PRETTY_NAME, trying to get name from line NAME");
      nameLine = lines.firstOrNullWhere((l) => l.startsWith("NAME="));
    }
    if (nameLine != null && nameLine.contains("=")) {
      osName = nameLine.split("=")[1];
      osName = osName!.substring(1, osName!.length - 1);
    }
    if (osName == null) {
      logger.log(Level.warning, "Failed to parse osName");
    }

    // get LOGO
    String? logoLine = lines.firstOrNullWhere((l) => l.startsWith("LOGO="));
    if (logoLine == null || !logoLine.contains("=")) {
      logger.log(Level.warning, "Failed to parse logo");
    } else {
      logo = logoLine.split("=")[1].trim();
      if (logo!.startsWith('"')) logo = logo!.substring(1);
      if (logo!.endsWith('"')) logo = logo!.substring(0, logo!.length - 1);
    }
  }

  @override
  Future<void> dispose() async {}

  static const osIconsMap = {
    "almalinux": "",
    "alpine": "",
    "arch": "",
    "archcraft": "",
    "arcolinux": "",
    "artix": "",
    "centos": "",
    "debian": "",
    "devuan": "",
    "elementary": "",
    "endeavouros": "",
    "fedora": "",
    "freebsd": "",
    "garuda": "",
    "gentoo": "",
    "hyperbola": "",
    "kali": "",
    "linuxmint": "󰣭",
    "mageia": "",
    "openmandriva": "",
    "manjaro": "",
    "neon": "",
    "nixos": "",
    "opensuse": "",
    "suse": "",
    "sles": "",
    "sles_sap": "",
    "opensuse-tumbleweed": "",
    "parrot": "",
    "pop": "",
    "raspbian": "",
    "rhel": "",
    "rocky": "",
    "slackware": "",
    "solus": "",
    "steamos": "",
    "tails": "",
    "trisquel": "",
    "ubuntu": "",
    "vanilla": "",
    "void": "",
    "zorin": "",
  };
}
