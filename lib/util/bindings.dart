import "dart:async";
import "dart:ffi";
import "package:ffi/ffi.dart";

typedef RegionPtr = Pointer<Void>;

abstract final class RegionBindings {
  @Native<RegionPtr Function()>(symbol: "waywing_create_region")
  external static RegionPtr createRegion();

  @Native<Void Function(RegionPtr)>(symbol: "waywing_destroy_region")
  external static void destroyRegion(RegionPtr region);

  @Native<Void Function(RegionPtr, Int32, Int32, Int32, Int32)>(symbol: "waywing_region_add")
  external static void regionAdd(RegionPtr region, int x, int y, int width, int height);

  @Native<Void Function(RegionPtr, Int32, Int32, Int32, Int32)>(symbol: "waywing_region_subtract")
  external static void regionSubtract(RegionPtr region, int x, int y, int width, int height);

  @Native<Void Function(Int64, RegionPtr)>(symbol: "waywing_set_input_region")
  external static void setInputRegion(int viewId, RegionPtr region);
}

abstract final class ActivationBindings {
  @Native<
    Void Function(
      Int64,
      Pointer<NativeFunction<Void Function(Pointer<Utf8>)>>,
    )
  >(symbol: "waywing_get_activation_token")
  external static void _getActivationToken(
    int viewId,
    Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> callback,
  );

  static Future<String> getActivationToken(int viewId) async {
    final completer = Completer<String>();
    _getActivationToken(
      viewId,
      NativeCallable<Void Function(Pointer<Utf8>)>.isolateLocal((Pointer<Utf8> token) {
        completer.complete(token.toDartString());
      }).nativeFunction,
    );
    return completer.future;
  }
}
