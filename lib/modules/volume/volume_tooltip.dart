import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/volume/volume_config.dart";
import "package:waywing/modules/volume/volume_indicator.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/widgets/motion_widgets/motion_container.dart";
import "package:waywing/widgets/text_tooltip_on_overflow.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";

class VolumeTooltip extends StatelessWidget {
  final VolumeConfig config;
  final VolumeService service;
  final VolumeIndicatorType type;

  const VolumeTooltip({
    required this.config,
    required this.service,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 256, maxWidth: 256 * 1.5),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: ValueListenableBuilder(
            valueListenable: type == VolumeIndicatorType.input ? service.defaultInput : service.defaultOutput,
            builder: (context, defaultOutput, child) {
              // TODO: 2 maybe add an AnimatedSwitcher here
              if (defaultOutput == null) {
                return Center(
                  child: Text("No audio output detected"),
                );
              }
              return VolumeSlider(
                config: config,
                model: defaultOutput,
              );
            },
          ),
        ),
      ),
    );
  }
}

class VolumeSlider extends StatelessWidget {
  final VolumeConfig config;
  final VolumeInterface model;
  final EdgeInsets padding;

  const VolumeSlider({
    required this.config,
    required this.model,
    this.padding = const EdgeInsets.only(top: 8, left: 18, right: 18, bottom: 8),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: model.name,
                        builder: (context, name, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextTooltipOnOverflow(
                                textSpan: TextSpan(text: name),
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),

                              if (model.subtitle != null)
                                ValueListenableBuilder(
                                  valueListenable: model.subtitle!,
                                  builder: (context, subtitle, child) {
                                    if (subtitle == null) return SizedBox.shrink();
                                    return Text(
                                      subtitle,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    );
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 6),
                    // WingedButton(
                    //   padding: EdgeInsets.zero,
                    //   child: Icon(MaterialCommunityIcons.volume_minus),
                    //   onTap: () {
                    //     model.decreaseVolume();
                    //   },
                    // ),
                    // WingedButton(
                    //   padding: EdgeInsets.zero,
                    //   child: Icon(MaterialCommunityIcons.volume_plus),
                    //   onTap: () {
                    //     model.increaseVolume();
                    //   },
                    // ),
                    ValueListenableBuilder(
                      valueListenable: model.isMuted,
                      builder: (context, isMuted, child) {
                        return WingedButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          child: MotionContainer(
                            motion: mainConfig.motions.expressive.effects.normal,
                            color: isMuted ? Theme.of(context).dividerColor : Colors.transparent,
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              MaterialCommunityIcons.volume_mute,
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                          onTap: () {
                            model.setMuted(!isMuted);
                          },
                        );
                      },
                    ),
                  ],
                ),
                VolumeScrollWhellListener(
                  config: config,
                  model: model,
                  child: ValueListenableBuilder(
                    valueListenable: model.volume,
                    builder: (context, volume, child) {
                      final label = "${(volume * 100).round()}";
                      return Theme(
                        data: Theme.of(context).copyWith(
                          sliderTheme: Theme.of(context).sliderTheme.copyWith(
                            tickMarkShape: SliderTickMarkShape.noTickMark,
                            trackShape: OverflowingRoundedRectSliderTrackShape(
                              overflowColor: Theme.of(context).colorScheme.error,
                            ),
                            thumbShape: LabeledRoundSliderThumbShape(
                              text: label,
                              textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: Colors.white,
                                letterSpacing: -0.5,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(offset: Offset(1, 1), blurRadius: 2),
                                  Shadow(offset: Offset(-1, -1), blurRadius: 2),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // TODO: 3 maybe try to make Slider use Motion animations, probably too much work
                        child: Slider(
                          padding: EdgeInsets.zero,
                          // label: label,
                          value: (volume * 100).clamp(0, config.maxVolume).toDouble(),
                          min: 0,
                          max: config.maxVolume.toDouble(),
                          divisions: (config.maxVolume / config.volumeStep).round(),
                          onChanged: (value) {
                            model.setVolume(value / 100);
                          },
                          secondaryTrackValue: 100,
                          thumbColor: volume == 1
                              ? Theme.of(context).colorScheme.secondary
                              : volume < 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                          activeColor: volume == 1
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                          secondaryActiveColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          inactiveColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LabeledRoundSliderThumbShape extends RoundSliderThumbShape {
  TextStyle textStyle;
  String text;

  LabeledRoundSliderThumbShape({
    required this.text,
    required this.textStyle,
  });

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    super.paint(
      context,
      center,
      activationAnimation: activationAnimation,
      enableAnimation: enableAnimation,
      isDiscrete: isDiscrete,
      labelPainter: labelPainter,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      textDirection: textDirection,
      value: value,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
    );

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(context.canvas, textOffset);
  }
}

class OverflowingRoundedRectSliderTrackShape extends RoundedRectSliderTrackShape {
  final Color overflowColor;

  OverflowingRoundedRectSliderTrackShape({required this.overflowColor});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );
    if (secondaryOffset == null) return;
    if (secondaryOffset.dx >= thumbCenter.dx) return;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius activeTrackRadius = Radius.circular(
      (trackRect.height + additionalActiveTrackHeight) / 2,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        secondaryOffset.dx,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx + (sliderTheme.trackHeight! / 2),
        trackRect.bottom + (additionalActiveTrackHeight / 2),
        topRight: activeTrackRadius,
        bottomRight: activeTrackRadius,
      ),
      Paint()..color = overflowColor,
    );
  }
}
