import "dart:convert";

// TODO: 1 delete this, this logic should be localized to the server doing it, instead of being used from the UI
extension ToUtf8 on List<int> {
  String toUtf8() => utf8.decode(this);
}
