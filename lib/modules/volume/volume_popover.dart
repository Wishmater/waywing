import "package:flutter/material.dart";
import "package:waywing/modules/volume/volume_service.dart";

class VolumePopover extends StatelessWidget {
  final VolumeService service;

  const VolumePopover({
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text("VolumePopover");
  }
}
