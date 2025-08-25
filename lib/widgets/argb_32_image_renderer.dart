import "dart:async";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "dart:ui" as ui;

class ARGB32ImageRenderer extends StatefulWidget {
  final Uint8List argb32Data; // ARGB32 byte data
  final int width;
  final int height;

  const ARGB32ImageRenderer({
    super.key,
    required this.argb32Data,
    required this.width,
    required this.height,
  });

  @override
  State<ARGB32ImageRenderer> createState() => _ARGB32ImageRendererState();
}

class _ARGB32ImageRendererState extends State<ARGB32ImageRenderer> {
  // TODO: 3 maybe we should implement a proper ImageProvider so it benefits from flutter caching, etc.
  late final imageFuture = _convertARGB32ToImage(widget.argb32Data, widget.width, widget.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width.toDouble(),
      height: widget.height.toDouble(),
      child: FutureBuilder<ui.Image>(
        future: imageFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RawImage(image: snapshot.data, fit: BoxFit.contain);
          } else if (snapshot.hasError) {
            // log error ??
            return SizedBox.shrink();
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Future<ui.Image> _convertARGB32ToImage(Uint8List argb32, int width, int height) async {
    // Convert ARGB32 to RGBA
    final rgbaData = _argb32ToRgba(argb32);

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgbaData,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        completer.complete(image);
      },
    );
    return completer.future;
  }

  Uint8List _argb32ToRgba(Uint8List argb32) {
    // ARGB32: [A, R, G, B] per pixel -> Convert to RGBA: [R, G, B, A]
    final rgbaData = Uint8List(argb32.length);
    for (int i = 0; i < argb32.length; i += 4) {
      rgbaData[i] = argb32[i + 1]; // R
      rgbaData[i + 1] = argb32[i + 2]; // G
      rgbaData[i + 2] = argb32[i + 3]; // B
      rgbaData[i + 3] = argb32[i]; // A
    }
    return rgbaData;
  }
}
