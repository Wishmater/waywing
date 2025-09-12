import "package:dartx/dartx_io.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/config.dart";
import "package:waywing/widgets/text_icon.dart";
import "package:xdg_icons/xdg_icons.dart";

enum IconType {
  direct, // image data received directly from apps through dbus or other protocols
  flutter, // flutter material icon
  linux, // standard xdg/freedesktop icons read from environmnet
  nerdFont,
}

// TODO: 2 ICONS migrate modules to use WingedIcon: nm, tray, notifications
// TODO: 3 is there a way to use nerdFonts from their "class" name, so we can use them for apps, OS, and such dynamically

class WingedIcon extends StatelessWidget {
  final ImageData? directImageData;
  final IconData? flutterIcon;
  final List<String>? iconNames; // linux
  final String? textIcon; // nerdFont

  /// defaults to to iconPriorities defined in mainConfig
  final List<IconType>? iconPriorities;

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
    var remainingIconPriorities = iconPriorities ?? mainConfig.theme.iconPriority;
    while (remainingIconPriorities.isNotEmpty) {
      final iconType = remainingIconPriorities.first;
      remainingIconPriorities = remainingIconPriorities.sublist(1);

      switch (iconType) {
        case IconType.direct:
          if (directImageData == null) continue;
          if (directBuilder != null) {
            return directBuilder!(context);
          } else {
            return _WingedRawIcon(
              directImageData: directImageData!,
              flutterIcon: flutterIcon,
              iconNames: iconNames,
              textIcon: textIcon,
              iconPriorities: remainingIconPriorities,
              notFoundBuilder: notFoundBuilder,
              size: size,
              color: color,
              directBuilder: directBuilder,
              flutterBuilder: flutterBuilder,
              linuxBuilder: linuxBuilder,
              textIconBuilder: textIconBuilder,
            );
          }

        case IconType.flutter:
          if (flutterIcon == null) continue;
          if (flutterBuilder != null) {
            return flutterBuilder!(context);
          } else {
            return Icon(flutterIcon!);
          }

        case IconType.linux:
          if (this.iconNames == null) continue;
          final iconNames = this.iconNames!.where((e) => e.isNotEmpty).toList();
          if (iconNames.isEmpty) continue;
          if (linuxBuilder != null) {
            return linuxBuilder!(context);
          } else {
            return _WingedXdgIcon(
              directImageData: directImageData,
              flutterIcon: flutterIcon,
              iconNames: iconNames,
              textIcon: textIcon,
              iconPriorities: remainingIconPriorities,
              notFoundBuilder: notFoundBuilder,
              size: size,
              color: color,
              directBuilder: directBuilder,
              flutterBuilder: flutterBuilder,
              linuxBuilder: linuxBuilder,
              textIconBuilder: textIconBuilder,
            );
          }

        case IconType.nerdFont:
          if (textIcon.isNullOrBlank) continue;
          if (textIconBuilder != null) {
            return textIconBuilder!(context);
          } else {
            return _WingedTextIcon(
              directImageData: directImageData,
              flutterIcon: flutterIcon,
              iconNames: iconNames,
              textIcon: textIcon!,
              iconPriorities: remainingIconPriorities,
              notFoundBuilder: notFoundBuilder,
              size: size,
              color: color,
              directBuilder: directBuilder,
              flutterBuilder: flutterBuilder,
              linuxBuilder: linuxBuilder,
              textIconBuilder: textIconBuilder,
            );
          }
      }
    }

    return notFoundBuilder?.call(context) ?? SizedBox.shrink();
  }
}

sealed class ImageData {}

class RawImageData extends ImageData {
  Uint8List data;
  RawImageData(List<int> data) : data = data is Uint8List ? data : Uint8List.fromList(data);
}

class _WingedRawIcon extends StatefulWidget {
  final ImageData directImageData;
  final IconData? flutterIcon;
  final List<String>? iconNames;
  final String? textIcon;
  final List<IconType> iconPriorities;
  final WidgetBuilder? notFoundBuilder;
  final double? size;
  final Color? color;
  final WidgetBuilder? directBuilder;
  final WidgetBuilder? flutterBuilder;
  final WidgetBuilder? linuxBuilder;
  final WidgetBuilder? textIconBuilder;

  const _WingedRawIcon({
    required this.directImageData,
    required this.flutterIcon,
    required this.iconNames,
    required this.textIcon,
    required this.iconPriorities,
    required this.notFoundBuilder,
    required this.size,
    required this.color,
    required this.directBuilder,
    required this.flutterBuilder,
    required this.linuxBuilder,
    required this.textIconBuilder,
  });

  @override
  State<_WingedRawIcon> createState() => __WingedRawIconState();
}

class __WingedRawIconState extends State<_WingedRawIcon> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _WingedXdgIcon extends StatelessWidget {
  final ImageData? directImageData;
  final IconData? flutterIcon;
  final List<String> iconNames;
  final String? textIcon;
  final List<IconType> iconPriorities;
  final WidgetBuilder? notFoundBuilder;
  final double? size;
  final Color? color;
  final WidgetBuilder? directBuilder;
  final WidgetBuilder? flutterBuilder;
  final WidgetBuilder? linuxBuilder;
  final WidgetBuilder? textIconBuilder;

  const _WingedXdgIcon({
    required this.directImageData,
    required this.flutterIcon,
    required this.iconNames,
    required this.textIcon,
    required this.iconPriorities,
    required this.notFoundBuilder,
    required this.size,
    required this.color,
    required this.directBuilder,
    required this.flutterBuilder,
    required this.linuxBuilder,
    required this.textIconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return XdgIcon(
      name: iconNames.first,
      size: size?.round(),
      // color: color,
      iconNotFoundBuilder: () {
        if (iconNames.length > 1) {
          return _WingedXdgIcon(
            directImageData: directImageData,
            flutterIcon: flutterIcon,
            iconNames: iconNames.sublist(1),
            textIcon: textIcon,
            iconPriorities: iconPriorities,
            notFoundBuilder: notFoundBuilder,
            size: size,
            color: color,
            directBuilder: directBuilder,
            flutterBuilder: flutterBuilder,
            linuxBuilder: linuxBuilder,
            textIconBuilder: textIconBuilder,
          );
        } else {
          return WingedIcon(
            directImageData: directImageData,
            flutterIcon: flutterIcon,
            iconNames: iconNames,
            textIcon: textIcon,
            iconPriorities: iconPriorities,
            notFoundBuilder: notFoundBuilder,
            size: size,
            color: color,
            directBuilder: directBuilder,
            flutterBuilder: flutterBuilder,
            linuxBuilder: linuxBuilder,
            textIconBuilder: textIconBuilder,
          );
        }
      },
    );
  }
}

class _WingedTextIcon extends StatelessWidget {
  final ImageData? directImageData;
  final IconData? flutterIcon;
  final List<String>? iconNames;
  final String textIcon;
  final List<IconType> iconPriorities;
  final WidgetBuilder? notFoundBuilder;
  final double? size;
  final Color? color;
  final WidgetBuilder? directBuilder;
  final WidgetBuilder? flutterBuilder;
  final WidgetBuilder? linuxBuilder;
  final WidgetBuilder? textIconBuilder;

  const _WingedTextIcon({
    required this.directImageData,
    required this.flutterIcon,
    required this.iconNames,
    required this.textIcon,
    required this.iconPriorities,
    required this.notFoundBuilder,
    required this.size,
    required this.color,
    required this.directBuilder,
    required this.flutterBuilder,
    required this.linuxBuilder,
    required this.textIconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return TextIcon(
      text: textIcon,
      size: size,
      color: color,
      // // TODO: 2 how to know if textIcon is "not found" (there is no font that can render the glyph)
      //
      // iconNotFoundBuilder: () {
      //   return WingedIcon(
      //   );
      // },
    );
  }
}
