import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:waywing/core/config.dart";
import "package:waywing/util/logger.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initializeLogger();
    await reloadConfig("");
  });

  testWidgets("Counter increments smoke test", (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      _ScrollTest(
        List.generate(
          50000,
          (i) => Container(
            key: ValueKey(i),
            child: SizedBox(height: 100, child: Text("$i")),
          ),
        ),
      ),
    );

    final listFinder = find.byType(Scrollable);
    expect(listFinder, findsOneWidget);

    await tester.pumpAndSettle();

    await binding.traceAction(() async {
      // Scroll until the item to be found appears.
      for (int i = 0; i < 10; i++) {
        final itemFinder = find.byKey(ValueKey((i + 1) * 50));
        await tester.scrollUntilVisible(
          itemFinder,
          10.0,
          // continuous: true,
          scrollable: listFinder,
        );
        await tester.pump(Duration(milliseconds: 15));
      }
    }, reportKey: "scrolling_timeline");
  });
}

class _ScrollTest extends StatelessWidget {
  final List<Widget> widgets;

  const _ScrollTest(this.widgets);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 500,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              children: widgets,
            ),
          ),
        ),
      ),
    );
  }
}
