import 'package:gurps_traits/src/parser.dart';
import 'package:gurps_traits/src/trait.dart';
import 'package:test/test.dart';

void main() {
  test('360° Vision', () {
    Trait t = Traits.buildTrait(Parser().parse('360° Vision').first);
    expect(t.runtimeType, Trait);
    expect(t.name, '360° Vision');
    expect(t.baseCost, 25);
    expect(t.reference, '360° Vision');
    expect(t.page, 'B34');
  });
  group('Absolute Direction', () {
    test('3D Spatial Sense', () {
      Trait t = Traits.buildTrait(Parser().parse('3D Spatial Sense').first);
      expect(t.runtimeType, Trait);
      expect(t.reference, 'Absolute Direction');
      expect(t.page, 'B34');
      expect(t.baseCost, 10);
      expect(t.name, '3D Spatial Sense');
    });
    test('Absolute Direction', () {
      Trait t = Traits.buildTrait(Parser().parse('Absolute Direction').first);
      expect(t.runtimeType, Trait);
      expect(t.reference, 'Absolute Direction');
      expect(t.page, 'B34');
      expect(t.baseCost, 5);
      expect(t.name, 'Absolute Direction');
    });

    // TODO Modifier: Requires Signal, -20%
  });
  group('Absolute Timing', () {
    test('Absolute Timing', () {
      Trait t = Traits.buildTrait(Parser().parse('Absolute Timing').first);
      expect(t.runtimeType, Trait);
      expect(t.reference, 'Absolute Timing');
      expect(t.page, 'B35');
      expect(t.baseCost, 2);
      expect(t.name, 'Absolute Timing');
    });
    test('Chronolocation', () {
      Trait t = Traits.buildTrait(Parser().parse('Chronolocation').first);
      expect(t.runtimeType, Trait);
      expect(t.reference, 'Absolute Timing');
      expect(t.page, 'B35');
      expect(t.baseCost, 5);
      expect(t.name, 'Chronolocation');
    });
  });
  group('Acute Senses', () {
    test('Acute Hearing', () {
      Trait t = Traits.buildTrait(Parser().parse('Acute Hearing').first);
      expect(t.runtimeType, LeveledTrait);
      expect(t.reference, 'Acute Senses');
      expect(t.page, 'B35');
      expect(t.baseCost, 2);
      expect(t.name, equals('Acute Hearing'));
    });
    test('Acute Taste and Smell', () {
      Trait t =
          Traits.buildTrait(Parser().parse('Acute Taste and Smell').first);
      expect(t.runtimeType, LeveledTrait);
      expect(t.reference, 'Acute Senses');
      expect(t.page, 'B35');
      expect(t.baseCost, 2);
      expect(t.name, equals('Acute Taste and Smell'));
    });
    test('Acute Touch', () {
      Trait t = Traits.buildTrait(Parser().parse('Acute Touch').first);
      expect(t.runtimeType, LeveledTrait);
      expect(t.reference, 'Acute Senses');
      expect(t.page, 'B35');
      expect(t.baseCost, 2);
      expect(t.name, equals('Acute Touch'));
    });
    test('Acute Vision', () {
      Trait t = Traits.buildTrait(Parser().parse('Acute Vision').first);
      expect(t.runtimeType, LeveledTrait);
      expect(t.reference, 'Acute Senses');
      expect(t.page, 'B35');
      expect(t.baseCost, 2);
      expect(t.name, equals('Acute Vision'));
    });
  });

  // TODO Administrative Rank?

  test('Affliction', () {
    Trait t = Traits.buildTrait(Parser().parse('Affliction').first);
    expect(t.runtimeType, LeveledTrait);
    expect(t.reference, 'Affliction');
    expect(t.page, 'B35');
    expect(t.baseCost, 10);
    expect(t.name, equals('Affliction'));
  });
  test('Altered Time Rate', () {
    Trait t = Traits.buildTrait(Parser().parse('Altered Time Rate').first);
    expect(t.runtimeType, LeveledTrait);
    expect(t.reference, 'Altered Time Rate');
    expect(t.page, 'B38');
    expect(t.baseCost, 100);
    expect(t.name, equals('Altered Time Rate'));
  });

  // TODO Allies

  group('Alternate Identity', () {
    test('Alternate Identity (Legal)', () {
      Trait t =
          Traits.buildTrait(Parser().parse('Alternate Identity (Legal)').first);
      expect(t.runtimeType, CategorizedTrait);
      expect(t.reference, 'Alternate Identity');
      expect(t.page, 'B39');
      expect(t.baseCost, 5);
      expect(t.name, equals('Alternate Identity (Legal)'));
    });
    test('Alternate Identity (Illegal)', () {
      Trait t = Traits.buildTrait(
          Parser().parse('Alternate Identity (Illegal)').first);
      expect(t.runtimeType, CategorizedTrait);
      expect(t.reference, 'Alternate Identity');
      expect(t.page, 'B39');
      expect(t.baseCost, 15);
      expect(t.name, equals('Alternate Identity (Illegal)'));
    });
  });
  test('Ambidexterity', () {
    Trait t = Traits.buildTrait(Parser().parse('Ambidexterity').first);
    expect(t.runtimeType, Trait);
    expect(t.reference, 'Ambidexterity');
    expect(t.page, 'B39');
    expect(t.baseCost, 5);
    expect(t.name, equals('Ambidexterity'));
  });
  test('Animal Empathy', () {
    Trait t = Traits.buildTrait(Parser().parse('Animal Empathy').first);
    expect(t.runtimeType, Trait);
    expect(t.reference, 'Animal Empathy');
    expect(t.page, 'B40');
    expect(t.baseCost, 5);
    expect(t.name, equals('Animal Empathy'));
  });

  // TODO: Appearance
  // TODO: Arm DX
  // TODO: Arm ST

  test('Binding', (){
    Trait t = Traits.buildTrait(Parser().parse('Binding').first);
    expect(t.runtimeType, LeveledTrait);
    expect(t.reference, 'Binding');
    expect(t.page, 'B40');
    expect(t.baseCost, 2);
    expect(t.name, equals('Binding'));

    // TODO: Enhancement: Engulfing, +60%
    // TODO: Enhancement: Only Damaged By X, variable
    // TODO: Enhancement: Sticky, +20%
    // TODO: Enhancement: Unbreakable, +40%
    // TODO: Limitation: Environmental, variable
    // TODO: Limitation: One-Shot, -10%

  });

  // TODO: Animal Friend (Talent)
  // TODO: Artificer (Talent)
}
