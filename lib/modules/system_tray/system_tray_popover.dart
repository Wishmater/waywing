import "dart:typed_data";

import "package:dartx/dartx_io.dart";
import "package:flutter/material.dart";
import "package:waywing/modules/system_tray/service/menu.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/winged_button.dart";
import "package:waywing/widgets/winged_container.dart";
import "package:waywing/widgets/winged_popover.dart";
import "package:xdg_icons/xdg_icons.dart";

class SystemTrayPopover extends StatelessWidget {
  final SystemTrayService service;
  final OrgKdeStatusNotifierItemValues item;

  const SystemTrayPopover({
    required this.service,
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final menu = item.dbusmenu!;
    // // unused props that could be useful
    // menu.status; // this seems useless
    // menu.iconThemePaths; // could be needed for some icons
    Widget result = SystemTrayMenu(
      layout: menu.layout,
      depth: 0,
    );
    // // textDirection throws uninitialized exception, this shouldn't be needed anyways
    // final textDirection = switch (menu.textDirection) {
    //   "ltr" => TextDirection.ltr,
    //   "rtl" => TextDirection.rtl,
    //   _ => null,
    // };
    // if (textDirection != null) {
    //   result = Directionality(
    //     textDirection: textDirection,
    //     child: result,
    //   );
    // }
    return IntrinsicHeight(child: IntrinsicWidth(child: result));
  }
}

class SystemTrayMenu extends StatelessWidget {
  final DBusMenuItem layout;
  final int depth;

  const SystemTrayMenu({
    required this.layout,
    required this.depth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final forceIconSpace = layout.submenu.any((e) {
      return e.properties.iconName.isNotEmpty || e.properties.iconData.isNotEmpty;
    });
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 256, maxHeight: 512),
      child: Scrollbar(
        controller: scrollController,
        child: ScrollOpacityGradient(
          scrollController: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: AnimatedBuilder(
              animation: layout,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8),
                    for (final item in layout.submenu) //
                      SystemTrayMenuItem(
                        parent: layout,
                        item: item,
                        depth: depth,
                        forceIconSpace: forceIconSpace,
                      ),
                    SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SystemTrayMenuItem extends StatelessWidget {
  final DBusMenuItem parent;
  final DBusMenuItem item;
  final int depth;
  final bool forceIconSpace;

  const SystemTrayMenuItem({
    super.key,
    required this.parent,
    required this.item,
    required this.depth,
    required this.forceIconSpace,
  });

  @override
  Widget build(BuildContext context) {
    if (!item.properties.visible) {
      return SizedBox.shrink();
    }
    if (item.properties.type == "separator") {
      return Divider(indent: forceIconSpace ? 38 : 16, endIndent: 16);
    }
    // // unused props that could be useful
    // item.properties.toggleType // TODO: 2 toggleable items (need something to test on)
    // item.properties.toggleState // TODO: 2 toggleable items (need something to test on)
    // item.properties.shortcuts // TODO: 2 add shortcuts (sometimes this is empty, yet Strings have "_" to indicate it, like in nm-applet)
    // item.properties.disposition // always "normal" on all examples i've seen
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: WingedPopover(
          builder: (context, popover, _) {
            return WingedButton(
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              alignment: Alignment.centerLeft,
              containedInkWell: true,
              onTap: !item.properties.enabled
                  ? null
                  : item.submenu.isNotEmpty
                  ? () => popover.togglePopover()
                  : () => {}, // dbusmenu.sendEvent(item, DBusMenuEventType.clicked), // TODO: 1 handle click on this item
              child: Row(
                children: [
                  SystemTrayMenuIcon(
                    path: item.properties.iconName,
                    data: item.properties.iconData,
                    forceIconSpace: forceIconSpace,
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          ...item.properties.label.split("_").mapIndexed((i, e) {
                            if (i == 0) return TextSpan(text: e);
                            if (e.isEmpty) return TextSpan();
                            return TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Stack(
                                    children: [
                                      Text(e[0]),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        height: 2,
                                        child: ColoredBox(color: Theme.of(context).textTheme.bodyLarge!.color!),
                                      ),
                                    ],
                                  ),
                                ),
                                // TextSpan(
                                //   text: e[0],
                                //   style: TextStyle(
                                //     decoration: TextDecoration.underline,
                                //     decorationStyle: TextDecorationStyle.solid,
                                //     decorationThickness: 2,
                                //   ),
                                // ),
                                TextSpan(text: e.substring(1)),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  if (item.submenu.isNotEmpty)
                    Transform.translate(
                      offset: Offset(4, 0),
                      child: Icon(
                        Icons.chevron_right,
                        size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.33,
                      ),
                    ),
                ],
              ),
            );
          },
          // TODO: 1 handle menu overflowing when too close to the right
          popoverParams: PopoverParams(
            enabled: item.submenu.isNotEmpty,
            anchorAlignment: Alignment.topRight,
            popupAlignment: Alignment.bottomRight,
            overflowAlignment: Alignment.topLeft,
            // -10 is the zIndex of Bar popups, it's not ideal to have it hardcoded here, but whatever
            zIndex: -10 - 1 - depth,
            containerId: "SystemTrayMenu-${parent.id}",
            builder: (context, _, _) {
              return SystemTrayMenu(
                layout: item,
                depth: depth + 1,
              );
            },
            containerBuilder: (context, _, child) {
              return WingedContainer(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}

class SystemTrayMenuIcon extends StatelessWidget {
  final String path;
  final List<int> data;
  final bool forceIconSpace;

  const SystemTrayMenuIcon({
    required this.path,
    required this.data,
    required this.forceIconSpace,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final size = TextIcon.getIconEffectiveSize(context);
    final size = Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.2;
    const padding = 4.0;
    if (path.isEmpty && data.isEmpty) {
      if (forceIconSpace) {
        return SizedBox(width: size + padding, height: size + padding);
      } else {
        return SizedBox.shrink();
      }
    }
    Widget result;
    if (data.isNotEmpty) {
      result = SizedBox(
        width: size,
        height: size,
        child: Image.memory(Uint8List.fromList(data)),
      );
    } else {
      result = XdgIcon(name: path, size: size.round());
    }
    return Padding(
      padding: EdgeInsets.only(right: padding),
      child: result,
    );
  }
}
