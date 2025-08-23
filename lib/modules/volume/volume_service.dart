import "dart:async";

import "package:flutter/foundation.dart";
import "package:pulseaudio/pulseaudio.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:dartx/dartx.dart";

class VolumeService extends Service {
  ValueListenable<VolumeOutputInterface?> get defaultOutput => _defaultOutput;
  late final ValueNotifier<VolumeOutputInterface?> _defaultOutput;

  ValueListenable<VolumeInputInterface?> get defaultInput => _defaultInput;
  late final ValueNotifier<VolumeInputInterface?> _defaultInput;

  ValueListenable<List<VolumeAppInterface>> get apps => _apps;
  late final ManualValueNotifier<List<VolumeAppInterface>> _apps;

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
      ),
    );
  }

  @override
  Future<void> init() async {
    _client = PulseAudio();
    await _client.initialize("waywing");

    final sinkInputs = await _client.getSinkInputList();
    final apps = sinkInputs.map((e) => VolumeAppInterface(_client, e)).toList();
    await Future.wait(apps.map((e) => e.init()));
    _apps = ManualValueNotifier(apps);

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
        app._onValuesUpdated();
      }
    });

    _sinkInputRemovedSubscription = _client.onSinkInputRemoved.listen((index) async {
      final i = _apps.value.indexWhere((e) => e._sinkInput.index == index);
      if (i != -1) {
        final app = _apps.value.removeAt(i);
        _apps.manualNotifyListeners();
        app.dispose();
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
        output._onValuesUpdated();
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
        input._onValuesUpdated();
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
    // if (result == null) return; // this should never happen after init() is successful
    _defaultOutput.value = result!;
  }

  VolumeOutputInterface? _getDefaultOutput(PulseAudioServerInfo serverInfo) {
    return outputs.value.firstOrNullWhere((e) => e._sink.name == serverInfo.defaultSinkName);
  }

  void _updateDefaultInput(PulseAudioServerInfo serverInfo) {
    if (serverInfo.defaultSourceName == _defaultInput.value?._source.name) return;
    final result = _getDefaultInput(serverInfo);
    // if (result == null) return; // this should never happen after init() is successful
    _defaultInput.value = result!;
  }

  VolumeInputInterface? _getDefaultInput(PulseAudioServerInfo serverInfo) {
    return inputs.value.firstOrNullWhere((e) => e._source.name == serverInfo.defaultSourceName);
  }

  // bool _isSourceRelevant(PulseAudioSource) {
  //   return _sour
  // }
}

abstract class VolumeInterface {
  ValueListenable<String> get name => _name;
  late final ValueNotifier<String> _name;

  ValueListenable<String?>? get subtitle => null;

  ValueListenable<double> get volume => _volume;
  late final ValueNotifier<double> _volume;

  ValueListenable<bool> get isMuted => _isMuted;
  late final ValueNotifier<bool> _isMuted;

  final PulseAudio _client;

  VolumeInterface(this._client);

  Future<void> init();

  // ignore: unused_element
  void _onValuesUpdated();

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
  }) {
    var newValue = volume.value + step;
    if (coerceToStepScale) newValue = _roundToNearestMultiple(newValue, step);
    if (max != null && newValue > max) newValue = max;
    return setVolume(newValue);
  }

  Future<void> decreaseVolume(
    double step, {
    bool coerceToStepScale = true,
  }) {
    var newValue = volume.value - step;
    if (coerceToStepScale) newValue = _roundToNearestMultiple(newValue, step);
    if (newValue < 0) newValue = 0;
    return setVolume(newValue);
  }

  double _roundToNearestMultiple(double value, double scale) {
    return (value / scale).round() * scale;
  }

  Future<void> setVolume(double value);

  Future<void> setMuted(bool value);
}

class VolumeAppInterface extends VolumeInterface {
  @override
  ValueListenable<String?>? get subtitle => _subtitle;
  late final ValueNotifier<String?> _subtitle;

  ValueListenable<String?> get iconName => _iconName;
  late final ValueNotifier<String?> _iconName;

  PulseAudioSinkInput _sinkInput;

  VolumeAppInterface(super._client, this._sinkInput);

  @override
  Future<void> init() async {
    if (_sinkInput.props.applicationName != null) {
      _name = ValueNotifier(_sinkInput.props.applicationName!);
      _subtitle = ValueNotifier(_sinkInput.name);
    } else {
      _name = ValueNotifier(_sinkInput.name);
      _subtitle = ValueNotifier(null);
    }
    _volume = ValueNotifier(_sinkInput.volume);
    _isMuted = ValueNotifier(_sinkInput.mute);

    _iconName = ValueNotifier(_sinkInput.props.applicationIconName ?? _sinkInput.props.mediaIconName);
  }

  @override
  void _onValuesUpdated() {
    if (_sinkInput.props.applicationName != null) {
      _name.value = _sinkInput.props.applicationName!;
      _subtitle.value = _sinkInput.name;
    } else {
      _name.value = _sinkInput.name;
      _subtitle.value = null;
    }
    _volume.value = _sinkInput.volume;
    _isMuted.value = _sinkInput.mute;
  }

  @override
  Future<void> setVolume(double value) {
    return _client.setSinkInputVolume(_sinkInput.index, value);
  }

  @override
  Future<void> setMuted(bool value) {
    return _client.setSinkInputMute(_sinkInput.index, value);
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
  void _onValuesUpdated() {
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
  void _onValuesUpdated() {
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
}
