class CustomException implements Exception {
  final message;

  const CustomException([this.message = ""]);
}

class ValueNotFoundException extends CustomException {
  final value;

  const ValueNotFoundException([String message = "", this.value])
      : super(message);
}

abstract class ParseException extends CustomException {
  final String actualText;

  String get expected;

  const ParseException([this.actualText]);

  @override
  String toString() =>
      '${runtimeType.toString()}: Expected "$expected" got "$actualText".';

  @override
  get message => this.toString();
}

class TraitFormatException extends ParseException {
  @override
  String get expected => 'Name {Level} (parenthetical notes) [Point Cost]';

  const TraitFormatException([String actualText]) : super(actualText);
}

class ModifierFormatException extends ParseException {
  @override
  String get expected => 'Name, {comma-separated-notes,} [+/-]<Integer-Value>%';

  const ModifierFormatException([String actualText]) : super(actualText);
}
