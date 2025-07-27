
import "dart:convert";

extension ToUtf8 on List<int> {
  String toUtf8() => utf8.decode(this);
}
