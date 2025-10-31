import "dart:async";

import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:flutter/widgets.dart";
import "package:waywing/util/logger.dart";
import "./handler.dart";

const deprecationMessage =
    "This has a lot of bugs, and limited compositor support.\n"
    "We can achieve the same by just declaring an InputRegion "
    "that covers the whole screen and handling clicks ourselves.\n"
    "It would make sense to go through this trouble if focusGrab protocol "
    "at least didn't eat the click, but the way it is implemented in hyprland "
    "at least offers no advantage over manually handling clicks with a screen-wide input region";

/// {@template request}
/// An active request means that the focus grab is currently active
///
/// An inactive request instead does not means that the focus grab is inactive,
/// instead means that this widget does not need the focus grab anymore
/// {@endtemplate}

@Deprecated(deprecationMessage)
class _FocusGrabControllerInternal {
  final _handler = FocusGrabHandler();

  FocusGrabRequest? _request;

  bool _requestFocusGrab() {
    if (_request != null) return false;
    _request = _handler.requestFocusGrab();
    return true;
  }

  bool _removeFocusGrab() {
    if (_request != null) {
      // throw StateError("DEBUGGING :)");
      _handler.removeFocusGrab(_request!);
      _request = null;
      return true;
    }
    return false;
  }
}

@Deprecated(deprecationMessage)
class FocusGrabController {
  static final Finalizer<_FocusGrabControllerInternal> _finalizer = Finalizer((internal) {
    if (internal._removeFocusGrab()) {
      mainLogger.error(
        "ERROR: FocusGrabController is being garbage collected "
        "but the focus grab is still active. A call to ungrabFocus is missing",
      );
    }
  });

  final _FocusGrabControllerInternal _internal;

  FocusGrabRequest? get request => _internal._request;

  /// Called when the focus grab object is cleared
  final VoidCallback onCleared;

  late final StreamSubscription<()> foucsSubscription;

  FocusGrabController({required this.onCleared}) : _internal = _FocusGrabControllerInternal() {
    foucsSubscription = FlLinuxWindowManager.instance.focusGrabCleared.listen((_) {
      final req = request;
      if (req != null) {
        onCleared.call();
        _internal._handler.removeFocusGrab(req);
      }
      _internal._request = null;
    });
    _finalizer.attach(this, _internal);
  }

  /// Send a request to grab the focus if the FocusGrab widget does not have
  /// an active request
  ///
  /// {@macro request}
  void grabFocus() {
    _internal._requestFocusGrab();
  }

  /// Cancel the request for the focus grab if there is an active request for the grab
  ///
  /// {@macro request}
  void ungrabFocus() {
    _internal._removeFocusGrab();
  }
}

@Deprecated(deprecationMessage)
class FocusGrab extends StatefulWidget {
  const FocusGrab({
    super.key,
    required this.child,
    required this.controller,
  });

  final Widget child;

  final FocusGrabController controller;

  @override
  State<FocusGrab> createState() => FocusGrabState();
}

@Deprecated(deprecationMessage)
class FocusGrabState extends State<FocusGrab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
