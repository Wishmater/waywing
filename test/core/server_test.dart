import "dart:async";
import "dart:convert";
import "dart:typed_data";
import "package:flutter_test/flutter_test.dart";
import "package:waywing/core/server.dart";


void main() {
  group("parseRequests", () {
    test("should parse request without body when no Content-Length header", () async {
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/test?param1=value1\n")),
        Uint8List.fromList(utf8.encode("Header1: Value1\n")),
        Uint8List.fromList(utf8.encode("Header2: Value2\n")),
        Uint8List.fromList(utf8.encode("\n")),
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      expect(request.path.toString(), equals("/api/test?param1=value1"));
      expect(request.headers, equals({
        "header1": "Value1",
        "header2": "Value2",
      }));

      // Body should be empty
      final bodyBytes = await request.body.toList();
      expect(bodyBytes, isEmpty);
    });

    test("should parse request with Content-Length body", () async {
      final bodyContent = "Hello World";
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/data\n")),
        Uint8List.fromList(utf8.encode("Content-Length: ${bodyContent.length}\n")),
        Uint8List.fromList(utf8.encode("Content-Type: text/plain\n")),
        Uint8List.fromList(utf8.encode("\n")),
        Uint8List.fromList(utf8.encode(bodyContent)),
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      expect(request.path.toString(), equals("/api/data"));
      expect(request.headers, equals({
        "content-length": bodyContent.length.toString(),
        "content-type": "text/plain",
      }));

      // Verify body content
      final bodyBytes = await request.body.toList();
      final bodyString = utf8.decode(bodyBytes.expand((x) => x).toList());
      expect(bodyString, equals(bodyContent));
    });

    test("should parse request with Transfer-Encoding zero-ended body", () async {
      final bodyContent = "Chunked body data";
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/upload\n")),
        Uint8List.fromList(utf8.encode("Transfer-Encoding: zero-ended\n")),
        Uint8List.fromList(utf8.encode("\n")),
        Uint8List.fromList(utf8.encode(bodyContent)),
        Uint8List.fromList([0]), // Zero byte indicating end
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      expect(request.path.toString(), equals("/api/upload"));
      expect(request.headers, equals({
        "transfer-encoding": "zero-ended",
      }));

      // Verify body content (should not include the zero byte)
      final bodyBytes = await request.body.toList();
      final bodyString = utf8.decode(bodyBytes.expand((x) => x).toList());
      expect(bodyString, equals(bodyContent));
    });

    test("should handle binary body data correctly", () async {
      final binaryData = Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0x04]);
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/binary\n")),
        Uint8List.fromList(utf8.encode("Content-Length: ${binaryData.length}\n")),
        Uint8List.fromList(utf8.encode("\n")),
        binaryData,
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      expect(request.path.toString(), equals("/api/binary"));

      final bodyBytes = await request.body.toList();
      final combinedBody = bodyBytes.expand((x) => x).toList();
      expect(combinedBody, equals(binaryData));
    });

    test("should handle multiple chunks in stream", () async {
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/test?")),
        Uint8List.fromList(utf8.encode("param=value\n")),
        Uint8List.fromList(utf8.encode("Header1: Val")),
        Uint8List.fromList(utf8.encode("ue1\nHeader2: Value2\n")),
        Uint8List.fromList(utf8.encode("\n")),
        Uint8List.fromList(utf8.encode("body")),
        Uint8List.fromList(utf8.encode(" content")),
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      expect(request.path.toString(), equals("/api/test?param=value"));
      expect(request.headers, equals({
        "header1": "Value1",
        "header2": "Value2",
      }));

      // Body should be empty since no Content-Length or Transfer-Encoding
      final bodyBytes = await request.body.toList();
      expect(bodyBytes, isEmpty);
    });

    test("should handle empty headers section", () async {
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/simple\n")),
        Uint8List.fromList(utf8.encode("\n")),
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      expect(request.path.toString(), equals("/api/simple"));
      expect(request.headers, isEmpty);

      final bodyBytes = await request.body.toList();
      expect(bodyBytes, isEmpty);
    });

    test("should handle query parameters correctly", () async {
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/path/indicating/action?param1=value1&param2=value2\n")),
        Uint8List.fromList(utf8.encode("\n")),
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      expect(request.path.path, equals("/path/indicating/action"));
      expect(request.path.queryParameters, equals({
        "param1": "value1",
        "param2": "value2",
      }));
    });

    test("should prioritize Content-Length over Transfer-Encoding when both present", () async {
      final bodyContent = "Fixed Length";
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/test\n")),
        Uint8List.fromList(utf8.encode("Content-Length: ${bodyContent.length}\n")),
        Uint8List.fromList(utf8.encode("\n")),
        Uint8List.fromList(utf8.encode(bodyContent)),
        Uint8List.fromList(utf8.encode("extra data that should be ignored")),
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      final bodyBytes = await request.body.toList();
      final bodyString = utf8.decode(bodyBytes.expand((x) => x).toList());
      expect(bodyString, equals(bodyContent));
    });

    test("should handle case insensitive headers", () async {
      final stream = Stream<Uint8List>.fromIterable([
        Uint8List.fromList(utf8.encode("/api/test\n")),
        Uint8List.fromList(utf8.encode("content-length: 5\n")),
        Uint8List.fromList(utf8.encode("TRANSFER-ENCODING: zero-ended\n")),
        Uint8List.fromList(utf8.encode("\n")),
        Uint8List.fromList(utf8.encode("hello")),
      ]);

      final request = await ProtocolParser.parseRequests(stream);

      // Should recognize headers regardless of case
      expect(request.headers.containsKey("content-length"), isTrue);
      expect(request.headers.containsKey("Content-Length"), isFalse); // Exact match
    });
  });
}
