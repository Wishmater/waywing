import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:pulseaudio/pulseaudio.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/session/session_service.dart";
import "package:waywing/modules/volume/volume_config.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:dartx/dartx.dart";

class VolumeService extends Service<VolumeServiceConfig> {
  late final SessionService _sessionService;

  ValueListenable<VolumeOutputInterface?> get defaultOutput => _defaultOutput;
  late final ValueNotifier<VolumeOutputInterface?> _defaultOutput;

  ValueListenable<VolumeInputInterface?> get defaultInput => _defaultInput;
  late final ValueNotifier<VolumeInputInterface?> _defaultInput;

  ValueListenable<List<VolumeAppInterface>> get apps => _apps;
  late final ManualValueNotifier<List<VolumeAppInterface>> _apps;
  ValueListenable<List<VolumeProcessInterface>> get groupedApps => _groupedApps;
  late final DerivedValueNotifier<List<VolumeProcessInterface>> _groupedApps;

  ValueListenable<List<VolumeOutputInterface>> get outputs => _outputs;
  late final ManualValueNotifier<List<VolumeOutputInterface>> _outputs;

  ValueListenable<List<VolumeInputInterface>> get inputs => _inputs;
  late final ManualValueNotifier<List<VolumeInputInterface>> _inputs;

  late final PulseAudio _client;

  late final StreamSubscription _serverInfoSubscription;
  late final StreamSubscription _sourceChangedSubscription;
  late final StreamSubscription _sourceRemovedSubscription;
  late final StreamSubscription _sinkChangedSubscription;
  late final StreamSubscription _sinkRemovedSubscription;
  late final StreamSubscription _sinkInputChangedSubscription;
  late final StreamSubscription _sinkInputRemovedSubscription;

  VolumeService._();

  static registerService(RegisterServiceCallback registerService) {
    registerService<VolumeService, dynamic>(
      ServiceRegistration(
        constructor: VolumeService._,
        schemaBuilder: () => VolumeServiceConfig.schema,
        configBuilder: VolumeServiceConfig.fromBlock,
      ),
    );
  }

  @override
  late final Map<String, WaywingAction>? actions = {
    "increaseOutputVolume": WaywingAction(
      'Increase volume for default output. Optional query param "amount", defaults to volumeStep set in config (which defaults to 5).',
      (request, _) {
        final amountParam = request.path.queryParameters["amount"];
        int amount;
        if (amountParam == null) {
          amount = config.volumeStep;
        } else {
          try {
            amount = int.parse(amountParam);
          } catch (_) {
            return WaywingResponse(400, 'Optional query param "amount" must be an integer.');
          }
        }
        final output = defaultOutput.value;
        if (output == null) {
          return WaywingResponse(422, "No default output registered");
        }
        output.increaseVolume(amount / 100, max: config.maxVolume / 100, coerceToScale: config.volumeStep / 100);
        return WaywingResponse.ok();
      },
    ),
    "decreaseOutputVolume": WaywingAction(
      'Decrease volume for default output. Optional query param "amount", defaults to volumeStep set in config (which defaults to 5).',
      (request, _) {
        final amountParam = request.path.queryParameters["amount"];
        int amount;
        if (amountParam == null) {
          amount = config.volumeStep;
        } else {
          try {
            amount = int.parse(amountParam);
          } catch (_) {
            return WaywingResponse(400, 'Optional query param "amount" must be an integer.');
          }
        }
        final output = defaultOutput.value;
        if (output == null) {
          return WaywingResponse(422, "No default output registered");
        }
        output.decreaseVolume(amount / 100);
        return WaywingResponse.ok();
      },
    ),
    "setOutputVolume": WaywingAction(
      'Set volume for default output. Required query param "value".',
      (request, _) {
        final valueParam = request.path.queryParameters["value"];
        int amount;
        if (valueParam == null) {
          return WaywingResponse(400, 'Query param "value" is required.');
        } else {
          try {
            amount = int.parse(valueParam);
          } catch (_) {
            return WaywingResponse(400, 'Query param "value" must be an integer.');
          }
        }
        final output = defaultOutput.value;
        if (output == null) {
          return WaywingResponse(422, "No default output registered");
        }
        output.setVolume(amount / 100);
        return WaywingResponse.ok();
      },
    ),
    "muteOutput": WaywingAction(
      "Mute default output.",
      (request, _) {
        final output = defaultOutput.value;
        if (output == null) {
          return WaywingResponse(422, "No default output registered");
        }
        output.setMuted(!output.isMuted.value);
        return WaywingResponse.ok();
      },
    ),
    "cycleOutput": WaywingAction(
      'Cycle default output. Optional query param "reverse".',
      (request, _) {
        if (outputs.value.isEmpty) {
          return WaywingResponse(422, "No outputs registered");
        }
        if (outputs.value.length == 1) {
          return WaywingResponse(422, "Only one output registered");
        }
        int currentIndex;
        final output = defaultOutput.value;
        if (output == null) {
          currentIndex = -1;
        } else {
          currentIndex = outputs.value.indexWhere((e) => e == output);
        }
        if (request.path.queryParameters["reverse"] != null) {
          currentIndex--;
        } else {
          currentIndex++;
        }
        if (currentIndex < 0) {
          currentIndex = outputs.value.lastIndex;
        } else if (currentIndex > outputs.value.lastIndex) {
          currentIndex = 0;
        }
        setDefaultOutput(outputs.value[currentIndex]);
        return WaywingResponse.ok();
      },
    ),
    "increaseInputVolume": WaywingAction(
      'Increase volume for default input. Optional query param "amount", defaults to volumeStep set in config (which defaults to 5).',
      (request, _) {
        final amountParam = request.path.queryParameters["amount"];
        int amount;
        if (amountParam == null) {
          amount = config.volumeStep;
        } else {
          try {
            amount = int.parse(amountParam);
          } catch (_) {
            return WaywingResponse(400, 'Optional query param "amount" must be an integer.');
          }
        }
        final input = defaultInput.value;
        if (input == null) {
          return WaywingResponse(422, "No default input registered");
        }
        input.increaseVolume(amount / 100, max: config.maxVolume / 100, coerceToScale: config.volumeStep / 100);
        return WaywingResponse.ok();
      },
    ),
    "decreaseInputVolume": WaywingAction(
      'Decrease volume for default input. Optional query param "amount", defaults to volumeStep set in config (which defaults to 5).',
      (request, _) {
        final amountParam = request.path.queryParameters["amount"];
        int amount;
        if (amountParam == null) {
          amount = config.volumeStep;
        } else {
          try {
            amount = int.parse(amountParam);
          } catch (_) {
            return WaywingResponse(400, 'Optional query param "amount" must be an integer.');
          }
        }
        final input = defaultInput.value;
        if (input == null) {
          return WaywingResponse(422, "No default input registered");
        }
        input.decreaseVolume(amount / 100);
        return WaywingResponse.ok();
      },
    ),
    "setInputVolume": WaywingAction(
      'Set volume for default input. Required query param "value".',
      (request, _) {
        final valueParam = request.path.queryParameters["value"];
        int amount;
        if (valueParam == null) {
          return WaywingResponse(400, 'Query param "value" is required.');
        } else {
          try {
            amount = int.parse(valueParam);
          } catch (_) {
            return WaywingResponse(400, 'Query param "value" must be an integer.');
          }
        }
        final input = defaultInput.value;
        if (input == null) {
          return WaywingResponse(422, "No default input registered");
        }
        input.setVolume(amount / 100);
        return WaywingResponse.ok();
      },
    ),
    "muteInput": WaywingAction(
      "Mute default input.",
      (request, _) {
        final input = defaultInput.value;
        if (input == null) {
          return WaywingResponse(422, "No default input registered");
        }
        input.setMuted(!input.isMuted.value);
        return WaywingResponse.ok();
      },
    ),
    "cycleInput": WaywingAction(
      'Cycle default input. Optional query param "reverse".',
      (request, _) {
        if (inputs.value.isEmpty) {
          return WaywingResponse(422, "No inputs registered");
        }
        if (inputs.value.length == 1) {
          return WaywingResponse(422, "Only one inputs registered");
        }
        int currentIndex;
        final input = defaultInput.value;
        if (input == null) {
          currentIndex = -1;
        } else {
          currentIndex = inputs.value.indexWhere((e) => e == input);
        }
        if (request.path.queryParameters["reverse"] != null) {
          currentIndex--;
        } else {
          currentIndex++;
        }
        if (currentIndex < 0) {
          currentIndex = inputs.value.lastIndex;
        } else if (currentIndex > inputs.value.lastIndex) {
          currentIndex = 0;
        }
        setDefaultInput(inputs.value[currentIndex]);
        return WaywingResponse.ok();
      },
    ),
  };

  late final StreamSubscription<SleepState> _preparingForSleepSubs;
  @override
  Future<void> init() async {
    _sessionService = await serviceRegistry.requestService<SessionService>(this);
    _preparingForSleepSubs = _sessionService.preparingForSleep.listen((v) {
      if (v == SleepState.awaking) {
        // TODO 1: I could resolve this service issues when awaking from sleep
        // if i reload all values from scratch when awaking
      }
    });

    _client = PulseAudio();
    await _client.initialize("waywing");

    final sinkInputs = await _client.getSinkInputList();
    final apps = sinkInputs.map((e) => VolumeAppInterface(_client, e)).toList();
    await Future.wait(apps.map((e) => e.init()));
    _apps = ManualValueNotifier(apps);
    _groupedApps = DerivedValueNotifier(
      dependencies: [_apps],
      derive: () {
        // TODO: 3 PERFORMANCE should we try to reuse the models already built, does it matter?
        final result = <int, List<VolumeAppInterface>>{};
        for (final e in _apps.value) {
          final id = e.processId.value ?? (-1 * e.name.value.hashCode);
          result[id] ??= [];
          result[id]!.add(e);
        }
        return result.values.map((e) {
          final model = VolumeProcessInterface(e.first._client, e);
          model.init(); // this should be sync
          return model;
        }).toList();
      },
    );

    _sinkInputChangedSubscription = _client.onSinkInputChanged.listen((sinkInput) async {
      final index = _apps.value.indexWhere((e) => e._sinkInput.index == sinkInput.index);
      if (index == -1) {
        final app = VolumeAppInterface(_client, sinkInput);
        await app.init();
        _apps.value.add(app);
        _apps.manualNotifyListeners();
      } else {
        final app = _apps.value[index];
        app._sinkInput = sinkInput;
        app._update();
      }
    });

    _sinkInputRemovedSubscription = _client.onSinkInputRemoved.listen((index) async {
      final i = _apps.value.indexWhere((e) => e._sinkInput.index == index);
      if (i != -1) {
        final app = _apps.value.removeAt(i);
        _apps.manualNotifyListeners();
        await app.dispose();
      }
    });

    final sinks = await _client.getSinkList();
    final outputs = sinks.map((e) => VolumeOutputInterface(_client, e)).toList();
    await Future.wait(outputs.map((e) => e.init()));
    _outputs = ManualValueNotifier(outputs);
    _sinkChangedSubscription = _client.onSinkChanged.listen((sink) async {
      final index = _outputs.value.indexWhere((e) => e._sink.index == sink.index);
      if (index == -1) {
        final output = VolumeOutputInterface(_client, sink);
        await output.init();
        _outputs.value.add(output);
        _outputs.manualNotifyListeners();
      } else {
        final output = _outputs.value[index];
        output._sink = sink;
        output._update();
      }
    });
    _sinkRemovedSubscription = _client.onSinkRemoved.listen((index) async {
      final i = _outputs.value.indexWhere((e) => e._sink.index == index);
      if (i != -1) {
        final output = _outputs.value.removeAt(i);
        _outputs.manualNotifyListeners();
        output.dispose();
      }
    });

    final sources = await _client.getSourceList();
    final inputs = sources.where((e) => e.monitorOfSink == null).map((e) => VolumeInputInterface(_client, e)).toList();
    await Future.wait(inputs.map((e) => e.init()));
    _inputs = ManualValueNotifier(inputs);
    _sourceChangedSubscription = _client.onSourceChanged.listen((source) async {
      if (source.monitorOfSink != null) {
        return;
      }
      final index = _inputs.value.indexWhere((e) => e._source.index == source.index);
      if (index == -1) {
        final input = VolumeInputInterface(_client, source);
        await input.init();
        _inputs.value.add(input);
        _inputs.manualNotifyListeners();
      } else {
        final input = _inputs.value[index];
        input._source = source;
        input._update();
      }
    });

    _sourceRemovedSubscription = _client.onSourceRemoved.listen((index) async {
      final i = _inputs.value.indexWhere((e) => e._source.index == index);
      if (i != -1) {
        final input = _inputs.value.removeAt(i);
        _inputs.manualNotifyListeners();
        input.dispose();
      }
    });

    final initialServerInfo = await _client.getServerInfo();
    VolumeOutputInterface? initialDefaultOutput = _getDefaultOutput(initialServerInfo);
    // int retryCount = 0;
    // while (initialDefaultOutput == null) {
    //   await Future.delayed(Duration(microseconds: 500));
    //   initialDefaultOutput = _getDefaultOutput(await _client.getServerInfo());
    //   retryCount++;
    //   // if (retryCount >= 10) {
    //   //   throw Exception(
    //   //     "Failed to initialize VolumeServer: couldn't get default output (sink) after retrying $retryCount times",
    //   //   );
    //   // }
    // }
    _defaultOutput = ValueNotifier(initialDefaultOutput);

    VolumeInputInterface? initialDefaultInput = _getDefaultInput(initialServerInfo);
    // retryCount = 0;
    // while (initialDefaultInput == null) {
    //   await Future.delayed(Duration(microseconds: 500));
    //   initialDefaultInput = _getDefaultInput(await _client.getServerInfo());
    //   retryCount++;
    //   // if (retryCount >= 10) {
    //   //   throw Exception(
    //   //     "Failed to initialize VolumeServer: couldn't get default input (source) after retrying $retryCount times",
    //   //   );
    //   // }
    // }
    _defaultInput = ValueNotifier(initialDefaultInput);

    _serverInfoSubscription = _client.onServerInfoChanged.listen((serverInfo) {
      _updateDefaultOutput(serverInfo);
      _updateDefaultInput(serverInfo);
    });
  }

  @override
  Future<void> dispose() async {
    _apps.dispose();
    _outputs.dispose();
    _inputs.dispose();
    _defaultOutput.dispose();
    _defaultInput.dispose();
    await Future.wait([
      _serverInfoSubscription.cancel(),
      _sourceChangedSubscription.cancel(),
      _sourceRemovedSubscription.cancel(),
      _sinkChangedSubscription.cancel(),
      _sinkRemovedSubscription.cancel(),
      _sinkInputChangedSubscription.cancel(),
      _sinkInputRemovedSubscription.cancel(),
      _preparingForSleepSubs.cancel(),
      ...apps.value.map((e) => e.dispose()),
      ...outputs.value.map((e) => e.dispose()),
      ...inputs.value.map((e) => e.dispose()),
    ]);
    _client.dispose();
  }

  Future<void> setDefaultOutput(VolumeOutputInterface output) {
    return _client.setDefaultSink(output._sink.name);
  }

  Future<void> setDefaultInput(VolumeInputInterface output) {
    return _client.setDefaultSource(output._source.name);
  }

  void _updateDefaultOutput(PulseAudioServerInfo serverInfo) {
    if (serverInfo.defaultSinkName == _defaultOutput.value?._sink.name) return;
    final result = _getDefaultOutput(serverInfo);
    if (result == null) {
      _defaultOutput.value = null;
      // this should never happen after init() is successful
      // but is in fact happening.
      // When i close the laptop lid, after opening again i get duplicated inputs (output throw but i dont get duplicated)
      // This is a bad state so I will just reset it
      _client.getSinkList().then((sinks) {
        // if for some reason you think this code is ugly and should be using async await
        // instead of callbacks then test this code.
        //
        // This code was necessary due to a bug that happens after the pc wakes up from suspende
        final outputs = sinks.map((sink) => VolumeOutputInterface(_client, sink));
        Future.wait(
          outputs.map((e) async {
            await e.init();
            return e;
          }),
        ).then((outputs) async {
          _outputs.value.clear();
          _outputs.value.addAll(outputs);
          final serverInfo = await _client.getServerInfo();
          _outputs.manualNotifyListeners();
          _updateDefaultOutput(serverInfo);
        });
      });
      return;
    }
    _defaultOutput.value = result;
  }

  VolumeOutputInterface? _getDefaultOutput(PulseAudioServerInfo serverInfo) {
    return outputs.value.firstOrNullWhere((e) => e._sink.name == serverInfo.defaultSinkName);
  }

  void _updateDefaultInput(PulseAudioServerInfo serverInfo) {
    if (serverInfo.defaultSourceName == _defaultInput.value?._source.name) return;
    final result = _getDefaultInput(serverInfo);
    if (result == null) {
      _defaultInput.value = null;
      // this should never happen after init() is successful
      // but is in fact happening, see _updateDefaultOutput above
      _client.getSourceList().then((sources) {
        // if for some reason you think this code is ugly and should be using async await
        // instead of callbacks then test this code.
        //
        // This code was necessary due to a bug that happens after the pc wakes up from suspende
        final inputs = sources
            .where((e) => e.monitorOfSink == null)
            .map((source) => VolumeInputInterface(_client, source));
        Future.wait(
          inputs.map((e) async {
            await e.init();
            return e;
          }),
        ).then((inputs) async {
          _inputs.value.clear();
          _inputs.value.addAll(inputs);
          final serverInfo = await _client.getServerInfo();
          _updateDefaultInput(serverInfo);
          _inputs.manualNotifyListeners();
        });
      });
      return;
    }
    _defaultInput.value = result;
  }

  VolumeInputInterface? _getDefaultInput(PulseAudioServerInfo serverInfo) {
    return inputs.value.firstOrNullWhere((e) => e._source.name == serverInfo.defaultSourceName);
  }
}

abstract class VolumeInterface {
  ValueListenable<String> get name => _name;
  late final ValueNotifier<String> _name;

  ValueListenable<String?>? get subtitle => null;

  ValueListenable<String?>? get iconName => null;

  ValueListenable<double> get volume => _volume;
  late final ValueNotifier<double> _volume;

  ValueListenable<bool> get isMuted => _isMuted;
  late final ValueNotifier<bool> _isMuted;

  final PulseAudio _client;

  VolumeInterface(this._client);

  Future<void> init();

  // ignore: unused_element
  void _update();

  @mustCallSuper
  Future<void> dispose() async {
    _name.dispose();
    _volume.dispose();
    _isMuted.dispose();
  }

  Future<void> increaseVolume(
    double step, {
    double? max,
    bool coerceToStepScale = true,
    double? coerceToScale,
  }) {
    var newValue = volume.value + step;
    if (coerceToStepScale) newValue = _roundToNearestMultiple(newValue, (coerceToScale ?? step));
    if (max != null && newValue > max) newValue = max;
    return setVolume(newValue);
  }

  Future<void> decreaseVolume(
    double step, {
    bool coerceToStepScale = true,
    double? coerceToScale,
  }) {
    var newValue = volume.value - step;
    if (coerceToStepScale) newValue = _roundToNearestMultiple(newValue, (coerceToScale ?? step));
    if (newValue < 0) newValue = 0;
    return setVolume(newValue);
  }

  Future<void> setVolume(double value);

  Future<void> setMuted(bool value);

  @override
  int get hashCode => name.value.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is VolumeInterface) {
      return name.value == other.name.value;
    }
    return identical(this, other);
  }
}

double _roundToNearestMultiple(double value, double scale) {
  return (value / scale).round() * scale;
}

class VolumeAppInterface extends VolumeInterface {
  @override
  ValueListenable<String?>? get subtitle => _subtitle;
  late final ValueNotifier<String?> _subtitle;

  @override
  ValueListenable<String?> get iconName => _iconName;
  late final ValueNotifier<String?> _iconName;

  ValueListenable<int?> get processId => _processId;
  late final ValueNotifier<int?> _processId;

  PulseAudioSinkInput _sinkInput;

  // late final ValueNotifier<String?> _processUser;

  VolumeAppInterface(super._client, this._sinkInput);

  String? get processBinary => _sinkInput.props.processBinary();

  @override
  Future<void> init() async {
    // print(
    //   JsonEncoder.withIndent("  ").convert(
    //     Map.fromEntries(_sinkInput.props.entries).mapValues((e) {
    //       return _valueToString(e.value);
    //     }),
    //   ),
    // );

    _processId = ValueNotifier(_sinkInput.props.processId());
    // _processUser = ValueNotifier(_sinkInput.props.processUser());

    if (_sinkInput.props.applicationName != null) {
      _name = ValueNotifier(_sinkInput.props.applicationName!);
    } else {
      _name = ValueNotifier(_sinkInput.name);
    }
    _volume = ValueNotifier(_sinkInput.volume);
    _isMuted = ValueNotifier(_sinkInput.mute);

    _iconName = ValueNotifier(
      _sinkInput.props.applicationIconName ?? _sinkInput.props.mediaIconName ?? _sinkInput.props.processBinary(),
    );
    _subtitle = ValueNotifier(null);
    _updateSubtitle();
  }

  @override
  void _update() {
    _processId.value = _sinkInput.props.processId();
    // _processUser.value = _sinkInput.props.processUser();

    if (_sinkInput.props.applicationName != null) {
      _name.value = _sinkInput.props.applicationName!;
    } else {
      _name.value = _sinkInput.name;
    }
    _volume.value = _sinkInput.volume;
    _isMuted.value = _sinkInput.mute;

    _iconName.value =
        _sinkInput.props.applicationIconName ?? _sinkInput.props.mediaIconName ?? _sinkInput.props.processBinary();
    _updateSubtitle();
  }

  @override
  Future<void> setVolume(double value) {
    return _client.setSinkInputVolume(_sinkInput.index, value);
  }

  @override
  Future<void> setMuted(bool value) {
    return _client.setSinkInputMute(_sinkInput.index, value);
  }

  @override
  int get hashCode => Object.hash(name.value, _sinkInput.index);

  @override
  bool operator ==(Object other) {
    if (other is VolumeAppInterface) {
      return name.value == other.name.value && _sinkInput.index == other._sinkInput.index;
    }
    return identical(this, other);
  }

  void _updateSubtitle() {
    final buff = StringBuffer();
    if (_sinkInput.props.applicationName != null) {
      buff.write(_sinkInput.name);
    }
    // if (_processId.value != null || _processUser.value != null) {
    //   buff.write(" (");
    //   if (_processId.value != null) {
    //     buff.write("${_processId.value}");
    //   }
    //   if (_processUser.value != null) {
    //     buff.write(":${_processUser.value}");
    //   }
    //   buff.write(")");
    // }
    if (buff.isEmpty) {
      _subtitle.value = null;
    } else {
      _subtitle.value = buff.toString();
    }
  }
}

class VolumeProcessInterface extends VolumeInterface {
  final List<VolumeAppInterface> apps;

  @override
  ValueListenable<String> get name => apps.first.name;

  @override
  ValueListenable<String?>? get subtitle => apps.first.subtitle;

  ValueListenable<int?> get processId => apps.first.processId;

  @override
  ValueListenable<String?> get iconName => _iconName;
  late final ValueNotifier<String?> _iconName;

  VolumeProcessInterface(super._client, List<VolumeAppInterface> apps)
    : assert(apps.isNotEmpty),
      apps = List.unmodifiable(apps);

  @override
  Future<void> init() async {
    _volume = DerivedValueNotifier(
      dependencies: apps.map((e) => e.volume).toList(),
      derive: () => apps.maxBy((e) => e.volume.value)!.volume.value,
    );
    _isMuted = DerivedValueNotifier(
      dependencies: apps.map((e) => e.isMuted).toList(),
      derive: () => apps.all((e) => e.isMuted.value),
    );
    _iconName = apps.first.processBinary != null ? ValueNotifier(apps.first.processBinary) : apps.first._iconName;
  }

  @override
  // ignore: unused_element
  void _update() {}

  @override
  Future<void> setVolume(double value) {
    final oldVolume = volume.value;
    final ratio = volume.value == 0 ? 1 : value / oldVolume;
    return Future.wait(
      apps.map((e) {
        final deviceVolume = e.volume.value * ratio;
        return e.setVolume(oldVolume == 0 ? value : deviceVolume);
      }),
    );
  }

  @override
  Future<void> setMuted(bool value) {
    return Future.wait(
      apps.map((e) {
        return e.setMuted(value);
      }),
    );
  }

  @override
  int get hashCode => processId.value?.hashCode ?? (-1 * name.value.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is VolumeProcessInterface) {
      return hashCode == other.hashCode;
    }
    return identical(this, other);
  }
}

extension on PropList {
  int? processId() {
    final strid = _valueToString(this["application.process.id"]);
    if (strid == null) {
      return null;
    }
    return int.tryParse(strid);
  }

  // String? processUser() => _valueToString(this["application.process.user"]);

  String? processBinary() => _valueToString(this["application.process.binary"]);
}

String? _valueToString(Uint8List? data) {
  if (data == null) {
    return null;
  }
  try {
    return const Utf8Codec().decoder.convert(data.takeWhile((e) => e != 0).toList());
  } catch (_) {
    return null;
  }
}

class VolumeOutputInterface extends VolumeInterface {
  PulseAudioSink _sink;

  VolumeOutputInterface(super._client, this._sink);

  @override
  Future<void> init() async {
    _name = ValueNotifier(_sink.description);
    _volume = ValueNotifier(_sink.volume);
    _isMuted = ValueNotifier(_sink.mute);
  }

  @override
  void _update() {
    _name.value = _sink.description;
    _volume.value = _sink.volume;
    _isMuted.value = _sink.mute;
  }

  @override
  Future<void> setVolume(double value) async {
    _client.setSinkVolume(_sink.name, value);
  }

  @override
  Future<void> setMuted(bool value) {
    return _client.setSinkMute(_sink.name, value);
  }

  @override
  int get hashCode => Object.hash(name.value, _sink.index);

  @override
  bool operator ==(Object other) {
    if (other is VolumeOutputInterface) {
      return name.value == other.name.value && _sink.index == other._sink.index;
    }
    return identical(this, other);
  }
}

class VolumeInputInterface extends VolumeInterface {
  PulseAudioSource _source;

  VolumeInputInterface(super._client, this._source);

  @override
  Future<void> init() async {
    _name = ValueNotifier(_source.description);
    _volume = ValueNotifier(_source.volume);
    _isMuted = ValueNotifier(_source.mute);
  }

  @override
  void _update() {
    _name.value = _source.description;
    _volume.value = _source.volume;
    _isMuted.value = _source.mute;
  }

  @override
  Future<void> setVolume(double value) async {
    _client.setSourceVolume(_source.name, value);
  }

  @override
  Future<void> setMuted(bool value) {
    return _client.setSourceMute(_source.name, value);
  }

  @override
  int get hashCode => Object.hash(name.value, _source.index);

  @override
  bool operator ==(Object other) {
    if (other is VolumeInputInterface) {
      return name.value == other.name.value && _source.index == other._source.index;
    }
    return identical(this, other);
  }
}
