import "package:human_file_size/human_file_size.dart";

class DecimalByteNumeralSystem extends NumeralSystem {
  static final List<Unit> _units = List.unmodifiable([
    Unit.byte,
    Unit.kilobyte,
    Unit.megabyte,
    Unit.gigabyte,
    Unit.terabyte,
    Unit.petabyte,
    Unit.exabyte,
    Unit.zettabyte,
    Unit.yottabyte,
  ]);

  @override
  List<Unit> get units => _units;

  const DecimalByteNumeralSystem();
}

class DecimalBitNumeralSystem extends NumeralSystem {
  static final List<Unit> _units = List.unmodifiable([
    Unit.bit,
    Unit.kilobit,
    Unit.megabit,
    Unit.gigabit,
    Unit.terabit,
    Unit.petabit,
    Unit.exabit,
    Unit.zettabit,
    Unit.yottabit,
  ]);

  @override
  List<Unit> get units => _units;

  const DecimalBitNumeralSystem();
}

class BinaryByteNumeralSystem extends NumeralSystem {
  static final List<Unit> _units = List.unmodifiable([
    Unit.byte,
    Unit.kibibyte,
    Unit.mebibyte,
    Unit.gibibyte,
    Unit.tebibyte,
    Unit.pebibyte,
    Unit.exbibyte,
    Unit.zebibyte,
    Unit.yobibyte,
  ]);

  @override
  List<Unit> get units => _units;

  const BinaryByteNumeralSystem();
}

class BinaryBitNumeralSystem extends NumeralSystem {
  static final List<Unit> _units = List.unmodifiable([
    Unit.bit,
    Unit.kibibit,
    Unit.mebibit,
    Unit.gibibit,
    Unit.tebibit,
    Unit.pebibit,
    Unit.exbibit,
    Unit.zebibit,
    Unit.yobibit,
  ]);

  @override
  List<Unit> get units => _units;

  const BinaryBitNumeralSystem();
}
