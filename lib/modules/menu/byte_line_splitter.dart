import "dart:convert";
import "dart:math";
import "dart:typed_data";

// ignore: constant_identifier_names
const int _LF = 10;

const _leadingZerosCompare = <int>[128, 192, 224, 240, 248, 252, 254, 255];

int _leadingZeros(int v) {
  int leadingZeros = 0;
  for (final i in _leadingZerosCompare) {
    if (v >= i) {
      leadingZeros += 1;
    } else {
      break;
    }
  }
  return leadingZeros;
}

class BytesLineSplitter extends Converter<Uint8List, List<Uint8List>> {
  @override
  List<Uint8List> convert(Uint8List input) {
    final response = <Uint8List>[];

    final iter = input.iterator;
    int start = 0;
    int i = 0;
    while (iter.moveNext()) {
      final leadingZeros = min(_leadingZeros(iter.current), 3);
      int j = 0;
      if (leadingZeros == 0 && iter.current == _LF) {
        response.add(Uint8List.sublistView(input, start, i));
        start = i + 1;
      }
      while (j < leadingZeros) {
        iter.moveNext();
        j++;
        i++;
      }
      i++;
    }
    return response;
  }

  @override
  Sink<Uint8List> startChunkedConversion(Sink<List<Uint8List>> sink) {
    return _LineSplitterChunkedConversionSink(sink);
  }
}

class _LineSplitterChunkedConversionSink implements Sink<Uint8List> {
  final Sink<List<Uint8List>> _sink;
  int _skipBytes = 0;

  _LineSplitterChunkedConversionSink(this._sink);

  @override
  void add(Uint8List chunk) {
    final iter = chunk.iterator;
    for (final _ in List.generate(_skipBytes, (i) => i, growable: false)) {
      iter.moveNext();
    }

    final response = <Uint8List>[];
    int start = 0;
    int i = 0;
    while (iter.moveNext()) {
      final leadingZeros = min(_leadingZeros(iter.current), 3);
      if (leadingZeros == 0 && iter.current == _LF) {
        response.add(Uint8List.sublistView(chunk, start, i));
        start = i + 1;
      }
      _skipBytes = leadingZeros;
      int j = 0;
      while (j < leadingZeros && iter.moveNext()) {
        j++;
        i++;
        _skipBytes--;
      }
      i++;
    }

    _sink.add(response);
  }

  @override
  void close() {
    _sink.close();
  }
}
