import "dart:io";

import "package:dartx/dartx_io.dart";
import "package:flutter/foundation.dart";
import "package:path/path.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";

// #!/path/to/shell/program ## this line is mandatory. If this line is missing the command will fail to be parsed
// # @name <name> ## line is optional name that will override the file name:
// # @description <description> ## small description of the program
// # @arg <type> <description> ## arguments type and description. Description is optional
// # @arg <type> <description> ## only one argument per line
// # @arg <type> <description> ## spam as much arguments as you want
// ## write your program

class UserCommand {
  /// program to run the file
  final String program;

  /// name of the program
  final String name;
  final String? description;
  final List<UserCommandArgument>? arguments;
  final String path;

  const UserCommand({required this.path, required this.program, required this.name, this.description, this.arguments});

  @override
  bool operator ==(covariant UserCommand other) {
    return program == other.program &&
        name == other.name &&
        description == other.description &&
        path == other.path &&
        listEquals(arguments ?? [], other.arguments ?? []);
  }

  @override
  int get hashCode => Object.hashAll([program, name, description, path, ...(arguments ?? [])]);
}

enum UserCommandArgumentType {
  int,
  string,
  float,
  bool;

  static UserCommandArgumentType? fromString(String v) {
    return switch (v.toLowerCase()) {
      "int" => int,
      "string" => string,
      "float" => float,
      "bool" => bool,
      _ => null,
    };
  }
}

class UserCommandArgument {
  final UserCommandArgumentType type;
  final String? description;

  const UserCommandArgument({required this.type, this.description});
}

class UserCommandService extends Service {
  UserCommandService._();

  static void registerService(RegisterServiceCallback registerService) {
    registerService<UserCommandService, dynamic>(
      ServiceRegistration(
        constructor: UserCommandService._,
      ),
    );
  }


  @override
  Future<void> init() async {
    // throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {
    // throw UnimplementedError();
  }

  Future<List<UserCommand>> commands() async {
    final response = <UserCommand>[];
    logger.trace("searching commands in ${dataDir.path}");
    await for (final entry in dataDir.list()) {
      logger.trace("entry found ${entry.name}");
      if (entry.statSync().type == FileSystemEntityType.file) {
        final content = await File(entry.absolute.path).readAsString();
        final command = _parseCommand(entry.absolute.path, content);
        if (command != null) {
          response.add(command);
        }
      }
    }
    return response;
  }

  UserCommand? _parseCommand(String path, String content) {
    logger.trace("parse command for $path");
    final line = StringBuffer();
    final iterator = content.codeUnits.iterator;

    // parse program
    _fillLine(line, iterator);
    final program = _parseProgram(line.toString());
    if (program == null) {
      logger.trace("program was null $path");
      return null;
    }
    logger.trace("program $program $path");
    line.clear();

    // parse name
    _fillLine(line, iterator);
    String? name = _parseName(line.toString());
    if (name != null) {
      line.clear();
      _fillLine(line, iterator);
    }
    if (name == null) {
      final nameWithExt = basename(path);
      final ext = extension(path);
      name = nameWithExt.removeSuffix(ext);
    }

    // parse description
    final description = _parseDescription(line.toString());
    if (description != null) {
      line.clear();
      _fillLine(line, iterator);
    }

    // parse arguments
    List<UserCommandArgument>? args;
    while (true) {
      final arg = _parseArg(line.toString());
      if (arg == null) {
        break;
      }
      args ??= [];
      args.add(arg);
      line.clear();
      _fillLine(line, iterator);
    }

    return UserCommand(
      path: path,
      program: program,
      name: name,
      description: description,
      arguments: args,
    );
  }

  void _fillLine(StringBuffer buffer, Iterator<int> characters) {
    while (characters.moveNext() && characters.current != 10) {
      buffer.writeCharCode(characters.current);
    }
  }

  String? _removeCommentAndTrim(String line) {
    line = line.trim();
    if (!line.startsWith("#")) {
      logger.trace("_removeCommentAndTrim dont start with # $line");
      return null;
    }
    line = line.removePrefix("#");
    return line.trim();
  }

  String? _parseProgram(String line) {
    line = _removeCommentAndTrim(line) ?? "";
    if (line == "") {
      return null;
    }
    if (!line.startsWith("!/")) {
      return null;
    }
    return line.substring(1);
  }

  String? _parseName(String line) {
    line = _removeCommentAndTrim(line) ?? "";
    if (line == "") {
      return null;
    }
    const name = "@name ";
    if (!line.startsWith(name)) {
      return null;
    }
    line = line.substring(name.length);
    return line.trim();
  }

  String? _parseDescription(String line) {
    line = _removeCommentAndTrim(line) ?? "";
    if (line == "") {
      return null;
    }
    const description = "@description ";
    if (!line.startsWith(description)) {
      return null;
    }
    line = line.substring(description.length);
    return line.trim();
  }

  UserCommandArgument? _parseArg(String line) {
    line = _removeCommentAndTrim(line) ?? "";
    if (line == "") {
      return null;
    }
    const arg = "@arg ";
    if (!line.startsWith(arg)) {
      return null;
    }
    line = line.substring(arg.length);
    String? typeStr;
    int i = 0;
    for (; i < line.codeUnits.length; i++) {
      final char = line.codeUnits[i];
      if (char == 32) {
        typeStr = line.substring(0, i);
        break;
      }
    }
    if (typeStr == null) {
      return null;
    }
    final type = UserCommandArgumentType.fromString(typeStr);
    if (type == null) {
      return null;
    }
    line = line.substring(i).trim();
    return UserCommandArgument(type: type, description: line);
  }
}
