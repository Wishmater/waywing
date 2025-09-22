import "dart:async";

import "package:fl_linux_window_manager/fl_linux_window_manager.dart";
import "package:mutex/mutex.dart";

int _id = 0;
int get _newID {
  _id += 1;
  return _id;
}

typedef FocusGrabRequest = int;

class FocusGrabHandler {
  static final Set<FocusGrabRequest> _request = {};
  static bool _withFocus = false;
  static StreamSubscription<()>? _cleareSubscription;
  static final Mutex _mut = Mutex();

  FocusGrabHandler() {
    _cleareSubscription ??= FlLinuxWindowManager.instance.focusGrabCleared.listen((_) {
      _withFocus = false;
      _request.clear();
    });
  }

  FocusGrabRequest requestFocusGrab() {
    final id = _newID;
    _request.add(id);
    if (!_withFocus) {
      _addSurface();
    }
    return id;
  }

  void removeFocusGrab(FocusGrabRequest request) {
    _request.remove(request);
    if (_request.isEmpty && _withFocus) {
      // delay _removeSurface to allow rapid remove/add focus grab requests
      // and not call that many times the native code
      Future.delayed(Duration(milliseconds: 50), () {
        if (_request.isEmpty && _withFocus) _removeSurface();
      });
    }
  }

  static Future<void> _addSurface() async {
    await _mut.protect(() async {
      await FlLinuxWindowManager.instance.focusGrab();
      _withFocus = true;
    });
  }

  static Future<void> _removeSurface() async {
    await _mut.protect(() async {
      await FlLinuxWindowManager.instance.focusUngrab();
      _withFocus = false;
    });
  }
}
