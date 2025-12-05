import "dart:io";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx.dart";
import "package:flutter/foundation.dart";
import "package:tronco/tronco.dart";
import "package:chalkdart/chalk.dart";

part "logger.config.dart";

late Logger mainLogger;

@Config()
mixin LoggingConfigBase on LoggingConfigI {
  static const _levelFilter = EnumField(
    Level.values,
    defaultTo: (kDebugMode ? Level.trace : Level.info),
  ); // TODO fix in config_gen add automatic parentesis on this cases
  static const _typeLevelFilters = MapField(StringField(), EnumField(Level.values), defaultTo: <String, Level>{});
  static const _output = StringField(nullable: true);
}

Future<void> initializeLogger() async {
  mainLogger = Logger(
    output: Output(null),
    printer: Printer(),
    filter: Filter(Level.info, {}),
  );
  await mainLogger.init();
}

void updateLoggerConfig(LoggingConfig config) {
  (mainLogger.output.value as Output).filePath = config.output;
  (mainLogger.filter.value as Filter)._defaultLevel = config.levelFilter;
  (mainLogger.filter.value as Filter)._types = config.typeLevelFilters.mapKeys((e) => LogType(e.key));
}

void updateLevel(Level level) {
  (mainLogger.filter.value as Filter)._defaultLevel = level;
}

class LogType extends LogEventProperty {
  final String value;
  const LogType(this.value);

  @override
  String print() => value;

  @override
  bool operator ==(covariant LogType other) => value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "LogType($value)";
  }
}

class Filter extends LogFilter {
  Level _defaultLevel;
  Level get defaultLevel => _defaultLevel;

  Map<LogType, Level> _types;
  Map<LogType, Level> get types => _types;

  Filter(Level defaultLevel, Map<LogType, Level> types) : _defaultLevel = defaultLevel, _types = types;

  @override
  bool shouldLog(LogEvent event) {
    bool found = false;
    for (final property in event.properties) {
      if (types.containsKey(property)) {
        found = true;
        if (event.level >= types[property]!) {
          return true;
        }
      }
    }
    if (found) {
      return false;
    }
    return event.level >= defaultLevel;
  }
}

// TODO 3.. create a buffered implementation for a performance gain oportunity
class FileOutput extends LogOutput {
  late final RandomAccessFile _file;
  final String path;
  FileOutput(this.path);

  @override
  Future<void> init() async {
    await File(path).parent.create(recursive: true);
    _file = File(path).openSync(mode: FileMode.writeOnlyAppend);
  }

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      _file.writeFromSync(line.codeUnits);
      _file.writeByteSync(10); // write newline character
    }
    _file.flushSync();
  }

  @override
  Future<void> destroy() async {
    await _file.close();
  }
}

class Output extends LogOutput {
  String? _filePath;
  set filePath(String? v) {
    if (_filePath == v) return;

    _filePath = v;
    _fileOutput?.destroy();
    if (v != null) {
      _fileOutput = FileOutput(v);
    } else {
      _fileOutput = null;
    }
  }

  FileOutput? _fileOutput;
  final ConsoleOutput? _consoleOutput;

  Output(this._filePath)
    : _consoleOutput = _filePath == null ? ConsoleOutput() : null,
      _fileOutput = _filePath != null
          ? FileOutput(_filePath) // ?? join(Platform.environment["XDG_RUNTIME_DIR"]!, "waywing", "log")
          : null;

  @override
  Future<void> init() async {
    _fileOutput?.init();
    _consoleOutput?.init();
  }

  @override
  Future<void> destroy() async {
    _fileOutput?.destroy();
    _consoleOutput?.destroy();
  }

  @override
  void output(OutputEvent event) {
    if (_fileOutput != null) {
      _fileOutput!.output(event);
    } else {
      _consoleOutput!.output(event);
    }
  }
}

class Printer extends LogPrinter {
  final String childIdentation;
  final String _identation;

  Printer._(this.childIdentation, this._identation);
  Printer([this.childIdentation = "\t"]) : _identation = "";

  factory Printer._withIdentation(String identation, String childIdentation) {
    return Printer._(childIdentation, identation + childIdentation);
  }

  Iterable<String> logError(Object error, StackTrace? st) sync* {
    yield "${_identation + childIdentation}error: $error";
    if (st != null) {
      int i = 0;
      int j = 0;
      final lines = st.toString().split("\n");
      yield* lines
          .map((e) {
            String response;
            if (i == 0) {
              response = "${_identation + childIdentation}Stacktrace: $e";
            } else {
              response = e == "" ? "" : "${_identation + childIdentation}$e";
            }
            i += 1;
            return response;
          })
          .where((e) {
            j += 1;
            return j != lines.length || e != "";
          });
    }
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "$n";
    if (n >= 10) return "0$n";
    return "00$n";
  }

  String formatDate(DateTime date) {
    return "${_twoDigits(date.hour)}:${_twoDigits(date.minute)}"
        ":${_twoDigits(date.second)}.${_threeDigits(date.millisecond)}";
  }

  @override
  Iterable<String> log(LogEvent event) sync* {
    final buffer = StringBuffer();
    final color = switch (event.level) {
      Level.trace => chalk.magenta,
      Level.debug => chalk.blue,
      Level.info => chalk.green,
      Level.warning => chalk.orange,
      Level.error => chalk.red,
      Level.fatal => chalk.red,
    };
    buffer.write("$_identation${color('${formatDate(event.time)} ${event.level.name}')} ");

    final properties = event.properties.map((e) => e.print()).join(" ");
    if (properties != "") {
      buffer.write("${chalk.cyan(chalk.underline(properties))} ");
    }
    buffer.write(event.message);
    yield buffer.toString();

    if (event.error != null) {
      yield* logError(event.error!, event.stackTrace);
    }

    for (final child in event.childEvents) {
      yield* Printer._withIdentation(_identation, childIdentation).log(child);
    }
  }
}

extension XAggregateLogger on Logger {
  AggregateLogger? create(
    Level level,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    List<LogEventProperty> properties = const [],
  }) {
    final event = LogEvent(
      level,
      message,
      time: time,
      error: error,
      stackTrace: stackTrace,
      properties: List.from(defaultProperties)..addAll(properties),
    );
    for (final hook in eventHooks) {
      hook(event);
    }
    if (!filter.value.shouldLog(event)) {
      return null;
    }
    return AggregateLogger(this, event);
  }
}

class AggregateLogger extends Logger {
  AggregateLogger(Logger parent, this.parentEvent)
    : childEvents = [],
      super.raw(
        filter: parent.filter,
        printer: parent.printer,
        output: parent.output,
        eventHooks: parent.eventHooks,
        outputHooks: parent.outputHooks,
        defaultProperties: parent.defaultProperties,
      );

  final LogEvent parentEvent;
  final List<LogEvent> childEvents;

  void add(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    List<LogEventProperty> properties = const [],
  }) => log(
    parentEvent.level,
    message,
    time: time,
    error: error,
    stackTrace: stackTrace,
    properties: properties,
  );

  @override
  void log(
    Level level,
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
    List<LogEvent> childEvents = const [],
    List<LogEventProperty> properties = const [],
  }) {
    final event = LogEvent(
      parentEvent.level,
      message,
      time: time,
      error: error,
      stackTrace: stackTrace,
      properties: List.from(defaultProperties)..addAll(properties),
    );
    for (final hook in eventHooks) {
      hook(event);
    }
    if (!filter.value.shouldLog(event)) {
      return;
    }
    this.childEvents.add(event);
  }

  void end() {
    super.log(
      parentEvent.level,
      parentEvent.message,
      error: parentEvent.error,
      stackTrace: parentEvent.stackTrace,
      properties: parentEvent.properties,
      time: parentEvent.time,
      childEvents: childEvents,
    );
  }

  @override
  Future<void> destroy() async {}
}

String listToString(Iterable list) {
  if (list.isEmpty) return "[]";
  return "[${list.map((e) => e.toString()).reduce((a, b) => "$a, $b")}";
}

class ConsoleOutput extends LogOutput {
  final IOSink _output = stdout;

  Future<void>? _flushFuture;
  final List<OutputEvent> _buffer;

  ConsoleOutput(): _buffer = [];

  @override
  Future<void> destroy() async {
    while(_flushFuture != null) {
      await _flushFuture;
      await Future.delayed(Duration(microseconds: 100));
    }
  }

  void _flushBuffer() {
    if (_buffer.isEmpty) {
      return;
    }
    for (final event in _buffer) {
      _addEvent(event);
    }
    _buffer.clear();
    _flush();
  }

  void _addEvent(OutputEvent event) {
    _output.add(event.lines.join("\n").toUtf8());
    _output.add("\n".toUtf8());
  }

  void _flush() {
    assert(_flushFuture == null);
    final flush = _output.flush().catchError((e) {
      // TODO 1: will this still report in onError callbacks in the future listeners?
      // TODO 1: how to report this error?
    });
    _flushFuture = flush;
    flush.then((_) {
      _flushFuture = null;
      _flushBuffer();
    });
  }

  @override
  void output(OutputEvent event) {
    if (_flushFuture != null) {
      _buffer.add(event);
      return;
    }

    _addEvent(event);
    _flush();
  }
}
