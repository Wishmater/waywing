import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:dartx/dartx.dart";
import "package:tronco/tronco.dart";
import "package:chalkdart/chalk.dart";

part "logger.g.dart";

late Logger mainLogger;

@Config()
mixin LoggingConfigBase on LoggingConfigI {
  static const _levelFilter = EnumField(Level.values, defaultTo: Level.info);
  static const _typeLevelFilters = MapField(StringField(), EnumField(Level.values));
}

void initializeLogger([LoggingConfig? config]) {
  mainLogger = Logger(
    output: ConsoleOutput(),
    printer: Printer(),
    filter: Filter(
      config?.levelFilter ?? Level.info,
      config?.typeLevelFilters.mapKeys((e) => LogType(e.key)) ?? {},
    ),
  );
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
}

class Filter extends LogFilter {
  final Level defaultLevel;
  final Map<LogType, Level> types;

  Filter(this.defaultLevel, this.types);

  @override
  bool shouldLog(LogEvent event) {
    bool found = false;
    for (final property in event.properties) {
      if (types.containsKey(property)) {
        found = true;
        if (event.level < types[property]!) {
          return false;
        }
      }
    }
    if (found) {
      return true;
    }
    return event.level >= defaultLevel;
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
