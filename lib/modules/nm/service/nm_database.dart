import "dart:io";

import "package:dartx/dartx_io.dart";
import "package:flutter/widgets.dart";
import "package:tronco/tronco.dart";
import "package:watcher/watcher.dart";

/// Proof of concept of simple txt database ( this is not performant implementation :) )
class NmDatabase extends ChangeNotifier {
  final String path;
  late final file = File(path);

  NmDatabase(this.path, Logger logger) {
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    _watch(logger);
  }

  Future<void> _watch(Logger logger) async {
    final dir = file.parent;
    final w = DirectoryWatcher(dir.absolute.path);
    w.events.listen(
      (event) {
        if (event.path == path) {
          notifyListeners();
        }
      },
      onError: (e) {
        logger.error("Database watching directory error $e");
      },
      cancelOnError: true,
    );
  }

  Set<String> getAll() {
    final content = file.readAsStringSync();
    final result = content.split("\n");
    result.removeLast();
    return result.toSet();
  }

  Future<void> insert(String item) async {
    return file.appendString("$item\n");
  }

  Future<void> remove(String item) async {
    final file = this.file.openSync(mode: FileMode.write);
    file.lockSync();

    _remove(file, item);

    file.unlockSync();
    file.closeSync();
  }

  void _remove(RandomAccessFile file, String item) {
    final len = file.lengthSync();
    file.setPositionSync(0);

    final data = file.readSync(len);
    final list = String.fromCharCodes(data).split("\n");
    if (!list.contains(item)) {
      return;
    }
    list.remove(item);
    file.truncate(0);

    final content = list.join("\n");
    file.writeStringSync(content);
    if (content[content.length - 1] != "\n") {
      file.writeStringSync("\n");
    }
  }
}
