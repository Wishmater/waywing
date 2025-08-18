import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/widgets/winged_button.dart";
import "package:waywing/widgets/winged_popover.dart";

class VolumeIndicator extends StatelessWidget {
  final VolumeService service;
  final WingedPopoverController popover;

  const VolumeIndicator({
    required this.service,
    required this.popover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service.defaultOutput,
      builder: (context, defaultOutput, child) {
        Widget result;
        if (defaultOutput == null) {
          result = Icon(MaterialCommunityIcons.volume_variant_off);
        } else {
          result = ValueListenableBuilder(
            valueListenable: defaultOutput.isMuted,
            builder: (context, isMuted, child) {
              if (isMuted) {
                return Icon(MaterialCommunityIcons.volume_mute);
              }
              return VolumeScrollWhellListener(
                model: defaultOutput,
                child: ValueListenableBuilder(
                  valueListenable: defaultOutput.volume,
                  builder: (context, volume, child) {
                    Widget icon;
                    Color volTrackColor = Theme.of(context).dividerTheme.color!;
                    Color volValueColor = Theme.of(context).colorScheme.primary;
                    // TODO: 2 add animation to icon change
                    if (volume == 0) {
                      icon = FractionalTranslation(
                        translation: Offset(-0.08, 0),
                        child: Icon(MaterialCommunityIcons.volume_low),
                      );
                      volTrackColor = Color.alphaBlend(Colors.black26, Theme.of(context).dividerTheme.color!);
                    } else if (volume <= 0.5) {
                      icon = Icon(MaterialCommunityIcons.volume_medium);
                    } else {
                      icon = FractionalTranslation(
                        translation: Offset(0.08, 0),
                        child: Icon(MaterialCommunityIcons.volume_high),
                      );
                    }
                    if (volume == 1) {
                      volValueColor = Theme.of(context).colorScheme.secondary;
                    }
                    // TODO: 1 add option to show percentage in indicator
                    final volBarSize = (Theme.of(context).iconTheme.size ?? kDefaultFontSize) * 0.25;
                    return IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // TODO: 1 support values over 1 in this indicator (maybe with a different color)
                          FractionallySizedBox(
                            heightFactor: 0.9,
                            child: Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              width: volBarSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(volBarSize / 2)),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: config.animationDuration,
                                    curve: config.animationCurve,
                                    width: volBarSize,
                                    color: volTrackColor,
                                  ),
                                  Positioned.fill(
                                    child: AnimatedFractionallySizedBox(
                                      duration: config.animationDuration,
                                      curve: config.animationCurve,
                                      heightFactor: volume,
                                      alignment: Alignment.bottomCenter,
                                      child: AnimatedContainer(
                                        duration: config.animationDuration,
                                        curve: config.animationCurve,
                                        color: volValueColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          icon,
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return WingedButton(
          onTap: () => popover.togglePopover(),
          onSecondaryTap: defaultOutput == null ? null : () => defaultOutput.setMuted(!defaultOutput.isMuted.value),
          child: result,
        );
      },
    );
  }
}

class VolumeScrollWhellListener extends StatelessWidget {
  final VolumeInterface model;
  final Widget child;

  const VolumeScrollWhellListener({
    required this.model,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: child,
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          if (pointerSignal.scrollDelta.dy > 0) {
            model.decreaseVolume();
          } else {
            model.increaseVolume();
          }
        }
      },
    );
  }
}
