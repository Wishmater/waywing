import "package:flutter/material.dart";
import "package:flutter_font_icons/flutter_font_icons.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/volume/volume_indicator.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/widgets/winged_button.dart";

class VolumeTooltip extends StatelessWidget {
  final VolumeService service;

  const VolumeTooltip({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 256, maxWidth: 256 * 1.5),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: ValueListenableBuilder(
            valueListenable: service.defaultOutput,
            builder: (context, defaultOutput, child) {
              // TODO: 1 maybe just also disable tooltip if defaultOutput==null
              // TODO: 2 maybe add an AnimatedSwitcher here
              if (defaultOutput == null) {
                return Center(
                  child: Text("No audio output detected"),
                );
              }
              return VolumeSlider(
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
  final VolumeInterface model;
  final EdgeInsets padding;

  const VolumeSlider({
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
                          // TODO: 1 properly deal with overflowing text
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
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
                    SizedBox(width: 16),
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
                          child: AnimatedContainer(
                            duration: mainConfig.animationDuration,
                            curve: mainConfig.animationCurve,
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
                  model: model,
                  child: ValueListenableBuilder(
                    valueListenable: model.volume,
                    builder: (context, volume, child) {
                      // TODO: 1 implement better slider, with permanent value label, and showing important breakpoints
                      return Slider(
                        padding: EdgeInsets.zero,
                        label: "${(volume * 100).round()}%",
                        value: (volume * 100).clamp(0, 100),
                        min: 0,
                        max: 100, // TODO: 1 implement going over 1
                        divisions: (100 / (VolumeInterface.volumeStep * 100)).round(),
                        onChanged: (value) {
                          model.setVolume(value / 100);
                        },
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
