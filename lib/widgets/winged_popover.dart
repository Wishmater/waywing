import 'package:flutter/material.dart';
import 'package:waywing/widgets/winged_popover_provider.dart';

typedef WingedPopoverChildBuilder =
    Widget Function(
      BuildContext context,
      WingedPopoverController popover,
      Widget? child,
    );

abstract class WingedPopoverController {
  bool get isShown;
  void show();
  void hide();
  void toggle();
}

class WingedPopover extends StatefulWidget {
  final WidgetBuilder popoverBuilder;
  final WingedPopoverChildBuilder builder;
  // TODO: 1 consider removing this and just always skipping 1 frame to get child sizing
  final BoxConstraints popoverConstraints;
  final EdgeInsets screenPadding;
  final Widget? child;
  final bool enabled;

  final String? containerId;

  const WingedPopover({
    required this.popoverBuilder,
    required this.popoverConstraints,
    required this.builder,
    this.child,
    this.containerId,
    this.enabled = true,
    this.screenPadding = EdgeInsets.zero,
    super.key,
  });

  @override
  State<WingedPopover> createState() => WingedPopoverState();
}

class WingedPopoverState extends State<WingedPopover> implements WingedPopoverController {
  late final WingedPopoverProviderState _provider;

  @override
  bool isShown = false;

  // TODO: 1 handle widget.enabled in didUpdateWidget (and maybe add asserts to methods)

  @override
  void initState() {
    super.initState();
    // this fails to detect changes upstream in the tree to register a new provider,
    // but this shouldn't happen in our use case
    _provider = context.findAncestorStateOfType<WingedPopoverProviderState>()!;
  }

  @override
  void dispose() {
    super.dispose();
    if (isShown) {
      hide();
    }
  }

  @override
  void show() => _provider.showHost(this);

  @override
  void hide() => _provider.hideHost(this);

  @override
  void toggle() => _provider.toggleHost(this);

  (Offset, Size) getPositioning() {
    RenderBox box = context.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(
      Offset.zero,
      // // this shouldn't be necessary since we always have a single provider at the root
      // ancestor: _provider?.context.findRenderObject(), // hack to support UI scale
    );
    return (position, box.size);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, this, widget.child);
  }
}
