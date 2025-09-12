import "dart:io";

import "package:dbus/dbus.dart";
import "package:path/path.dart" as path;
import "package:json_annotation/json_annotation.dart";
import "package:waywing/modules/application-launcher/packages/freedesktop_entry/freedesktop_entry.dart";

part "application.g.dart";

typedef Key = DesktopEntryKey;

@JsonSerializable()
class Application {
  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
  factory Application.fromJson(Map<String, dynamic> json) => _$ApplicationFromJson(json);

  /// Application name
  final String name;

  /// Additional information about the application that the desktop file entry may provide
  final String? comment;

  /// Icon to display on the ListTile widget. If the value is an absolute path,
  /// the given file will be used. If the value is not an absolute path,
  /// the algorithm described in the
  /// [Icon Theme Specification](https://specifications.freedesktop.org/icon-theme-spec/latest/)
  /// will be used to locate the icon
  final String? icon;
  // String? iconPath;

  /// A list of strings identifying the desktop environments that
  /// should display/not display a given desktop entry.
  final List<String>? onlyShownIn;

  /// A list of strings identifying the desktop environments that
  /// should display/not display a given desktop entry.
  final List<String>? notShownIn;

  /// A boolean value specifying if D-Bus activation is supported for this application.
  /// If this key is missing, the default value is false.
  /// If the value is true then implementations should ignore the Exec key
  /// and send a D-Bus message to launch the application.
  /// See D-Bus Activation for more information on how this works.
  /// Applications should still include Exec= lines in their desktop files
  /// for compatibility with implementations that do not understand the DBusActivatable key.
  final bool dBusActivatable;

  /// Path to an executable file on disk used to determine if the program is actually installed.
  /// If the path is not an absolute path, the file is looked up in the $PATH environment variable.
  /// If the file is not present or if it is not executable,
  /// the entry may be ignored (not be used in menus, for example).
  final String? tryExec;

  /// Program to execute, possibly with arguments.
  /// See the [Exec key](https://specifications.freedesktop.org/desktop-entry-spec/latest/exec-variables.html)
  /// for details on how this key works.
  /// The Exec key is required if DBusActivatable is not set to true.
  final String? exec;

  /// Whether the program runs in a terminal window.
  final bool terminal;

  /// Categories in which the application place. Possible values are:
  /// AudioVideo, Audio, Video, Development, Education, Game, Graphics, Network
  /// Office, Science, Settings, System, Utility
  ///
  /// More details on: https://specifications.freedesktop.org/menu-spec/latest/category-registry.html
  final List<Categories>? categories;

  /// A list of strings which may be used in addition to other metadata to describe this entry.
  final List<String>? keywords;

  /// Last date the file was modified, used for caching
  final DateTime lastModified;

  /// Desktop entry absolute filepath
  final String filepath;

  /// Times this application have been executed
  int timesExec;

  Application({
    required this.name,
    this.exec,
    this.tryExec,
    this.comment,
    this.icon,
    this.categories,
    this.dBusActivatable = false,
    this.terminal = false,
    this.onlyShownIn,
    this.notShownIn,
    this.keywords,
    this.timesExec = 0,
    required this.lastModified,
    required this.filepath,
  });

  // throws ParseApplicationException
  static Application _getAppFromEntries(
    Map<String, String> entries,
    File file,
  ) {
    if (entries[Key.dBusActivatable.string] == null && entries[Key.exec.string] == null) {
      throw DesktopEntryInvalidStateException(InvalidStateEnum.missingExecAndDBusActivatable);
    }

    final name = entries[Key.name.string];
    if (name == null) {
      throw const DesktopEntryInvalidStateException(InvalidStateEnum.missingName);
    }

    final hidden = entries[Key.hidden.string];
    if (hidden?.toLowerCase() == "true") {
      throw const DesktopEntryInvalidStateException(InvalidStateEnum.hidden);
    }
    final noDisplay = entries[Key.noDisplay.string];
    if (noDisplay?.toLowerCase() == "true") {
      throw const DesktopEntryInvalidStateException(InvalidStateEnum.hidden);
    }

    final categories = Categories.fromList(entries[Key.categories.string]?.split(";"));
    final keywords = entries[Key.categories.string]?.split(";");
    return Application(
      name: name,
      exec: entries[Key.exec.string],
      tryExec: entries[Key.tryExec.string],
      comment: entries[Key.comment.string],
      icon: entries[Key.icon.string],
      dBusActivatable: entries[Key.dBusActivatable.string]?.toLowerCase() == "true",
      terminal: entries[Key.terminal.string]?.toLowerCase() == "true",
      categories: categories?.toList(growable: false),
      keywords: keywords,
      notShownIn: entries["NotShowIn"]?.split(";"),
      onlyShownIn: entries["OnlyShownIn"]?.split(";"),
      lastModified: file.statSync().modified,
      filepath: file.absolute.path,
    );
  }

  // throws ParseApplicationException
  static Application parseFromFile(File file) {
    String contents = file.readAsStringSync();

    final desktopEntry = DesktopEntry.parse(contents);
    final local = localization();

    if (local != null) {
      final (lang, country) = local;
      final desktopEntryL = desktopEntry.localize(lang: lang, country: country);

      return _getAppFromEntries(desktopEntryL.entries, file);
    }

    final data = desktopEntry.entries.map((key, value) => MapEntry(key, value.value));
    return _getAppFromEntries(data, file);
  }

  @override
  bool operator ==(covariant Application other) => other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return "Application name: $name filepath: $filepath";
  }

  Future<void> run({bool forceExec = false}) async {
    if (!forceExec && dBusActivatable) {
      String dbusname = path.basename(filepath);
      if (dbusname.endsWith(".desktop")) {
        dbusname = dbusname.substring(0, dbusname.length - ".desktop".length);
      }
      final client = DBusClient.session();
      final pathObject = DBusObjectPath("/${dbusname.replaceAll('.', '/').replaceAll('-', '_')}");
      final remoteObject = DBusRemoteObject(client, name: dbusname, path: pathObject);
      final params = [
        DBusDict(
          DBusSignature.string,
          DBusSignature.variant,
          {
            const DBusString("activation-token"): DBusVariant(
              DBusString(Platform.environment["XDG_ACTIVATION_TOKEN"] ?? ""), // TODO 1: get activation token from user action
            ),
          },
        ),
      ];
      try {
        await remoteObject.callMethod("org.freedesktop.Application", "Activate", params);
      } on DBusMethodResponseException catch (e) {
        if (e is DBusServiceUnknownException) {
          return run(forceExec: true);
        }
        throw Exception("dbus activation error: $e");
      }
    } else {
      if (exec == null) {
        throw Exception("invalid desktop: no exec found when dBusActivable is false");
      }
      final (cmd, args) = parseExec(exec!);
      if (terminal) {
        // TODO increase the list of terminals to launch and also make it configurable
        await Process.start("alacritty", ["-e", cmd, ...args], mode: ProcessStartMode.detached);
      } else {
        await Process.start(cmd, args, mode: ProcessStartMode.detached);
      }
    }
  }
}

enum _ParsingExecState {
  insideQuotes,
  inSpace,
  inWord,
}

(String, List<String>) parseExec(String exec) {
  assert(exec != "");
  List<String> arguments = [];

  int start = 0;
  var state = _ParsingExecState.inSpace;
  for (int i = 0; i < exec.length; i++) {
    final char = exec[i];
    switch (state) {
      case _ParsingExecState.inSpace:
        if (char == '"') {
          start = i + 1;
          state = _ParsingExecState.insideQuotes;
        } else if (isPrintableAndNotSpace(char)) {
          start = i;
          state = _ParsingExecState.inWord;
        }
      case _ParsingExecState.insideQuotes:
        // if char is quotes and the previous char is not backslash
        if (char == '"' && !(i > 0 && exec[i - 1] == "\\")) {
          if (i > start) {
            arguments.add(exec.substring(start, i));
          }
          state = _ParsingExecState.inSpace;
        }
      case _ParsingExecState.inWord:
        if (char == " ") {
          if (i > start) {
            arguments.add(exec.substring(start, i));
          }
          state = _ParsingExecState.inSpace;
        }
    }
  }
  final last = exec.substring(start, exec.length).trim();
  if (last.isNotEmpty) {
    arguments.add(last);
  }
  arguments = arguments.map((e) {
    // match %u but not %%u. This is intended because %% is escaping the %
    e = e.replaceAll(RegExp("[^%]{0,1}%[a-zA-Z]"), "");
    e = e.replaceAll("%%", "%");
    return e;
  }).toList();
  arguments = arguments.where((e) => e != "--" && e.isNotEmpty).toList();
  assert(arguments.isNotEmpty, "empty command while parsing $exec");
  if (arguments.length > 1) {
    return (arguments[0], arguments.sublist(1));
  } else {
    return (arguments[0], []);
  }
}

enum Categories {
  audioVideo("AudioVideo"),
  audio("Audio"),
  video("Video"),
  development("Development"),
  education("Education"),
  game("Game"),
  graphics("Graphics"),
  network("Network"),
  office("Office"),
  science("Science"),
  settings("Settings"),
  system("System"),
  utility("Utility");

  final String value;
  const Categories(this.value);

  static Iterable<Categories>? fromList(List<String>? categoriesStr) {
    if (categoriesStr == null) {
      return null;
    }
    return categoriesStr
        .map(
          (e) => switch (e) {
            "AudioVideo" => Categories.audioVideo,
            "Audio" => Categories.audio,
            "Video" => Categories.video,
            "Development" => Categories.development,
            "Education" => Categories.education,
            "Game" => Categories.game,
            "Graphics" => Categories.graphics,
            "Network" => Categories.network,
            "Office" => Categories.office,
            "Science" => Categories.science,
            "Settings" => Categories.settings,
            "System" => Categories.system,
            "Utility" => Categories.utility,
            String() => null,
          },
        )
        .nonNulls;
  }
}

enum InvalidStateEnum {
  missingExecAndDBusActivatable("exec and dBusActivatable where missing"),
  missingName("name is missing"),
  hidden("application is hidden");

  final String _message;
  const InvalidStateEnum(this._message);

  @override
  String toString() {
    return _message;
  }
}

class DesktopEntryInvalidStateException {
  final InvalidStateEnum state;
  const DesktopEntryInvalidStateException(this.state);

  @override
  String toString() {
    return state.toString();
  }
}

/// Filters out filesystem entities that don't exist.
Iterable<T> whereExists<T extends FileSystemEntity>(Iterable<T> entities) sync* {
  for (T entity in entities) {
    if (entity.existsSync()) {
      yield entity;
    }
  }
}

(String lang, String country)? localization() {
  final localization = Platform.environment["LANG"]?.split(".")[0].split("_");
  if (localization == null || localization.length != 2) {
    return null;
  }
  return (localization[0], localization[1]);
}


bool isPrintableAndNotSpace(String char) {
  assert(char.isNotEmpty);
  assert(char.length == 1);

  final codePoint = char.codeUnitAt(0);

  // C0 controls and DEL (0x00-0x1F, 0x7F) // check for 32 because is space
  if (codePoint <= 32 || codePoint == 127) return false;

  // C1 controls (0x80-0x9F)
  if (codePoint >= 128 && codePoint <= 159) return false;

  // Dont allow space
  if (codePoint == 160) return false;

  // Additional control characters (e.g., line/paragraph separators, formatting)
  if ((codePoint >= 0x2028 && codePoint <= 0x2029) || // Line/Paragraph separators
      (codePoint >= 0x200B && codePoint <= 0x200F) || // Zero-width spaces
      (codePoint >= 0x2060 && codePoint <= 0x2064) || // Invisible formatting
      (codePoint >= 0x2066 && codePoint <= 0x2069)) { // Bidirectional controls
    return false;
  }

  return true;
}
