import "dart:async";
import "dart:typed_data";
import "dart:ui" as ui;

import "package:dartx/dartx.dart";
import "package:dbus/dbus.dart";
import "package:flutter/services.dart";
import "package:waywing/modules/notification/spec/application.dart";

/// Notifications can optionally have a type indicator.
/// Although neither client or nor server must support this, some may choose to.
/// Those servers implementing categories may use them to intelligently display the
/// notification in a certain way, or group notifications of similar types.
sealed class NotificationCategories {
  const NotificationCategories();

  static NotificationCategories? fromString(String? value) {
    if (value == null) {
      return null;
    }
    return switch (value) {
      "call" => CallGeneric(),
      "call.ended" => CallEnded(),
      "call.incoming" => CallIcoming(),
      "call.unanswered" => CallUnanswered(),
      "device" => DeviceGeneric(),
      "device.added" => DeviceAdded(),
      "device.error" => DeviceError(),
      "device.removed" => DeviceRemoved(),
      "email" => EmailGeneric(),
      "email.arrived" => EmailArrived(),
      "email.bounced" => EmailBounced(),
      "im" => ImGeneric(),
      "im.error" => ImError(),
      "im.received" => ImReceived(),
      "network" => NetworkGeneric(),
      "network.connected" => NetworkConnected(),
      "network.disconnected" => NetworkDisconnected(),
      "network.error" => NetworkError(),
      "presence" => PresenceGeneric(),
      "presence.offline" => PresenceOffline(),
      "presence.online" => PresenceOnline(),
      "transfer" => TransferGeneric(),
      "transfer.complete" => TransferComplete(),
      "transfer.error" => TransferError(),
      String() => null,
    };
  }
}

sealed class Call extends NotificationCategories {
  const Call();
}

/// A generic audio or video call notification that doesn't fit into any other category.
class CallGeneric extends Call {
  const CallGeneric();
}

/// An audio or video call was ended.
class CallEnded extends Call {
  const CallEnded();
}

///	A audio or video call is incoming.
class CallIcoming extends Call {
  const CallIcoming();
}

/// An incoming audio or video call was not answered.
class CallUnanswered extends Call {
  const CallUnanswered();
}

sealed class Device extends NotificationCategories {
  const Device();
}

/// A generic device-related notification that doesn't fit into any other category.
class DeviceGeneric extends Device {
  const DeviceGeneric();
}

/// A device, such as a USB device, was added to the system.
class DeviceAdded extends Device {
  const DeviceAdded();
}

/// A device had some kind of error.
class DeviceError extends Device {
  const DeviceError();
}

/// A device, such as a USB device, was removed from the system.
class DeviceRemoved extends Device {
  const DeviceRemoved();
}

sealed class Email extends NotificationCategories {
  const Email();
}

/// A generic e-mail-related notification that doesn't fit into any other category.
class EmailGeneric extends Email {
  const EmailGeneric();
}

/// A new e-mail notification.
class EmailArrived extends Email {
  const EmailArrived();
}

/// A notification stating that an e-mail has bounced.
class EmailBounced extends Email {
  const EmailBounced();
}

sealed class Im extends NotificationCategories {
  const Im();
}

/// A generic instant message-related notification that doesn't fit into any other category.
class ImGeneric extends Im {
  const ImGeneric();
}

/// An instant message error notification.
class ImError extends Im {
  const ImError();
}

/// A received instant message notification.
class ImReceived extends Im {
  const ImReceived();
}

sealed class Network extends NotificationCategories {
  const Network();
}

/// A generic network notification that doesn't fit into any other category.
class NetworkGeneric extends Network {
  const NetworkGeneric();
}

/// A network connection notification, such as successful sign-on to a network service.
///
/// This should not be confused with device.added for new network devices.
class NetworkConnected extends Network {
  const NetworkConnected();
}

/// A network disconnected notification.
///
/// This should not be confused with device.removed for disconnected network devices.
class NetworkDisconnected extends Network {
  const NetworkDisconnected();
}

/// A network-related or connection-related error.
class NetworkError extends Network {
  const NetworkError();
}

sealed class Presence extends NotificationCategories {
  const Presence();
}

/// A generic presence change notification that doesn't fit into any other category,
/// such as going away or idle.
class PresenceGeneric extends Presence {
  const PresenceGeneric();
}

/// An offline presence change notification.
class PresenceOffline extends Presence {
  const PresenceOffline();
}

/// An online presence change notification.
class PresenceOnline extends Presence {
  const PresenceOnline();
}

sealed class Transfer extends NotificationCategories {
  const Transfer();
}

/// A generic file transfer or download notification that doesn't fit into any other category.
class TransferGeneric extends Transfer {
  const TransferGeneric();
}

/// A file transfer or download complete notification.
class TransferComplete extends Transfer {
  const TransferComplete();
}

/// A file transfer or download error.
class TransferError extends Transfer {
  const TransferError();
}

/// For low and normal urgencies, server implementations may display the notifications how they choose.
/// They should, however, have a sane expiration timeout dependent on the urgency level.
///
/// Critical notifications should not automatically expire, as they are things that the
/// user will most likely want to know about.
enum NotificationUrgency {
  low(0),
  normal(1),
  critical(2);

  final int value;
  const NotificationUrgency(this.value);

  static NotificationUrgency from(int v) => switch (v) {
    0 => low,
    1 => normal,
    2 => critical,
    int() => normal,
  };
}

class NotificationHintImage {
  final int width;
  final int height;
  final int rowstride;
  final bool hasAlpha;
  final int bitsPerSample;
  final int channels;
  late final Future<ui.Image> image;

  NotificationHintImage({
    required this.width,
    required this.height,
    required this.rowstride,
    required this.hasAlpha,
    required this.bitsPerSample,
    required this.channels,
    required List<int> imageData,
  }) {
    final completer = Completer<ui.Image>();
    image = completer.future;

    assert(bitsPerSample == 8, "Only 8 bits per sample is supported");
    assert(rowstride >= width * channels, "rowstride ($rowstride) must be >= width * channels (${width * channels})");

    final int minDataLength = height * rowstride;
    assert(imageData.length >= minDataLength, "imageData length (${imageData.length}) must be at least $minDataLength");

    // Support only 3 or 4 channels
    assert(channels == 3 || channels == 4, "expected channels 3 or 4, got $channels");

    Uint8List rgbaData;

    if (channels == 3) {
      rgbaData = Uint8List(width * height * 4);
      int destIndex = 0;

      for (int y = 0; y < height; y++) {
        int srcRowStart = y * rowstride;

        for (int x = 0; x < width; x++) {
          int srcIndex = srcRowStart + x * 3;

          rgbaData[destIndex++] = imageData[srcIndex]; // R
          rgbaData[destIndex++] = imageData[srcIndex + 1]; // G
          rgbaData[destIndex++] = imageData[srcIndex + 2]; // B
          rgbaData[destIndex++] = 255; // A (opaque)
        }
      }
    } else {
      rgbaData = Uint8List(width * height * 4);
      int destIndex = 0;

      for (int y = 0; y < height; y++) {
        int srcRowStart = y * rowstride;

        for (int x = 0; x < width; x++) {
          int srcIndex = srcRowStart + x * 4;

          rgbaData[destIndex++] = imageData[srcIndex]; // R
          rgbaData[destIndex++] = imageData[srcIndex + 1]; // G
          rgbaData[destIndex++] = imageData[srcIndex + 2]; // B
          rgbaData[destIndex++] = imageData[srcIndex + 3]; // A
        }
      }
    }

    ui.decodeImageFromPixels(rgbaData, width, height, ui.PixelFormat.rgba8888, (image) {
      completer.complete(image);
    });
  }

  static final _signature = DBusSignature.struct([
    DBusSignature.int32,
    DBusSignature.int32,
    DBusSignature.int32,
    DBusSignature.boolean,
    DBusSignature.int32,
    DBusSignature.int32,
    DBusSignature.array(DBusSignature.byte),
  ]);

  static NotificationHintImage? fromDBusValue(DBusValue? value) {
    if (value == null) {
      return null;
    }
    if (value.signature != _signature) {
      return null;
    }
    final fields = value.asStruct();
    return NotificationHintImage(
      width: fields[0].asInt32(),
      height: fields[1].asInt32(),
      rowstride: fields[2].asInt32(),
      hasAlpha: fields[3].asBoolean(),
      bitsPerSample: fields[4].asInt32(),
      channels: fields[5].asInt32(),
      imageData: fields[6].asByteArray().toList(),
    );
  }
}

class NotificationHints {
  /// When set, a server that has the "action-icons" capability will attempt to interpret
  /// any action identifier as a named icon. The localized display name will be used to
  /// annotate the icon for accessibility purposes.
  ///
  /// The icon name should be compliant with the Freedesktop.org Icon Naming Specification.
  final bool actionIcons;

  /// The type of notification this is.
  final NotificationCategories? category;

  /// This specifies the name of the desktop filename representing the calling program.
  /// This should be the same as the prefix used for the application's .desktop file.
  ///
  /// An example would be "rhythmbox" from "rhythmbox.desktop".
  ///
  /// This can be used by the daemon to retrieve the correct icon for the application,
  /// for logging purposes, etc.
  final String? desktopEntry;

  /// Some apps may implement this with the exact name of the desktopEntry removing .desktop
  ///
  /// This interface allows for activation
  late final OrgFreedesktopApplication? application;

  /// Notification image
  final NotificationHintImage? imageData;

  /// Alternative way to define the notification image
  final String? imagePath;

  ///  When set the server will not automatically remove the notification when
  /// an action has been invoked.
  ///
  /// The notification will remain resident in the server until it is explicitly
  /// removed by the user or by the sender.
  ///
  /// This hint is likely only useful when the server has the "persistence" capability.
  final bool resident;

  /// The path to a sound file to play when the notification pops up.
  final String? soundFile;

  /// A themeable named sound from the freedesktop.org sound naming specification to
  /// play when the notification pops up. Similar to icon-name, only for sounds.
  ///
  /// An example would be "message-new-instant".
  final String? soundName;

  /// Causes the server to suppress playing any sounds, if it has that ability.
  /// This is usually set when the client itself is going to play its own sound.
  final bool? supressSound;

  /// When set the server will treat the notification as transient and by-pass the
  /// server's persistence capability, if it should exist.
  final bool? transient;

  /// The urgency level.
  final NotificationUrgency urgency;

  /// If this notification is suppose to use the synchronous logic.
  /// Replace a previous notification with this same synchronous value.
  final String? synchronous;

  /// A placeholder for the text input when inline reply is requested
  final String? inlineReplyPlaceholderText;

  NotificationHints._({
    required DBusClient dbusClient,
    required this.urgency,
    required this.actionIcons,
    required this.resident,
    this.category,
    this.desktopEntry,
    this.imageData,
    this.imagePath,
    this.soundFile,
    this.soundName,
    this.supressSound,
    this.transient,
    this.synchronous,
    this.inlineReplyPlaceholderText,
  }) {
    OrgFreedesktopApplication? application;
    if (desktopEntry != null) {
      try {
        final name = desktopEntry!.removeSuffix(".desktop");
        application = OrgFreedesktopApplication(dbusClient, name, DBusObjectPath("/${name.replaceAll('.', '/')}"));
      } catch (_) {
        application = null;
      }
    }
    this.application = application;
  }

  factory NotificationHints(DBusClient client, Map<String, DBusValue> hints) {
    return NotificationHints._(
      dbusClient: client,
      actionIcons: _parseValue<bool>(hints["action-icons"]) ?? false,
      soundFile: _parseValue<String>(hints["sound-file"]),
      soundName: _parseValue<String>(hints["sound-name"]),
      supressSound: _parseValue<bool>(hints["supress-sound"]),
      transient: _parseValue<bool>(hints["transient"]),
      urgency: NotificationUrgency.from(_parseValue<int>(hints["transient"]) ?? 1),
      resident: _parseValue<bool>(hints["resident"]) ?? false,
      desktopEntry: _parseDesktopEntry(_parseValue<String>(hints["desktop-entry"])),
      category: NotificationCategories.fromString(_parseValue<String>(hints["category"])),
      imageData: NotificationHintImage.fromDBusValue(hints["image-data"] ?? hints["image_data"] ?? hints["icon_data"]),
      imagePath: _parseValue<String>(hints["image-path"] ?? hints["image_path"]),
      synchronous: _parseValue<String>(
        hints["synchronous"] ??
            hints["private-synchronous"] ??
            hints["x-canonical-private-synchronous"] ??
            hints["x-dunst-stack-tag"],
      ),
      inlineReplyPlaceholderText: _parseValue<String>(hints["x-kde-reply-placeholder-text"]),
    );
  }

  static T? _parseValue<T>(DBusValue? hint) {
    if (hint == null) {
      return null;
    }
    final signature = switch (T) {
      const (String) => [DBusSignature.string],
      const (bool) => [DBusSignature.boolean],
      const (int) => [
        DBusSignature.int16,
        DBusSignature.int32,
        DBusSignature.int64,
        DBusSignature.uint16,
        DBusSignature.uint32,
        DBusSignature.uint64,
      ],
      Type() => throw StateError("no dbus signature for type $T"),
    };
    if (!signature.contains(hint.signature)) {
      return null;
    }
    return switch (T) {
      const (String) => hint.asString() as T,
      const (bool) => hint.asBoolean() as T,
      const (int) =>
        switch (hint.signature) {
              DBusSignature.int16 => hint.asInt16(),
              DBusSignature.int32 => hint.asInt32(),
              DBusSignature.int64 => hint.asInt64(),
              DBusSignature.uint16 => hint.asUint16(),
              DBusSignature.uint32 => hint.asUint32(),
              DBusSignature.uint64 => hint.asUint64(),
              DBusSignature() => throw StateError("unreachable"),
            }
            as T,
      Type() => throw StateError("unreachable"),
    };
  }

  static String? _parseDesktopEntry(String? desktopEntry) {
    if (desktopEntry == null) {
      return null;
    }
    return desktopEntry.removeSuffix(".desktop");
  }

  @override
  bool operator ==(covariant NotificationHints other) {
    if (identical(this, other)) {
      return true;
    }
    return actionIcons == other.actionIcons &&
        urgency == other.urgency &&
        resident == other.resident &&
        category == other.category &&
        desktopEntry == other.desktopEntry &&
        imageData == other.imageData &&
        imagePath == other.imagePath &&
        soundFile == other.soundFile &&
        soundName == other.soundName &&
        supressSound == other.supressSound &&
        transient == other.transient &&
        synchronous == other.synchronous &&
        inlineReplyPlaceholderText == other.inlineReplyPlaceholderText;
  }

  @override
  int get hashCode => Object.hashAll([
    urgency,
    actionIcons,
    resident,
    category,
    desktopEntry,
    imageData,
    imagePath,
    soundFile,
    soundName,
    supressSound,
    transient,
    synchronous,
    inlineReplyPlaceholderText,
  ]);

  @override
  String toString() {
    return "actionIcons: $actionIcons "
        "urgency: $urgency "
        "resident: $resident "
        "category: $category "
        "desktopEntry: $desktopEntry "
        "imagePath: $imagePath {"
        "imageData: ${imageData != null} "
        "soundFile: $soundFile "
        "soundName: $soundName "
        "supressSound: $supressSound "
        "synchronous: $synchronous "
        "transient: $transient "
        "inlineReplyPlaceholderText: $inlineReplyPlaceholderText";
  }
}

class Actions {
  final Action? defaultAction;
  final Action? inlineReply;
  final List<Action> actions;

  Actions._(this.defaultAction, this.inlineReply, this.actions);

  factory Actions(List<String> actions) {
    if (actions.length < 2 || actions.length % 2 != 0) {
      return Actions._(null, null, []);
    }
    final parsedActions = <Action>[];
    Action? inlineReply;
    Action? defaultAction;
    for (int i = 0; i < actions.length; i += 2) {
      String key = actions[i];
      String value = actions[i + 1];
      switch (key.toLowerCase()) {
        case "default":
          defaultAction = Action(key: key, value: value);
        case "inline-reply":
          if (value == "") {
            value = "Reply"; // TODO 3: this should be localization dependent
          }
          inlineReply = Action(key: key, value: value);
        default:
          parsedActions.add(Action(key: key, value: value));
      }
    }
    return Actions._(defaultAction, inlineReply, parsedActions);
  }

  @override
  bool operator ==(covariant Actions other) {
    if (defaultAction != other.defaultAction || inlineReply != other.inlineReply) {
      return false;
    }
    if (identical(actions, other.actions)) {
      return true;
    }
    if (actions.length != other.actions.length) {
      return false;
    }
    for (int i = 0; i < actions.length; i++) {
      if (actions[i] != other.actions[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(
    (() sync* {
      yield defaultAction;
      yield inlineReply;
      yield* actions;
    })(),
  );

  @override
  String toString() {
    return "defaultAction: $defaultAction inlineReply: $inlineReply actions: [${actions.join(", ")}]";
  }
}

class Action {
  final String key;
  final String value;

  const Action({required this.key, required this.value});

  @override
  bool operator ==(covariant Action other) {
    return key == other.key && value == other.value;
  }

  @override
  int get hashCode => Object.hashAll([key, value]);

  @override
  String toString() {
    return "Action(key: $key, value: $value)";
  }
}
