import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initializeLogger();
    await reloadConfig("");
  });


  group("end-to-end test", () {
    testWidgets("tap on the floating action button, verify counter", (
      tester,
    ) async {
      // Load app widget.
      await tester.pumpWidget(MaterialApp(
        home: WingedContainer(
          child: Text("Hello")
        ),
      ));

      // Verify the counter starts at 0.
      expect(find.text("Hello"), findsOneWidget);

      // Finds the floating action button to tap on.
      // final fab = find.byKey(const ValueKey("increment"));

      // // Emulate a tap on the floating action button.
      // await tester.tap(fab);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text("Hello"), findsOneWidget);
    });
  });
}
