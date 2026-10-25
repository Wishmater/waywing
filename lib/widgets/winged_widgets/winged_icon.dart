import "dart:math";
import "dart:typed_data";

import "package:flutter/material.dart";
import "package:fz_icons/fz_icons.dart" as fz;
import "package:waywing/core/config.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";

// TODO: 2 ICONS migrate modules to use WingedIcon: nm, tray, notifications
// TODO: 3 is there a way to use nerdFonts from their "class" name, so we can use them for apps, OS, and such dynamically

/// Waywing wrapper around [fz.FzIcon] that wires the app config into the icon
/// resolver: icon priority, and material symbols style for flutter icons.
class WingedIcon extends StatelessWidget {
  final List<fz.ImageData>? directImageData;
  final IconData? flutterIcon;
  final List<String>? iconNames; // linux
  final String? textIcon; // nerdFont

  /// defaults to icon priorities defined in mainConfig
  final List<fz.IconType>? iconPriorities;

  /// defaults to building SizedBox.empty()
  final WidgetBuilder? notFoundBuilder;

  final double? size;
  final Color? color;

  /// specific builders if there is the need to build a more complicated widget for a type
  /// this will override the default widget built from value
  final WidgetBuilder? directBuilder;
  final WidgetBuilder? flutterBuilder;
  final WidgetBuilder? linuxBuilder;
  final WidgetBuilder? textIconBuilder;

  const WingedIcon({
    this.directImageData,
    this.flutterIcon,
    this.iconNames,
    this.textIcon,
    this.iconPriorities,
    this.notFoundBuilder,
    this.size,
    this.color,
    this.directBuilder,
    this.flutterBuilder,
    this.linuxBuilder,
    this.textIconBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    fz.FzIcon.defaultShowDebugTooltip = mainConfig.internalDebugIcons;
    return fz.FzIcon(
      directImageData: directImageData,
      flutterIcon: flutterIcon,
      iconNames: iconNames,
      textIcon: textIcon,
      iconPriorities: iconPriorities ?? mainConfig.theme.iconPriority,
      notFoundBuilder: notFoundBuilder,
      size: size,
      color: color,
      directBuilder: directBuilder,
      // Use our SymbolIcon so mainConfig's fill/weight/variation apply, while
      // fz's SymbolIcon has no access to mainConfig.
      flutterBuilder:
          flutterBuilder ??
          (flutterIcon == null ? null : (context) => fz.SymbolIcon(flutterIcon!, size: size, color: color)),
      linuxBuilder: linuxBuilder,
      textIconBuilder: textIconBuilder,
    );
  }
}

class PixmapIconsImageData extends fz.ImageData {
  final PixmapIcons pixmapIcons;
  const PixmapIconsImageData(this.pixmapIcons);

  @override
  String toString() {
    return "PixmapIconsImageData: $pixmapIcons";
  }

  @override
  Widget build(BuildContext context, fz.FzRawIcon widget) {
    if (pixmapIcons.icons.isEmpty) {
      return widget.buildFallback(context, "Empty pixmap icons data");
    }
    final size = widget.size ?? fz.TextIcon.getIconEffectiveSize(context);
    Pixmap icon = pixmapIcons.icons[0];
    // TODO: 3 choose the optimal size needed, instead of just getting largest
    for (int i = 1; i < pixmapIcons.icons.length; i++) {
      final e = pixmapIcons.icons[i];
      if ((e.width + e.height) > (icon.width + icon.height)) {
        icon = e;
      }
    }
    return SizedBox.square(
      dimension: min(size, (icon.width + icon.height) / 2),
      child: fz.ARGB32ImageRenderer(
        argb32Data: Uint8List.fromList(icon.data.toList()),
        height: icon.height,
        width: icon.width,
        // TODO: 2 implement fallback if not found
      ),
    );
  }
}
