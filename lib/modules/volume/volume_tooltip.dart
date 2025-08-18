import "package:flutter/material.dart";
import "package:waywing/modules/volume/volume_service.dart";

class VolumeTooltip extends StatelessWidget {
  final VolumeService service;

  const VolumeTooltip({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text("VolumeTooltip");
  }
}
