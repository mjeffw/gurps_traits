// Helper functions.

///
/// Regrettable that we have to do this because this project is pure Dart.
/// Flutter has a collection utility package with this method.
///
bool listEquals(List<dynamic> one, List<dynamic> other) {
  if (identical(one, other)) return true;
  if (one.runtimeType != other.runtimeType || one.length != other.length) {
    return false;
  }
  for (var i = 0; i < one.length; i++) {
    if (one[i] != other[i]) return false;
  }
  return true;
}

///
/// Converts a string into Title Case.
///
String toTitleCase(String text) => RegExp(r'\w+')
    .allMatches(text)
    .map(getWord)
    .map(capitalizeWord)
    .reduce((a, b) => '$a $b');

///
/// Return the substring matched by this [RegExpMatch].
///
String getWord(RegExpMatch match) =>
    match.input.substring(match.start, match.end);

///
/// Convert the first character of this word to UpperCase.
///
String capitalizeWord(String word) =>
    word.replaceRange(0, 1, word.substring(0, 1).toUpperCase());
