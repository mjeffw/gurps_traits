import 'package:sorcery_parser/src/trait.dart';
import 'package:test/test.dart';

void main() {
  group('flat cost', () {
    group('Protected Sense', () {
      test('Vision', () {
        Trait t = Traits.parse('Protected Vision');
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.text, 'Protected Vision');
      });

      test('Hearing', () {
        Trait t = Traits.parse('Protected Hearing');
        expect(t.reference, 'Protected Sense');
        expect(t.cost, 5);
        expect(t.text, 'Protected Hearing');
      });
    });

    test('Dark Vision', () {
      Trait t = Traits.parse('Dark Vision');
      expect(t.reference, 'Dark Vision');
      expect(t.cost, 25);
      expect(t.text, 'Dark Vision');
    });
  });

  group('leveled', () {
    test('Obscure', () {
      Trait t = Traits.parse('Obscure 3');
      expect(t.reference, 'Obscure');
      expect(t.cost, 6);
      expect(t.text, 'Obscure');
      expect(t.level, 3);
    });

    test('Affliction', () {
      Trait t = Traits.parse('Affliction 1');
      expect(t.reference, 'Affliction');
      expect(t.cost, 10);
      expect(t.text, 'Affliction');
      expect(t.level, 1);
    });

    test('Obscure -- extra information', () {
      expect(() => Traits.parse('Obscure Vision 5'),
          throwsA(isA<AssertionError>()));
    });

    test('Affliction -- missing level', () {
      expect(() => Traits.parse('Affliction'), throwsA(isA<AssertionError>()));
    });

    test('Create', () {
      Trait t = Traits.parse('Create Visible Light 1');
      expect(t.reference, 'Create');
      expect(t.cost, 20);
      expect(t.text, 'Create Visible Light');
      expect(t.level, 1);
    }, skip: false);
  });

  group('Variable', () {
    test('Innate Attack - Burning 1d', () {
      Trait t = Traits.parse('Burning Attack 1d');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 5);
      expect(t.text, 'Burning Attack 1d');
      expect(t.level, 1);
    });

    test('Innate Attack - Burning', () {
      Trait t = Traits.parse('Burning Attack');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 5);
      expect(t.text, 'Burning Attack 1d');
      expect(t.level, 1);
    });

    test('Innate Attack - Corrosion 1d', () {
      Trait t = Traits.parse('Corrosion Attack 1d');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 10);
      expect(t.text, 'Corrosion Attack 1d');
      expect(t.level, 1);
    });

    test('Innate Attack - Cutting 2d', () {
      Trait t = Traits.parse('Cutting Attack 2d');
      expect(t.reference, 'Innate Attack');
      expect(t.cost, 14);
      expect(t.text, 'Cutting Attack 2d');
      expect(t.level, 2);
    });
  });
}
