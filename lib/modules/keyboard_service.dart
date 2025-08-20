import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:fl_linux_window_manager/models/keyboard_mode.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:mutex/mutex.dart" as mut;

extension on KeyboardMode {
  bool isPriorityGreater(KeyboardMode other) {
    return switch (this) {
      KeyboardMode.none => false,
      KeyboardMode.onDemand => switch (other) {
        KeyboardMode.none => true,
        _ => false,
      },
      KeyboardMode.exclusive => switch (other) {
        KeyboardMode.exclusive => false,
        _ => true,
      },
    };
  }

  bool isPriorityEqualOrGreater(KeyboardMode other) {
    return switch (this) {
      KeyboardMode.none => switch (other) {
        KeyboardMode.none => true,
        _ => false,
      },
      KeyboardMode.onDemand => switch (other) {
        KeyboardMode.exclusive => false,
        _ => true,
      },
      KeyboardMode.exclusive => switch (other) {
        _ => true,
      },
    };
  }
}

enum KeyboardServiceMode {
  onDemand,
  exclusive;

  KeyboardMode kMode() {
    return switch (this) {
      KeyboardServiceMode.onDemand => KeyboardMode.onDemand,
      KeyboardServiceMode.exclusive => KeyboardMode.exclusive,
    };
  }
}

class _GenerateId {
  static int _id = 0;
  static int get generate => _id++;
}

/// Service to manage keyboard input mode. This class is intended
/// to be used on initState/dispose on widgets that needs keyboard input
class KeyboardService extends Service {
  final Map<int, KeyboardServiceMode> _modes;
  int? _currentId;
  mut.Mutex mutex;

  KeyboardMode get _currentMode => _currentId != null ? _modes[_currentId]!.kMode() : KeyboardMode.none;

  KeyboardService._() : _modes = {}, _currentId = null, mutex = mut.Mutex();

  static registerService(RegisterServiceCallback registerService) {
    registerService<KeyboardService, dynamic>(
      ServiceRegistration(
        constructor: KeyboardService._,
      ),
    );
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}

  /// Sets a keyboard mode.
  /// Returns the id of the request, this allow other services to request a keyboard mode
  /// without conflict.
  ///
  /// Exclusive mode has a greater priority than onDemand mode. This means that if a
  /// widget request onDemand and the current mode is exclusive, the request will be ignored until
  /// the request expires (removeMode is called with the request id).
  Future<int> setMode(KeyboardServiceMode mode) async {
    return await mutex.protect(() async {
      final id = _GenerateId.generate;
      _modes[id] = mode;
      if (mode.kMode().isPriorityGreater(_currentMode)) {
        _currentId = id;
        await FlLinuxWindowManager.instance.setKeyboardInteractivity(mode.kMode());
      }
      return id;
    });
  }

  /// Recieve the request id and remove the asociated mode from the list.
  ///
  /// If the asociated mode is the one running then the next max priority mode is set
  /// as current.
  Future<void> removeMode(int id) async {
    return await mutex.protect(() async {
      final prevMode = _modes.remove(id)?.kMode();
      if (prevMode == null) {
        return;
      }
      if (id == _currentId) {
        final id = _searchMaxPriorityMode();
        if (id == -1) {
          assert(_modes.isEmpty, "modes is not empty but searchMaxPriorityMode return -1");
          assert(
            prevMode.isPriorityGreater(KeyboardMode.none),
            "all KeyboardServiceMode KeyboardMode must be greater than KeyboardMode.none",
          );
          _currentId = null;
          await FlLinuxWindowManager.instance.setKeyboardInteractivity(KeyboardMode.none);
        } else {
          _currentId = id;
          if (prevMode.isPriorityGreater(_currentMode)) {
            await FlLinuxWindowManager.instance.setKeyboardInteractivity(_currentMode);
          }
        }
      }
    });
  }

  int _searchMaxPriorityMode() {
    int id = -1;
    KeyboardMode mode = KeyboardMode.none;
    for (final entry in _modes.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.kMode().isPriorityEqualOrGreater(mode)) {
        id = key;
        mode = value.kMode();
      }
    }
    return id;
  }
}
