import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:fl_linux_window_manager/models/keyboard_mode.dart";
import "package:flutter/material.dart";

class KeyboardFocus extends StatefulWidget {
  final Widget child;

  const KeyboardFocus({
    required this.child,
    super.key,
  });

  @override
  State<KeyboardFocus> createState() => _KeyboardFocusState();
}

class _KeyboardFocusState extends State<KeyboardFocus> {
  late final _KeyboardFocusProviderState provider;

  @override
  void initState() {
    super.initState();
    // assumes the provider won't change during the lifetime of this widget, which should be true
    provider = context.findAncestorStateOfType<_KeyboardFocusProviderState>()!;
  }

  @override
  void dispose() {
    super.dispose();
    provider.removeFocus(this);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (isFocused) {
        if (isFocused) {
          provider.requestFocus(this);
        } else {
          provider.removeFocus(this);
        }
      },
      child: widget.child,
    );
  }
}

class KeyboardFocusProvider extends StatefulWidget {
  final Widget child;
  const KeyboardFocusProvider({
    required this.child,
    super.key,
  });

  @override
  State<KeyboardFocusProvider> createState() => _KeyboardFocusProviderState();
}

class _KeyboardFocusProviderState extends State<KeyboardFocusProvider> {
  final Set<_KeyboardFocusState> activeFocuseRequests = {};

  @override
  void initState() {
    super.initState();
    _update();
  }

  void requestFocus(_KeyboardFocusState state) {
    activeFocuseRequests.add(state);
    _update();
  }

  void removeFocus(_KeyboardFocusState state) {
    activeFocuseRequests.remove(state);
    _update();
  }

  KeyboardMode? currentValue;
  void _update() async {
    // TODO: 3 we should throttle calls so 2 can't happen at once, like we did with update_window calls
    final KeyboardMode newValue;
    if (activeFocuseRequests.isEmpty) {
      newValue = KeyboardMode.none;
    } else {
      newValue = KeyboardMode.onDemand;
    }
    if (newValue != currentValue) {
      await FlLinuxWindowManager.instance.setKeyboardInteractivity(newValue);
      currentValue = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
