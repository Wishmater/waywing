import "dart:io";
import "dart:typed_data";

import "package:tronco/tronco.dart";

/// Protocol description.
///
/// To make a request client will use /path/indicating/action?param1=value1&param2=value2
/// to invoke an action
///
/// The response will have an status code in the first line, and the rest of the lines is the
/// response body
///
/// Status codes semantics follow the http protocol.
///
/// Status code are numbers but this is a text protocol, so the status code will be send as a string
/// representing the number

/// This class implement an IPC mecanism so that other applications can interact with Waywing
class WaywingServer {
  late final ServerSocket _server;

  final String path;
  final Logger logger;
  final WaywingRouter router;

  static WaywingServer? _instance;
  static WaywingServer get instance => _instance!;

  WaywingServer._(this.path, this.logger) : router = WaywingRouter();
  factory WaywingServer(String path, Logger logger) {
    _instance ??= WaywingServer._(path, logger);
    return _instance!;
  }

  Future<void> init() async {
    _server = await ServerSocket.bind(InternetAddress(path, type: InternetAddressType.unix), 0);

    await for (final socket in _server) {
      socket.listen((data) {
        final lines = String.fromCharCodes(data).split("\n").where((e) => e.trim() != "");
        for (final line in lines) {
          final uri = Uri.parse(line);
          socket.add(router.enroute(uri));
        }
      });
    }
  }
}

typedef WaywingRouteCallback = (int, Uint8List) Function(Map<String, String> params);

class WaywingRouter {
  final Map<String, WaywingRouteCallback> _routes;

  WaywingRouter() : _routes = {};

  register(String path, WaywingRouteCallback callback) {
    assert(!_routes.containsKey(path), "trying to register an already register path: $path");
    _routes[path] = callback;
  }

  Uint8List enroute(Uri url) {
    final result = _routes[url.path]?.call(url.queryParameters);
    if (result != null) {
      final response = Uint8List.fromList("${result.$1}\n".codeUnits);
      response.addAll(result.$2);
      return response;
    } else {
      return _notFound;
    }
  }

  static final Uint8List _notFound = Uint8List.fromList("404\n".codeUnits);
}
