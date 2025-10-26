import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/battery/battery_config.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/modules/battery/battery_indicator.dart";
import "package:waywing/modules/battery/battery_tooltip.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

class BatteryFeather extends Feather<BatteryConfig> {
  late BatteryService service;

  ManualNotifier enableProfileChange = ManualNotifier();

  BatteryFeather._();

  static void registerFeather(RegisterFeatherCallback<BatteryFeather, void> registerFeather) {
    registerFeather(
      "Battery",
      FeatherRegistration(
        constructor: BatteryFeather._,
        configBuilder: BatteryConfig.fromBlock,
        schemaBuilder: () => BatteryConfig.schema,
      ),
    );
  }

  @override
  String get name => "Battery";

  @override
  Future<void> init(BuildContext context) async {
    service = await serviceRegistry.requestService<BatteryService>(this);
  }

  @override
  void onConfigUpdated(covariant BatteryConfig oldConfig) {
    if (oldConfig.enableProfile != config.enableProfile) {
      enableProfileChange.manualNotifyListeners();
    }
  }

  @override
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([batteryComponent]);

  late final batteryComponent = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        ListenableBuilder(
          listenable: enableProfileChange,
          builder: (context, _) {
            if (service.profile != null && config.enableProfile) {
              return WingedButton(
                onTap: () => popover!.togglePopover(),
                child: BatteryIndicator(battery: service.battery),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                child: BatteryIndicator(battery: service.battery),
              );
            }
          },
        ),
      ];
    },
    buildTooltip: (context) {
      return BatteryTooltip(config: config, service: service);
    },
    buildPopover: (context) {
      if (service.profile != null && config.enableProfile) {
        return BatteryPopover(profile: service.profile!);
      } else {
        return SizedBox.shrink();
      }
    },
  );
}

class BatteryPopover extends StatelessWidget {
  final ProfileValues profile;

  const BatteryPopover({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder(
            valueListenable: profile.actionsInfo,
            builder: (context, actions, _) {
              return Column(
                children: [
                  _ProfileSelector(profile),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  final ProfileValues profile;
  const _ProfileSelector(this.profile);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([profile.activeProfile, profile.profiles]),
      builder: (context, _) {
        final profiles = profile.profiles.value;
        final activeProfile = profile.activeProfile.value;
        return KeyboardFocus(
          debugLabel: "ProfileSelector",
          mode: KeyboardFocusMode.onDemand,
          child: RadioGroup<String>(
            groupValue: activeProfile,
            onChanged: (profile) {
              if (profile != null) {
                this.profile.setActiveProfile(profile);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final profile in profiles) _Profile(profile.profile)],
            ),
          ),
        );
      },
    );
  }
}

class _Profile extends StatelessWidget {
  final String profile;
  const _Profile(this.profile);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(value: profile),
        Text(profile),
      ],
    );
  }
}
