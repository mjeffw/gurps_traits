class ValueNotFoundException implements Exception {
  final String message;
  final String value;

  const ValueNotFoundException([this.message = "", this.value]);

  String toString() {
    return 'ValueNotFoundException: $message: $value';
  }
}
