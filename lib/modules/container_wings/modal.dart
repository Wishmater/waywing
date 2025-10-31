import "dart:math";

import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/util/config_fields.dart";
import "package:waywing/widgets/hideable.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/motion_widgets/motion_container.dart";
import "package:waywing/widgets/shapes/external_rounded_corners_shape.dart";
import "package:waywing/widgets/winged_widgets/winged_container.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

part "modal.config.dart";

class ModalWing extends Wing<ModalConfig> {
  ModalWing._();

  static void registerFeather(RegisterFeatherCallback<ModalWing, ModalConfig> registerFeather) {
    registerFeather(
      "Modal",
      FeatherRegistration<ModalWing, ModalConfig>(
        constructor: ModalWing._,
        schemaBuilder: () => ModalConfig.schema,
        configBuilder: ModalConfig.fromBlock,
      ),
    );
  }

  @override
  String get name => "Modal";

  late Feather feather = config.getFeatherInstance(uniqueId);

  @override
  List<Feather> getFeathers() => [feather];

  @override
  void onConfigUpdated(ModalConfig oldConfig) {
    feather = config.getFeatherInstance(uniqueId);
  }

  final show = ValueNotifier(false);

  @override
  String get actionsPath => feather.prettyUniqueId.replaceAll("${prettyUniqueId.split(".").last}.", "");

  @override
  late final Map<String, WaywingAction>? actions = {
    "show": WaywingAction(
      "Show the modal",
      (request) {
        show.value = true;
        return WaywingResponse.ok();
      },
    ),
    "hide": WaywingAction(
      "Hide the modal",
      (request) {
        show.value = false;
        return WaywingResponse.ok();
      },
    ),
    "toggle": WaywingAction(
      "Toggle the modal",
      (request) {
        show.value = !show.value;
        return WaywingResponse.ok();
      },
    ),
  };

  @override
  Widget buildWing(BuildContext context, EdgeInsets rerservedSpace) {
    return NotificationListener<CloseRequestNotification>(
      onNotification: (_) {
        show.value = false;
        return true;
      },
      child: ValueListenableBuilder(
        valueListenable: show,
        builder: (contex, show, _) {
          final result = Hideable(
            show: show,
            builder: (context, _) {
              return FutureBuilder(
                future: featherRegistry.awaitInitialization(feather),
                builder: (context, snapshot) {
                  Widget result;
                  // TODO: 3 add animation to snapshot status change
                  if (snapshot.hasError) {
                    result = Padding(
                      padding: const EdgeInsets.all(16),
                      child: Focus(
                        autofocus: true,
                        child: WingedIcon(
                          // TODO: 3 add details of the error, maybe show extract this feather error-handling
                          // logic into a widget that can be used in multiple places
                          flutterIcon: SymbolsVaried.error,
                          color: mainConfig.theme.errorColor,
                        ),
                      ),
                    );
                  } else if (snapshot.connectionState != ConnectionState.done) {
                    result = Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox.square(
                        dimension: 32,
                        child: Focus(
                          autofocus: true,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  } else {
                    final screenSize = MediaQuery.sizeOf(context);
                    final avalilableSize = Size(
                      screenSize.width - rerservedSpace.horizontal,
                      screenSize.height - rerservedSpace.vertical,
                    );
                    result = ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: min(avalilableSize.width, config.maxWidth?.toDouble() ?? double.infinity),
                        maxHeight: max(avalilableSize.width, config.maxHeight?.toDouble() ?? double.infinity),
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: feather.components,
                        builder: (context, components, _) {
                          // TODO: 1 what to do when there are several/no components
                          return components.first.buildPopover!(context);
                        },
                      ),
                    );
                  }
                  return WingedContainer(
                    motion: mainConfig.motions.expressive.spatial.slow,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    addInputRegion: false,
                    shape: ExternalRoundedCornersBorder(
                      borderRadius: BorderRadius.all(Radius.circular(mainConfig.theme.containerRounding)),
                    ),
                    unfocusContainerOnMouseExit: false,
                    child: FocusScope(
                      canRequestFocus: show,
                      child: KeyboardFocus(
                        debugLabel: "Modal",
                        mode: KeyboardFocusMode.exclusive,
                        child: CallbackShortcuts(
                          bindings: {
                            const SingleActivator(LogicalKeyboardKey.escape): () {
                              this.show.value = false;
                            },
                          },
                          child: result,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );

          return InputRegion(
            active: show,
            child: IgnorePointer(
              ignoring: !show,
              child: GestureDetector(
                onTap: () => this.show.value = false,
                child: MotionContainer(
                  motion: mainConfig.motions.expressive.spatial.normal,
                  // TODO: 1 allow user to change alignment, including fractional alignments
                  alignment: Alignment.center,
                  padding: rerservedSpace,
                  color: !show ? Colors.transparent : config.barrierColor,
                  child: result,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

@Config()
mixin ModalConfigBase on ModalConfigI {
  static const _barrierColor = ColorField(defaultTo: MyColor(0x8A000000));
  static const _barrierDismissable = BooleanField(defaultTo: true);
  static const _maxWidth = DoubleNumberField(nullable: true, validator: _heightWidth);
  static const _maxHeight = DoubleNumberField(nullable: true, validator: _heightWidth);

  static Map<String, ({BlockSchema schema, dynamic Function(BlockData) from})> _getDynamicSchemaTables() =>
      featherRegistry.getDynamicFeathersSchemas();

  // TODO: 1 validate that has 1 and only 1 feather
  (String, Object) get feather => dynamicSchemas.first;

  T getFeatherInstance<T extends Feather>(String uniqueIdPrefix) {
    return getFeatherInstancesStatic<T>([feather], uniqueIdPrefix).first;
  }
}

ValidatorResult<double> _heightWidth(double value) {
  if (value < 200) {
    return ValidatorError(_RangeValidationError<double>(start: 200, end: double.infinity, actual: value));
  }
  return ValidatorSuccess();
}

// TODO: 2 standardize validations, this is currently copy-pasted in several places
class _RangeValidationError<T extends Comparable> extends ValidationError {
  final T start;
  final T end;
  final T actual;

  _RangeValidationError({required this.start, required this.end, required this.actual});

  @override
  String toString() {
    return "Range validation error. Expected to be between $start and $end but got $actual";
  }

  @override
  String error() {
    return toString();
  }
}
