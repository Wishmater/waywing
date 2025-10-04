import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "dart:collection";

import "package:freezed_annotation/freezed_annotation.dart";
import "package:tronco/tronco.dart";

final _newLine = "\n".codeUnitAt(0);

/// This class implement an IPC mecanism so that other applications can interact with Waywing
///
/// Protocol description.
///
/// To make a request client will use /path/indicating/action?param1=value1&param2=value2
/// to invoke an action. This must be single line data.
///
/// Like the http protocol, the nexts lines are requests headers. The only important request
/// header for the current implementation is Content-Length. Each header is a single line,
/// and the end of the headers is an empty line.
///
/// After the headers there comes a body. We finish reading the body until {Content-Length} bytes or
/// if Transfer-Encoding is set to zero-ended until the first 0 recieved when reading the body.
///
/// If {Content-Length} is not found it's assumed that the body is empty.
///
///
/// The response will have an status code in the first line, and the rest of the lines is the
/// response body
///
/// Status codes semantics follow the http protocol.
///
/// Status code are numbers but this is a text protocol, so the status code will be send as a string
/// representing the number
class WaywingServer {
  late final ServerSocket _server;

  final String path;
  final Logger logger;
  final WaywingRouter router;

  static WaywingServer? _instance;
  static WaywingServer get instance => _instance!;

  WaywingServer._(this.path, this.logger) : router = WaywingRouter();
  static void create(String path, Logger logger) {
    _instance ??= WaywingServer._(path, logger);
  }

  Future<void> init() async {
    if (await File(path).exists()) {
      await File(path).delete();
    }
    await File(path).parent.create(recursive: true);

    _server = await ServerSocket.bind(InternetAddress(path, type: InternetAddressType.unix), 0);

    await for (final socket in _server) {
      logger.debug("Recieved request ${socket.address}");
      WaywingRequest? request;
      try {
        request = await ProtocolParser.parseRequests(socket);
        socket.add(await router.enroute(request));
        socket.add("\n".codeUnits);
        await socket.flush();
      } catch (e, st) {
        logger.error("Failed handling request $request", error: e, stackTrace: st);
      } finally {
        try {
          await socket.close();
        } catch (_) {}
      }
    }
  }
}

typedef TypeRouteCb = FutureOr<WaywingResponse> Function(WaywingRequest request);

abstract class WaywingAction {
  /// callback to invoke when this action get activated
  TypeRouteCb get route;

  /// One line description of the action
  String get description;

  factory WaywingAction(String description, TypeRouteCb route) => _WaywingAction(description, route);
}

class _WaywingAction implements WaywingAction {
  @override
  final TypeRouteCb route;
  @override
  final String description;
  _WaywingAction(this.description, this.route);
}

class WaywingActionCallback implements WaywingAction {
  @override
  String get description => "";

  @override
  final TypeRouteCb route;

  const WaywingActionCallback(this.route);
}

class WaywingRouter {
  final Map<String, WaywingAction> _routes;

  WaywingRouter() : _routes = {} {
    _routes["list-actions"] = WaywingAction("List available actions", (_) {
      return WaywingResponse(200, _routes.keys.map((k) => "$k\t\t${_routes[k]!.description}").join("\n"));
    });
  }

  void register(String path, WaywingAction callback) {
    assert(!_routes.containsKey(path), "trying to register an already register path: $path");
    _routes[path] = callback;
  }

  void unregister(String path) {
    _routes.remove(path);
  }

  Future<List<int>> enroute(WaywingRequest request) async {
    final url = request.path;
    final result = await _routes[url.path]?.route(request);
    if (result != null) {
      final response = <int>[];
      response.addAll("${result.code}\n".codeUnits);
      response.addAll(result.body.codeUnits);
      return response;
    } else {
      return _notFound;
    }
  }

  static final Uint8List _notFound = Uint8List.fromList("404".codeUnits);
}

class WaywingResponse {
  final int code;
  final String body;

  const WaywingResponse(this.code, this.body);

  const WaywingResponse.ok([this.body = ""]) : code = 200;
}

class WaywingRequest {
  final Uri path;
  final Map<String, String> headers;
  final Stream<Uint8List> body;

  WaywingRequest({
    required this.path,
    required this.headers,
    required this.body,
  });

  /// Helper method to read the entire body as a string
  Future<String> bodyAsString() async {
    final bytes = await body.expand((chunk) => chunk).toList();
    return utf8.decode(bytes);
  }

  @override
  String toString() {
    return "Request $path $headers";
  }
}

@visibleForTesting
abstract final class ProtocolParser {
  static Future<WaywingRequest> parseRequests(Stream<Uint8List> stream) async {
    final iterator = StreamIterator(stream);
    final buffer = <int>[]; // path and header data
    Uint8List? body;
    bool prevNewLine = false;

    outer:
    while (await iterator.moveNext()) {
      final data = iterator.current;
      for (int i = 0; i < data.length; i++) {
        final char = data[i];
        if (char == _newLine) {
          if (prevNewLine) {
            body = Uint8List.sublistView(data, i + 1);
            break outer;
          } else {
            prevNewLine = true;
          }
        } else {
          prevNewLine = false;
        }
        buffer.add(char);
      }
    }

    final lines = utf8.decoder.convert(buffer).split("\n");

    // Read the first line (path)
    final path = Uri.parse(lines.first.trim());

    // Read headers until empty line
    final headers = Headers(HashMap());
    for (final line in lines.sublist(1)) {
      final colonIndex = line.indexOf(":");
      if (colonIndex != -1) {
        final key = line.substring(0, colonIndex).trim().toLowerCase();
        final value = line.substring(colonIndex + 1).trim();
        headers[key] = value;
      }
    }

    // Create body stream based on headers
    final bodyStream = _createBodyStream(headers, body ?? Uint8List.fromList([]), iterator);

    return WaywingRequest(
      path: path,
      headers: headers,
      body: bodyStream,
    );
  }

  static Stream<Uint8List> _createBodyStream(
    Map<String, String> headers,
    Uint8List body,
    StreamIterator<Uint8List> data,
  ) {
    final contentLength = int.tryParse(headers["content-length"] ?? "");
    final transferEncoding = headers["transfer-encoding"]?.toLowerCase();

    if (contentLength != null) {
      return _readBodyByContentLength(contentLength, body, data);
    } else if (transferEncoding == "zero-ended") {
      return _readBodyZeroEnded(body, data);
    } else {
      // No body expected
      return const Stream.empty();
    }
  }

  static Stream<Uint8List> _readBodyByContentLength(
    int contentLength,
    Uint8List body,
    StreamIterator<Uint8List> iterator,
  ) async* {
    int bytesRead = 0;

    if (body.length > contentLength) {
      yield Uint8List.sublistView(body, 0, contentLength);
      return;
    } else {
      yield body;
      bytesRead += body.length;
    }

    while (await iterator.moveNext()) {
      final data = iterator.current;
      if (bytesRead < contentLength) {
        final remaining = contentLength - bytesRead;
        if (data.length <= remaining) {
          yield data;
          bytesRead += data.length;
        } else {
          yield Uint8List.sublistView(data, 0, remaining);
          bytesRead = contentLength;
        }
      }
      if (bytesRead >= contentLength) {
        break;
      }
    }
  }

  static Stream<Uint8List> _readBodyZeroEnded(Uint8List body, StreamIterator<Uint8List> iterator) async* {
    for (int i = 0; i < body.length; i++) {
      final byte = body[i];
      if (byte == 0) {
        // Found zero terminator
        yield Uint8List.sublistView(body, 0, i);
        return;
      }
    }

    // Send accumulated data as chunk
    yield body;

    while (await iterator.moveNext()) {
      final data = iterator.current;
      for (int i = 0; i < data.length; i++) {
        final byte = data[i];
        if (byte == 0) {
          // Found zero terminator
          yield Uint8List.sublistView(data, 0, i);
          return;
        }
      }
      yield data;
    }
  }
}

class Headers implements Map<String, String> {
  final HashMap<String, String> _headers;
  const Headers(this._headers);

  @override
  String? operator [](covariant String key) {
    return _headers[key.toLowerCase()];
  }

  @override
  void operator []=(String key, String value) {
    _headers[key.toLowerCase()] = value;
  }

  @override
  void addAll(Map<String, String> other) {
    _headers.addAll(other.map((k, v) => MapEntry(k.toLowerCase(), v)));
  }

  @override
  void addEntries(Iterable<MapEntry<String, String>> newEntries) {
    _headers.addEntries(newEntries.map((e) => MapEntry(e.key.toLowerCase(), e.value)));
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    return _headers.cast<RK, RV>();
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  bool containsKey(covariant String key) {
    return _headers.containsKey(key);
  }

  @override
  bool containsValue(covariant String value) {
    return _headers.containsValue(value);
  }

  @override
  Iterable<MapEntry<String, String>> get entries => _headers.entries;

  @override
  void forEach(void Function(String key, String value) action) {
    return _headers.forEach(action);
  }

  @override
  bool get isEmpty => _headers.isEmpty;

  @override
  bool get isNotEmpty => _headers.isNotEmpty;

  @override
  Iterable<String> get keys => _headers.keys;

  @override
  // TODO: implement length
  int get length => _headers.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(String key, String value) convert) {
    return _headers.map(convert);
  }

  @override
  String putIfAbsent(String key, String Function() ifAbsent) {
    return _headers.putIfAbsent(key.toLowerCase(), ifAbsent);
  }

  @override
  String? remove(covariant String key) {
    return _headers.remove(key.toLowerCase());
  }

  @override
  void removeWhere(bool Function(String key, String value) test) {
    return _headers.removeWhere(test);
  }

  @override
  String update(String key, String Function(String value) update, {String Function()? ifAbsent}) {
    return _headers.update(key.toLowerCase(), update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(String Function(String key, String value) update) {
    return _headers.updateAll(update);
  }

  @override
  Iterable<String> get values => _headers.values;

  @override
  String toString() => _headers.toString();
}
