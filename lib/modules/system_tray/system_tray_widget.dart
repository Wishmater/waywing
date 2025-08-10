import "dart:async";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/system_tray/service/istatus_notifier_item.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/widgets/winged_button.dart";
import "package:image/image.dart" as img;
import "dart:ui" as ui;

class SystemTrayWidget extends StatefulWidget {
  final SystemTrayService service;

  const SystemTrayWidget({
    required this.service,
    super.key,
  });

  @override
  State<SystemTrayWidget> createState() => _SystemTrayWidgetState();
}

class _SystemTrayWidgetState extends State<SystemTrayWidget> {
  late final StatusNotifierItemsValues values;

  @override
  void initState() {
    super.initState();
    values = widget.service.values;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: values.items,
      builder: (context, _) {
        if (values.items.value.isEmpty) {
          return SizedBox(
            width: !config.isBarVertical ? config.barItemSize : null,
            height: config.isBarVertical ? config.barItemSize : null,
            child: Text("emtpyz"),
          );
        }
        if (config.isBarVertical) {
          return Column(
            children: [
              for (final item in values.items.value)
                SizedBox(
                  width: !config.isBarVertical ? config.barItemSize : null,
                  height: config.isBarVertical ? config.barItemSize : null,
                  child: Text("${item.title.value} "),
                ),
            ],
          );
        } else {
          return Row(
            children: [
              for (final item in values.items.value) _SystemTrayElementWidget(item),
              // SizedBox(
              //   width: !config.isBarVertical ? config.barItemSize : null,
              //   height: config.isBarVertical ? config.barItemSize : null,
              //   child: Text("${item.title.value} "),
              // ),
            ],
          );
        }
      },
    );
  }
}

class _SystemTrayElementWidget extends StatefulWidget {
  final OrgKdeStatusNotifierItemValues item;

  const _SystemTrayElementWidget(this.item);

  @override
  State<_SystemTrayElementWidget> createState() => _SystemTrayElementState();
}

class _SystemTrayElementState extends State<_SystemTrayElementWidget> {
  OrgKdeStatusNotifierItemValues get item => widget.item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: !config.isBarVertical ? config.barItemSize : null,
      height: config.isBarVertical ? config.barItemSize : null,
      child: _IconUtils(item.iconName.value, item.iconPixmap.value),
    );
  }
}

class _IconUtils extends StatelessWidget {
  final String path;
  final PixmapIcons data;

  const _IconUtils(this.path, this.data);

  @override
  Widget build(BuildContext context) {
    if (data != PixmapIcons.empty()) {
      Pixmap icon = data.icons[0];
      for (int i = 1; i < data.icons.length; i++) {
        if ((data.icons[i].width + data.icons[i].height) > (icon.width + icon.height)) {
          icon = data.icons[i];
        }
      }
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ARGB32ImageRenderer(
          argb32Data: Uint8List.fromList(icon.data.toList()),
          height: icon.height,
          width: icon.width,
        ),
      );
    } else {
      return Text(path);
    }
  }
}

class ARGB32ImageRenderer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.toDouble(),
      height: height.toDouble(),
      child: FutureBuilder<ui.Image>(
        future: _convertARGB32ToImage(argb32Data, width, height),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return RawImage(image: snapshot.data, fit: BoxFit.contain);
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return const CircularProgressIndicator();
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
