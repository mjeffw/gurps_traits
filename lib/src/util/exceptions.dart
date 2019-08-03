class CustomException implements Exception {
  final message;

  const CustomException([this.message = ""]);
}

class ValueNotFoundException extends CustomException {
  final value;

  const ValueNotFoundException([String message = "", this.value])
      : super(message);
}

class TraitParseException extends CustomException {
  final String actualText;

  const TraitParseException([this.actualText]);

  @override
  String toString() => 'TraitParseException: Expected '
      '"Name {Level} (parenthetical notes) [Point Cost]";'
      ' got "$actualText"';

  @override
  get message => this.toString();
}
