import "package:flutter/material.dart";
import "package:waywing/modules/volume/volume_service.dart";
import "package:waywing/modules/volume/volume_tooltip.dart";
import "package:waywing/widgets/opacity_gradient.dart";

class VolumePopover extends StatelessWidget {
  final VolumeService service;

  const VolumePopover({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 512,
        maxWidth: 512 * 1.5,
        maxHeight: 512,
      ),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 6),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: service.apps,
                  builder: (context, apps, _) {
                    return VolumeInterfaceList(
                      models: apps,
                      label: "APPS",
                    );
                  },
                ),
              ),
              // VerticalDivider(),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: service.defaultOutput,
                  builder: (context, defaultOutput, child) {
                    return ValueListenableBuilder(
                      valueListenable: service.outputs,
                      builder: (context, outputs, _) {
                        return VolumeInterfaceList(
                          models: outputs,
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
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: service.defaultInput,
                  builder: (context, defaultInput, child) {
                    return ValueListenableBuilder(
                      valueListenable: service.inputs,
                      builder: (context, inputs, _) {
                        return VolumeInterfaceList(
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
  final List<T> models;
  final T? defaultModel;
  final void Function(T defaultModel)? onDefaultSelected;
  final String label;

  const VolumeInterfaceList({
    required this.models,
    required this.label,
    this.defaultModel,
    this.onDefaultSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: 2 add app icon (only for apps)
    final scrollController = ScrollController();
    final nonDefaultModels = models.where((e) => e != defaultModel);
    // TODO: 2 add animations to list
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (defaultModel != null) //
                        buildVolumeSlider(context, defaultModel!),
                      if (defaultModel != null && nonDefaultModels.isNotEmpty)
                        Divider(indent: 24, endIndent: 24, height: 24),
                      for (final e in nonDefaultModels) //
                        buildVolumeSlider(context, e),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVolumeSlider(BuildContext context, T model) {
    return Row(
      children: [
        SizedBox(
          width: 16,
        ),
        if (onDefaultSelected != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Radio(
              value: model,
              groupValue: defaultModel,
              onChanged: (value) {
                onDefaultSelected!(value!);
              },
            ),
          ),
        Expanded(
          child: VolumeSlider(
            model: model,
            padding: const EdgeInsets.only(top: 8, left: 2, right: 18, bottom: 8),
          ),
        ),
      ],
    );
  }
}
