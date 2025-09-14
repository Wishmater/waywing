import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:upower/upower.dart";
import "package:waywing/core/feather.dart";
import "package:waywing/core/feather_registry.dart";
import "package:waywing/core/service_registry.dart";
import "package:waywing/modules/battery/battery_service.dart";
import "package:waywing/modules/battery/battery_indicator.dart";
import "package:waywing/util/derived_value_notifier.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

class BatteryFeather extends Feather {
  late BatteryService service;

  BatteryFeather._();

  static void registerFeather(RegisterFeatherCallback<BatteryFeather, void> registerFeather) {
    registerFeather(
      "Battery",
      FeatherRegistration(
        constructor: BatteryFeather._,
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
  late final ValueListenable<List<FeatherComponent>> components = DummyValueNotifier([batteryComponent]);

  late final batteryComponent = FeatherComponent(
    buildIndicators: (context, popover) {
      return [
        BatteryIndicator(battery: service.battery),
        WingedButton(
          onTap: () => popover!.togglePopover(),
          child: BatteryIndicator(battery: service.battery),
        ),
      ];
    },
    buildPopover: (context) {
      return BatteryPopover(profile: service.profile);
    },
  );
}

class BatteryPopover extends StatelessWidget {
  final ProfileValues profile;

  const BatteryPopover({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 300,
      child: ValueListenableBuilder(
        valueListenable: profile.actionsInfo,
        builder: (context, actions, _) {
          return Column(
            children: [
             ...[for (final action in actions) _ActionWidget(profile, action)],
             _ProfileSelector(profile),
            ],
          );
        },
      ),
    );
  }
}

class _ActionWidget extends StatelessWidget {
  final UPowerProfileActionInfo actionInfo;
  final ProfileValues profile;

  const _ActionWidget(this.profile, this.actionInfo);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(actionInfo.description, overflow: TextOverflow.fade),
        Switch(
          onChanged: (value) {
            profile.setActionEnabled(actionInfo.name, value);
          },
          value: actionInfo.enabled,
        ),
      ],
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  final ProfileValues profile;
  const _ProfileSelector(this.profile);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: profile.activeProfile,
      builder: (context, activeProfile, _) {
        return ValueListenableBuilder(
          valueListenable: profile.profiles,
          builder: (context, profiles, _) {
            return Column(
              children: [
                for (final profile in profiles)
                  Row(
                    children: [
                      Text(profile.profile),
                      Switch(
                        onChanged: (value) {
                          if (true) {
                            this.profile.setActiveProfile(profile.profile);
                          }
                        },
                        value: profile.profile == activeProfile,
                      )
                    ]
                  )
              ]
            );
          }
        );
      }
    );
  }
}
