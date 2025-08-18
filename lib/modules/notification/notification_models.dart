import "dart:async";
import "dart:ui" as ui;

import "package:flutter/services.dart";

/// Notifications can optionally have a type indicator.
/// Although neither client or nor server must support this, some may choose to.
/// Those servers implementing categories may use them to intelligently display the
/// notification in a certain way, or group notifications of similar types.
sealed class NotificationCategories {
  const NotificationCategories();
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
class TransferGeneric extends NotificationCategories {
  const TransferGeneric();
}

/// A file transfer or download complete notification.
class TransferComplete extends NotificationCategories {
  const TransferComplete();
}

/// A file transfer or download error.
class TransferError extends NotificationCategories {
  const TransferError();
}

enum NotificationUrgencyLevel {
  low,
  normal,
  critical;

  NotificationUrgencyLevel fromInt(int level) {
    return switch (level) {
      0 => low,
      1 => normal,
      _ => critical,
    };
  }
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

          rgbaData[destIndex++] = imageData[srcIndex];     // R
          rgbaData[destIndex++] = imageData[srcIndex + 1]; // G
          rgbaData[destIndex++] = imageData[srcIndex + 2]; // B
          rgbaData[destIndex++] = 255;                     // A (opaque)
        }
      }
    } else {
      rgbaData = Uint8List(width * height * 4);
      int destIndex = 0;

      for (int y = 0; y < height; y++) {
        int srcRowStart = y * rowstride;

        for (int x = 0; x < width; x++) {
          int srcIndex = srcRowStart + x * 4;

          rgbaData[destIndex++] = imageData[srcIndex];     // R
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
}

class NotificationHints {
  /// When set, a server that has the "action-icons" capability will attempt to interpret
  /// any action identifier as a named icon. The localized display name will be used to
  /// annotate the icon for accessibility purposes.
  ///
  /// The icon name should be compliant with the Freedesktop.org Icon Naming Specification.
  final bool? actionIcons;

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
  final bool? resident;

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
  final NotificationUrgencyLevel? urgencyLevel;

  const NotificationHints({
    this.actionIcons,
    this.category,
    this.desktopEntry,
    this.imageData,
    this.imagePath,
    this.resident,
    this.soundFile,
    this.soundName,
    this.supressSound,
    this.transient,
    this.urgencyLevel,
  });
}
