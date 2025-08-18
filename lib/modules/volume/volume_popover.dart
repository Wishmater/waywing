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
                  valueListenable: service.outputs,
                  builder: (context, outputs, _) {
                    return VolumeInterfaceList(
                      models: outputs,
                      label: "OUTPUTS",
                    );
                  },
                ),
              ),
              // VerticalDivider(),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: service.inputs,
                  builder: (context, inputs, _) {
                    return VolumeInterfaceList(
                      models: inputs,
                      label: "INPUTS",
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

class VolumeInterfaceList extends StatelessWidget {
  final List<VolumeInterface> models;
  final String label;

  const VolumeInterfaceList({
    required this.models,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: 1 implement defaults
    // TODO: 2 add app icon (only for apps)
    final scrollController = ScrollController();
    return Column(
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
                    for (final e in models) VolumeSlider(model: e),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
