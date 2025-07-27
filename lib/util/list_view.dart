import "dart:collection";

class InmutableListView<E> extends UnmodifiableListView<E> {
  @override
  final int length;

  final Iterable<E> _source;
  Iterable<E> get source => _source;

  InmutableListView(this._source) : length = _source.length, super(_source);


  @override
  bool operator ==(covariant InmutableListView<E> other) {
    return length == other.length && _source == other._source;
  }
}
