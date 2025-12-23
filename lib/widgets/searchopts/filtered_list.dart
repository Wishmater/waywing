import "dart:collection";

import "package:nucleo_dart/nucleo_dart.dart";

class JoinedFilterList<T> implements FilteredList<T> {
  @override
  final Map<int, T> items;

  @override
  Snapshot get _snapshot => throw UnimplementedError();

  late final JoinSnapshot _joinSnapshot;

  JoinedFilterList(this.items, Snapshot first, Snapshot second) {
    _joinSnapshot = first.join(second);
  }

  @override
  T operator [](int index) {
    return items[_joinSnapshot.item(index).index]!;
  }

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => length != 0;

  @override
  int get length => _joinSnapshot.length;

  @override
  List<T> sublist(int start, [int? end]) {
    final indexes = _joinSnapshot.items(start, end);
    assert(() {
      final len = indexes.length;
      final set = HashSet<MatchIndex>(
        equals: (a, b) => a.index == b.index,
        hashCode: (e) => e.index.hashCode,
      );
      set.addAll(indexes);

      return set.length == len;
    }(), "has repeated items");
    return indexes.map((e) => items[e.index]!).toList();
  }
}

class FilteredList<T> {
  final Snapshot _snapshot;
  final Map<int, T> items;

  FilteredList(this.items, this._snapshot);

  int get length => _snapshot.matchedCount;

  T operator [](int index) {
    return items[_snapshot.matchedItemIndex(index).index]!;
  }

  bool get isEmpty => length == 0;

  bool get isNotEmpty => length != 0;

  List<T> sublist(int start, [int? end]) {
    final indexes = _snapshot.matchedItemsIndex(start, end);
    return indexes.map((e) => items[e.index]!).toList();
  }
}
