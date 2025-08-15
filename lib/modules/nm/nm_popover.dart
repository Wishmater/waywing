import "package:flutter/material.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/nm_indicator.dart";
import "package:waywing/modules/nm/nm_service.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/simple_shadow.dart";
import "package:waywing/widgets/winged_button.dart";

class NetworkManagerPopover extends StatefulWidget {
  final NetworkManagerConfig config;
  final NMServiceWifiDevice device;

  const NetworkManagerPopover({
    required this.config,
    required this.device,
    super.key,
  });

  @override
  State<NetworkManagerPopover> createState() => _NetworkManagerPopoverState();
}

class _NetworkManagerPopoverState extends State<NetworkManagerPopover> {
  ValueNotifier<String?> selectedSsid = ValueNotifier(null);
  ValueNotifier<bool> requestingPassword = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 256,
        maxWidth: 384,
        maxHeight: 512,
      ),
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20, right: 16, top: 8, bottom: 4),
                constraints: BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Text("Wi-Fi", style: Theme.of(context).textTheme.bodyLarge),
                    Expanded(child: SizedBox.shrink()),
                    // TODO: 1 listening to and show an animation while refreshing
                    WingedButton(
                      child: Icon(Icons.refresh),
                      builder: (context, snapshot, child) {
                        return RefreshIcon(
                          isRefreshing: snapshot.connectionState != ConnectionState.done,
                          child: child,
                        );
                      },
                      onTap: () async {
                        return widget.device.requestScan();
                      },
                    ),
                    SizedBox(width: 6),
                    SizedBox(
                      width: 60 * 0.7,
                      height: 40 * 0.7,
                      child: FittedBox(
                        child: Switch(
                          // TODO: 1 implement turning wifi on/off
                          value: true,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget.device.activeAccessPoint,
                  builder: (context, activeAccessPoint, child) {
                    return ValueListenableBuilder(
                      valueListenable: widget.device.accessPoints,
                      builder: (context, accessPoints, child) {
                        final apWidgets = <Widget>[];
                        if (activeAccessPoint != null) {
                          apWidgets.addAll([
                            APWidget(
                              device: widget.device,
                              ap: activeAccessPoint,
                              isConnected: true,
                              selectedSsid: selectedSsid,
                              requestingPassword: requestingPassword,
                            ),
                            if (accessPoints.length > 1)
                              Divider(
                                height: 12,
                              ),
                          ]);
                        }
                        for (int i = 0; i < accessPoints.length; i++) {
                          final ap = accessPoints[i];
                          if (activeAccessPoint?.ssid == ap.ssid) continue;
                          apWidgets.add(
                            APWidget(
                              device: widget.device,
                              ap: ap,
                              isConnected: false,
                              selectedSsid: selectedSsid,
                              requestingPassword: requestingPassword,
                            ),
                          );
                        }

                        final scrollController = ScrollController();
                        return Scrollbar(
                          controller: scrollController,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                height: 3,
                                child: CustomPaint(
                                  painter: SimpleShadowPainter(shadowOpacity: 0.25),
                                ),
                              ),
                              ScrollOpacityGradient(
                                scrollController: scrollController,
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      ...apWidgets,
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class APWidget extends StatefulWidget {
  final NMServiceWifiDevice device;
  final NMServiceAccessPoint ap;
  final bool isConnected;
  final ValueNotifier<String?> selectedSsid;
  final ValueNotifier<bool> requestingPassword;

  const APWidget({
    required this.device,
    required this.ap,
    required this.isConnected,
    required this.selectedSsid,
    required this.requestingPassword,
    super.key,
  });

  @override
  State<APWidget> createState() => _APWidgetState();
}

class _APWidgetState extends State<APWidget> {
  late final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.selectedSsid,
      builder: (context, selectedSsid, _) {
        final isSelected = selectedSsid == widget.ap.ssid;
        List<Widget> extraWidgets = [];
        if (isSelected) {
          extraWidgets.addAll([
            SizedBox(width: 36),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: widget.requestingPassword,
                builder: (context, requestingPassword, _) {
                  if (!requestingPassword) return SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: SizedBox(
                      height: 32,
                      child: TextFormField(
                        autofocus: true,
                        controller: passwordController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.only(left: 6, right: 6),
                          label: Text("Password"),
                          labelStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 8),
            WingedButton(
              child: Text(
                widget.isConnected ? "DISCONNECT" : "CONNECT",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onTap: () async {
                if (widget.isConnected) {
                  widget.device.disconnect();
                } else {
                  if (widget.requestingPassword.value) {
                    // TODO: 1 implement autoConnect
                    return widget.device.connect(
                      widget.ap,
                      userPassword: passwordController.text,
                    );
                  } else {
                    final connectResult = await widget.device.connect(widget.ap);
                    if (connectResult == ConnectResponse.needsPassword) {
                      widget.requestingPassword.value = true;
                    }
                  }
                }
              },
            ),
          ]);
        }

        return InkWell(
          onTap: isSelected
              ? null
              : () {
                  widget.selectedSsid.value = widget.ap.ssid;
                  widget.requestingPassword.value = false;
                },
          child: AnimatedContainer(
            duration: config.animationDuration * 2,
            curve: config.animationCurve,
            color: !isSelected ? Colors.transparent : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            constraints: BoxConstraints(minHeight: 38),
            child: Column(
              children: [
                Row(
                  children: [
                    NetworkIcon(
                      device: widget.device,
                      type: widget.device.deviceType,
                      isConnected: true,
                    ),
                    SizedBox(width: 12),
                    Text(widget.ap.ssid),
                  ],
                ),
                if (extraWidgets.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: extraWidgets,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RefreshIcon extends StatefulWidget {
  final bool isRefreshing;
  final Widget child;

  const RefreshIcon({
    required this.isRefreshing,
    required this.child,
    super.key,
  });

  @override
  State<RefreshIcon> createState() => _RefreshIconState();
}

class _RefreshIconState extends State<RefreshIcon> with TickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: config.animationDuration * 2,
  );
  late final animation = CurvedAnimation(
    parent: animationController,
    curve: config.animationCurve,
  );

  @override
  void initState() {
    super.initState();
    updateAnimation(null);
  }

  @override
  void didUpdateWidget(covariant RefreshIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateAnimation(oldWidget.isRefreshing);
  }

  void updateAnimation(bool? previousRefreshing) {
    if (previousRefreshing != null && previousRefreshing == widget.isRefreshing) return;
    if (widget.isRefreshing) {
      animationController.repeat();
    } else {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation,
      child: widget.child,
    );
  }
}
