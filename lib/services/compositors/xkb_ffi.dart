import "dart:ffi";

import "package:ffi/ffi.dart";

typedef _XkbContextNewNative = Pointer<Void> Function(Int32 flags);
typedef _XkbContextNewDart = Pointer<Void> Function(int flags);

typedef _XkbContextUnrefNative = Void Function(Pointer<Void>);
typedef _XkbContextUnrefDart = void Function(Pointer<Void>);

typedef _XkbContextIncludePathGetNative = Pointer<Int8> Function(Pointer<Void>, Uint32 index);
typedef _XkbContextIncludePathGetDart = Pointer<Int8> Function(Pointer<Void>, int index);

final class XkbFfi {
  static bool _initAttempted = false;
  static bool _available = false;

  static late final _XkbContextNewDart _new;
  static late final _XkbContextUnrefDart _unref;
  static late final _XkbContextIncludePathGetDart _includePathGet;

  static dynamic _tryLookup(DynamicLibrary lib) {
    _new = lib.lookupFunction<_XkbContextNewNative, _XkbContextNewDart>("xkb_context_new");
    _unref = lib.lookupFunction<_XkbContextUnrefNative, _XkbContextUnrefDart>(
      "xkb_context_unref",
    );
    _includePathGet = lib.lookupFunction<_XkbContextIncludePathGetNative, _XkbContextIncludePathGetDart>(
      "xkb_context_include_path_get",
    );
  }

  static bool _init() {
    if (_initAttempted) return _available;
    _initAttempted = true;
    try {
      _tryLookup(DynamicLibrary.process());
      _available = true;
    } catch (_) {
      try {
        _tryLookup(DynamicLibrary.open("libxkbcommon.so"));
        _available = true;
      } catch (_) {
        _available = false;
      }
    }
    return _available;
  }

  static String? getXkbConfigPath() {
    if (!_init()) return null;
    try {
      final context = _new(0);
      final pathPtr = _includePathGet(context, 0);
      final result = pathPtr == nullptr ? null : pathPtr.cast<Utf8>().toDartString();
      _unref(context);
      return result;
    } catch (_) {
      return null;
    }
  }
}
