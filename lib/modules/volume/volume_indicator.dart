import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/volume/volume_config.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/widgets/winged_button.dart";
import "package:waywing/widgets/winged_popover.dart";

enum VolumeIndicatorType {
  single,
  output,
  input,
}

class VolumeIndicator extends StatelessWidget {
  final VolumeConfig config;
  final VolumeService service;
  final WingedPopoverController popover;
  final VolumeIndicatorType type;

  const VolumeIndicator({
    required this.config,
    required this.service,
    required this.popover,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxHeight > constraints.maxWidth;
        return ValueListenableBuilder(
          valueListenable: type == VolumeIndicatorType.input ? service.defaultInput : service.defaultOutput,
          builder: (context, defaultOutput, child) {
            Widget result;
            if (defaultOutput == null) {
              result = type == VolumeIndicatorType.input
                  ? Icon(MaterialCommunityIcons.microphone_off)
                  : Icon(MaterialCommunityIcons.volume_variant_off);
            } else {
              result = ValueListenableBuilder(
                valueListenable: defaultOutput.isMuted,
                builder: (context, isMuted, child) {
                  if (isMuted) {
                    return type == VolumeIndicatorType.input
                        ? Icon(MaterialCommunityIcons.microphone_outline) // TODO: 2 find a better icon for muted mic
                        : Icon(MaterialCommunityIcons.volume_mute);
                  }
                  return VolumeScrollWhellListener(
                    model: defaultOutput,
                    config: config,
                    child: ValueListenableBuilder(
                      valueListenable: defaultOutput.volume,
                      builder: (context, volume, child) {
                        Widget icon;
                        Color volTrackColor = Theme.of(context).dividerTheme.color!;
                        Color volValueColor = Theme.of(context).colorScheme.primary;
                        if (volume == 0) {
                          volTrackColor = Color.alphaBlend(Colors.black26, Theme.of(context).dividerTheme.color!);
                        } else if (volume == 1) {
                          volValueColor = Theme.of(context).colorScheme.secondary;
                        }
                        // TODO: 2 add animation to icon change
                        if (type == VolumeIndicatorType.input) {
                          // TODO: 2 find better icons for mic low/med/high volume (or implement a better continuous clipper (similar to wifi) that works for both)
                          icon = Icon(MaterialCommunityIcons.microphone);
                        } else {
                          if (volume == 0) {
                            icon = FractionalTranslation(
                              translation: Offset(-0.08, 0),
                              child: Icon(MaterialCommunityIcons.volume_low),
                            );
                          } else if (volume <= 0.5) {
                            icon = Icon(MaterialCommunityIcons.volume_medium);
                          } else {
                            icon = FractionalTranslation(
                              translation: Offset(0.08, 0),
                              child: Icon(MaterialCommunityIcons.volume_high),
                            );
                          }
                        }

                        final volBarSize = (Theme.of(context).iconTheme.size ?? kDefaultFontSize) * 0.25;
                        Widget result = IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FractionallySizedBox(
                                heightFactor: 0.9,
                                child: Container(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  width: volBarSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(volBarSize / 2)),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Positioned.fill(
                                        child: AnimatedFractionallySizedBox(
                                          duration: mainConfig.animationDuration,
                                          curve: mainConfig.animationCurve,
                                          heightFactor: volume <= 1 ? 0 : (volume - 1) / volume,
                                          alignment: Alignment.topCenter,
                                          child: AnimatedContainer(
                                            duration: mainConfig.animationDuration,
                                            curve: mainConfig.animationCurve,
                                            width: volBarSize,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ),
                                      ),
                                      AnimatedFractionallySizedBox(
                                        duration: mainConfig.animationDuration,
                                        curve: mainConfig.animationCurve,
                                        heightFactor: volume <= 1 ? 1 : 1 / volume,
                                        alignment: Alignment.bottomCenter,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            AnimatedContainer(
                                              duration: mainConfig.animationDuration,
                                              curve: mainConfig.animationCurve,
                                              width: volBarSize,
                                              color: volTrackColor,
                                            ),
                                            Positioned.fill(
                                              child: AnimatedFractionallySizedBox(
                                                duration: mainConfig.animationDuration,
                                                curve: mainConfig.animationCurve,
                                                heightFactor: volume.clamp(0, 1),
                                                alignment: Alignment.bottomCenter,
                                                child: AnimatedContainer(
                                                  duration: mainConfig.animationDuration,
                                                  curve: mainConfig.animationCurve,
                                                  color: volValueColor,
                                                ),
                                              ),
                                            ),
                                          ],
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
                        if (config.showPercentageIndicator && !isMuted) {
                          final text = Padding(
                            padding: EdgeInsets.only(left: 3),
                            // TODO: 2 add animation to text change ?
                            child: Text(
                              "${(volume * 100).round()}%",
                            ),
                          );
                          if (isVertical) {
                            result = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                result,
                                text,
                              ],
                            );
                          } else {
                            result = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                result,
                                text,
                              ],
                            );
                          }
                        }
                        return result;
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
      },
    );
  }
}

class VolumeScrollWhellListener extends StatelessWidget {
  final VolumeInterface model;
  final VolumeConfig config;
  final Widget child;

  const VolumeScrollWhellListener({
    required this.model,
    required this.config,
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
            model.decreaseVolume(config.volumeStep / 100);
          } else {
            model.increaseVolume(config.volumeStep / 100, max: config.maxVolume / 100);
          }
        }
      },
    );
  }
}
