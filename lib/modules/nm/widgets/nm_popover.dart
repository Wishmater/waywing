import "dart:math";

import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.varied.dart";
import "package:motor/motor.dart";
import "package:waywing/core/config.dart";
import "package:waywing/modules/nm/nm_config.dart";
import "package:waywing/modules/nm/widgets/nm_indicator.dart";
import "package:waywing/modules/nm/service/nm_service.dart";
import "package:waywing/util/animation_utils.dart";
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/motion_layout/motion_column.dart";
import "package:waywing/widgets/motion_widgets/motion_container.dart";
import "package:waywing/widgets/opacity_gradient.dart";
import "package:waywing/widgets/simple_shadow.dart";
import "package:waywing/widgets/winged_widgets/winged_button.dart";
import "package:waywing/widgets/winged_widgets/winged_icon.dart";

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
  late final Future<void> initialRefreshFuture;

  @override
  void initState() {
    super.initState();
    initialRefreshFuture = requestScan();
  }

  Future<void> requestScan() async {
    await widget.device.requestScan();
    return widget.device.awaitScan();
  }

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
              Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 16, top: 8, bottom: 4),
                  constraints: BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      Text("Wi-Fi", style: Theme.of(context).textTheme.bodyLarge),
                      Expanded(child: SizedBox.shrink()),
                      WingedButton(
                        builder: (context, snapshot, child) {
                          return SpinningWidget(
                            isSpinning: snapshot.connectionState != ConnectionState.done,
                            child: child,
                          );
                        },
                        onTap: requestScan,
                        initialFuture: initialRefreshFuture,
                        child: WingedIcon(
                          flutterIcon: SymbolsVaried.refresh,
                          iconNames: ["view-refresh"],
                          textIcon: "󰑐", // nf-md-refresh
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                      SizedBox(width: 6),
                      SizedBox(
                        width: 60 * 0.7,
                        height: 40 * 0.7,
                        child: FittedBox(
                          child: ValueListenableBuilder(
                            valueListenable: widget.device.wirelessEnabled,
                            builder: (context, value, child) {
                              return Switch(
                                value: value,
                                onChanged: (value) {
                                  widget.device.setWirelessEnabled(value);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget.device.activeAccessPoint,
                  builder: (context, activeAccessPoint, child) {
                    return ValueListenableBuilder(
                      valueListenable: widget.device.accessPoints,
                      builder: (context, accessPoints, child) {
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: MotionColumn(
                                      motion: mainConfig.motions.standard.spatial.normal,
                                      // TODO: 1 equality seem to not be working correctly, causing the animations
                                      // to be wonky when APs are refreshed
                                      data: [
                                        if (activeAccessPoint != null) activeAccessPoint,
                                        if (activeAccessPoint != null) null,
                                        ...accessPoints.where((e) => e.ssid != activeAccessPoint?.ssid),
                                      ],
                                      itemBuilder: (context, ap) {
                                        if (ap == null) {
                                          return Divider(
                                            height: 12,
                                            indent: 16,
                                            endIndent: 16,
                                            thickness: 0.5,
                                            radius: BorderRadius.circular(0.25),
                                          );
                                        }
                                        return APWidget(
                                          device: widget.device,
                                          ap: ap,
                                          isConnected: ap.ssid == activeAccessPoint?.ssid,
                                          selectedSsid: selectedSsid,
                                          requestingPassword: requestingPassword,
                                        );
                                      },
                                    ),
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
  late final autoConnect = ValueNotifier(true);

  Future? _connectTapFuture;

  Future<void> onConnectTap() async {
    if (_connectTapFuture != null) return _connectTapFuture;
    _connectTapFuture = _onConnectTap();
    await _connectTapFuture;
    _connectTapFuture = null;
  }

  Future _onConnectTap() async {
    if (widget.isConnected) {
      widget.device.disconnect();
    } else {
      if (widget.requestingPassword.value) {
        return widget.device.connect(
          widget.ap,
          userPassword: passwordController.text,
          autoconnect: autoConnect.value,
        );
      } else {
        final connectResult = await widget.device.connect(
          widget.ap,
          autoconnect: autoConnect.value,
        );
        if (connectResult == ConnectResponse.needsPassword) {
          widget.requestingPassword.value = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 2 implement internal size animation (so it animates when changing size for selected, request password, etc.)
    return ValueListenableBuilder(
      valueListenable: widget.selectedSsid,
      builder: (context, selectedSsid, _) {
        final isSelected = selectedSsid == widget.ap.ssid;
        List<Widget> extraWidgets = [];
        if (isSelected) {
          extraWidgets.addAll([
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: widget.requestingPassword,
                builder: (context, requestingPassword, _) {
                  // TODO: 2 add animated switcher to password/autoConnect
                  if (widget.isConnected) {
                    return SizedBox.shrink();
                  }
                  if (requestingPassword) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 36, right: 8),
                      child: SizedBox(
                        height: 32,
                        child: KeyboardFocus(
                          mode: KeyboardFocusMode.onDemand,
                          child: TextFormField(
                            autofocus: true,
                            controller: passwordController,
                            style: Theme.of(context).textTheme.bodyMedium,
                            onFieldSubmitted: (_) => onConnectTap(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                              contentPadding: EdgeInsets.only(left: 6, right: 6),
                              label: Text("Password"),
                              labelStyle: TextStyle(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (isSelected) {
                    return Container(
                      padding: const EdgeInsets.only(left: 30, right: 6),
                      alignment: Alignment.centerRight,
                      child: ValueListenableBuilder(
                        valueListenable: autoConnect,
                        builder: (context, value, _) {
                          return WingedButton(
                            onTap: () => autoConnect.value = !value,
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            alignment: null,
                            child: IntrinsicWidth(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 0,
                                    child: ExcludeFocusTraversal(
                                      child: Checkbox(
                                        value: value,
                                        onChanged: (value) => autoConnect.value = value!,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "Auto\nconnect",
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(height: 0.8),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            WingedButton(
              onTap: onConnectTap,
              child: Text(
                widget.isConnected ? "DISCONNECT" : "CONNECT",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ]);
        }

        // TODO: 2 this shoud use WingedButton
        return InkWell(
          onTap: isSelected
              ? null
              : () {
                  widget.selectedSsid.value = widget.ap.ssid;
                  widget.requestingPassword.value = false;
                },
          child: MotionContainer(
            motion: mainConfig.motions.standard.effects.slow,
            color: !isSelected ? Colors.transparent : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            constraints: BoxConstraints(minHeight: 38),
            child: Column(
              children: [
                Row(
                  children: [
                    WifiIcon(
                      device: widget.device,
                      accessPoint: widget.ap,
                      type: widget.device.deviceType,
                      isConnected: widget.isConnected,
                      showTxRxIndicators: true,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Text(widget.ap.ssid),
                          if (widget.ap.isSecured)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: WingedIcon(
                                flutterIcon: SymbolsVaried.lock,
                                iconNames: ["system-lock-screen"],
                                textIcon: "󰌾", // nf-md-lock
                                size: Theme.of(context).textTheme.bodyMedium!.fontSize! * 0.75,
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                            ),
                        ],
                      ),
                    ),
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

class SpinningWidget extends StatefulWidget {
  final bool isSpinning;
  final Widget child;

  const SpinningWidget({
    required this.isSpinning,
    required this.child,
    super.key,
  });

  @override
  State<SpinningWidget> createState() => _SpinningWidgetState();
}

class _SpinningWidgetState extends State<SpinningWidget> with TickerProviderStateMixin {
  late final SingleMotionController motionController;

  void _onControllerTick() => setState(() {});

  int get nextValue => (motionController.value + 1).floor();

  @override
  void initState() {
    super.initState();
    motionController = SingleMotionController(
      motion: mainConfig.motions.expressive.spatial.slow.multiplySpeed(0.03), // make it a bit slower
      vsync: this,
      initialValue: 0,
    )..addListener(_onControllerTick);
    motionController.addListener(() {
      if (widget.isSpinning && motionController.value % 1 > 0.33) {
        motionController.animateTo(nextValue + 1);
      }
    });
    updateAnimation(null);
  }

  @override
  void dispose() {
    motionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SpinningWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateAnimation(oldWidget.isSpinning);
  }

  void updateAnimation(bool? previousRefreshing) {
    if (previousRefreshing != null && previousRefreshing == widget.isSpinning) return;
    if (widget.isSpinning) {
      motionController.animateTo(nextValue.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 2 * pi * motionController.value,
      transformHitTests: false,
      child: widget.child,
    );
  }
}
