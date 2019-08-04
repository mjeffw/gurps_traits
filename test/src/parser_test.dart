import 'package:sorcery_parser/src/util/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('parse', () {
    test('missing cost', () {
      var text = '360° Vision';
      try {
        Parser().digest(text);
      } catch (e) {
        expect(e, isA<TraitParseException>());
        expect(e.message,
            'TraitParseException: Expected "Name {Level} (parenthetical notes) [Point Cost]"; got "360° Vision"');
      }
    });

    test('Multi-Word Name', () {
      var digest = Parser().digest('360° Vision [25].');
      expect(digest.rawText, '360° Vision [25]');
      expect(digest.name, '360° Vision');
      expect(digest.cost, 25);
      expect(digest.level, isNull);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Alpha-only, Single Word Name', () {
      var digest = Parser().digest('Amphibious [10].');
      expect(digest.rawText, 'Amphibious [10]');
      expect(digest.name, 'Amphibious');
      expect(digest.cost, 10);
      expect(digest.level, isNull);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Level 1', () {
      var digest = Parser().digest('Altered Time Rate 1 [100].');
      expect(digest.rawText, 'Altered Time Rate 1 [100]');
      expect(digest.name, 'Altered Time Rate');
      expect(digest.cost, 100);
      expect(digest.level, 1);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Level 2', () {
      var digest = Parser().digest('Altered Time Rate 2 [200].');
      expect(digest.rawText, 'Altered Time Rate 2 [200]');
      expect(digest.name, 'Altered Time Rate');
      expect(digest.cost, 200);
      expect(digest.level, 2);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Single Parenthetical Note', () {
      var digest = Parser().digest('Night Vision 4 (Runecasting, −30%) [3]. ');
      expect(digest.rawText, 'Night Vision 4 (Runecasting, −30%) [3]');
      expect(digest.name, 'Night Vision');
      expect(digest.cost, 3);
      expect(digest.level, 4);
      expect(digest.parentheticalNotes, 'Runecasting, −30%');
      expect(digest.notes, orderedEquals(['Runecasting, −30%']));
    });

    test('Multiple Parenthetical Notes', () {
      var digest = Parser().digest(
          'Clairsentience (Clairvoyance, -10%; ESP, -10%; Visible, -10%) [35]');
      expect(digest.name, 'Clairsentience');
      expect(digest.cost, 35);
      expect(digest.level, isNull);
      expect(digest.parentheticalNotes,
          'Clairvoyance, -10%; ESP, -10%; Visible, -10%');
      expect(digest.notes,
          orderedEquals(['Clairvoyance, -10%', 'ESP, -10%', 'Visible, -10%']));
    });

    // Affliction 1 (HT; Advantage, Hide, +30%; Fixed Duration, +0%; Increased 1/2D, 10x, +15%; No Signature, +20%; Sorcery, −30%) [14].

    test('Notes with modifiers', () {
      var digest = Parser().digest(
          'Affliction 1 (HT; Advantage, Hide, +30%; Fixed Duration, +0%; Increased 1/2D, 10x, +15%; No Signature, +20%; Sorcery, −30%) [14]');
      expect(digest.name, 'Affliction');
      expect(digest.cost, 14);
      expect(digest.level, 1);
      expect(digest.parentheticalNotes,
          'HT; Advantage, Hide, +30%; Fixed Duration, +0%; Increased 1/2D, 10x, +15%; No Signature, +20%; Sorcery, −30%');
      expect(
          digest.notes,
          orderedEquals([
            'HT',
            'Advantage, Hide, +30%',
            'Fixed Duration, +0%',
            'Increased 1/2D, 10x, +15%',
            'No Signature, +20%',
            'Sorcery, −30%'
          ]));

      expect(
          digest.modifiers,
          orderedEquals([
            'Advantage, Hide, +30%',
            'Fixed Duration, +0%',
            'Increased 1/2D, 10x, +15%',
            'No Signature, +20%',
            'Sorcery, −30%'
          ]));

      expect(digest.specialization, 'HT');
    });
  });
}

class Components {
  // Modifiers are always of the format, '<text>, <+|-><number>%'
  final regExpModifier = RegExp(r'^.*, [+|-|−](\d+)\%');

  String rawText;

  String name;

  double cost;

  int level;

  String parentheticalNotes;

  // notes are separated by semi-colons
  get notes => parentheticalNotes == null
      ? []
      : parentheticalNotes.split(';').map((s) => s.trim()).toList();

  get modifiers => parentheticalNotes == null
      ? []
      : notes.where((s) => regExpModifier.hasMatch(s)).toList();

  get specialization => parentheticalNotes == null ? null : notes[0];

  Components(
      {this.name,
      this.cost,
      this.level,
      this.rawText,
      this.parentheticalNotes});
}

const _NAME = r'(?<name>.+)'; // any
const _LEVEL = r' (?<level>\d+)'; // space + digits
const _PARENTH = r' \((?<notes>.*)\)'; // space + ( + any  + )
const _COST = r' \[(?<cost>\d+)\]'; // space + [ + digits + ]

///
/// ```Name {Level} (parenthetical notes) [Point Cost]```
///
class Parser {
  static String simplePattern = '^$_NAME$_COST';
  static String simpleWithNotePattern = '^$_NAME$_PARENTH$_COST';
  static String levelPattern = '^$_NAME$_LEVEL$_COST';
  static String levelWithNotePattern = '^$_NAME$_LEVEL$_PARENTH$_COST';

  List<RegExp> regExps = [
    RegExp(levelWithNotePattern),
    RegExp(levelPattern),
    RegExp(simpleWithNotePattern),
    RegExp(simplePattern)
  ];

  Components digest(String input) {
    RegExpMatch match = firstMatch(regExps, input);

    return Components(
        rawText: match.group(0),
        name: match.namedGroup('name'),
        cost: double.tryParse(match.namedGroup('cost')),
        level: _tryParseLevel(match),
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
