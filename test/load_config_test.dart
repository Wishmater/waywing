import "package:flutter_test/flutter_test.dart";
import "package:tronco/tronco.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/bar/bar_config.dart";
import "package:waywing/util/logger.dart";

void main() {
  setUp(() {
    initializeLogger();
    mainLogger.clone();
    updateLevel(Level.debug);
  });

  test("load config", () async {
    try {
      final config = await reloadConfig(configInput);
      print(config);
      print((config.dynamicSchemas["Bar"]![0] as BarConfig).end?.rawFeathers);
      print((config.dynamicSchemas["Bar"]![0] as BarConfig).center?.rawFeathers);
      print((config.dynamicSchemas["Bar"]![0] as BarConfig).start?.rawFeathers);
    } catch (e, st) {
      print("$e\n$st");
      print(BarConfig.schema.tables["End"]!.tables);
    }
    print(BarConfig.schema.tables["End"]!.tables);
  });
}

const configInput = """
Bar {
	side = "bottom"
	size = 20

	marginTop = 80
	marginBottom = 40
	indicatorPadding = 8
	radiusInCross = size * 0.5
	radiusInMain = size * 0.5 * 0.67
	# radiusOutMain = size * 0.5 * 1.5
	radiusOutCross = size * 0.5

	Center {
	  NetworkManager {}
		Volume {}
	}

	End {
	  Battery {}
	}
}

Logging {
	levelFilter = "trace"
}

""";
