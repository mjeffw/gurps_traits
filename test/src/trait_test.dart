import 'package:sorcery_parser/src/trait.dart';
import 'package:sorcery_parser/src/util/die_roll.dart';
import 'package:sorcery_parser/src/util/exceptions.dart';
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
    group('Resolve by alternate name', () {
      test('Burning', () {
        InnateAttack t = Traits.parse('Burning Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.burning);
      }, skip: false);

      test('Corrosion', () {
        InnateAttack t = Traits.parse('Corrosion Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.corrosion);
      }, skip: false);

      test('Crushing', () {
        InnateAttack t = Traits.parse('Crushing Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.crushing);
      }, skip: false);

      test('Cutting', () {
        InnateAttack t = Traits.parse('Cutting Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.cutting);
      }, skip: false);

      test('Fatigue', () {
        InnateAttack t = Traits.parse('Fatigue Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.fatigue);
      }, skip: false);

      test('Impaling', () {
        InnateAttack t = Traits.parse('Impaling Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.impaling);
      }, skip: false);

      test('Small Piercing', () {
        InnateAttack t = Traits.parse('Small Piercing Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.small_piercing);
      }, skip: false);

      test('Piercing', () {
        InnateAttack t = Traits.parse('Piercing Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.piercing);
      }, skip: false);

      test('Large Piercing', () {
        InnateAttack t = Traits.parse('Large Piercing Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.large_piercing);
      }, skip: false);

      test('Huge Piercing', () {
        InnateAttack t = Traits.parse('Huge Piercing Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.huge_piercing);
      }, skip: false);

      test('Toxic', () {
        InnateAttack t = Traits.parse('Toxic Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.toxic);
      }, skip: false);
    });

    group('Cost per die', () {
      test('Burning', () {
        InnateAttack t = Traits.parse('Burning Attack 1d') as InnateAttack;
        expect(t.cost, 5);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 10);
      }, skip: false);

      test('Corrosion', () {
        InnateAttack t = Traits.parse('Corrosion Attack') as InnateAttack;
        expect(t.cost, 10);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 20);
      }, skip: false);

      test('Crushing', () {
        InnateAttack t = Traits.parse('Crushing Attack') as InnateAttack;
        expect(t.cost, 5);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 10);
      }, skip: false);

      test('Cutting', () {
        InnateAttack t = Traits.parse('Cutting Attack') as InnateAttack;
        expect(t.cost, 7);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 14);
      }, skip: false);

      test('Fatigue', () {
        InnateAttack t = Traits.parse('Fatigue Attack') as InnateAttack;
        expect(t.cost, 10);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 20);
      }, skip: false);

      test('Impaling', () {
        InnateAttack t = Traits.parse('Impaling Attack') as InnateAttack;
        expect(t.cost, 8);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 16);
      }, skip: false);

      test('Small Piercing', () {
        InnateAttack t = Traits.parse('Small Piercing Attack') as InnateAttack;
        expect(t.cost, 3);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 6);
      }, skip: false);

      test('Piercing', () {
        InnateAttack t = Traits.parse('Piercing Attack') as InnateAttack;
        expect(t.cost, 5);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 10);
      }, skip: false);

      test('Large Piercing', () {
        InnateAttack t = Traits.parse('Large Piercing Attack') as InnateAttack;
        expect(t.cost, 6);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 12);
      }, skip: false);

      test('Huge Piercing', () {
        InnateAttack t = Traits.parse('Huge Piercing Attack') as InnateAttack;
        expect(t.cost, 8);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 16);
      }, skip: false);

      test('Toxic', () {
        InnateAttack t = Traits.parse('Toxic Attack') as InnateAttack;
        expect(t.cost, 4);
        t.dice = DieRoll.fromString('2d');
        expect(t.cost, 8);
      }, skip: false);
    });

    test('No dice specified defaults to 1d', () {
      InnateAttack t = Traits.parse('Fatigue Attack') as InnateAttack;
      expect(t.reference, 'Innate Attack');
      expect(t.dice, DieRoll(dice: 1));
    }, skip: false);

    group('Description is <type> + <unnormalized-dice>', () {
      test('No dice specified defaults to 1d', () {
        InnateAttack t = Traits.parse('Corrosion Attack') as InnateAttack;
        expect(t.description, 'Corrosion Attack 1d');
      }, skip: false);

      test('Shows dice plus adds', () {
        InnateAttack t = Traits.parse('Fatigue Attack 2d-1') as InnateAttack;
        expect(t.description, 'Fatigue Attack 2d-1');
      }, skip: false);

      test('Handles multi-word types', () {
        InnateAttack t =
            Traits.parse('Huge Piercing Attack 3d') as InnateAttack;
        expect(t.description, 'Huge Piercing Attack 3d');
      }, skip: false);
    });

    group('Calculates dice', () {
      test('Crushing Attack', () {
        InnateAttack t = Traits.parse('Crushing Attack') as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.dice, DieRoll(dice: 1, normalize: false));
        expect(t.description, 'Crushing Attack 1d');
        expect(t.cost, 5);
      }, skip: false);

      test('Crushing Attack 1d', () {
        InnateAttack t = Traits.parse('Crushing Attack 1d') as InnateAttack;
        expect(t.dice, DieRoll(dice: 1, normalize: false));
        expect(t.description, 'Crushing Attack 1d');
        expect(t.cost, 5);
      }, skip: false);

      test('2d', () {
        InnateAttack t = Traits.parse('Crushing Attack 2d') as InnateAttack;
        expect(t.dice, DieRoll.fromString('2d'));
      }, skip: false);

      test('3d-1', () {
        InnateAttack t = Traits.parse('Crushing Attack 3d-1') as InnateAttack;
        expect(t.dice, DieRoll.fromString('3d-1'));
      }, skip: false);

      test('3d-2 unnormalized', () {
        InnateAttack t = Traits.parse('Crushing Attack 3d-2') as InnateAttack;
        expect(t.dice, DieRoll.fromString('3d-2', normalize: false));
      }, skip: false);

      test('4d+1', () {
        InnateAttack t = Traits.parse('Crushing Attack 4d+1') as InnateAttack;
        expect(t.dice, DieRoll.fromString('4d+1'));
      }, skip: false);

      test('4d+2', () {
        InnateAttack t = Traits.parse('Crushing Attack 4d+2') as InnateAttack;
        expect(t.dice, DieRoll.fromString('4d+2'));
      }, skip: false);
    });

    group('Partial dice', () {
      test('3d-4', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d-4') as InnateAttack;
        expect(t.cost, 18);
      }, skip: false);

      test('3d-3', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d-3') as InnateAttack;
        expect(t.cost, 21);
      }, skip: false);

      test('3d-2', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d-2') as InnateAttack;
        expect(t.cost, 24);
      }, skip: false);

      test('3d-1', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d-1') as InnateAttack;
        expect(t.cost, 27);
      }, skip: false);

      test('3d+1', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d+1') as InnateAttack;
        expect(t.cost, 33);
      }, skip: false);

      test('3d+2', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d+2') as InnateAttack;
        expect(t.cost, 36);
      }, skip: false);

      test('3d+3', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d+3') as InnateAttack;
        expect(t.cost, 39);
      }, skip: false);

      test('3d+4', () {
        InnateAttack t = Traits.parse('Fatigue Attack 3d+4') as InnateAttack;
        expect(t.cost, 42);
      }, skip: false);

      test('1 point', () {
        InnateAttack t =
            Traits.parse('Huge Piercing Attack 1 point') as InnateAttack;
        expect(t.cost, 2);
        expect(t.dice, DieRoll(adds: 1));
      });

      test('2 points', () {
        InnateAttack t =
            Traits.parse('Huge Piercing Attack 2 points') as InnateAttack;
        expect(t.cost, 4);
        expect(t.dice, DieRoll(adds: 2));
      });

      test('3 points', () {
        InnateAttack t =
            Traits.parse('Huge Piercing Attack 3 points') as InnateAttack;
        expect(t.cost, 6);
        expect(t.dice, DieRoll(adds: 3, normalize: false));
      });

      test('4 points', () {
        InnateAttack t =
            Traits.parse('Huge Piercing Attack 4 points') as InnateAttack;
        expect(t.cost, 8);
        expect(t.dice, DieRoll(adds: 4, normalize: false));
      });
    });
  });

  group('Variable', () {
    group('Create', () {
      group('Set reference', () {
        test('Create', () {
          expect(() => Traits.parse('Create'), throwsA(isA<Error>()));
        });

        test('Create Rock', () {
          LeveledTrait t = Traits.parse('Create Rock') as LeveledTrait;
          expect(t.reference, 'Create');
        });

        test('Create Solid', () {
          LeveledTrait t = Traits.parse('Create Solid 1') as LeveledTrait;
          expect(t.reference, 'Create');
        });

        test('Create Acid', () {
          LeveledTrait t = Traits.parse('Create Acid 2') as LeveledTrait;
          expect(t.reference, 'Create');
        });
      });

      group('Set level', () {
        test('Create Rock', () {
          LeveledTrait t = Traits.parse('Create Rock') as LeveledTrait;
          expect(t.level, 1);
        });

        test('Create Rock 1', () {
          LeveledTrait t = Traits.parse('Create Rock 1') as LeveledTrait;
          expect(t.level, 1);
        });

        test('Create Rock 2', () {
          LeveledTrait t = Traits.parse('Create Rock 2') as LeveledTrait;
          expect(t.level, 2);
        });
      });

      group('Parenthetical notes', () {
        test('Create Rock 1', () {
          LeveledTrait t = Traits.parse('Create Rock 1') as LeveledTrait;
          expect(t.parentheticalNotes, 'Rock');
        });

        test('Create Iron 1', () {
          LeveledTrait t = Traits.parse('Create Iron 1') as LeveledTrait;
          expect(t.parentheticalNotes, 'Iron');
        });

        test('Create Solid 1', () {
          LeveledTrait t = Traits.parse('Create Solid 1') as LeveledTrait;
          expect(t.parentheticalNotes, 'Solid');
        });

        test('Create Acid 1', () {
          LeveledTrait t = Traits.parse('Create Acid 1') as LeveledTrait;
          expect(t.parentheticalNotes, 'Acid');
        });
      }, skip: false);

      group('Description', () {
        test('Create Rock 1', () {
          LeveledTrait t = Traits.parse('Create Rock 1') as LeveledTrait;
          expect(t.description, 'Create 1');
        });

        test('Create Iron 2', () {
          LeveledTrait t = Traits.parse('Create Iron 2') as LeveledTrait;
          expect(t.description, 'Create 2');
        });
      }, skip: false);

      group('Cost per level', () {
        test('Solid', () {
          LeveledTrait t = Traits.parse('Create Solid 1') as LeveledTrait;
          expect(t.cost, 40);
        });

        test('Earth', () {
          LeveledTrait t = Traits.parse('Create Earth 1') as LeveledTrait;
          expect(t.cost, 20);
        });

        test('Rock', () {
          LeveledTrait t = Traits.parse('Create Rock 1') as LeveledTrait;
          expect(t.cost, 10);
        });

        test('Iron', () {
          LeveledTrait t = Traits.parse('Create Iron 1') as LeveledTrait;
          expect(t.cost, 5);
        });

        test('Missing', () {
          LeveledTrait t = Traits.parse('Create Missing 1') as LeveledTrait;
          expect(() => t.cost, throwsA(isA<ValueNotFoundException>()));
        });
      }, skip: false);
    });
  }, skip: false);
}
