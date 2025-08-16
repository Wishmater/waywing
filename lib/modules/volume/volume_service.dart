import "package:flutter/widgets.dart";
import "package:pulseaudio/pulseaudio.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/util/slice.dart";

class VolumeService extends Service {
  late final PulseAudio pulseaudio;
  late VolumeValues values;

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
    pulseaudio = PulseAudio();
    await pulseaudio.initialize("waywing");
    values = VolumeValues(this);
  }

  @override
  Future<void> dispose() async {
    pulseaudio.dispose();
  }

  Future<void> setVolumeInput(PulseAudioSinkInput input, double value) async {
    pulseaudio.setSinkInputVolume(input.index, value);
  }

  Future<void> setVolumeSink(PulseAudioSink sink, double value) async {
    pulseaudio.setSinkVolume(sink.name, value);
  }
}

class VolumeValues {
  // final WeakReference<VolumeService> service;
  // PulseAudio get client => service.target!.pulseaudio;

  bool _setDefaultSink() {
    final i = _sinks.indexWhere((e) => e.name == serverInfo.value.defaultSinkName);
    if (i == -1) {
      return false;
    }
    defaultSink.value = _sinks[i];
    return true;
  }

  bool _setDefaultSource() {
    final i = _sources.indexWhere((e) => e.name == serverInfo.value.defaultSourceName);
    if (i == -1) {
      return false;
    }
    defaultSource.value = _sources[i];
    return true;
  }

  VolumeValues(VolumeService service)
    : serverInfo = ValueNotifier(PulseAudioServerInfo.emtpy()),
      inputs = _ValueNotifier(Slice([])),
      _inputs = [],
      sinks = _ValueNotifier(Slice([])),
      _sinks = [],
      sources = _ValueNotifier(Slice([])),
      _sources = [],
      defaultSink = _ValueNotifier(PulseAudioSink.empty()),
      defaultSource = _ValueNotifier(PulseAudioSource.empty()) {
    final client = service.pulseaudio;
    // initialize server info
    client.onServerInfoChanged.listen((info) {
      serverInfo.value = info;
    });
    client.getServerInfo().then((info) {
      serverInfo.value = info;
    });
    // set default sink
    serverInfo.addListener(() async {
      if (serverInfo.value.defaultSinkName != defaultSink.value.name) {
        int count = 0;
        while (!_setDefaultSink() && count < 10) {
          await Future.delayed(Duration(microseconds: 500));
          count++;
        }
      }
    });
    // set default source
    serverInfo.addListener(() async {
      if (serverInfo.value.defaultSourceName != defaultSource.value.name) {
        int count = 0;
        while (!_setDefaultSource() && count < 10) {
          await Future.delayed(Duration(microseconds: 500));
          count++;
        }
      }
    });

    // initialize sink inputs
    client.onSinkInputChanged.listen((input) {
      final index = _inputs.indexWhere((e) => e.index == input.index);
      if (index == -1) {
        _inputs.add(input);
        inputs.value = Slice(_inputs);
      } else {
        _inputs[index] = input;
        (inputs as _ValueNotifier<Slice<PulseAudioSinkInput>>)._markAsDirty();
      }
    });
    client.onSinkInputRemoved.listen((index) {
      final i = _inputs.indexWhere((e) => e.index == index);
      if (i != -1) {
        _inputs.removeAt(i);
        inputs.value = Slice(_inputs);
      }
    });
    client.getSinkInputList().then((list) {
      _inputs = list;
      inputs.value = Slice(_inputs);
    });

    // initialize sinks
    client.onSinkChanged.listen((sink) {
      final index = _inputs.indexWhere((e) => e.index == sink.index);
      if (index == -1) {
        if (defaultSink.value.index == sink.index) {
          defaultSink.value = sink;
        }
        _sinks.add(sink);
        sinks.value = Slice(_sinks);
      } else {
        _sinks[index] = sink;
        (sinks as _ValueNotifier<Slice<PulseAudioSink>>)._markAsDirty();
        if (sink.name == serverInfo.value.defaultSinkName) {
          defaultSink.value = sink;
        }
      }
    });
    client.onSinkRemoved.listen((index) {
      final i = _sinks.indexWhere((e) => e.index == index);
      if (i != -1) {
        _sinks.removeAt(i);
        sinks.value = Slice(_sinks);
      }
    });
    client.getSinkList().then((list) {
      _sinks = list;
      sinks.value = Slice(_sinks);
    });

    // initialize sources
    client.onSourceChanged.listen((source) {
      final index = _inputs.indexWhere((e) => e.index == source.index);
      if (index == -1) {
        if (defaultSource.value.index == source.index) {
          defaultSource.value = source;
        }
        _sources.add(source);
        sources.value = Slice(_sources);
      } else {
        _sources[index] = source;
        (sources as _ValueNotifier<Slice<PulseAudioSource>>)._markAsDirty();
        if (source.name == serverInfo.value.defaultSourceName) {
          defaultSource.value = source;
        }
      }
    });
    client.onSourceRemoved.listen((index) {
      final i = _sources.indexWhere((e) => e.index == index);
      if (i != -1) {
        _sources.removeAt(i);
        sources.value = Slice(_sources);
      }
    });
    client.getSourceList().then((list) {
      _sources = list;
      sources.value = Slice(_sources);
    });
  }

  final ValueNotifier<PulseAudioServerInfo> serverInfo;

  /// This represent the audio that applications sends to sinks
  ///
  /// Example: a video sound
  final ValueNotifier<Slice<PulseAudioSinkInput>> inputs;
  List<PulseAudioSinkInput> _inputs;

  /// Sinks are audio outputs (ex: speakers)
  final ValueNotifier<Slice<PulseAudioSink>> sinks;
  List<PulseAudioSink> _sinks;

  final ValueNotifier<PulseAudioSink> defaultSink;
  final ValueNotifier<PulseAudioSource> defaultSource;

  /// Sources are audio inputs (ex: microphone)
  final ValueNotifier<Slice<PulseAudioSource>> sources;
  List<PulseAudioSource> _sources;
}

class _ValueNotifier<T> extends ValueNotifier<T> {
  _ValueNotifier(super.value);

  void _markAsDirty() {
    notifyListeners();
  }
}
