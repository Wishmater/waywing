import "dart:async";
import "dart:ui" as ui;

import "package:dartx/dartx.dart";
import "package:dbus/dbus.dart";
import "package:flutter/foundation.dart";
import "package:flutter/scheduler.dart";
import "package:hive_ce/hive.dart";

sealed class NotificationImage {
  const NotificationImage();
}

class NotificationImageData extends NotificationImage {
  final NotificationHintImage data;

  Future<ui.Image> get image => data.image;

  const NotificationImageData(this.data);
}

class NotificationImagePath extends NotificationImage {
  final String path;

  const NotificationImagePath(this.path);
}

int _idGenerator = 0;

class Notification {
  /// Unique identifier for the notification.
  /// Clients use this ID to update, close, or reference a specific notification.
  final int id;

  /// This is the optional name of the application sending the notification.
  /// This should be the application's formal name, rather than some sort of ID.
  /// An example would be "FredApp E-Mail Client," rather than "fredapp-email-client." .
  final String appName;

  /// Icon to render
  String appIcon;

  /// This is a single line overview of the notification.
  ///
  /// For instance, "You have mail" or "A friend has come online".
  /// It should generally not be longer than 40 characters, though this is not a requirement,
  /// and server implementations should word wrap if necessary.
  ///
  /// The summary must be encoded using UTF-8.
  final String summary;

  /// This is a multi-line body of text. Each line is a paragraph, server implementations
  /// are free to word wrap them as they see fit.
  ///
  /// The body may contain simple markup as specified in Markup. It must be encoded using UTF-8.
  ///
  /// If the body is omitted, just the summary is displayed.
  final String body;

  /// The timestamp (in milliseconds since epoch) when the notification was created.
  final int timestampMs;

  /// The timeout time in milliseconds since the display of the notification at which the notification
  /// should automatically close.
  ///
  /// If -1, the notification's expiration time is dependent on the notification server's settings,
  /// and may vary for the type of notification.
  ///
  /// If 0, the notification never expires.
  final int timeout;

  /// True if notification is at the top of the list
  final bool isFirst;

  /// The actions send a request message back to the notification client when invoked.
  /// This functionality may not be implemented by the notification server, conforming clients
  /// should check if it is available before using it (see the GetCapabilities message in Protocol).
  /// An implementation is free to ignore any requested by the client.
  /// As an example one possible rendering of actions would be as buttons in the notification popup.
  ///
  /// Actions are sent over as a list of pairs. Each even element in the list (starting at index 0)
  /// represents the identifier for the action. Each odd element in the list is the localized
  /// string that will be displayed to the user.
  ///
  /// The default action (usually invoked by clicking the notification) should have a key named
  /// "default". The name can be anything, though implementations are free not to display it.
  final Actions actions;

  /// Hints are a way to provide extra data to a notification server that the server may
  /// be able to make use of.
  final NotificationHints hints;

  /// For low and normal urgencies, server implementations may display the notifications how they choose.
  /// They should, however, have a sane expiration timeout dependent on the urgency level.
  ///
  /// Critical notifications should not automatically expire, as they are things that the
  /// user will most likely want to know about.
  NotificationUrgency get urgency => hints.urgency;

  /// Image to display
  NotificationImage? get image {
    if (hints.imageData != null) {
      return NotificationImageData(hints.imageData!);
    } else if (hints.imagePath != null) {
      return NotificationImagePath(hints.imagePath!);
    }
    return null;
  }

  Notification.clientNew({
    required this.appName,
    required this.appIcon,
    required this.summary,
    required this.body,
    required this.actions,
    required this.hints,
    int? timeout,
  }) : id = 0,
       timestampMs = 0,
       timeout = timeout ?? -1,
       isFirst = false;

  Notification._({
    required this.id,
    required this.timestampMs,
    required this.appName,
    required this.appIcon,
    required this.summary,
    required this.body,
    required this.actions,
    required this.hints,
    required this.timeout,
    required this.isFirst,
  });

  Notification({
    required this.appName,
    required this.appIcon,
    required this.summary,
    required this.body,
    required this.actions,
    required this.hints,
    required this.timeout,
  }) : timestampMs = DateTime.now().millisecondsSinceEpoch,
       id = _idGenerator++,
       isFirst = false;

  Notification copyWith({
    int? id,
    String? appName,
    String? appIcon,
    String? summary,
    String? body,
    Actions? actions,
    NotificationHints? hints,
    int? timeout,
    int? timestampMs,
    bool? isFirst,
  }) {
    return Notification._(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      actions: actions ?? this.actions,
      hints: hints ?? this.hints,
      timeout: timeout ?? this.timeout,
      timestampMs: timestampMs ?? this.timestampMs,
      isFirst: isFirst ?? this.isFirst,
    );
  }

  @override
  bool operator ==(covariant Notification other) {
    if (identical(this, other)) return true;

    return appName == other.appName &&
        appIcon == other.appIcon &&
        summary == other.summary &&
        body == other.body &&
        image == other.image &&
        actions == other.actions &&
        hints == other.hints &&
        timeout == other.timeout &&
        timestampMs == other.timestampMs &&
        isFirst == other.isFirst;
  }

  @override
  int get hashCode => Object.hashAll([
    appName,
    appIcon,
    summary,
    body,
    image,
    actions,
    hints,
    timeout,
    timestampMs,
  ]);

  @override
  String toString() {
    return "Notification(id: $id, appName: $appName, appIcon: $appIcon, summary: $summary, body: $body)";
  }
}

class NotificationsHiveAdapter extends TypeAdapter<Notification> {
  @override
  Notification read(BinaryReader reader) {
    return Notification._(
      id: reader.readInt(),
      appName: reader.readString(),
      appIcon: reader.readString(),
      summary: reader.readString(),
      body: reader.readString(),
      timestampMs: reader.readInt(),
      timeout: reader.readInt(),
      isFirst: reader.readBool(),
      actions: Actions.hiveRead(reader),
      hints: NotificationHints.hiveRead(reader),
    );
  }

  @override
  int get typeId => 3827;

  @override
  void write(BinaryWriter writer, Notification notification) {
    writer.writeInt(notification.id);
    writer.writeString(notification.appName);
    writer.writeString(notification.appIcon);
    writer.writeString(notification.summary);
    writer.writeString(notification.body);
    writer.writeInt(notification.timestampMs);
    writer.writeInt(notification.timeout);
    writer.writeBool(notification.isFirst);

    notification.actions.hiveWrite(writer);
    notification.hints.hiveWrite(writer);
  }
}

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

  @override
  String toString() {
    return switch (this) {
      CallGeneric() => "call",
      CallEnded() => "call.ended",
      CallIcoming() => "call.incoming",
      CallUnanswered() => "call.unanswered",
      DeviceGeneric() => "device",
      DeviceAdded() => "device.added",
      DeviceError() => "device.error",
      DeviceRemoved() => "device.removed",
      EmailGeneric() => "email",
      EmailArrived() => "email.arrived",
      EmailBounced() => "email.bounced",
      ImGeneric() => "im",
      ImError() => "im.error",
      ImReceived() => "im.received",
      NetworkGeneric() => "network",
      NetworkConnected() => "network.connected",
      NetworkDisconnected() => "network.disconnected",
      NetworkError() => "network.error",
      PresenceGeneric() => "presence",
      PresenceOffline() => "presence.offline",
      PresenceOnline() => "presence.online",
      TransferGeneric() => "transfer",
      TransferComplete() => "transfer.complete",
      TransferError() => "transfer.error",
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

  void hiveWrite(BinaryWriter writer) {
    writer.writeInt(value);
  }

  static NotificationUrgency hiveRead(BinaryReader reader) {
    return from(reader.readInt());
  }
}

class NotificationHintImage {
  final int width;
  final int height;
  final int rowstride;
  final bool hasAlpha;
  final int bitsPerSample;
  final int channels;
  late final Uint8List rgbaData;

  NotificationHintImage._(
    this.width,
    this.height,
    this.rowstride,
    this.hasAlpha,
    this.bitsPerSample,
    this.channels,
    this.rgbaData,
  );

  NotificationHintImage({
    required this.width,
    required this.height,
    required this.rowstride,
    required this.hasAlpha,
    required this.bitsPerSample,
    required this.channels,
    required List<int> imageData,
  }) {
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

    // I think this increase the memory usage as it duplicates the bytes used when
    // ui.decodeImageFromPixels is called but is necessary to restore the notification
    // from the file system
    this.rgbaData = rgbaData;
  }

  Future<ui.Image>? _image;
  Future<ui.Image> get image {
    if (_image != null) {
      return _image!;
    }
    final completer = Completer<ui.Image>();
    _image = completer.future;
    ui.decodeImageFromPixels(rgbaData, width, height, ui.PixelFormat.rgba8888, (image) {
      completer.complete(image);
    });
    return _image!;
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

  void hiveWrite(BinaryWriter writer) {
    writer.writeInt(width);
    writer.writeInt(height);
    writer.writeInt(rowstride);
    writer.writeBool(hasAlpha);
    writer.writeInt(bitsPerSample);
    writer.writeInt(channels);
    writer.writeByteList(rgbaData);
  }

  static NotificationHintImage hiveRead(BinaryReader reader) {
    return NotificationHintImage._(
      reader.readInt(),
      reader.readInt(),
      reader.readInt(),
      reader.readBool(),
      reader.readInt(),
      reader.readInt(),
      reader.readByteList(),
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

  /// The urgency level.
  final NotificationUrgency urgency;

  ///  When set the server will not automatically remove the notification when
  /// an action has been invoked.
  ///
  /// The notification will remain resident in the server until it is explicitly
  /// removed by the user or by the sender.
  ///
  /// This hint is likely only useful when the server has the "persistence" capability.
  final bool resident;

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
  late final String? applicationDBusName;

  /// Alternative way to define the notification image
  final String? imagePath;

  /// The path to a sound file to play when the notification pops up.
  final String? soundFile;

  /// A themeable named sound from the freedesktop.org sound naming specification to
  /// play when the notification pops up. Similar to icon-name, only for sounds.
  ///
  /// An example would be "message-new-instant".
  final String? soundName;

  /// If this notification is suppose to use the synchronous logic.
  /// Replace a previous notification with this same synchronous value.
  final String? synchronous;

  /// A placeholder for the text input when inline reply is requested
  final String? inlineReplyPlaceholderText;

  /// Causes the server to suppress playing any sounds, if it has that ability.
  /// This is usually set when the client itself is going to play its own sound.
  final bool? suppressSound;

  /// When set the server will treat the notification as transient and by-pass the
  /// server's persistence capability, if it should exist.
  final bool? transient;

  /// Notification image
  final NotificationHintImage? imageData;

  NotificationHints._({
    required this.urgency,
    required this.actionIcons,
    required this.resident,
    required this.category,
    required this.desktopEntry,
    required this.imageData,
    required this.imagePath,
    required this.soundFile,
    required this.soundName,
    required this.suppressSound,
    required this.transient,
    required this.synchronous,
    required this.inlineReplyPlaceholderText,
  }) {
    String? applicationDBusName;
    if (desktopEntry != null) {
      try {
        final name = desktopEntry!.removeSuffix(".desktop");
        // Check that name give a valid path
        final _ = DBusObjectPath(name.replaceAll(".", "/"));
        applicationDBusName = name;
      } catch (_) {}
    }
    this.applicationDBusName = applicationDBusName;
  }

  factory NotificationHints(Map<String, DBusValue> hints) {
    return NotificationHints._(
      actionIcons: _parseValue<bool>(hints["action-icons"]) ?? false,
      soundFile: _parseValue<String>(hints["sound-file"]),
      soundName: _parseValue<String>(hints["sound-name"]),
      suppressSound: _parseValue<bool>(hints["suppress-sound"]),
      transient: _parseValue<bool>(hints["transient"]),
      urgency: NotificationUrgency.from(_parseValue<int>(hints["urgency"]) ?? 1),
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
        DBusSignature.byte,
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
              DBusSignature.byte => hint.asByte(),
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

  Map<String, DBusValue> serialize() {
    return {
      "urgency": DBusByte(urgency.value),
      if (actionIcons) "action-icons": DBusBoolean(actionIcons),
      if (category != null) "category": DBusString(category!.toString()),
      if (soundFile != null) "sound-file": DBusString(soundFile!),
      if (soundName != null) "sound-name": DBusString(soundName!),
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
        suppressSound == other.suppressSound &&
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
    suppressSound,
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
        "imagePath: $imagePath "
        "imageData: ${imageData != null} "
        "soundFile: $soundFile "
        "soundName: $soundName "
        "supressSound: $suppressSound "
        "synchronous: $synchronous "
        "transient: $transient "
        "inlineReplyPlaceholderText: $inlineReplyPlaceholderText";
  }

  void hiveWrite(BinaryWriter writer) {
    writer.writeBool(actionIcons);
    writer.writeBool(resident);
    urgency.hiveWrite(writer);

    if (category != null) {
      writer.writeString("category");
      writer.writeString(category.toString());
    }

    if (desktopEntry != null) {
      writer.writeString("desktopEntry");
      writer.writeString(desktopEntry!);
    }

    if (applicationDBusName != null) {
      writer.writeString("applicationDBusName");
      writer.writeString(applicationDBusName!);
    }

    if (imagePath != null) {
      writer.writeString("imagePath");
      writer.writeString(imagePath!);
    }

    if (soundFile != null) {
      writer.writeString("soundFile");
      writer.writeString(soundFile!);
    }

    if (soundName != null) {
      writer.writeString("soundName");
      writer.writeString(soundName!);
    }

    if (synchronous != null) {
      writer.writeString("synchronous");
      writer.writeString(synchronous!);
    }

    if (inlineReplyPlaceholderText != null) {
      writer.writeString("inlineReplyPlaceholderText");
      writer.writeString(inlineReplyPlaceholderText!);
    }

    if (suppressSound != null) {
      writer.writeString("suppressSound");
      writer.writeBool(suppressSound!);
    }

    if (transient != null) {
      writer.writeString("transient");
      writer.writeBool(transient!);
    }

    if (imageData != null) {
      writer.writeString("imageData");
      imageData!.hiveWrite(writer);
    }

    writer.writeString("__end__");
  }

  static NotificationHints hiveRead(BinaryReader reader) {
    final actionIcons = reader.readBool();
    final resident = reader.readBool();
    final urgency = NotificationUrgency.hiveRead(reader);

    final optionals = <String, dynamic>{};
    while (true) {
      final name = reader.readString();
      if (name == "__end__") {
        break;
      }
      optionals[name] = switch (name) {
        "category" ||
        "desktopEntry" ||
        "applicationDBusName" ||
        "imagePath" ||
        "soundFile" ||
        "soundName" ||
        "synchronous" ||
        "inlineReplyPlaceholderText" => reader.readString(),

        "suppressSound" || "transient" => reader.readBool(),
        "imageData" => NotificationHintImage.hiveRead(reader),

        _ => throw ArgumentError("unknown field $name"),
      };
    }
    return NotificationHints._(
      urgency: urgency,
      actionIcons: actionIcons,
      resident: resident,
      category: optionals["category"] != null ? NotificationCategories.fromString(optionals["category"]) : null,
      desktopEntry: optionals["desktopEntry"],
      imageData: optionals["imageData"],
      imagePath: optionals["imagePath"],
      inlineReplyPlaceholderText: optionals["inlineReplyPlaceholderText"],
      soundFile: optionals["soundFile"],
      soundName: optionals["soundName"],
      suppressSound: optionals["suppressSound"],
      synchronous: optionals["synchronous"],
      transient: optionals["transient"],
    );
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

  List<String> serialize() {
    final result = <String>[];
    defaultAction?.serialize(result);
    inlineReply?.serialize(result);
    for (final action in actions) {
      action.serialize(result);
    }
    return result;
  }

  void hiveWrite(BinaryWriter writer) {
    writer.writeBool(defaultAction != null);
    defaultAction?.hiveWrite(writer);

    writer.writeBool(inlineReply != null);
    inlineReply?.hiveWrite(writer);

    writer.writeInt(actions.length);
    for (final action in actions) {
      action.hiveWrite(writer);
    }
  }

  static Actions hiveRead(BinaryReader reader) {
    Action? defaultAction;
    Action? inlineReply;
    List<Action> actions = [];

    final hasDefaultAction = reader.readBool();
    if (hasDefaultAction) {
      defaultAction = Action.hiveRead(reader);
    }

    final hasInlineReply = reader.readBool();
    if (hasInlineReply) {
      inlineReply = Action.hiveRead(reader);
    }

    final actionListLength = reader.readInt();
    for (int i = 0; i < actionListLength; i++) {
      actions.add(Action.hiveRead(reader));
    }

    return Actions._(defaultAction, inlineReply, actions);
  }
}

class Action {
  final String key;
  final String value;

  const Action({required this.key, required this.value});

  const Action.inlineReply([this.value = ""]) : key = "inline-reply";
  const Action.defaults(this.value) : key = "default";

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

  void serialize(List<String> list) {
    list.addAll([key, value]);
  }

  void hiveWrite(BinaryWriter writer) {
    writer.writeString(key);
    writer.writeString(value);
  }

  static Action hiveRead(BinaryReader reader) {
    return Action(key: reader.readString(), value: reader.readString());
  }
}

class NotificationTimer implements Listenable {
  Duration currentTimeout;
  final Duration startTimeout;
  Duration? _prevDur;

  double get percentageCompleted {
    final passed = (startTimeout - currentTimeout).inMicroseconds.toDouble();
    final total = startTimeout.inMicroseconds.toDouble();
    return passed / total;
  }

  late int _callbackId;
  final void Function() _callback;

  bool _running;
  bool get running => _running;

  bool _called;

  final List<ui.VoidCallback> _listeners;

  NotificationTimer(this._callback, Duration timeout)
    : _running = true,
      _called = false,
      _listeners = [],
      startTimeout = timeout,
      currentTimeout = timeout {
    _callbackId = SchedulerBinding.instance.scheduleFrameCallback(_updateTime);
  }

  void stop() => _running = false;
  void start() => _running = true;

  void _updateTime(Duration dur) {
    if (_disposed) {
      return;
    }
    _prevDur ??= dur;
    final delta = dur - _prevDur!;
    _prevDur = dur;

    if (running) {
      currentTimeout -= delta;
    }
    if (currentTimeout < Duration.zero && !_called) {
      _callback();
      _called = true;
    } else {
      _callbackId = SchedulerBinding.instance.scheduleFrameCallback(_updateTime, rescheduling: true);
    }
    if (running) {
      _notifyListener();
    }
  }

  bool _disposed = false;
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    SchedulerBinding.instance.cancelFrameCallbackWithId(_callbackId);
    _listeners.clear();
  }

  @override
  void addListener(ui.VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(ui.VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListener() {
    for (var e in _listeners) {
      e.call();
    }
  }
}

class NotificationGroup {
  final List<Notification> notifications;
  final String name;

  NotificationGroup(this.name) : notifications = [];

  void add(Notification notification) => notifications.add(notification);
}
