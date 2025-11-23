import "package:dbus/dbus.dart";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/modules/system_tray/system_tray_feather.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";
import "package:xdg_icons/xdg_icons.dart";

class SystemTrayIndicator extends StatelessWidget {
  final SystemTrayService service;
  final SystemTrayConfig configuration;
  final OrgKdeStatusNotifierItemValues item;
  final WingedPopoverController popover;

  const SystemTrayIndicator({
    required this.service,
    required this.configuration,
    required this.item,
    required this.popover,
    super.key,
  });

  void tooglePopover() {
    popover.togglePopover();
    if (item.dbusmenu != null && popover.isPopoverShown) {
      item.dbusmenu!.aboutToShow(item.dbusmenu!.layout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        iconTheme: theme.iconTheme.copyWith(
          size: configuration.iconSizeAdapted,
        ),
      ),
      child: XdgIconTheme(
        data: XdgIconThemeData(
          size: configuration.iconSizeAdapted.round(),
        ),
        child: GestureDetector(
          // TODO: 2 should onTertiaryTap be added to WingedButton?
          onTertiaryTapDown: (_) {
            item.secondaryActivate();
          },
          child: WingedButton(
            onTap: (_, _) async {
              if (!item.itemIsMenu) {
                try {
                  await item.primaryActivate();
                } on DBusUnknownMethodException catch (_) {
                  // if activate is not available then assume itemIsMenu is wrong
                  // and this is an only menu item
                  tooglePopover();
                }
              } else {
                tooglePopover();
              }
            },
            onSecondaryTap: (_, _) {
              tooglePopover();
            },
            child: SystemTrayItemIcon(item: item, configuration: configuration),
          ),
        ),
      ),
    );
  }
}

class SystemTrayItemIcon extends StatelessWidget {
  final OrgKdeStatusNotifierItemValues item;
  final SystemTrayConfig configuration;

  const SystemTrayItemIcon({
    required this.item,
    required this.configuration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return switch (item.status.value) {
      // TODO: 2 what icon should passive show or should passive be shown?
      "Passive" => SystemTrayIcon(
        iconName: item.iconName,
        iconPixmap: item.iconPixmap,
      ),
      "Active" => SystemTrayIcon(
        iconName: item.iconName,
        iconPixmap: item.iconPixmap,
      ),
      "NeedsAttention" => SystemTrayIcon(
        iconName: item.attentionIconName,
        iconPixmap: item.attentionIconPixmap,
      ),
      _ => SystemTrayIcon(
        iconName: item.iconName,
        iconPixmap: item.iconPixmap,
      ),
    };
  }
}

class SystemTrayIcon extends StatelessWidget {
  final DBusValueSignalNotifier<String> iconName;
  final DBusValueSignalNotifier<PixmapIcons> iconPixmap;
  final double? size;

  const SystemTrayIcon({
    required this.iconName,
    required this.iconPixmap,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: iconName,
      builder: (context, path, _) {
        return ValueListenableBuilder(
          valueListenable: iconPixmap,
          builder: (context, data, _) {
            return RawSystemTrayIcon(path: path, data: data, size: size);
          },
        );
      },
    );
  }
}

class RawSystemTrayIcon extends StatelessWidget {
  final String path;
  final PixmapIcons data;
  final double? size;

  const RawSystemTrayIcon({
    required this.path,
    required this.data,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isAbsolutePath = isAbsolute(path);
    return WingedIcon(
      size: size,
      directImageData: [
        if (path.isNotEmpty && isAbsolutePath) AbsolutePathFileImageData(path),
        PixmapIconsImageData(data),
      ],
      iconNames: [
        if (path.isNotEmpty && !isAbsolutePath) path,
      ],
      notFoundBuilder: (context) {
        return IconSpacer(size: size);
      },
    );
  }
}
