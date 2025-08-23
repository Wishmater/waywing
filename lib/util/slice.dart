import "dart:collection";

// TODO: 1 remove this, so far it's always better to use change notifiers in services
class Slice<E> extends UnmodifiableListView<E> {
  @override
  final int length;

  final Iterable<E> _source;
  Iterable<E> get source => _source;

  Slice(this._source) : length = _source.length, super(_source);

  @override
  bool operator ==(covariant Slice<E> other) {
    return length == other.length && _source == other._source;
  }

  @override
  int get hashCode => Object.hashAll([length, _source]);
}
