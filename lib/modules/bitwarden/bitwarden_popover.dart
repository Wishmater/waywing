import "dart:async";

import "package:fl_linux_window_manager/widgets/input_region.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/services.dart";
import "package:waywing/modules/bitwarden/bitwarden_service.dart";
import "package:bitwarden_vault_api/bitwarden_api.dart" as bw;
import "package:waywing/widgets/keyboard_focus.dart";
import "package:waywing/widgets/searchopts/searchopts.dart";

class BitwardenPopover extends StatefulWidget {
  final BitwardenService service;
  final VoidCallback close;

  const BitwardenPopover({super.key, required this.service, required this.close});

  @override
  State<StatefulWidget> createState() => BitwardenPopoverState();
}

class BitwardenPopoverState extends State<BitwardenPopover> {
  bool hasMasterPassword = false;
  Future<List<bw.Item>> itemsFuture = Future.delayed(Duration.zero, () => []);

  late DateTime lastTimeUpdated;

  @override
  void initState() {
    hasMasterPassword = widget.service.hasMasterPassword;

    if (hasMasterPassword) {
      _requestItems();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showDialog<bool>(
          context: context,
          builder: _buildDialog,
          barrierColor: Colors.transparent,
        ).then((v) {
          if (v != true) {
            widget.close();
          }
        });
      });
    }

    lastTimeUpdated = DateTime.now();
    super.initState();
  }

  Widget _buildDialog(BuildContext context) {
    return _BitwardenMasterPasswordDialog(
      setPasswordCallback: (password) async {
        try {
          await widget.service.unlock(masterPassword: password);
        } catch (_) {
          return false;
        }
        await widget.service.setMasterPassword(password);
        return true;
      },
      onSuccess: () {
        if (mounted) {
          setState(() {
            hasMasterPassword = true;
          });
        }
        Navigator.pop(context, true);
      },
      onCancel: () {
        Navigator.pop(context, false);
      },
    );
  }

  @override
  void didUpdateWidget(BitwardenPopover oldWidget) {
    if (DateTime.now().isAfter(lastTimeUpdated.add(Duration(seconds: 30))) && hasMasterPassword) {
      _requestItems();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _requestItems() {
    itemsFuture = widget.service.items();
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("ERROR ${snapshot.error}");
        }
        final items = snapshot.data!;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SearchOptions(
              options: items
                  .where((e) => e.type == bw.ItemTypeEnum.login && e.login != null)
                  .map((e) => BitwardenItemOption(e))
                  .toList(),
              renderOption: _renderOption,
              onSelected: _onSelected,
              height: constraints.maxHeight.toDouble(),
            );
          },
        );
      },
    );
  }

  void _onSelected(bw.Item item) async {
    switch (item.type) {
      case null:
        throw UnimplementedError();
      case bw.ItemTypeEnum.login:
        Clipboard.setData(ClipboardData(text: item.login!.password ?? ""));
      case bw.ItemTypeEnum.secureNote:
        throw UnimplementedError();
      case bw.ItemTypeEnum.card:
        throw UnimplementedError();
      case bw.ItemTypeEnum.identity:
        throw UnimplementedError();
    }
  }

  Widget _renderOption(BuildContext context, bw.Item item, SearchOptionsRenderConfig searchoptConfig) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        item.name ?? "unknown",
        style: theme.textTheme.bodyLarge,
        softWrap: false,
        overflow: TextOverflow.fade,
      ),
      onTap: () {
        _onSelected(item);
      },
    );
  }
}

class BitwardenItemOption extends Option<bw.Item> {
  final bw.Item item;

  const BitwardenItemOption(this.item);

  @override
  int get identifier => item.id.hashCode;

  @override
  bw.Item get object => item;

  @override
  String get primaryValue => item.name ?? "unknown";

  @override
  String? get secondaryValue => null;
}

class _BitwardenMasterPasswordDialog extends StatefulWidget {
  final FutureOr<bool> Function(String) setPasswordCallback;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _BitwardenMasterPasswordDialog({
    required this.setPasswordCallback,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_BitwardenMasterPasswordDialog> createState() => _BitwardenMasterPasswordDialogState();
}

class _BitwardenMasterPasswordDialogState extends State<_BitwardenMasterPasswordDialog> {
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  String? errorMessage;
  bool isValidating = false;

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void _validatePassword(String enteredPassword) async {
    if (enteredPassword.isEmpty) {
      setState(() {
        errorMessage = "Please enter a password";
      });
      return;
    }

    setState(() {
      isValidating = true;
    });

    if (await widget.setPasswordCallback(enteredPassword)) {
      widget.onSuccess();
    } else {
      if (mounted) {
        setState(() {
          errorMessage = "Incorrect password. Please try again.";
        });
      }
      passwordController.clear();
    }

    if (mounted) {
      setState(() {
        isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputRegion(
      child: KeyboardFocus(
        debugLabel: "BitwardenDialog",
        mode: KeyboardFocusMode.onDemand,
        child: Center(
          child: Disableable(
            isEnabled: !isValidating,
            child: AlertDialog(
              title: Text("Enter Bitwarden master password"),
              content: TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Master Password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  errorText: errorMessage,
                ),
                onSubmitted: _validatePassword, // Submit on Enter key
              ),
              actions: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => _validatePassword(passwordController.text),
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Disableable extends StatelessWidget {
  final bool isEnabled;
  final Widget child;
  final double disabledOpacity;

  const Disableable({
    super.key,
    required this.isEnabled,
    required this.child,
    this.disabledOpacity = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : disabledOpacity,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: child,
      ),
    );
  }
}
