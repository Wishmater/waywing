import 'package:flutter/material.dart';
import 'package:waywing/util/state_positioning.dart';
import 'package:waywing/widgets/winged_popover_provider.dart';

typedef WidgetBuilderWithChild =
    Widget Function(
      BuildContext context,
      Widget child,
    );

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
  /// Make sure the container doesn't add any padding, or modifies
  /// the size of the child in any way, or the it can cause positioning bugs.
  final WidgetBuilderWithChild popoverContainerBuilder;
  final WidgetBuilder popoverBuilder;
  final WingedPopoverChildBuilder builder;
  final Widget? child;
  final bool enabled;
  final EdgeInsets screenPadding;
  final Alignment anchorAlignment;
  final Alignment popupAlignment;
  final String? containerId;
  final int zIndex;

  const WingedPopover({
    // TODO: 2 maybe set a default for this (probably not)
    required this.popoverContainerBuilder,
    required this.popoverBuilder,
    required this.builder,
    this.child,
    this.containerId,
    this.enabled = true,
    this.screenPadding = EdgeInsets.zero,
    this.anchorAlignment = Alignment.center,
    this.popupAlignment = Alignment.center,
    this.zIndex = 10,
    super.key,
  });

  @override
  State<WingedPopover> createState() => WingedPopoverState();
}

class WingedPopoverState extends State<WingedPopover> with StatePositioningMixin implements WingedPopoverController {
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

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, this, widget.child);
  }
}
