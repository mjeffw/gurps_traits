import 'package:gurps_traits/gurps_traits.dart';
import 'package:test/test.dart';

void main() {
  group('parse', () {
    test('missing cost', () {
      var text = '360° Vision';
      try {
        Parser().parse(text);
      } catch (e) {
        expect(e, isA<TraitFormatException>());
        expect(e.message,
            'TraitParseException: Expected "Name {Level} (parenthetical notes) [Point Cost]"; got "360° Vision"');
      }
    });

    test('Multi-Word Name', () {
      var digest = Parser().parse('360° Vision [25].');
      expect(digest.rawText, '360° Vision [25]');
      expect(digest.name, '360° Vision');
      expect(digest.cost, 25);
      expect(digest.level, isNull);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Alpha-only, Single Word Name', () {
      var digest = Parser().parse('Amphibious [10].');
      expect(digest.rawText, 'Amphibious [10]');
      expect(digest.name, 'Amphibious');
      expect(digest.cost, 10);
      expect(digest.level, isNull);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Level 1', () {
      var digest = Parser().parse('Altered Time Rate 1 [100].');
      expect(digest.rawText, 'Altered Time Rate 1 [100]');
      expect(digest.name, 'Altered Time Rate');
      expect(digest.cost, 100);
      expect(digest.level, 1);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Level 2', () {
      var digest = Parser().parse('Altered Time Rate 2 [200].');
      expect(digest.rawText, 'Altered Time Rate 2 [200]');
      expect(digest.name, 'Altered Time Rate');
      expect(digest.cost, 200);
      expect(digest.level, 2);
      expect(digest.parentheticalNotes, isNull);
      expect(digest.notes, isEmpty);
    });

    test('Single Parenthetical Note', () {
      var digest = Parser().parse('Night Vision 4 (Runecasting, −30%) [3]. ');
      expect(digest.rawText, 'Night Vision 4 (Runecasting, −30%) [3]');
      expect(digest.name, 'Night Vision');
      expect(digest.cost, 3);
      expect(digest.level, 4);
      expect(digest.parentheticalNotes, 'Runecasting, −30%');
      expect(digest.notes, orderedEquals(['Runecasting, −30%']));
    });

    test('Multiple Parenthetical Notes', () {
      var digest = Parser().parse(
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
      var digest = Parser().parse(
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

      expect(digest.specialties, 'HT');
    });
  });
}
