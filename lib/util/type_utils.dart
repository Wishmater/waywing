
sealed class Either<L, R> {
  const Either();
}

class EitherLeft<L, R> extends Either<L, R> {
  final L value;

  const EitherLeft(this.value);
}

class EitherRigth<L, R> extends Either<L, R> {
  final R value;

  const EitherRigth(this.value);
}
