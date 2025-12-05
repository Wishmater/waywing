import "package:dartx/dartx_io.dart";
import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/volume/volume_config.dart";
import "package:waywing/modules/volume/volume_indicator.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/modules/volume/volume_tooltip.dart";
import "package:waywing/widgets/icons/text_icon.dart";
import "package:waywing/widgets/motion_layout/motion_column.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

class VolumePopover extends StatelessWidget {
  final VolumeConfig config;
  final VolumeService service;
  final VolumeIndicatorType type;

  const VolumePopover({
    required this.config,
    required this.service,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const minWidthPerItem = (256 * 0.75);
    final itemCount = switch (type) {
      VolumeIndicatorType.single => 3,
      VolumeIndicatorType.output => 2,
      VolumeIndicatorType.input => 1,
    };
    final minWidth = minWidthPerItem * itemCount;
    final maxWidth = minWidth * 1.5;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        maxHeight: 512,
      ),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 6),
              if (type == VolumeIndicatorType.output || type == VolumeIndicatorType.single)
                Expanded(
                  child: service.config.groupByApp
                      ? ValueListenableBuilder(
                          valueListenable: service.groupedApps,
                          builder: (context, groupedApps, _) {
                            return GroupedVolumeInterfaceList(
                              models: groupedApps,
                              service: service,
                              config: config,
                              label: "APPS",
                            );
                          },
                        )
                      : ValueListenableBuilder(
                          valueListenable: service.apps,
                          builder: (context, apps, _) {
                            return VolumeInterfaceList(
                              models: apps,
                              service: service,
                              config: config,
                              label: "APPS",
                            );
                          },
                        ),
                ),
              // VerticalDivider(),
              if (type == VolumeIndicatorType.output || type == VolumeIndicatorType.single)
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: service.defaultOutput,
                    builder: (context, defaultOutput, child) {
                      return ValueListenableBuilder(
                        valueListenable: service.outputs,
                        builder: (context, outputs, _) {
                          return VolumeInterfaceList(
                            config: config,
                            models: outputs,
                            service: service,
                            label: "OUTPUTS",
                            defaultModel: defaultOutput,
                            onDefaultSelected: (model) {
                              service.setDefaultOutput(model);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              // VerticalDivider(),
              if (type == VolumeIndicatorType.input || type == VolumeIndicatorType.single)
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: service.defaultInput,
                    builder: (context, defaultInput, child) {
                      return ValueListenableBuilder(
                        valueListenable: service.inputs,
                        builder: (context, inputs, _) {
                          return VolumeInterfaceList(
                            config: config,
                            service: service,
                            models: inputs,
                            label: "INPUTS",
                            defaultModel: defaultInput,
                            onDefaultSelected: (model) {
                              service.setDefaultInput(model);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class VolumeInterfaceList<T extends VolumeInterface> extends StatelessWidget {
  final VolumeConfig config;
  final VolumeService service;
  final List<T> models;
  final T? defaultModel;
  final void Function(T defaultModel)? onDefaultSelected;
  final String label;

  const VolumeInterfaceList({
    required this.config,
    required this.service,
    required this.models,
    required this.label,
    this.defaultModel,
    this.onDefaultSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final nonDefaultModels = models.where((e) => e != defaultModel);
    return FocusTraversalGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(height: 12),
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              child: ScrollOpacityGradient(
                scrollController: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MotionColumn(
                      motion: mainConfig.motions.standard.spatial.normal,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      data: [
                        if (defaultModel != null) //
                          defaultModel,
                        if (defaultModel != null && nonDefaultModels.isNotEmpty) //
                          null, // divider
                        for (final e in nonDefaultModels) //
                          e,
                      ],
                      itemBuilder: (context, e) {
                        if (e == null) {
                          return Divider(indent: 24, endIndent: 24, height: 24);
                        } else {
                          return PopoverVolumeSlider(
                            model: e,
                            padding: const EdgeInsets.only(top: 8, left: 2, right: 18, bottom: 8),
                            config: config,
                            service: service,
                            onDefaultSelected: onDefaultSelected,
                            defaultModel: defaultModel,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupedVolumeInterfaceList<T extends VolumeInterface> extends StatelessWidget {
  final VolumeConfig config;
  final VolumeService service;
  final List<VolumeProcessInterface> models;
  final String label;

  const GroupedVolumeInterfaceList({
    required this.config,
    required this.service,
    required this.models,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return FocusTraversalGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(height: 12),
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              child: ScrollOpacityGradient(
                scrollController: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MotionColumn(
                      motion: mainConfig.motions.standard.spatial.normal,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      data: models,
                      itemBuilder: (context, processModel) {
                        assert(processModel.apps.isNotEmpty);
                        return Padding(
                          padding: processModel.apps.length == 1 ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
                          child: MotionColumn(
                            motion: mainConfig.motions.standard.spatial.normal,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            data: [
                              processModel,
                              if (processModel.apps.length > 1) //
                                ...processModel.apps,
                            ],
                            itemBuilder: (context, e) {
                              if (e is VolumeProcessInterface) {
                                return PopoverVolumeSlider(
                                  model: e,
                                  showSubtitle: processModel.apps.length == 1,
                                  padding: processModel.apps.length == 1
                                      ? const EdgeInsets.only(top: 8, left: 2, right: 18, bottom: 8)
                                      : const EdgeInsets.only(top: 8, left: 2, right: 18, bottom: 0),
                                  config: config,
                                  service: service,
                                );
                              }
                              final maxVolume = config.maxVolume ?? service.config.maxVolume;
                              if (e.iconName != null) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 24,
                                    right: 12,
                                  ),
                                  child: ValueListenableBuilder(
                                    valueListenable: e.iconName!,
                                    builder: (context, iconName, child) {
                                      return PopoverVolumeSlider(
                                        model: e,
                                        showTitle: false,
                                        showIcon: iconName != processModel.iconName.value,
                                        dense: true,
                                        padding: const EdgeInsets.only(top: 4, left: 2, right: 18, bottom: 0),
                                        config: config,
                                        service: service,
                                      );
                                    },
                                  ),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 24,
                                  // this makes it so the "100" mark is aligned
                                  right: (24 * ((maxVolume - 100) / 100)).coerceAtLeast(0),
                                ),
                                child: PopoverVolumeSlider(
                                  model: e,
                                  showTitle: false,
                                  showIcon: false,
                                  dense: true,
                                  padding: const EdgeInsets.only(top: 4, left: 2 + 24, right: 18, bottom: 0),
                                  config: config,
                                  service: service,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PopoverVolumeSlider<T extends VolumeInterface> extends StatelessWidget {
  final VolumeConfig config;
  final VolumeService service;
  final T model;
  final bool showTitle;
  final bool showSubtitle;
  final bool showIcon;
  final bool dense;
  final void Function(T defaultModel)? onDefaultSelected;
  final T? defaultModel;
  final EdgeInsets padding;

  const PopoverVolumeSlider({
    required this.config,
    required this.service,
    required this.model,
    this.onDefaultSelected,
    this.defaultModel,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showIcon = true,
    this.dense = false,
    this.padding = const EdgeInsets.only(top: 8, left: 18, right: 18, bottom: 8),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onDefaultSelected == null) //
          SizedBox(width: 16),
        if (onDefaultSelected != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Radio(
              value: model,
              // ignore: deprecated_member_use
              groupValue: defaultModel,
              // ignore: deprecated_member_use
              onChanged: (value) {
                onDefaultSelected!(value!);
              },
            ),
          ),
        if (model.iconName != null)
          // TODO: 3 maybe don't leave space if none of the apps have resolved icon
          Padding(
            padding: EdgeInsets.only(right: 6, top: padding.top, bottom: padding.bottom),
            child: ValueListenableBuilder(
              valueListenable: model.iconName!,
              builder: (context, iconName, child) {
                if (!showIcon || iconName == null) {
                  return SizedBox.square(dimension: TextIcon.getIconEffectiveSize(context));
                }
                return WingedIcon(
                  iconNames: [iconName],
                  notFoundBuilder: (context) => IconSpacer(),
                );
              },
            ),
          ),
        Expanded(
          child: VolumeSlider(
            model: model,
            service: service,
            config: config,
            padding: padding,
            showTitle: showTitle,
            showSubtitle: showSubtitle,
            dense: dense,
          ),
        ),
      ],
    );
  }
}
