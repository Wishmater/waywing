import "package:filo_windowing/filo_windowing.dart";
import "package:flutter_test/flutter_test.dart";
import "package:waywing/core/screen_edge.dart";

void main() {
  test("each edge anchors its own side and both perpendicular sides", () {
    expect(
      ScreenEdge.top.layerAnchors.value,
      FiloLayerAnchors.top.value | FiloLayerAnchors.left.value | FiloLayerAnchors.right.value,
    );
    expect(
      ScreenEdge.bottom.layerAnchors.value,
      FiloLayerAnchors.bottom.value | FiloLayerAnchors.left.value | FiloLayerAnchors.right.value,
    );
    expect(
      ScreenEdge.left.layerAnchors.value,
      FiloLayerAnchors.left.value | FiloLayerAnchors.top.value | FiloLayerAnchors.bottom.value,
    );
    expect(
      ScreenEdge.right.layerAnchors.value,
      FiloLayerAnchors.right.value | FiloLayerAnchors.top.value | FiloLayerAnchors.bottom.value,
    );
  });
}
