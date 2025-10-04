import "package:flutter_test/flutter_test.dart";
import "package:waywing/modules/command_palette/user_command_service.dart";
import "package:waywing/util/logger.dart";

void main() async {
  UserCommandService service = UserCommandService();
  await initializeLogger();
  service.logger = mainLogger;

  test("command metadata parsing - complete command", () {
    const content = """
#!/bin/bash
# @name test-command
# @description This is a test command
# @arg string The input file
# @arg int Number of iterations
# @arg bool Whether to show verbose output
# @arg string | csv | json Output format
# Actual script content here
echo "Hello World"
""";

    final command = service.parseCommand("/path/to/script", content);

    expect(command, isNotNull);
    expect(command!.program, equals("/bin/bash"));
    expect(command.name, equals("test-command"));
    expect(command.description, equals("This is a test command"));
    expect(command.path, equals("/path/to/script"));
    expect(command.arguments, hasLength(4));

    // Check first argument (string)
    expect(command.arguments![0].type, isA<UserCommandArgumentTypeString>());
    expect(command.arguments![0].description, equals("The input file"));

    // Check second argument (int)
    expect(command.arguments![1].type, isA<UserCommandArgumentTypeInt>());
    expect(command.arguments![1].description, equals("Number of iterations"));

    // Check third argument (bool)
    expect(command.arguments![2].type, isA<UserCommandArgumentTypeBool>());
    expect(command.arguments![2].description, equals("Whether to show verbose output"));

    // Check fourth argument (union)
    expect(command.arguments![3].type, isA<UserCommandArgumentTypeUnion>());
    final unionType = command.arguments![3].type as UserCommandArgumentTypeUnion;
    expect(unionType.options, equals(["string", "csv", "json"]));
    expect(command.arguments![3].description, equals("Output format"));
  });

  test("command metadata parsing - minimal command", () {
    const content = """
#!/usr/bin/env python3
# Actual script content
print("Minimal command")
""";

    final command = service.parseCommand("/path/to/minimal.py", content);

    expect(command, isNotNull);
    expect(command!.program, equals("/usr/bin/env python3"));
    expect(command.name, equals("minimal")); // Derived from filename
    expect(command.description, isNull);
    expect(command.arguments, isNull);
    expect(command.path, equals("/path/to/minimal.py"));
  });

  test("command metadata parsing - name from filename", () {
    const content = """
#!/bin/bash
# @description Command without explicit name
echo "Hello"
""";

    final command = service.parseCommand("/path/to/my-script.sh", content);

    expect(command, isNotNull);
    expect(command!.name, equals("my-script"));
    expect(command.description, equals("Command without explicit name"));
  });

  test("command metadata parsing - no program line", () {
    const content = """
# This is missing the program line
# @name invalid-command
echo "This should fail"
""";

    final command = service.parseCommand("/path/to/invalid", content);

    expect(command, isNull);
  });

  test("command metadata parsing - only program line", () {
    const content = "#!/bin/bash";

    final command = service.parseCommand("/path/to/script", content);

    expect(command, isNotNull);
    expect(command!.program, equals("/bin/bash"));
    expect(command.name, equals("script")); // From filename
    expect(command.description, isNull);
    expect(command.arguments, isNull);
  });

  test("command metadata parsing - arguments with union types", () {
    const content = """
#!/bin/bash
# @name union-test
# @arg red | blue | green color
# @arg small | medium | large size
# @arg bool enabled
echo "Union test"
""";

    final command = service.parseCommand("/path/to/union", content);

    expect(command, isNotNull);
    expect(command!.arguments, hasLength(3));

    // Check first union argument
    expect(command.arguments![0].type, isA<UserCommandArgumentTypeUnion>());
    final colorType = command.arguments![0].type as UserCommandArgumentTypeUnion;
    expect(colorType.options, equals(["red", "blue", "green"]));

    // Check second union argument
    expect(command.arguments![1].type, isA<UserCommandArgumentTypeUnion>());
    final sizeType = command.arguments![1].type as UserCommandArgumentTypeUnion;
    expect(sizeType.options, equals(["small", "medium", "large"]));

    // Check bool argument
    expect(command.arguments![2].type, isA<UserCommandArgumentTypeBool>());
  });

  test("command metadata parsing - argument types without descriptions", () {
    const content = """
#!/bin/bash
# @name type-test
# @arg string
# @arg int
# @arg float
# @arg bool
echo "Type test"
""";

    final command = service.parseCommand("/path/to/types", content);

    expect(command, isNotNull);
    expect(command!.arguments, hasLength(4));

    expect(command.arguments![0].type, isA<UserCommandArgumentTypeString>());
    expect(command.arguments![0].description, equals(""));

    expect(command.arguments![1].type, isA<UserCommandArgumentTypeInt>());
    expect(command.arguments![1].description, equals(""));

    expect(command.arguments![2].type, isA<UserCommandArgumentTypeFloat>());
    expect(command.arguments![2].description, equals(""));

    expect(command.arguments![3].type, isA<UserCommandArgumentTypeBool>());
    expect(command.arguments![3].description, equals(""));
  });

//   test("command metadata parsing - mixed valid and invalid metadata lines", () {
//     const content = """
// #!/bin/bash
// # @name mixed-test
// # This is a regular comment that should be ignored
// # @description Valid description
// # @invalid-tag This should be ignored
// # @arg string Valid argument
// # More regular comments
// echo "Mixed test"
// """;

//     final command = service.parseCommand("/path/to/mixed", content);

//     expect(command, isNotNull);
//     expect(command!.name, equals("mixed-test"));
//     expect(command.description, equals("Valid description"));
//     expect(command.arguments, hasLength(1));
//     expect(command.arguments![0].type, isA<UserCommandArgumentTypeString>());
//   });

  test("command metadata parsing - empty file", () {
    const content = "";

    final command = service.parseCommand("/path/to/empty", content);

    expect(command, isNull);
  });

  test("command metadata parsing - windows-style line endings", () {
    const content = "#!/bin/bash\r\n# @name windows-test\r\n# @description Windows style\r\necho \"test\"";

    final command = service.parseCommand("/path/to/windows", content);

    expect(command, isNotNull);
    expect(command!.program, equals("/bin/bash"));
    expect(command.name, equals("windows-test"));
    expect(command.description, equals("Windows style"));
  });

//   test("command metadata parsing - complex union with spaces", () {
//     const content = """
// #!/bin/bash
// # @name complex-union
// # @arg option one | option two | option three selection
// echo "Complex union"
// """;

//     final command = service.parseCommand("/path/to/complex", content);

//     expect(command, isNotNull);
//     expect(command!.arguments, hasLength(1));
//     expect(command.arguments![0].type, isA<UserCommandArgumentTypeUnion>());

//     final unionType = command.arguments![0].type as UserCommandArgumentTypeUnion;
//     expect(unionType.options, equals(["option one", "option two", "option three"]));
//     expect(command.arguments![0].description, equals("option one | option two | option three selection"));
//   });

  test("command equality and hashCode", () {
    const content1 = """
#!/bin/bash
# @name test
# @description test command
# @arg string input
echo "test"
""";

    const content2 = """
#!/bin/bash
# @name test
# @description test command
# @arg string input
echo "test"
""";

    final command1 = service.parseCommand("/path/to/test1", content1);
    final command2 = service.parseCommand("/path/to/test2", content2);

    expect(command1, isNotNull);
    expect(command2, isNotNull);

    // Different paths should make them not equal
    expect(command1 == command2, isFalse);

    // Same path, same content should be equal
    final command3 = service.parseCommand("/path/to/same", content1);
    final command4 = service.parseCommand("/path/to/same", content2);
    expect(command3 == command4, isTrue);

    // HashCode should be consistent
    expect(command1.hashCode, isNot(equals(command2.hashCode)));
    expect(command3.hashCode, equals(command4.hashCode));
  });
}
