import "dart:typed_data";

import "package:dbus/dbus.dart";
import "package:flutter/material.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/widgets/argb_32_image_renderer.dart";
import "package:waywing/widgets/text_icon.dart";
import "package:waywing/widgets/winged_button.dart";
import "package:waywing/widgets/winged_popover.dart";
import "package:xdg_icons/xdg_icons.dart";

class SystemTrayIndicator extends StatelessWidget {
  final SystemTrayService service;
  final OrgKdeStatusNotifierItemValues item;
  final WingedPopoverController popover;

  const SystemTrayIndicator({
    required this.service,
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
    return GestureDetector(
      onTertiaryTapDown: (_) {
        item.secondaryActivate();
      },
      child: WingedButton(
        onTap: () async {
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
        onSecondaryTap: () {
          tooglePopover();
        },
        child: SystemTrayItemIcon(item: item),
      ),
    );
  }
}

class SystemTrayItemIcon extends StatelessWidget {
  final OrgKdeStatusNotifierItemValues item;

  const SystemTrayItemIcon({
    required this.item,
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

  const SystemTrayIcon({
    required this.iconName,
    required this.iconPixmap,
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
            return RawSystemTrayIcon(path: path, data: data);
          },
        );
      },
    );
  }
}

class RawSystemTrayIcon extends StatelessWidget {
  final String path;
  final PixmapIcons data;

  const RawSystemTrayIcon({
    required this.path,
    required this.data,
    super.key,
  });

  Widget renderPixmap(BuildContext context, double size) {
    if (data != PixmapIcons.empty() && data.icons.isNotEmpty) {
      Pixmap icon = data.icons[0];
      // TODO: 3 choose the optimal size needed, instead of just getting largest
      for (int i = 1; i < data.icons.length; i++) {
        if ((data.icons[i].width + data.icons[i].height) > (icon.width + icon.height)) {
          icon = data.icons[i];
        }
      }
      return SizedBox(
        width: size,
        height: size,
        child: ARGB32ImageRenderer(
          argb32Data: Uint8List.fromList(icon.data.toList()),
          height: icon.height,
          width: icon.width,
        ),
      );
    } else {
      return SizedBox(width: size, height: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = TextIcon.getIconEffectiveSize(context);
    if (path.isNotEmpty) {
      return XdgIcon(name: path, size: size.round(), iconNotFoundBuilder: () {
        return renderPixmap(context, size);
      });
    } else {
      return renderPixmap(context, size);
    }
  }
}
