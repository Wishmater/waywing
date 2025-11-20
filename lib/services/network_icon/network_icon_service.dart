import "dart:io";
import "dart:typed_data";

import "package:hive_ce/hive.dart";
import "package:http/http.dart" as http;
import "package:http_cache_client/http_cache_client.dart" ;
import "package:http_cache_core/http_cache_core.dart";

import "package:html/parser.dart" as parser;
import "package:http_cache_hive_store/http_cache_hive_store.dart";
import "package:waywing/core/service.dart";
import "package:waywing/core/service_registry.dart";
// ignore: implementation_imports
import "package:hive_ce/src/hive_impl.dart" show HiveImpl;

// TODO 3: browser have a cache mechanism that uses the response headers. We should use the same mechanism
// for our own cache control.

// TODO 1: Make all request idempotent
class NetworkIconService extends Service {
  final HiveImpl _db = HiveImpl();
  late final CacheClient cacheClient;

  NetworkIconService._();

  static void registerService(RegisterServiceCallback registration) {
    registration<NetworkIconService, dynamic>(
      ServiceRegistration(
        constructor: NetworkIconService._,
      ),
    );
  }

  @override
  Future<void> init() async {
    _db.init(dataDir.path);
    _db.registerAdapter(_IconAdapter());
    final options = CacheOptions(
      store: HiveCacheStore(null, hiveBoxName: "icon_cache"),
      policy: CachePolicy.forceCache,
      hitCacheOnErrorCodes: [500],
      hitCacheOnNetworkFailure: true,
    );

    cacheClient = CacheClient(
      http.Client(),
      options: options,
    );
  }

  @override
  Future<void> dispose() async {
    await _db.close();
  }

  Future<Uri?> _getFavicon(Uri uri) async {
    // Fetch the HTML
    final http.Response response;
    try {
      response = await cacheClient.get(uri);
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

  Future<Uint8List?> fromUrl(Uri uri) async {
    final baseUrl = "${uri.scheme}://${uri.host}";
    final fallback = Uri.parse("$baseUrl/favicon.ico");

    final iconUri = await _getFavicon(uri) ?? fallback;

    return await _fromFavicon(iconUri, fallback);
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
  Future<Uint8List?> _fromFavicon(Uri iconUri, [Uri? fallback]) async {
    logger.trace("get icon from icon url $iconUri");

    final http.Response response;
    try {
      response = await cacheClient.get(iconUri);
    } catch (e) {
      logger.warning("failed url get request, return null icon file $iconUri", error: e);
      return null;
    }
    if (response.statusCode != 200) {
      logger.warning("request to $iconUri returned bad status code, expected 200 got ${response.statusCode}");
      return null;
    }
    final contentType = response.headers[HttpHeaders.contentTypeHeader];
    if (contentType != null && !_validHeaders.contains(contentType)) {
      if (fallback != null && iconUri != fallback) {
        logger.warning(
          "request to $iconUri does not contains valid headers ${response.headers[HttpHeaders.contentTypeHeader]}. Using fallback $fallback",
        );
        return _fromFavicon(fallback);
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
    return response.bodyBytes;
  }
}

extension on Uri {
  String cacheFilePath() {
    return "$host/$path";
  }
}

class _Icon {
  final String baseUrl;
  final String filepath;
  final String contentType;
  final DateTime cacheInvalidation;

  const _Icon({
    required this.baseUrl,
    required this.filepath,
    required this.contentType,
    required this.cacheInvalidation,
  });
}

class _IconAdapter extends TypeAdapter<_Icon> {
  @override
  _Icon read(BinaryReader reader) {
    final url = reader.readString();
    final filepath = reader.readString();
    final contentType = reader.readString();
    final invalidation = reader.read();

    return _Icon(
      baseUrl: url,
      filepath: filepath,
      contentType: contentType,
      cacheInvalidation: invalidation,
    );
  }

  @override
  int get typeId => 3828;

  @override
  void write(BinaryWriter writer, _Icon obj) {
    writer.writeString(obj.baseUrl);
    writer.writeString(obj.filepath);
    writer.writeString(obj.contentType);
    writer.write(obj.cacheInvalidation);
  }
}
