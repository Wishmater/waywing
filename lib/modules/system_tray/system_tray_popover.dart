import "dart:typed_data";

import "package:dartx/dartx_io.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/system_tray/service/menu.dart";
import "package:waywing/modules/system_tray/service/status_item.dart";
import "package:waywing/modules/system_tray/service/system_tray_service.dart";
import "package:waywing/widgets/motion_layout/motion_column.dart";
import "package:waywing/widgets/motion_widgets/motion_divider.dart";
import "package:waywing/widgets/motion_widgets/motion_intrinsic_size.dart";
import "package:waywing/widgets/disposable_builder.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";
import "package:xdg_icons/xdg_icons.dart";

class SystemTrayPopover extends StatelessWidget {
  final SystemTrayService service;
  final OrgKdeStatusNotifierItemValues trayItem;

  const SystemTrayPopover({
    required this.service,
    required this.trayItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final menu = trayItem.dbusmenu!;
    // // unused props that could be useful
    // menu.status; // this seems useless
    // menu.iconThemePaths; // could be needed for some icons
    Widget result = SystemTrayMenu(
      service: service,
      trayItem: trayItem,
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
    return KeyedSubtree(
      key: ValueKey(trayItem.id),
      child: IntrinsicHeight(child: IntrinsicWidth(child: result)),
    );
  }
}

class SystemTrayMenu extends StatefulWidget {
  final SystemTrayService service;
  final OrgKdeStatusNotifierItemValues trayItem;
  final DBusMenuItem layout;
  final int depth;

  const SystemTrayMenu({
    required this.service,
    required this.trayItem,
    required this.layout,
    required this.depth,
    super.key,
  });

  @override
  State<SystemTrayMenu> createState() => _SystemTrayMenuState();
}

// this needs to be stateful to use the state hashCode as an identifier
class _SystemTrayMenuState extends State<SystemTrayMenu> {
  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 256, maxHeight: 512),
      child: Scrollbar(
        controller: scrollController,
        child: ScrollOpacityGradient(
          scrollController: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            child: DisposableAnimatedBuilder(
              animation: widget.layout,
              builder: (context, child) {
                final forceIconSpace = widget.layout.submenu.any((e) {
                  return e.properties.iconName.isNotEmpty || e.properties.iconData.isNotEmpty;
                });
                // TODO: 3 we shouldn't do this in build
                final wrappedItems = <WrappedDbusMenuItem>[];
                int subgroup = 0;
                for (final e in widget.layout.submenu) {
                  var isSeparator = false;
                  final int timesRepeated;
                  if (e.properties.type == "separator") {
                    subgroup++;
                    isSeparator = true;
                    timesRepeated = wrappedItems.count((o) => o.isSeparator && o.subgroup == subgroup);
                  } else {
                    timesRepeated = wrappedItems.count(
                      (o) => !o.isSeparator && o.item.properties.label == e.properties.label,
                    );
                  }
                  wrappedItems.add(WrappedDbusMenuItem(e, subgroup, timesRepeated, isSeparator));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: MotionColumn<WrappedDbusMenuItem>(
                    motion: mainConfig.motions.standard.spatial.normal,
                    addGlobalKeys: true,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    data: wrappedItems,
                    itemBuilder: (context, wappedItem) {
                      return SystemTrayMenuItem(
                        service: widget.service,
                        trayItem: widget.trayItem,
                        uniqueID: "SystemTrayMenu-$hashCode",
                        item: wappedItem.item,
                        depth: widget.depth,
                        forceIconSpace: forceIconSpace,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SystemTrayMenuItem extends StatefulWidget {
  final SystemTrayService service;
  final OrgKdeStatusNotifierItemValues trayItem;
  final DBusMenuItem item;
  final int depth;
  final bool forceIconSpace;
  final String uniqueID;

  const SystemTrayMenuItem({
    required this.service,
    required this.trayItem,
    required this.item,
    required this.depth,
    required this.forceIconSpace,
    required this.uniqueID,
    super.key,
  });

  @override
  State<SystemTrayMenuItem> createState() => _SystemTrayMenuItemState();
}

// this needs to be stateful to use the state hashCode as an identifier
class _SystemTrayMenuItemState extends State<SystemTrayMenuItem> {
  @override
  Widget build(BuildContext context) {
    return DisposableAnimatedBuilder(
      animation: widget.item,
      builder: (context, _) {
        if (!widget.item.properties.visible) {
          return SizedBox.shrink();
        }
        if (widget.item.properties.type == "separator") {
          // TODO: 2 remove separators when there are two in a row or first/last on the list
          return MotionDivider.horizontal(
            motion: mainConfig.motions.standard.spatial.normal,
            indent: widget.forceIconSpace ? 38 : 16,
            endIndent: 16,
            thickness: 0.5,
            radius: BorderRadius.circular(0.25),
          );
        }
        // // unused props that could be useful
        // item.properties.toggleType // TODO: 2 toggleable items (need something to test on)
        // item.properties.toggleState // TODO: 2 toggleable items (need something to test on)
        // item.properties.shortcuts // TODO: 2 add shortcuts (sometimes this is empty, yet Strings have "_" to indicate it, like in nm-applet)
        // item.properties.disposition // always "normal" on all examples i've seen
        return IntrinsicWidth(
          child: IntrinsicHeight(
            // TODO: 1 in nm-applet, when seeing available APs, when the available APs are refreshed,
            // it will close an open AP submenu, presumably because this is re-initialized.
            child: WingedPopover(
              builder: (context, popover, _) {
                return DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: widget.item.properties.enabled ? null : Theme.of(context).disabledColor,
                    height: 1.33,
                  ),
                  child: WingedButton(
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 30),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    alignment: Alignment.centerLeft,
                    containedInkWell: true,
                    onTap: !widget.item.properties.enabled || widget.item.isDisposed
                        ? null
                        : widget.item.submenu.isNotEmpty
                        ? () {
                            popover.togglePopover();
                            if (popover.isPopoverShown) {
                              widget.trayItem.dbusmenu!.aboutToShow(widget.item);
                            }
                          }
                        // TODO: 3 do we need to send events for the other event types? (hover, opened, closed, etc.)
                        : () => widget.trayItem.dbusmenu!.sendEvent(widget.item, DBusMenuEventType.clicked),
                    child: Row(
                      children: [
                        AnimatedIntrinsicSize(
                          motion: mainConfig.motions.standard.spatial.normal,
                          child: SystemTrayMenuIcon(
                            item: widget.item,
                            forceIconSpace: widget.forceIconSpace,
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                ...widget.item.properties.label.split("_").mapIndexed((i, e) {
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
                                              child: ColoredBox(
                                                color: widget.item.properties.enabled
                                                    ? Theme.of(context).textTheme.bodyLarge!.color!
                                                    : Theme.of(context).disabledColor,
                                              ),
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
                        if (widget.item.submenu.isNotEmpty)
                          Transform.translate(
                            offset: Offset(4, 0),
                            child: WingedIcon(
                              flutterIcon: SymbolsVaried.chevron_right,
                              iconNames: ["arrow-right"],
                              textIcon: "󰅂", // nf-md-chevron_right
                              size: Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.33,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              // TODO: 1 handle menu overflowing when too close to the right
              // TODO: 1 this should be a tooltip (opening on hover), not a popover
              // this requires implementing the chain of depndant popovers, so we can keep
              // parents alive while children are hovered, and also so we can instatly close
              // children when parents are closed (instead of waiting for the end of parent
              // animation to close child, which looks really weird)
              popoverParams: PopoverParams(
                motion: mainConfig.motions.standard.spatial.normal,
                enabled: widget.item.submenu.isNotEmpty && !widget.item.isDisposed,
                anchorAlignment: Alignment.topRight,
                popupAlignment: Alignment.bottomRight,
                overflowAlignment: Alignment.topLeft,
                // -10 is the zIndex of Bar popups, it's not ideal to have it hardcoded here, but whatever
                zIndex: -10 - 1 - widget.depth,
                containerId: widget.uniqueID,
                extraOffset: Offset(0, -8),
                stickToHost: true,
                builder: (context, _, _) {
                  return SystemTrayMenu(
                    // make sure the state is dispose when switching to another popover
                    key: ValueKey("SystemTrayMenu-$hashCode"),
                    service: widget.service,
                    trayItem: widget.trayItem,
                    layout: widget.item,
                    depth: widget.depth + 1,
                  );
                },
                containerBuilder: (context, _, child) {
                  return WingedContainer(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class SystemTrayMenuIcon extends StatefulWidget {
  final DBusMenuItem item;
  final bool forceIconSpace;

  const SystemTrayMenuIcon({
    required this.item,
    required this.forceIconSpace,
    super.key,
  });

  String get path => item.properties.iconName;
  List<int> get data => item.properties.iconData;

  @override
  State<SystemTrayMenuIcon> createState() => _SystemTrayMenuIconState();
}

class _SystemTrayMenuIconState extends State<SystemTrayMenuIcon> {
  ImageProvider? imageProvider;

  ImageProvider getImageProvider() {
    return MemoryImage(Uint8List.fromList(widget.data));
  }

  @override
  void didUpdateWidget(covariant SystemTrayMenuIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.id != oldWidget.item.id) {}
  }

  Future<void> reloadImage() async {
    try {
      final newImageProvider = getImageProvider();
      final newWidget = widget;
      await precacheImage(newImageProvider, context);
      if (!mounted) return;
      if (widget != newWidget) return;
      setState(() {
        imageProvider = newImageProvider;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // final size = TextIcon.getIconEffectiveSize(context);
    final size = Theme.of(context).textTheme.bodyLarge!.fontSize! * 1.2;
    const padding = 4.0;
    if (widget.path.isEmpty && widget.data.isEmpty) {
      if (widget.forceIconSpace) {
        return SizedBox(width: size + padding, height: size + padding);
      } else {
        return SizedBox.shrink();
      }
    }
    Widget result;
    // TODO: 1 migrate to WingedIcon
    if (widget.data.isNotEmpty) {
      imageProvider ??= getImageProvider();
      result = SizedBox(
        width: size,
        height: size,
        child: Image(image: imageProvider!),
      );
    } else {
      result = XdgIcon(name: widget.path, size: size.round());
    }
    return Padding(
      padding: EdgeInsets.only(right: padding),
      child: result,
    );
  }
}

class WrappedDbusMenuItem {
  final DBusMenuItem item;
  final int subgroup;
  final int timesRepeated;
  final bool isSeparator;

  WrappedDbusMenuItem(this.item, this.subgroup, this.timesRepeated, this.isSeparator);

  @override
  int get hashCode => Object.hash(item.properties.label, subgroup, timesRepeated);
  // int get hashCode => item.id.hashCode; // id is unreliable, it changes on update
  // int get hashCode => item.properties.label.hashCode; // label can be repeated

  @override
  bool operator ==(Object other) {
    if (other is WrappedDbusMenuItem) {
      return subgroup == other.subgroup &&
          timesRepeated == other.timesRepeated &&
          isSeparator == other.isSeparator &&
          item.properties.label == other.item.properties.label;
    }
    // if (other is WrappedDbusMenuItem) return item.id == other.item.id;
    // if (other is WrappedDbusMenuItem) return item.properties.label == other.item.properties.label;
    return super == other;
  }
}
