import 'package:sorcery_parser/src/trait.dart';
import 'package:sorcery_parser/src/util/die_roll.dart';
import 'package:test/test.dart';

void main() {
  group('flat cost', () {
    group('Protected Sense', () {
      // Canon: 'Protected Sense (%s1, %s2; modifiers...) [10]'
      // Alternatively: 'Protected %s (modifiers...) [5]'
      test('Sense', () {
        Trait t = Traits.parse('Protected Sense');
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.description, 'Protected Sense');
      });

      test('Vision', () {
        Trait t = Traits.parse('Protected Vision');
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.description, 'Protected Vision');
      });

      test('Hearing', () {
        Trait t = Traits.parse('Protected Hearing');
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.description, 'Protected Hearing');
      });
    }, skip: false);

    test('Dark Vision', () {
      Trait t = Traits.parse('Dark Vision');
      expect(t.reference, 'Dark Vision');
      expect(t.cost, 25);
      expect(t.description, 'Dark Vision');
    });
  });

  group('leveled', () {
    test('Obscure', () {
      // Canon: 'Obscure (Sense)'
      LeveledTrait t = Traits.parse('Obscure') as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 2);
      expect(t.description, 'Obscure 1');
      expect(t.level, 1);
    });

    test('Obscure 3', () {
      // Canon: 'Obscure (Sense)'
      LeveledTrait t = Traits.parse('Obscure 3') as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 6);
      expect(t.description, 'Obscure 3');
      expect(t.level, 3);
      expect(t.parentheticalNotes, null);
    });

    test('Obscure Vision', () {
      LeveledTrait t = Traits.parse('Obscure Vision') as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 2);
      expect(t.description, 'Obscure 1');
      expect(t.level, 1);
      expect(t.parentheticalNotes, 'Vision');
    });

    test('Obscure Dark Vision 5', () {
      LeveledTrait t = Traits.parse('Obscure Dark Vision 5') as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 10);
      expect(t.description, 'Obscure 5');
      expect(t.level, 5);
      expect(t.parentheticalNotes, 'Dark Vision');
    });

    test('Obscure 360-Degree Vision 5', () {
      LeveledTrait t = Traits.parse('Obscure 360° Vision 2') as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 4);
      expect(t.description, 'Obscure 2');
      expect(t.level, 2);
      expect(t.parentheticalNotes, '360° Vision');
    });

    test('Affliction', () {
      LeveledTrait t = Traits.parse('Affliction') as LeveledTrait;
      expect(t.reference, 'Affliction');
      expect(t.cost, 10);
      expect(t.description, 'Affliction 1');
      expect(t.level, 1);
    });

    test('Affliction 2', () {
      LeveledTrait t = Traits.parse('Affliction 2') as LeveledTrait;
      expect(t.reference, 'Affliction');
      expect(t.cost, 20);
      expect(t.description, 'Affliction 2');
      expect(t.level, 2);
    });
  });

  group('Innate Attack', () {
    test('Crushing Attack 1d', () {
      InnateAttack t = Traits.parse('Crushing Attack 1d') as InnateAttack;
      expect(t.reference, 'Innate Attack');
      expect(t.dice, DieRoll(dice: 1, normalize: false));
      expect(t.description, 'Crushing Attack 1d');
      expect(t.cost, 5);
    }, skip: false);

    test('Crushing Attack 3d', () {
      InnateAttack t = Traits.parse('Crushing Attack 3d') as InnateAttack;
      expect(t.reference, 'Innate Attack');
      expect(t.dice, DieRoll(dice: 3, normalize: false));
      expect(t.description, 'Crushing Attack 3d');
      expect(t.cost, 15);
    }, skip: false);

    test('Crushing Attack 3d-1', () {
      InnateAttack t = Traits.parse('Crushing Attack 3d-1') as InnateAttack;
      expect(t.reference, 'Innate Attack');
      expect(t.dice, DieRoll(dice: 3, adds: -1, normalize: false));
      expect(t.description, 'Crushing Attack 3d-1');
      expect(t.cost, 14);
    }, skip: false);

    test('Crushing Attack 3d-2', () {
      InnateAttack t = Traits.parse('Crushing Attack 3d-2') as InnateAttack;
      expect(t.dice, DieRoll(dice: 3, adds: -2, normalize: false));
      expect(t.description, 'Crushing Attack 3d-2');
      expect(t.cost, 12);
    }, skip: false);

    test('Crushing Attack 3d+1', () {
      InnateAttack t = Traits.parse('Crushing Attack 3d+1') as InnateAttack;
      expect(t.reference, 'Innate Attack');
      expect(t.dice, DieRoll(dice: 3, adds: 1, normalize: false));
      expect(t.description, 'Crushing Attack 3d+1');
      expect(t.cost, 17);
    }, skip: false);

    test('Crushing Attack 3d+2', () {
      InnateAttack t = Traits.parse('Crushing Attack 3d+2') as InnateAttack;
      expect(t.dice, DieRoll(dice: 3, adds: 2, normalize: false));
      expect(t.description, 'Crushing Attack 3d+2');
      expect(t.cost, 18);
    }, skip: false);
  });

  group('Variable', () {
    test('Innate Attack - Burning 1d', () {
      Trait t = Traits.parse('Burning Attack 1d');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 5);
      expect(t.description, 'Burning Attack 1d');
      // expect(t.level, 1);
    });

    test('Innate Attack - Burning', () {
      Trait t = Traits.parse('Burning Attack');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 5);
      expect(t.description, 'Burning Attack 1d');
      // expect(t.level, 1);
    });

    test('Innate Attack - Corrosion 1d', () {
      Trait t = Traits.parse('Corrosion Attack 1d');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 10);
      expect(t.description, 'Corrosion Attack 1d');
      // expect(t.level, 1);
    });

    test('Innate Attack - Cutting 2d', () {
      Trait t = Traits.parse('Cutting Attack 2d');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 14);
      expect(t.description, 'Cutting Attack 2d');
      // expect(t.level, 2);
    });
  }, skip: true);
}
