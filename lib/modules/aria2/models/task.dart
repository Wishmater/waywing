import 'package:path/path.dart' as p;

class Aria2Task {
  final String gid;
  final String name;
  final Aria2TaskStatus status;

  final String dir;
  final int totalLength;
  final int completedLength;

  final int connections;
  final int downloadSpeed;
  final int uploadLength;
  final int uploadSpeed;

  final List<Aria2TaskFile> files;

  // TODO: 2 bittorrent-only stuff
  // final List<String> announceList;
  // final Aria2TaskMode mode; // this can pro

  // TODO: 1 test with a non-bittorrent download and see if anything breaks
  const Aria2Task({
    required this.gid,
    required this.name,
    required this.status,
    required this.dir,
    required this.totalLength,
    required this.completedLength,
    required this.connections,
    required this.downloadSpeed,
    required this.uploadLength,
    required this.uploadSpeed,
    required this.files,
    // required this.mode,
  });

  factory Aria2Task.fromJson(Map<String, dynamic> json) {
    final files = (json["files"] as List).map((e) => Aria2TaskFile.fromJson(e)).toList();
    return Aria2Task(
      gid: json["gid"],
      // TODO: 2 maybe take into account several files for fallback name if there are many
      name: json["bittorrent"]?["info"]?["name"] ?? p.basename(files.first.path),
      status: Aria2TaskStatus.fromString(json["status"]),
      dir: json["dir"],
      totalLength: int.parse(json["totalLength"]),
      completedLength: int.parse(json["completedLength"]),
      connections: int.parse(json["connections"]),
      downloadSpeed: int.parse(json["downloadSpeed"]),
      uploadLength: int.parse(json["uploadLength"]),
      uploadSpeed: int.parse(json["uploadSpeed"]),
      files: files,
      // mode: Aria2TaskBittorrentMode.fromString(json["bittorrent"]["mode"]),
    );
  }

  @override
  int get hashCode => gid.hashCode;

  @override
  bool operator ==(Object other) => other is Aria2Task && other.gid == gid;
}

class Aria2TaskFile {
  final int length;
  final int completedLength;
  final String path;
  final bool selected;
  final List<String> uris;

  Aria2TaskFile({
    required this.length,
    required this.completedLength,
    required this.path,
    required this.selected,
    required this.uris,
  });
  factory Aria2TaskFile.fromJson(Map<String, dynamic> json) {
    return Aria2TaskFile(
      length: int.parse(json["length"]),
      completedLength: int.parse(json["completedLength"]),
      path: json["path"],
      selected: json["selected"] == "true",
      uris: (json["uris"] as List).cast<String>(),
    );
  }

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) => other is Aria2TaskFile && other.path == path;
}

enum Aria2TaskBittorrentMode {
  single,
  multi;

  static Aria2TaskBittorrentMode fromString(String value) {
    return switch (value) {
      "single" => single,
      "multi" => multi,
      _ => throw UnimplementedError("Unknown aria2 task mode: $value"),
    };
  }
}

enum Aria2TaskStatus {
  // active
  active,

  // waiting
  waiting,
  paused,

  // stopped
  stopped,
  complete,
  error;

  static Aria2TaskStatus fromString(String value) {
    return switch (value) {
      "active" => active,
      "waiting" => waiting,
      "paused" => paused,
      "stopped" => stopped,
      "complete" => complete,
      "error" => error,
      _ => throw UnimplementedError("Unknown aria2 task status: $value"),
    };
  }
}
