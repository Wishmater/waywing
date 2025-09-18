import "package:flutter/src/painting/edge_insets.dart";
import "package:flutter/src/widgets/framework.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/wing.dart";

class ModalWing extends Wing {
  ModalWing._();

  static void registerFeather(RegisterFeatherCallback<ModalWing, dynamic> registerFeather) {
    registerFeather(
      "Bar",
      FeatherRegistration(
        constructor: ModalWing._,
      ),
    );
  }

  @override
  String get name => "Modal";

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    // TODO: implement buildWing
    throw UnimplementedError();
  }

}
