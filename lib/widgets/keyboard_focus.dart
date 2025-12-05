import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:fl_linux_window_manager/models/keyboard_mode.dart";
import "package:flutter/material.dart";
import "package:mutex/mutex.dart" as mut;
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/logger.dart";

final _logger = mainLogger.clone(properties: [LogType("KeyboardFocus")]);

class KeyboardFocus extends StatefulWidget {
  final Widget child;
  final KeyboardFocusMode mode;
  final String? debugLabel;
  final bool request;

  const KeyboardFocus({
    required this.child,
    required this.mode,
    this.debugLabel,
    this.request = true,
    super.key,
  });

  @override
  State<KeyboardFocus> createState() => _KeyboardFocusState();
}

class _KeyboardFocusState extends State<KeyboardFocus> {
  late final _KeyboardFocusProviderState provider;
  late final Logger logger;
  Future<int>? requestId;

  @override
  void initState() {
    if (widget.debugLabel != null) {
      logger = _logger.clone(properties: [..._logger.defaultProperties, StringProperty(widget.debugLabel!)]);
    } else {
      logger = _logger;
    }
    logger.debug("Initialization of _KeyboardFocusState");
    super.initState();
    // assumes the provider won't change during the lifetime of this widget, which should be true
    provider = context.findAncestorStateOfType<_KeyboardFocusProviderState>()!;
  }

  @override
  void didUpdateWidget(KeyboardFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request != widget.request) {
      logger.debug("didUpdateWidget with new request value ${widget.request}");
      if (widget.request) {
        assert(requestId == null);
        requestId ??= provider.requestFocus(widget.mode);
      } else {
        requestId?.then((id) => provider.removeFocus(id));
        requestId = null;
      }
    }
  }

  @override
  void dispose() {
    logger.debug("Deinitialization of _KeyboardFocusState");
    requestId?.then((id) => provider.removeFocus(id));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (isFocused) {
        if (isFocused) {
          requestId ??= provider.requestFocus(widget.mode);
        } else {
          requestId?.then((id) => provider.removeFocus(id));
          requestId = null;
        }
      },
      child: widget.child,
    );
  }
}

class KeyboardFocusProvider extends StatefulWidget {
  final Widget child;
  final KeyboardFocusService keyboardService;

  const KeyboardFocusProvider({
    super.key,
    required this.child,
    required this.keyboardService,
  });

  @override
  State<KeyboardFocusProvider> createState() => _KeyboardFocusProviderState();
}

class _KeyboardFocusProviderState extends State<KeyboardFocusProvider> {
  @override
  void initState() {
    super.initState();
    widget.keyboardService.mutex.protect(() {
      _logger.trace("Setting initial keyboard interactivity mode: ${widget.keyboardService._currentMode}");
      return FlLinuxWindowManager.instance.setKeyboardInteractivity(widget.keyboardService._currentMode);
    });
  }

  Future<int> requestFocus(KeyboardFocusMode mode) {
    return widget.keyboardService.setMode(mode);
  }

  Future<void> removeFocus(int id) {
    return widget.keyboardService.removeMode(id);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

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

enum KeyboardFocusMode {
  onDemand,
  exclusive;

  KeyboardMode kMode() {
    return switch (this) {
      KeyboardFocusMode.onDemand => KeyboardMode.onDemand,
      KeyboardFocusMode.exclusive => KeyboardMode.exclusive,
    };
  }
}

class _GenerateId {
  static int _id = 0;
  static int get generate => _id++;
}

/// Service to manage keyboard input mode. This class is intended
/// to be used on initState/dispose on widgets that needs keyboard input
class KeyboardFocusService {
  final Map<int, KeyboardFocusMode> _modes;
  int? _currentId;
  mut.Mutex mutex;

  KeyboardMode getDefaultMode() => mainConfig.requestKeyboardFocus ? KeyboardMode.onDemand : KeyboardMode.none;

  KeyboardMode get _currentMode {
    if (_currentId != null) {
      return _modes[_currentId]!.kMode();
    }
    return getDefaultMode();
  }

  KeyboardFocusService._() : _modes = {}, _currentId = null, mutex = mut.Mutex();

  static KeyboardFocusService? _instance;
  factory KeyboardFocusService() {
    _instance ??= KeyboardFocusService._();
    return _instance!;
  }

  /// Sets a keyboard mode.
  /// Returns the id of the request, this allow other services to request a keyboard mode
  /// without conflict.
  ///
  /// Exclusive mode has a greater priority than onDemand mode. This means that if a
  /// widget request onDemand and the current mode is exclusive, the request will be ignored until
  /// the request expires (removeMode is called with the request id).
  Future<int> setMode(KeyboardFocusMode mode) async {
    assert(
      mode.kMode().isPriorityGreater(KeyboardMode.none),
      "all KeyboardFocusMode KeyboardMode must be greater than KeyboardMode.none",
    );
    return await mutex.protect(() async {
      final id = _GenerateId.generate;
      _modes[id] = mode;
      if (mode.kMode().isPriorityGreater(_currentMode)) {
        _currentId = id;
        _logger.trace("Setting keyboard interactivity mode: ${mode.kMode()}");
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
        final id = _searchMaxPriorityMode().$1;
        if (id == -1) {
          assert(_modes.isEmpty, "modes is not empty but searchMaxPriorityMode return -1");
          _currentId = null;
          final fallbackMode = getDefaultMode();
          if (fallbackMode != prevMode) {
            _logger.trace("Setting keyboard interactivity mode fallback (id==-1): $fallbackMode");
            await FlLinuxWindowManager.instance.setKeyboardInteractivity(fallbackMode);
          }
        } else {
          _currentId = id;
          if (prevMode.isPriorityGreater(_currentMode)) {
            _logger.trace("Setting keyboard interactivity mode fallback: $_currentMode");
            await FlLinuxWindowManager.instance.setKeyboardInteractivity(_currentMode);
          }
        }
      }
    });
  }

  (int, KeyboardMode) _searchMaxPriorityMode() {
    int id = -1;
    KeyboardMode mode = getDefaultMode();
    for (final entry in _modes.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.kMode().isPriorityEqualOrGreater(mode)) {
        id = key;
        mode = value.kMode();
      }
    }
    return (id, mode);
  }
}
