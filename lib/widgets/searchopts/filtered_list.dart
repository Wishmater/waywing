import "package:nucleo_dart/nucleo_dart.dart";

class FilteredList<T> {
  final Snapshot _snapshot;
  final Map<int, T> items;

  FilteredList(this.items, this._snapshot);

  T get first {
    return items[_snapshot.matchedItemIndex(0)]!;
  }

  T get last {
    final lastIdx = _snapshot.matchedCount - 1;
    assert(lastIdx > 0);
    return items[_snapshot.matchedItemIndex(lastIdx)]!;
  }

  int get length => _snapshot.matchedCount;

  T operator [](int index) {
    return items[_snapshot.matchedItemIndex(index)]!;
  }

  bool get isEmpty => length == 0;

  bool get isNotEmpty => length != 0;

  List<T> sublist(int start, [int? end]) {
    final indexes = _snapshot.matchedItemsIndex(start, end);
    return indexes.map((i) => items[i]!).toList();
  }
}
