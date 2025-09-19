import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_mdi_icons/flutter_mdi_icons.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/volume/volume_config.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/widgets/icons/composed_icon.dart";
import "package:waywing/widgets/icons/symbol_icon.dart";
import "package:waywing/widgets/motion_widgets/motion_container.dart";
import "package:waywing/widgets/motion_widgets/motion_fractionally_sized_box.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";
import "package:waywing/widgets/winged_widgets/winged_popover.dart";

enum VolumeIndicatorType {
  single,
  output,
  input,
}

class VolumeIndicator extends StatefulWidget {
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
  State<VolumeIndicator> createState() => _VolumeIndicatorState();
}

class _VolumeIndicatorState extends State<VolumeIndicator> {
  ValueListenable<VolumeInterface?> get listenable => getListenable();

  ValueListenable<VolumeInterface?> getListenable([VolumeIndicatorType? type]) {
    type ??= widget.type;
    if (type == VolumeIndicatorType.input) {
      return widget.service.defaultInput;
    } else {
      return widget.service.defaultOutput;
    }
  }

  @override
  void initState() {
    super.initState();
    listenable.addListener(addVolumeListener);
    addVolumeListener();
    _previousDevice = listenable.value;
  }

  @override
  void didUpdateWidget(covariant VolumeIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type) {
      getListenable(oldWidget.type).removeListener(addVolumeListener);
      listenable.addListener(addVolumeListener);
    }
  }

  @override
  void dispose() {
    listenable.removeListener(addVolumeListener);
    super.dispose();
  }

  VolumeInterface? _previousDevice;
  void addVolumeListener() {
    _previousDevice?.volume.removeListener(onVolumeChanged);
    _previousDevice?.isMuted.removeListener(onVolumeChanged);
    listenable.value?.volume.addListener(onVolumeChanged);
    listenable.value?.isMuted.addListener(onVolumeChanged);
  }

  void onVolumeChanged() async {
    if (widget.config.showTooltipOnVolumeChange) {
      await widget.popover.showTooltip(showDelay: Duration.zero);
      await widget.popover.hideTooltip(hideDelay: Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxHeight > constraints.maxWidth;
        return ValueListenableBuilder(
          valueListenable: listenable,
          builder: (context, defaultOutput, child) {
            Widget result;
            if (defaultOutput == null) {
              if (widget.type == VolumeIndicatorType.input) {
                result = WingedIcon(
                  flutterIcon: SymbolsVaried.mic_off,
                  iconNames: ["audio-input-microphone-muted", "audio-input-microphone"],
                  textIcon: "", // nf-fa-microphone_lines_slash
                );
              } else {
                result = WingedIcon(
                  flutterIcon: SymbolsVaried.volume_off,
                  iconNames: ["audio-volume-off", "audio-volume-muted"],
                  textIcon: "󰸈", // nf-md-volume_variant_off
                );
              }
            } else {
              result = ValueListenableBuilder(
                valueListenable: defaultOutput.isMuted,
                builder: (context, isMuted, child) {
                  if (isMuted) {
                    if (widget.type == VolumeIndicatorType.input) {
                      return WingedIcon(
                        flutterIcon: SymbolsVaried.mic,
                        iconNames: ["audio-input-microphone-low", "audio-input-microphone"],
                        textIcon: "󰍮", // nf-md-microphone_outline
                        flutterBuilder: (context) => ComposedIcon(
                          subicon: SymbolIcon(SymbolsVaried.close),
                          subiconSize: 0.6,
                          subiconAlignment: Alignment.centerRight,
                          child: SymbolIcon(SymbolsVaried.mic),
                        ),
                      );
                    } else {
                      return WingedIcon(
                        flutterIcon: SymbolsVaried.no_sound,
                        iconNames: ["audio-volume-muted"],
                        textIcon: "󰝟", // nf-md-volume_mute
                      );
                    }
                  }
                  return VolumeScrollWhellListener(
                    model: defaultOutput,
                    config: widget.config,
                    child: ValueListenableBuilder(
                      valueListenable: defaultOutput.volume,
                      builder: (context, volume, child) {
                        Widget icon;
                        Color volTrackColor = Theme.of(context).dividerTheme.color ?? Theme.of(context).dividerColor;
                        Color volValueColor = Theme.of(context).colorScheme.primary;
                        if (volume == 0) {
                          volTrackColor = Color.alphaBlend(Colors.black26, Theme.of(context).dividerTheme.color!);
                        } else if (volume == 1) {
                          volValueColor = Theme.of(context).colorScheme.secondary;
                        }
                        // TODO: 2 add animation to icon change
                        if (widget.type == VolumeIndicatorType.input) {
                          // TODO: 2 find better icons for mic low/med/high volume (or implement a better continuous clipper (similar to wifi) that works for both)
                          icon = WingedIcon(
                            flutterIcon: SymbolsVaried.mic,
                            iconNames: ["audio-input-microphone-high", "audio-input-microphone"],
                            textIcon: "", // nf-fa-microphone_lines
                          );
                        } else {
                          if (volume == 0) {
                            icon = WingedIcon(
                              flutterIcon: SymbolsVaried.volume_mute,
                              iconNames: ["audio-volume-low"],
                              textIcon: "󰕿", // nf-md-volume_low
                              flutterBuilder: (context) => FractionalTranslation(
                                translation: Offset(-0.08, 0),
                                child: SymbolIcon(Mdi.volumeLow),
                              ),
                            );
                          } else if (volume <= 0.5) {
                            icon = WingedIcon(
                              flutterIcon: SymbolsVaried.volume_down,
                              iconNames: ["audio-volume-medium"],
                              textIcon: "󰖀", // nf-md-volume_medium
                            );
                          } else {
                            icon = WingedIcon(
                              flutterIcon: SymbolsVaried.volume_up,
                              iconNames: ["audio-volume-high"],
                              textIcon: "󰕾", // nf-md-volume_high
                              flutterBuilder: (context) => FractionalTranslation(
                                translation: Offset(0.08, 0),
                                child: SymbolIcon(SymbolsVaried.volume_up),
                              ),
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
                                        child: MotionFractionallySizedBox(
                                          motion: mainConfig.motions.expressive.spatial.normal,
                                          heightFactor: volume <= 1 ? 0 : (volume - 1) / volume,
                                          alignment: Alignment.topCenter,
                                          child: MotionContainer(
                                            motion: mainConfig.motions.expressive.spatial.normal,
                                            width: volBarSize,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ),
                                      ),
                                      MotionFractionallySizedBox(
                                        motion: mainConfig.motions.expressive.spatial.normal,
                                        heightFactor: volume <= 1 ? 1 : 1 / volume,
                                        alignment: Alignment.bottomCenter,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            MotionContainer(
                                              motion: mainConfig.motions.expressive.spatial.normal,
                                              width: volBarSize,
                                              color: volTrackColor,
                                            ),
                                            Positioned.fill(
                                              child: MotionFractionallySizedBox(
                                                motion: mainConfig.motions.expressive.spatial.normal,
                                                heightFactor: volume.clamp(0, 1),
                                                alignment: Alignment.bottomCenter,
                                                child: MotionContainer(
                                                  motion: mainConfig.motions.expressive.spatial.normal,
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
                        if (widget.config.showPercentageIndicator && !isMuted) {
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
              onTap: () => widget.popover.togglePopover(),
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
