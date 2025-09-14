import "package:flutter/material.dart";
import "package:waywing/widgets/icons/text_icon.dart";

class ComposedIcon extends StatefulWidget {
  final Widget child;
  final double? size;
  final Widget? subicon;
  final double subiconSize; // fractional
  final Alignment subiconAlignment;

  const ComposedIcon({
    required this.child,
    this.size,
    this.subicon,
    this.subiconSize = 0.5,
    this.subiconAlignment = Alignment.bottomRight,
    super.key,
  });

  @override
  State<ComposedIcon> createState() => _ComposedIconState();
}

class _ComposedIconState extends State<ComposedIcon> {
  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = widget.size ?? TextIcon.getIconEffectiveSize(context, iconTheme: iconTheme);
    final subiconSize = iconSize * widget.subiconSize;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        ClipPath(
          clipper: _SubiconShapeClipper(
            sizeFraction: widget.subiconSize,
            alignment: widget.subiconAlignment,
          ),
          child: IconTheme(
            data: iconTheme.copyWith(
              size: iconSize,
            ),
            child: widget.child,
          ),
        ),
        if (widget.subicon != null)
          Positioned.fill(
            child: Align(
              alignment: widget.subiconAlignment,
              child: IconTheme(
                data: iconTheme.copyWith(
                  size: subiconSize,
                ),
                child: widget.subicon!,
              ),
            ),
          ),
      ],
    );
  }
}

class _SubiconShapeClipper extends CustomClipper<Path> {
  final double sizeFraction; // fractional
  final Alignment alignment;

  const _SubiconShapeClipper({
    required this.sizeFraction,
    required this.alignment,
  });

  @override
  getClip(Size size) {
    // TODO: 2 HARD implement clipping the exact shape of the subicon. Ideally we render
    // the subicon with max weight, convert the rendered image to a path somehow, fill it in
    // so there are no holes inside the path, and then use it to clip here. We would probably
    // need to cache generated paths for each Icon because it will be very expensive.
    final width = size.width * sizeFraction;
    final height = size.height * sizeFraction;
    final horizontalSpace = size.width - width;
    final verticalSpace = size.height - height;
    final path = Path();
    path.addOval(
      Rect.fromLTWH(
        horizontalSpace * (alignment.x + 1) * 0.5,
        verticalSpace * (alignment.y + 1) * 0.5,
        width,
        height,
      ),
    );
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return Path.combine(PathOperation.difference, outerPath, path);
  }

  @override
  bool shouldReclip(covariant _SubiconShapeClipper oldClipper) {
    return sizeFraction != oldClipper.sizeFraction || alignment != oldClipper.alignment;
  }
}
