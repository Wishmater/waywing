import "package:flutter/material.dart";
import "package:pulseaudio/pulseaudio.dart";
import "package:waywing/modules/volume/voulme_service.dart";

class VolumeWidget extends StatefulWidget {
  final VolumeService service;

  const VolumeWidget({super.key, required this.service});

  @override
  State<VolumeWidget> createState() => VolumeWidgetState();
}

class VolumeWidgetState extends State<VolumeWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListenableBuilder(
        listenable: widget.service.values.defaultSink,
        builder: (context, _) {
          return Text((widget.service.values.defaultSink.value.volume * 100).toStringAsFixed(1));
        },
      ),
    );
  }
}

class VolumePopover extends StatefulWidget {
  final VolumeService service;

  const VolumePopover({super.key, required this.service});

  @override
  State<StatefulWidget> createState() => VolumePopoverState();
}

class VolumePopoverState extends State<VolumePopover> {
  VolumeValues get values => widget.service.values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: ListenableBuilder(
        listenable: Listenable.merge([values.inputs, values.defaultSink]),
        builder: (context, _) {
          final children = [
            for (final input in values.inputs.value)
              _SinkWidget(
                input,
                widget.service,
              ),
          ];
          return Column(
            children: [_SystemWidget(values.defaultSink.value, widget.service), ...children],
          );
        },
      ),
    );
  }
}

class _SystemWidget extends StatelessWidget {
  final PulseAudioSink sink;
  final VolumeService service;

  const _SystemWidget(this.sink, this.service);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("System: ${(sink.volume * 100).toStringAsFixed(1)}"),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_upward, size: 15),
              onPressed: () {
                service.setVolumeSink(sink, sink.volume + 0.05);
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward, size: 15),
              onPressed: () {
                service.setVolumeSink(sink, sink.volume - 0.05);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SinkWidget extends StatelessWidget {
  final VolumeService service;
  final PulseAudioSinkInput input;

  const _SinkWidget(this.input, this.service);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${input.props.applicationName}: ${(input.volume * 100).toStringAsFixed(1)}"),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_upward, size: 15),
              onPressed: () {
                service.setVolumeInput(input, input.volume + 0.05);
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward, size: 15),
              onPressed: () {
                service.setVolumeInput(input, input.volume - 0.05);
              },
            ),
          ],
        ),
      ],
    );
  }
}
