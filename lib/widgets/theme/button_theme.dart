import "package:flutter/material.dart";

// TODO: 2 all theme/style parameters in config used in WingedButton, WingedContainer, etc.
// should be added to theme extensions and used from context, so they can be overriden for a subtree.

@immutable
class WingedButtonTheme extends ThemeExtension<WingedButtonTheme> {
  const WingedButtonTheme({required this.boxConstraints});

  final BoxConstraints? boxConstraints;

  @override
  WingedButtonTheme copyWith({BoxConstraints? boxConstraints}) {
    return WingedButtonTheme(boxConstraints: boxConstraints ?? this.boxConstraints);
  }

  @override
  WingedButtonTheme lerp(WingedButtonTheme? other, double t) {
    if (other == null) return this;
    return WingedButtonTheme(
      boxConstraints: BoxConstraints.lerp(boxConstraints, other.boxConstraints, t),
    );
  }

  static WingedButtonTheme of(BuildContext context) {
    return Theme.of(context).extension<WingedButtonTheme>()!;
  }
}

extension WingedButtonThemeExtension on ThemeData {
  WingedButtonTheme get wingedButtonTheme => extension<WingedButtonTheme>()!;
}
