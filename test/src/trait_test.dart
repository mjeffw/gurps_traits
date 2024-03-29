import 'package:gurps_dice/gurps_dice.dart';
import 'package:gurps_traits/src/parser.dart';
import 'package:gurps_traits/src/trait.dart';
import 'package:gurps_traits/src/util/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('blank trait', () {
    test('copyWith', () {
      Trait t = Trait(
          name: 'Bar',
          baseCost: 5,
          page: 'B4',
          reference: 'Bar',
          modifiers: [Modifier(name: 'Baz', value: -20)]);
      expect(t.modifiers, containsAll([Modifier(name: 'Baz', value: -20)]));
      Trait u = t.copyWith(modifiers: []);
      expect(u.modifiers, isEmpty);
      expect(t.copyWith().modifiers,
          containsAll([Modifier(name: 'Baz', value: -20)]));
    });
  });

  group('flat cost', () {
    group('Protected Sense', () {
      // Canon: 'Protected Sense (%s1, %s2; modifiers...) [10]'
      // Alternatively: 'Protected %s (modifiers...) [5]'
      test('Sense', () {
        TemplateTrait t =
            Traits.buildTrait(Parser().parse('Protected Sense').first);
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.description, 'Protected Sense');
      });

      test('Vision', () {
        TemplateTrait t =
            Traits.buildTrait(Parser().parse('Protected Vision [5].').first);
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.description, 'Protected Vision');
      });

      test('Hearing', () {
        TemplateTrait t =
            Traits.buildTrait(Parser().parse('Protected Hearing [5]').first);
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.description, 'Protected Hearing');
      });
    }, skip: false);

    test('Dark Vision', () {
      TemplateTrait t =
          Traits.buildTrait(Parser().parse('Dark Vision [25]').first);
      expect(t.reference, 'Dark Vision');
      expect(t.cost, 25);
      expect(t.description, 'Dark Vision');
    });

    test('copyWith', () {
      Trait t = Traits.buildTrait(Parser().parse('Dark Vision [25]').first);
      expect(t.modifiers, isEmpty);

      Trait u = t.copyWith(modifiers: [Modifier(name: 'Bar', value: 15)]);
      expect(u.modifiers, containsAll([Modifier(name: 'Bar', value: 15)]));
      var copyWith = u.copyWith();
      expect(
          copyWith.modifiers, containsAll([Modifier(name: 'Bar', value: 15)]));
    });
  });

  group('leveled', () {
    test('copyWith', () {
      var parse = Parser().parse('Obscure 3').first;
      LeveledTrait t = Traits.buildTrait(parse) as LeveledTrait;
      expect(t.modifiers, isEmpty);

      var u = t.copyWith(modifiers: [Modifier(name: 'Foo', value: -10)]);
      expect(
          u.modifiers, containsAllInOrder([Modifier(name: 'Foo', value: -10)]));

      var v = u.copyWith();
      expect(
          v.modifiers, containsAllInOrder([Modifier(name: 'Foo', value: -10)]));
    });

    test('Obscure', () {
      // Canon: 'Obscure (Sense)'
      LeveledTrait t =
          Traits.buildTrait(Parser().parse('Obscure (Sense) [2/level]').first)
              as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 2);
      expect(t.description, 'Obscure 1 (Sense)');
      expect(t.level, 1);
    });

    test('Obscure 3', () {
      // Canon: 'Obscure (Sense)'
      var parse = Parser().parse('Obscure 3').first;
      LeveledTrait t = Traits.buildTrait(parse) as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 6);
      expect(t.description, 'Obscure 3');
      expect(t.level, 3);
      expect(t.specialization, isNull);
    });

    test('Obscure Vision', () {
      LeveledTrait t = Traits.buildTrait(Parser().parse('Obscure Vision').first)
          as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 2);
      expect(t.description, 'Obscure 1 (Vision)');
      expect(t.level, 1);
      expect(t.specialization, 'Vision');
    });

    test('Obscure (Vision)', () {
      var parse = Parser().parse('Obscure (Vision)').first;
      LeveledTrait t = Traits.buildTrait(parse) as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 2);
      expect(t.description, 'Obscure 1 (Vision)');
      expect(t.level, 1);
      expect(t.specialization, 'Vision');
    });

    test('Obscure Dark Vision 5', () {
      LeveledTrait t =
          Traits.buildTrait(Parser().parse('Obscure Dark Vision 5').first)
              as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 10);
      expect(t.description, 'Obscure 5 (Dark Vision)');
      expect(t.level, 5);
      expect(t.specialization, 'Dark Vision');
    });

    test('Obscure 360-Degree Vision 5', () {
      LeveledTrait t =
          Traits.buildTrait(Parser().parse('Obscure 360° Vision 2').first)
              as LeveledTrait;
      expect(t.reference, 'Obscure');
      expect(t.cost, 4);
      expect(t.description, 'Obscure 2 (360° Vision)');
      expect(t.level, 2);
      expect(t.specialization, '360° Vision');
    });

    test('Affliction', () {
      LeveledTrait t =
          Traits.buildTrait(Parser().parse('Affliction').first) as LeveledTrait;
      expect(t.reference, 'Affliction');
      expect(t.cost, 10);
      expect(t.description, 'Affliction 1');
      expect(t.level, 1);
    });

    test('Affliction 2', () {
      LeveledTrait t = Traits.buildTrait(Parser().parse('Affliction 2').first)
          as LeveledTrait;
      expect(t.reference, 'Affliction');
      expect(t.cost, 20);
      expect(t.description, 'Affliction 2');
      expect(t.level, 2);
    });
  }, skip: false);

  group('Innate Attack', () {
    group('Resolve by alternate name', () {
      test('Burning', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Burning Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.burning);
      });

      test('Corrosion', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Corrosion Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.corrosion);
      });

      test('Crushing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.crushing);
      });

      test('Cutting', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Cutting Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.cutting);
      });

      test('Fatigue', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.fatigue);
      });

      test('Impaling', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Impaling Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.impaling);
      });

      test('Small Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Small Piercing Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.small_piercing);
      });

      test('Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Piercing Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.piercing);
      });

      test('Large Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Large Piercing Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.large_piercing);
      });

      test('Huge Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Huge Piercing Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.huge_piercing);
      });

      test('Toxic', () {
        InnateAttack t = Traits.buildTrait(Parser().parse('Toxic Attack').first)
            as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.type, InnateAttackType.toxic);
      });
    }, skip: false);

    group('Cost per die', () {
      test('No change of dice', () {
        var parse = Parser().parse('Burning Attack 1d').first;
        InnateAttack t = Traits.buildTrait(parse) as InnateAttack;
        expect(t.cost, 5);
        t = t.copyWith();
        expect(t.cost, 5);
      });

      test('Burning', () {
        var parse = Parser().parse('Burning Attack 1d').first;
        InnateAttack t = Traits.buildTrait(parse) as InnateAttack;
        expect(t.cost, 5);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 10);
      });

      test('Corrosion', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Corrosion Attack').first)
                as InnateAttack;
        expect(t.cost, 10);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 20);
      });

      test('Crushing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack').first)
                as InnateAttack;
        expect(t.cost, 5);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 10);
      });

      test('Cutting', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Cutting Attack').first)
                as InnateAttack;
        expect(t.cost, 7);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 14);
      });

      test('Fatigue', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack').first)
                as InnateAttack;
        expect(t.cost, 10);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 20);
      });

      test('Impaling', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Impaling Attack').first)
                as InnateAttack;
        expect(t.cost, 8);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 16);
      });

      test('Small Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Small Piercing Attack').first)
                as InnateAttack;
        expect(t.cost, 3);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 6);
      });

      test('Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Piercing Attack').first)
                as InnateAttack;
        expect(t.cost, 5);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 10);
      });

      test('Large Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Large Piercing Attack').first)
                as InnateAttack;
        expect(t.cost, 6);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 12);
      });

      test('Huge Piercing', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Huge Piercing Attack').first)
                as InnateAttack;
        expect(t.cost, 8);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 16);
      });

      test('Toxic', () {
        InnateAttack t = Traits.buildTrait(Parser().parse('Toxic Attack').first)
            as InnateAttack;
        expect(t.cost, 4);
        t = t.copyWith(dice: DieRoll.fromString('2d'));
        expect(t.cost, 8);
      });
    }, skip: false);

    test('No dice specified defaults to 1d', () {
      InnateAttack t = Traits.buildTrait(Parser().parse('Fatigue Attack').first)
          as InnateAttack;
      expect(t.reference, 'Innate Attack');
      expect(t.dice, DieRoll(dice: 1));
    }, skip: false);

    group('Description is <type> + <unnormalized-dice>', () {
      test('No dice specified defaults to 1d', () {
        var parse = Parser().parse('Corrosion Attack').first;
        InnateAttack t = Traits.buildTrait(parse) as InnateAttack;
        expect(t.description, 'Corrosion Attack 1d');
      });

      test('Shows dice plus adds', () {
        var parse = Parser().parse('Fatigue Attack 2d-1').first;
        InnateAttack t = Traits.buildTrait(parse) as InnateAttack;
        expect(t.description, 'Fatigue Attack 2d-1');
      });

      test('Handles multi-word types', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Huge Piercing Attack 3d').first)
                as InnateAttack;
        expect(t.description, 'Huge Piercing Attack 3d');
      });
    }, skip: false);

    group('Calculates dice', () {
      test('Crushing Attack', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack').first)
                as InnateAttack;
        expect(t.reference, 'Innate Attack');
        expect(t.dice, DieRoll(dice: 1, normalized: false));
        expect(t.description, 'Crushing Attack 1d');
        expect(t.cost, 5);
      });

      test('Crushing Attack 1d', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack 1d').first)
                as InnateAttack;
        expect(t.dice, DieRoll(dice: 1, normalized: false));
        expect(t.description, 'Crushing Attack 1d');
        expect(t.cost, 5);
      });

      test('2d', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack 2d').first)
                as InnateAttack;
        expect(t.dice, DieRoll.fromString('2d'));
      });

      test('3d-1', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack 3d-1').first)
                as InnateAttack;
        expect(t.dice, DieRoll.fromString('3d-1'));
      });

      test('3d-2 unnormalized', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack 3d-2').first)
                as InnateAttack;
        expect(t.dice, DieRoll.fromString('3d-2', normalize: false));
      });

      test('4d+1', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack 4d+1').first)
                as InnateAttack;
        expect(t.dice, DieRoll.fromString('4d+1'));
      });

      test('4d+2', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Crushing Attack 4d+2').first)
                as InnateAttack;
        expect(t.dice, DieRoll.fromString('4d+2'));
      });
    }, skip: false);

    group('Partial dice', () {
      test('3d-4', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d-4').first)
                as InnateAttack;
        expect(t.cost, 18);
      });

      test('3d-3', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d-3').first)
                as InnateAttack;
        expect(t.cost, 21);
      });

      test('3d-2', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d-2').first)
                as InnateAttack;
        expect(t.cost, 24);
      });

      test('3d-1', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d-1').first)
                as InnateAttack;
        expect(t.cost, 27);
      });

      test('3d+1', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d+1').first)
                as InnateAttack;
        expect(t.cost, 33);
      });

      test('3d+2', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d+2').first)
                as InnateAttack;
        expect(t.cost, 36);
      });

      test('3d+3', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d+3').first)
                as InnateAttack;
        expect(t.cost, 39);
      });

      test('3d+4', () {
        InnateAttack t =
            Traits.buildTrait(Parser().parse('Fatigue Attack 3d+4').first)
                as InnateAttack;
        expect(t.cost, 42);
      });

      test('1 point', () {
        var parse = Parser().parse('Huge Piercing Attack 1 point').first;
        InnateAttack t = Traits.buildTrait(parse) as InnateAttack;
        expect(t.cost, 2);
        expect(t.dice, DieRoll(adds: 1));
      });

      test('2 points', () {
        InnateAttack t = Traits.buildTrait(
                Parser().parse('Huge Piercing Attack 2 points').first)
            as InnateAttack;
        expect(t.cost, 4);
        expect(t.dice, DieRoll(adds: 2));
      });

      test('3 points', () {
        InnateAttack t = Traits.buildTrait(
                Parser().parse('Huge Piercing Attack 3 points').first)
            as InnateAttack;
        expect(t.cost, 6);
        expect(t.dice, DieRoll(adds: 3, normalized: false));
      });

      test('4 points', () {
        InnateAttack t = Traits.buildTrait(
                Parser().parse('Huge Piercing Attack 4 points').first)
            as InnateAttack;
        expect(t.cost, 8);
        expect(t.dice, DieRoll(adds: 4, normalized: false));
      });
    });
  }, skip: false);

  group('Variable', () {
    group('Categorized trait', () {
      group('copyWith', () {
        test('modifiers', () {
          var t = Traits.buildTrait(Parser().parse('Create').first)
              as CategorizedLeveledTrait;
          expect(t.modifiers, isEmpty);
          var u = t.copyWith(modifiers: [Modifier(name: 'Foo', value: 10)]);
          expect(u.modifiers,
              containsAllInOrder([Modifier(name: 'Foo', value: 10)]));
        });
        test('no modifiers', () {
          var t = Traits.buildTrait(Parser().parse('Create').first)
              as CategorizedLeveledTrait;
          expect(t.modifiers, isEmpty);
          var u = t.copyWith();
          expect(u.modifiers, isEmpty);
        });
      });

      group('Set reference', () {
        test('Create', () {
          var t = Traits.buildTrait(Parser().parse('Create').first);
          expect(t.reference, 'Create');
        });

        test('Create Rock', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Rock').first)
                  as LeveledTrait;
          expect(t.reference, 'Create');
        });

        test('Create Solid', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Solid 1').first)
                  as LeveledTrait;
          expect(t.reference, 'Create');
        });

        test('Create Acid', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Acid 2').first)
                  as LeveledTrait;
          expect(t.reference, 'Create');
        });
      });

      group('Set level', () {
        test('Create Rock', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Rock').first)
                  as LeveledTrait;
          expect(t.level, 1);
        });

        test('Create Rock 1', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Rock 1').first)
                  as LeveledTrait;
          expect(t.level, 1);
        });

        test('Create Rock 2', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Rock 2').first)
                  as LeveledTrait;
          expect(t.level, 2);
        });
      });

      group('Parenthetical notes', () {
        test('Create Rock 1', () {
          var parse = Parser().parse('Create Rock 1').first;
          LeveledTrait t = Traits.buildTrait(parse) as LeveledTrait;
          expect(t.specialization, 'Rock');
        });

        test('Create Iron 1', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Iron 1').first)
                  as LeveledTrait;
          expect(t.specialization, 'Iron');
        });

        test('Create Solid 1', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Solid 1').first)
                  as LeveledTrait;
          expect(t.specialization, 'Solid');
        });

        test('Create Acid 1', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Acid 1').first)
                  as LeveledTrait;
          expect(t.specialization, 'Acid');
        });
      }, skip: false);

      group('Description', () {
        test('Create Rock 1', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Rock 1').first)
                  as LeveledTrait;
          expect(t.description, 'Create 1 (Rock)');
        });

        test('Create Iron 2', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Iron 2').first)
                  as LeveledTrait;
          expect(t.description, 'Create 2 (Iron)');
        });
      }, skip: false);

      group('Cost per level', () {
        test('Solid', () {
          TraitComponents parse = Parser().parse('Create Solid 1').first;
          LeveledTrait t = Traits.buildTrait(parse) as LeveledTrait;
          expect(t.cost, 40);
        });

        test('Earth', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Earth 1').first)
                  as LeveledTrait;
          expect(t.cost, 20);
        });

        test('Rock', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Rock 1').first)
                  as LeveledTrait;
          expect(t.cost, 10);
        });

        test('Iron', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Iron 1').first)
                  as LeveledTrait;
          expect(t.cost, 5);
        });

        test('Solid 2', () {
          TraitComponents parse = Parser().parse('Create Solid 2').first;
          LeveledTrait t = Traits.buildTrait(parse) as LeveledTrait;
          expect(t.cost, 80);
        });

        test('Earth 2', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Earth 2').first)
                  as LeveledTrait;
          expect(t.cost, 40);
        });

        test('Rock 3', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Rock 3').first)
                  as LeveledTrait;
          expect(t.cost, 30);
        });

        test('Iron 4', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Iron 4').first)
                  as LeveledTrait;
          expect(t.cost, 20);
        });

        test('Missing', () {
          LeveledTrait t =
              Traits.buildTrait(Parser().parse('Create Missing 1').first)
                  as LeveledTrait;
          expect(() => t.cost, throwsA(isA<ValueNotFoundException>()));
        });
      }, skip: false);

      test('Parenthetical text', () {
        var text = 'Permeation';
        var parenth =
            'Earth; Can Carry Objects, Light Encumbrance, +20%; Runecasting, −10%';
        var first2 = Parser().parse('$text ($parenth)').first;
        TemplateTrait t = Traits.buildTrait(first2);
        expect(t.specialization, 'Earth');
        expect(t.baseCost, 40);
        expect(t.cost, 44);
      });
    });

    group('Categorized', () {
      group('copyWith', () {
        test('modifiers', () {
          var t =
              Traits.buildTrait(Parser().parse('Appearance (Horrific)').first);
          expect(t.modifiers, isEmpty);
          var u = t.copyWith(modifiers: [
            Modifier(
                name: 'Accessibility',
                detail: 'Only in alternate form',
                value: -30)
          ]);
          expect(
              u.modifiers,
              containsAllInOrder([
                Modifier(
                    name: 'Accessibility',
                    detail: 'Only in alternate form',
                    value: -30)
              ]));
          var v = u.copyWith();
          expect(
              v.modifiers,
              containsAllInOrder([
                Modifier(
                    name: 'Accessibility',
                    detail: 'Only in alternate form',
                    value: -30)
              ]));
        });
      });
    });
  }, skip: false);

  test('Shade, Self', () {
    var text =
        'Immunity to Sunburn [1] + Robust Vision [1] + Temperature Tolerance 1 (Heat; Runecasting, −30%) [3].';
    Traits.buildTrait(Parser().parse(text).first);
  }, skip: false);
}
