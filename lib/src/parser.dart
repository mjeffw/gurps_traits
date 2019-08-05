import 'util/exceptions.dart';

class ModifierComponents {
  String name;
  String detail;
  int value;

  ModifierComponents({this.name, this.value, this.detail});

  // Modifiers are always of the format, '<text>, <+|-><number>%'
  static final regExpModifier =
      RegExp(r'^(?<name>.+), (?<sign>[+|-|−])(?<value>\d+)\%');

  static ModifierComponents parse(String input) {
    if (regExpModifier.hasMatch(input)) {
      RegExpMatch match = regExpModifier.firstMatch(input);
      return ModifierComponents(
        name: _name(match.namedGroup('name')),
        value: _value(match.namedGroup('sign'), match.namedGroup('value')),
        detail: _detail(match.namedGroup('name')),
      );
    } else {
      throw CustomException();
    }
  }

  static String _name(String match) => match.split(',')[0];

  static _detail(String match) =>
      match.replaceFirst('${_name(match)}, ', '').trim();

  static _value(String sign, String value) {
    int result = int.tryParse(value);
    int x = ['-', '−'].contains(sign) ? -1 : 1;
    return x * result;
  }
}

class TraitComponents {
  String rawText;
  String name;
  double cost;
  int level;
  String parentheticalNotes;
  String dice;

  // notes are separated by semi-colons
  get notes => parentheticalNotes == null
      ? []
      : parentheticalNotes.split(';').map((s) => s.trim()).toList();

  List<String> get modifiers => parentheticalNotes == null
      ? []
      : notes
          .where((s) => ModifierComponents.regExpModifier.hasMatch(s))
          .toList();

  get specialization => parentheticalNotes == null ? null : notes[0];

  TraitComponents(
      {this.name,
      this.cost,
      this.level,
      this.rawText,
      this.parentheticalNotes,
      this.dice});
}

const _NAME = r'(?<name>.+)'; // any
const _NOTES = r' \((?<notes>.*)\)'; // space + ( + any  + )
const _COST = r'(?: \[(?<cost>\d+)(?:/level)?\])'; // space + [ + digits + ]

///
/// ```Name {Level} (parenthetical notes) [Point Cost]```
///
class Parser {
  static String namePattern = '^$_NAME';
  static String nameCostPattern = '^$_NAME$_COST';
  static String nameNotesPattern = '^$_NAME$_NOTES';
  static String nameNotesCostPattern = '^$_NAME$_NOTES$_COST';

  List<RegExp> regExps = [
    RegExp(nameNotesCostPattern),
    RegExp(nameNotesPattern),
    RegExp(nameCostPattern),
    RegExp(namePattern),
  ];

  Parser() {
    regExps.forEach((f) => print(f.pattern));
  }

  TraitComponents parse(String input) {
    input = input.trim().replaceAll('—', '-');
    RegExpMatch match = firstMatch(regExps, input);

    String name = match.namedGroup('name').trim();
    String level;
    String dice;
    String levelPattern =
        r'^(?<name>.+)(?: (?<level>\d+)$|(?<dice>\d+d(?:[+|-]\d+)?)$)';
    RegExp regExp = RegExp(levelPattern);
    if (regExp.hasMatch(name)) {
      RegExpMatch match = regExp.firstMatch(name);
      if (match.namedGroup('level') != null) {
        level = match.namedGroup('level');
        name = match.namedGroup('name');
      } else {
        dice = match.namedGroup('dice');
        name = match.namedGroup('name');
      }
    }

    bool hasCost =
        match.groupNames.contains('cost') && match.namedGroup('cost') != null;

    return TraitComponents(
        rawText: match.group(0),
        name: name,
        cost: hasCost ? double.tryParse(match.namedGroup('cost')) : null,
        level: level == null ? null : int.tryParse(level),
        dice: dice,
        parentheticalNotes: match.groupNames.contains('notes')
            ? match.namedGroup('notes')
            : null);
  }

  RegExpMatch firstMatch(List<RegExp> regExps, String source) => regExps
      .firstWhere((regExp) => regExp.hasMatch(source),
          orElse: () => throw TraitParseException(source))
      .firstMatch(source);

  int _tryParseLevel(RegExpMatch match) {
    if (match.groupNames.contains('level')) {
      return (match.namedGroup('level') == null)
          ? 1
          : int.tryParse(match.namedGroup('level'));
    }
    return null;
  }
}
