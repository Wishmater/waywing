import "package:flutter/cupertino.dart";
import "package:waywing/modules/nm/nm_service.dart";

class NetworkManagerWidget extends StatefulWidget {
  final NetworkManagerService service;
  const NetworkManagerWidget({super.key, required this.service});

  @override
  State<NetworkManagerWidget> createState() => _NetworkManagerState();
}

class _NetworkManagerState extends State<NetworkManagerWidget> {
  late final WifiManager wifiDevice;

  @override
  void initState() {
    super.initState();

    final device = widget.service.getWirelessDevice();
    wifiDevice = WifiManager(device!);
  }

  @override
  void dispose() {
    wifiDevice.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wifiDevice.activeAccessPoint,
      builder: (context, _) {
        return Text(wifiDevice.activeAccessPoint.value == null ? "NO" : "SI");
      },
    );
  }
}
