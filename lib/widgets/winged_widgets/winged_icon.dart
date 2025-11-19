import "dart:io";

import "package:dartx/dartx_io.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";
import "package:waywing/widgets/argb_32_image_renderer.dart";
import "package:waywing/widgets/icons/symbol_icon.dart";
import "package:waywing/widgets/icons/text_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";
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
  final List<ImageData>? directImageData;
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

  final IconUsageLog? _iconUsageLog;

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
  }) : _iconUsageLog = null;

  const WingedIcon._({
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
    required IconUsageLog iconUsageLog,
  }) : _iconUsageLog = iconUsageLog;

  @override
  Widget build(BuildContext context) {
    final iconUsageLog = _iconUsageLog ?? IconUsageLog();
    Widget result = buildContent(context, iconUsageLog);
    if (mainConfig.internalDebugIcons && _iconUsageLog == null) {
      result = buildIconDebugTooltip(context, result, iconUsageLog);
    }
    return result;
  }

  Widget buildContent(BuildContext context, IconUsageLog iconUsageLog) {
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
              iconUsageLog: iconUsageLog,
            );
          }

        case IconType.flutter:
          if (flutterIcon == null) continue;
          if (flutterBuilder != null) {
            return flutterBuilder!(context);
          } else {
            return SymbolIcon(
              flutterIcon!,
              size: size,
              color: color,
            );
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
              iconUsageLog: iconUsageLog,
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
              iconUsageLog: iconUsageLog,
            );
          }
      }
    }
    return notFoundBuilder?.call(context) ?? SizedBox.shrink();
  }

  Widget buildIconDebugTooltip(BuildContext context, Widget child, IconUsageLog iconUsageLog) {
    return WingedTooltip(
      child: child,
      tooltipBuilder: (context) {
        final theme = Theme.of(context);
        final tooltipContent = <Widget>[];
        var remainingIconPriorities = iconPriorities ?? mainConfig.theme.iconPriority;
        bool passSuccess = false;
        while (remainingIconPriorities.isNotEmpty) {
          final iconType = remainingIconPriorities.first;
          remainingIconPriorities = remainingIconPriorities.sublist(1);
          switch (iconType) {
            case IconType.direct:
              if (directImageData == null || directImageData!.isEmpty) {
                continue;
              }
              if (tooltipContent.isNotEmpty) {
                tooltipContent.add(Divider());
              }
              tooltipContent.add(
                Text(
                  "Direct",
                  style: theme.textTheme.bodyLarge,
                ),
              );
              for (final e in directImageData!) {
                final error = iconUsageLog.directImageDataErrors[e];
                final lineContent = <InlineSpan>[];
                lineContent.add(TextSpan(text: e.toString()));
                if (error != null) {
                  lineContent.addAll([
                    TextSpan(text: "   "),
                    TextSpan(
                      text: error,
                      style: theme.textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ]);
                } else if (!passSuccess) {
                  lineContent.addAll([
                    TextSpan(text: "   "),
                    TextSpan(
                      text: "SHOWING",
                      style: theme.textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ]);
                }
                tooltipContent.add(Text.rich(TextSpan(children: lineContent)));
                if (error == null) passSuccess = true;
              }
            case IconType.flutter:
              if (flutterIcon == null) {
                continue;
              }
              if (tooltipContent.isNotEmpty) {
                tooltipContent.add(Divider());
              }
              tooltipContent.addAll([
                Text(
                  "Flutter",
                  style: theme.textTheme.bodyLarge,
                ),
                if (!passSuccess)
                  Text(
                    "SHOWING",
                    style: theme.textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
              ]);
              passSuccess = true;
            case IconType.linux:
              if (iconNames == null || iconNames!.isEmpty) {
                continue;
              }
              if (tooltipContent.isNotEmpty) {
                tooltipContent.add(Divider());
              }
              tooltipContent.add(
                Text(
                  "Linux",
                  style: theme.textTheme.bodyLarge,
                ),
              );
              for (final e in iconNames!) {
                final error = iconUsageLog.iconNamesErrors[e];
                final lineContent = <InlineSpan>[];
                lineContent.add(TextSpan(text: e));
                if (error != null) {
                  lineContent.addAll([
                    TextSpan(text: "   "),
                    TextSpan(
                      text: error,
                      style: theme.textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ]);
                } else if (!passSuccess) {
                  lineContent.addAll([
                    TextSpan(text: "   "),
                    TextSpan(
                      text: "SHOWING",
                      style: theme.textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ]);
                }
                tooltipContent.add(Text.rich(TextSpan(children: lineContent)));
                if (error == null) passSuccess = true;
              }
            case IconType.nerdFont:
              if (textIcon == null) {
                continue;
              }
              if (tooltipContent.isNotEmpty) {
                tooltipContent.add(Divider());
              }
              tooltipContent.add(
                Text(
                  "Nerd Font",
                  style: theme.textTheme.bodyLarge,
                ),
              );
              final error = iconUsageLog.textIconError;
              final lineContent = <InlineSpan>[];
              lineContent.add(TextSpan(text: "$textIcon  "));
              if (error != null) {
                lineContent.addAll([
                  TextSpan(text: "   "),
                  TextSpan(
                    text: error,
                    style: theme.textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ]);
              } else if (!passSuccess) {
                lineContent.addAll([
                  TextSpan(text: "   "),
                  TextSpan(
                    text: "SHOWING",
                    style: theme.textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ]);
              }
              tooltipContent.add(Text.rich(TextSpan(children: lineContent)));
              if (error == null) passSuccess = true;
          }
        }
        if (tooltipContent.isEmpty) {
          tooltipContent.add(Text("< no icons set >"));
        }
        tooltipContent.insertAll(0, [
          Text("Icon types debug info"),
          Divider(),
        ]);
        return IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: tooltipContent,
          ),
        );
      },
    );
  }
}

sealed class ImageData {
  const ImageData();
}

class AbsolutePathFileImageData extends ImageData {
  final String absolutePath;
  const AbsolutePathFileImageData(this.absolutePath);

  @override
  String toString() {
    return "AbsolutePathFileImageData: $absolutePath";
  }
}

class RawImageData extends ImageData {
  // TODO 3: raw image needs some kind of information
  // for the widget to know how to render it
  final Uint8List data;
  RawImageData(List<int> data) : data = data is Uint8List ? data : Uint8List.fromList(data);

  @override
  String toString() {
    return "RawImageData: length = ${data.length}";
  }
}

class PixmapIconsImageData extends ImageData {
  final PixmapIcons pixmapIcons;
  const PixmapIconsImageData(this.pixmapIcons);

  @override
  String toString() {
    return "PixmapIconsImageData: iconCount = ${pixmapIcons.icons.length}";
  }
}

class _WingedRawIcon extends StatelessWidget {
  final List<ImageData> directImageData;
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
  final IconUsageLog iconUsageLog;

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
    required this.iconUsageLog,
  });

  @override
  Widget build(BuildContext context) {
    return switch (directImageData.first) {
      AbsolutePathFileImageData data => buildAbsolutePathFileImageData(context, data),
      PixmapIconsImageData data => buildPixmapIconsImageData(context, data),
      RawImageData data => buildRawImageData(context, data),
    };
  }

  Widget buildRawImageData(BuildContext context, RawImageData data) {
    final size = this.size ?? TextIcon.getIconEffectiveSize(context);
    return Image.memory(
      data.data,
      width: size,
      height: size,
      errorBuilder: (context, e, st) {
        return buildFallback(context, e.toString());
      },
    );
  }

  Widget buildAbsolutePathFileImageData(BuildContext context, AbsolutePathFileImageData data) {
    final size = this.size ?? TextIcon.getIconEffectiveSize(context);
    return Image.file(
      File(data.absolutePath),
      width: size,
      height: size,
      errorBuilder: (context, e, st) {
        return buildFallback(context, e.toString());
      },
    );
  }

  Widget buildPixmapIconsImageData(BuildContext context, PixmapIconsImageData data) {
    if (data.pixmapIcons.icons.isEmpty) {
      return buildFallback(context, "Empty pixmap icons data");
    }
    final size = this.size ?? TextIcon.getIconEffectiveSize(context);
    Pixmap icon = data.pixmapIcons.icons[0];
    // TODO: 3 choose the optimal size needed, instead of just getting largest
    for (int i = 1; i < data.pixmapIcons.icons.length; i++) {
      final e = data.pixmapIcons.icons[i];
      if ((e.width + e.height) > (icon.width + icon.height)) {
        icon = e;
      }
    }
    return SizedBox.square(
      dimension: size,
      child: ARGB32ImageRenderer(
        argb32Data: Uint8List.fromList(icon.data.toList()),
        height: icon.height,
        width: icon.width,
        // TODO: 2 implement fallback if not found
      ),
    );
  }

  Widget buildFallback(BuildContext context, String error) {
    iconUsageLog.directImageDataErrors[directImageData.first] = error;
    if (directImageData.length > 1) {
      return _WingedRawIcon(
        directImageData: directImageData.sublist(1),
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
        iconUsageLog: iconUsageLog,
      );
    } else {
      return WingedIcon._(
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
        iconUsageLog: iconUsageLog,
      );
    }
  }
}

class _WingedXdgIcon extends StatelessWidget {
  final List<ImageData>? directImageData;
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
  final IconUsageLog iconUsageLog;

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
    required this.iconUsageLog,
  });

  @override
  Widget build(BuildContext context) {
    return XdgIcon(
      name: iconNames.first,
      size: size?.round(),
      // color: color,
      iconNotFoundBuilder: () {
        iconUsageLog.iconNamesErrors[iconNames.first] = "Icon not found";
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
            iconUsageLog: iconUsageLog,
          );
        } else {
          return WingedIcon._(
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
            iconUsageLog: iconUsageLog,
          );
        }
      },
    );
  }
}

class _WingedTextIcon extends StatelessWidget {
  final List<ImageData>? directImageData;
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
  final IconUsageLog iconUsageLog;

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
    required this.iconUsageLog,
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

class IconSpacer extends StatelessWidget {
  final double? size;

  const IconSpacer({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: size ?? TextIcon.getIconEffectiveSize(context));
  }
}

class IconUsageLog {
  final Map<ImageData, String> directImageDataErrors = {};
  final Map<String, String> iconNamesErrors = {}; // linux
  String? textIconError; // nerdFont
}
