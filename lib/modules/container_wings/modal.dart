import "package:config/config.dart";
import "package:config_gen/config_gen.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:waywing/core/config.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/server.dart";
import "package:waywing/core/wing.dart";
import "package:waywing/modules/app_launcher/service/application_service.dart";
import "package:waywing/util/config_fields.dart";
import "package:waywing/util/focus_grab/widget.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/motion_widgets/motion_container.dart";
import "package:waywing/widgets/winged_widgets/winged_popover_provider.dart";

part "modal.config.dart";

class ModalWing extends Wing<ModalConfig> {
  late ApplicationService service;

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
  late final focusGrabController = FocusGrabController(
    onCleared: () {
      show.value = false;
    },
  );

  @override
  String get actionsPath => feather.prettyUniqueId.replaceAll("${prettyUniqueId.split(".").last}.", "");

  @override
  late final Map<String, WaywingAction>? actions = {
    "show": WaywingAction(
      "Show the modal",
      (request) {
        show.value = true;
        focusGrabController.grabFocus();
        return WaywingResponse.ok();
      },
    ),
    "hide": WaywingAction(
      "Hide the modal",
      (request) {
        show.value = false;
        focusGrabController.ungrabFocus();
        return WaywingResponse.ok();
      },
    ),
    "toggle": WaywingAction(
      "Toggle the modal",
      (request) {
        show.value = !show.value;
        if (show.value) {
          focusGrabController.grabFocus();
        } else {
          focusGrabController.ungrabFocus();
        }
        return WaywingResponse.ok();
      },
    ),
  };

  @override
  Widget buildWing(EdgeInsets rerservedSpace) {
    return NotificationListener<CloseRequestNotification>(
      onNotification: (_) {
        show.value = false;
        focusGrabController.ungrabFocus();
        return true;
      },
      child: ValueListenableBuilder(
        valueListenable: show,
        builder: (contex, show, _) {
          Widget result;
          if (!show) {
            return SizedBox.shrink();
          }

          result = KeyboardFocus(
            mode: KeyboardFocusMode.onDemand,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  this.show.value = false;
                  focusGrabController.ungrabFocus();
                },
              },
              child: FocusGrab(
                controller: focusGrabController,
                child: SizedBox(
                  width: config.width.toDouble(),
                  height: config.height.toDouble(),
                  child: ValueListenableBuilder(
                    valueListenable: feather.components,
                    builder: (context, components, _) {
                      // TODO: 1 what to do when there are several/no components
                      return components.first.buildPopover!(context);
                    },
                  ),
                ),
              ),
            ),
          );

          return MotionContainer(
            motion: mainConfig.motions.expressive.spatial.normal,
            alignment: Alignment.center,
            padding: rerservedSpace,
            color: !show ? Colors.transparent : config.barrierColor,
            child: result,
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
  static const _width = DoubleNumberField(defaultTo: 400, validator: _heightWidth);
  static const _height = DoubleNumberField(defaultTo: 400, validator: _heightWidth);
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
