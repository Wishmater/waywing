import "dart:io";

import "package:dartx/dartx_io.dart";
import "package:flutter/widgets.dart";
import "package:tronco/tronco.dart";
import "package:watcher/watcher.dart";

/// Proof of concept of simple txt database ( this is not performant implementation :) )
class NmDatabase {
  final String path;
  final ChangeNotifier notifer;

  NmDatabase(this.path, Logger logger) : notifer = ChangeNotifier() {
    _watch(logger);
  }

  void dispose() {
    notifer.dispose();
  }

  Future<void> _watch(Logger logger) async {
    final dir = File(path).parent;
    await dir.create(recursive: true);
    final w = DirectoryWatcher(dir.absolute.path);
    w.events.listen(
      (event) {
        if (event.path == path) {
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          notifer.notifyListeners();
        }
      },
      onError: (e) {
        logger.error("watching directory error $e");
      },
      cancelOnError: true,
    );
  }

  Set<String> getAll() {
    try {
      final content = File(path).readAsStringSync();
      return content.split("\n").toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> insert(String item) async {
    await File(path).appendString(item);
  }

  Future<void> remove(String item) async {
    final file = File(path).openSync(mode: FileMode.write);
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
