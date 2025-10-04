// ignore_for_file: avoid_print

import "package:config/config.dart";
import "package:dartx/dartx_io.dart";
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
      print(BarConfig.fromBlock((config.dynamicSchemas.firstOrNullWhere((e) => e.$1 == "Bar") as (String, BlockData)).$2).end?.rawFeathers);
      print(BarConfig.fromBlock((config.dynamicSchemas.firstOrNullWhere((e) => e.$1 == "Bar") as (String, BlockData)).$2).center?.rawFeathers);
      print(BarConfig.fromBlock((config.dynamicSchemas.firstOrNullWhere((e) => e.$1 == "Bar") as (String, BlockData)).$2).start?.rawFeathers);
    } catch (e, st) {
      print("$e\n$st");
      print(BarConfig.schema.blocks["End"]!.blocks);
    }
    print(BarConfig.schema.blocks["End"]!.blocks);
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
