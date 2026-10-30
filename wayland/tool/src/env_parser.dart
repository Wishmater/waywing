import 'dart:io';

import 'tool.dart';

Map<String, String> readDotEnv(String path) {
  final file = File(path);
  if (!file.existsSync()) return const {};

  final values = <String, String>{};

  final lines = file.readAsLinesSync();
  for (var index = 0; index < lines.length; index++) {
    var line = lines[index].trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    if (line.startsWith('export ')) {
      line = line.substring('export '.length).trimLeft();
    }

    final location = '$path:${index + 1}';

    final equals = line.indexOf('=');
    if (equals <= 0) {
      throw ToolError('$location: expected KEY=VALUE');
    }
    final key = line.substring(0, equals).trim();
    final value = line.substring(equals+1).trim();
    values[key] = value;
  }
  return values;
}
