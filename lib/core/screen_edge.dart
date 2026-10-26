import "package:filo_windowing/filo_windowing.dart";

/// Represents an edge of the screen.
///
/// This is used by wings to position themselves and by the window manager to
/// choose wlr-layer-shell anchors.
enum ScreenEdge {
  top,
  right,
  bottom,
  left;

  /// The wlr-layer-shell anchors for a strip attached to this edge.
  ///
  /// The strip is anchored to its own edge and to both perpendicular edges, so
  /// the compositor stretches it across the output on that axis.
  FiloLayerAnchors get layerAnchors => switch (this) {
    ScreenEdge.top => FiloLayerAnchors.top | FiloLayerAnchors.left | FiloLayerAnchors.right,
    ScreenEdge.right => FiloLayerAnchors.right | FiloLayerAnchors.top | FiloLayerAnchors.bottom,
    ScreenEdge.bottom => FiloLayerAnchors.bottom | FiloLayerAnchors.left | FiloLayerAnchors.right,
    ScreenEdge.left => FiloLayerAnchors.left | FiloLayerAnchors.top | FiloLayerAnchors.bottom,
  };
}
