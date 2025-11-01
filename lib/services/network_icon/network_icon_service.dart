import "dart:io";

import "package:dartx/dartx_io.dart";
import "package:http/http.dart" as http;
import "package:html/parser.dart" as parser;
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";

// TODO 3: browser have a cache mechanism that uses the response headers. We should use the same mechanism
// for our own cache control.

// TODO 1: Make all request idempotent
class NetworkIconService extends Service {
  NetworkIconService._();

  static void registerService(RegisterServiceCallback registration) {
    registration<NetworkIconService, dynamic>(
      ServiceRegistration(
        constructor: NetworkIconService._,
      ),
    );
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}

  Future<Uri?> _getFavicon(Uri uri) async {
    // Fetch the HTML
    final http.Response response;
    try {
      response = await http.get(uri);
    } catch (e) {
      logger.warning("failed url get request, return null favicon url $uri", error: e);
      return null;
    }
    if (response.statusCode != 200) {
      logger.warning("request to $uri returned bad status code, expected 200 got ${response.statusCode}");
      return null;
    }

    try {
      // Parse HTML to find favicon
      final document = parser.parse(response.body);
      final iconLink = document.querySelector('link[rel="icon"], link[rel="shortcut icon"]');
      if (iconLink != null) {
        String? href = iconLink.attributes["href"];
        if (href != null) {
          var result = Uri.parse(href);
          if (!result.hasScheme) {
            result = result.replace(scheme: uri.scheme);
          }
          if (result.host == "") {
            result = result.replace(host: uri.host);
          }
          return result;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<File?> fromUrl(Uri uri) async {
    final baseUrl = "${uri.scheme}://${uri.host}";
    final fallback = Uri.parse("$baseUrl/favicon.ico");

    final chacheFile = dataDir.file(Uri.parse("$baseUrl/favicon.ico").cacheFilePath());
    if (chacheFile.existsSync()) {
      logger.info("cache hit for $uri in ${chacheFile.absolute.path}");
      return chacheFile;
    }
    logger.info("cache miss for $uri");

    logger.trace("finding icon for $uri");
    final iconUri = await _getFavicon(uri) ?? fallback;

    return await fromFavicon(iconUri, fallback);
  }

  final _validHeaders = <String>[
    "image/ico",
    "image/x-ico",
    "image/x-icon",
    "image/vnd.microsoft.icon",
    "application/ico",
    "text/ico",
    "application/octet-stream",
    "image/png",
    "image/svg+xml", // TODO 2: does this gets rendered with the Image.file widget? I would assume that it won't
  ];
  Future<File?> fromFavicon(Uri iconUri, [Uri? fallback]) async {
    logger.trace("get icon from icon url $iconUri");
    final file = dataDir.file(iconUri.cacheFilePath());
    if (file.existsSync()) {
      logger.info("cache hit for $iconUri in ${file.absolute.path}");
      return file;
    }
    logger.info("cache miss for $iconUri");

    final http.Response response;
    try {
      response = await http.get(iconUri);
    } catch (e) {
      logger.warning("failed url get request, return null icon file $iconUri", error: e);
      return null;
    }
    if (response.statusCode != 200) {
      logger.warning("request to $iconUri returned bad status code, expected 200 got ${response.statusCode}");
      return null;
    }
    if (response.headers[HttpHeaders.contentTypeHeader] != null &&
        !_validHeaders.contains(response.headers[HttpHeaders.contentTypeHeader])) {
      if (fallback != null && iconUri != fallback) {
        logger.warning(
          "request to $iconUri does not contains valid headers ${response.headers[HttpHeaders.contentTypeHeader]}. Using fallback $fallback\n\n${response.headers}\n",
        );
        return fromFavicon(fallback);
      } else {
        logger.warning(
          "request to $iconUri does not contains valid headers ${response.headers[HttpHeaders.contentTypeHeader]}. Returning null",
        );
        return null;
      }
    }
    if (response.bodyBytes.isEmpty) {
      logger.warning("request to $iconUri returned empty body, return null icon file");
      return null;
    }
    logger.trace("creating file for ${file.absolute.path}");
    file.createSync(recursive: true);
    await file.writeAsBytes(response.bodyBytes, flush: true);

    logger.trace("successfully created new icon file ${file.absolute.path}");
    return file;
  }
}

extension on Uri {
  String cacheFilePath() {
    return "$host/$path";
  }
}
