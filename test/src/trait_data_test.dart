import 'package:gurps_traits/src/template.dart';
import 'package:gurps_traits/src/trait.dart';
import 'package:test/test.dart';

void main() {
  test('simple', () {
    var text = '''{
      "reference": "360° Vision",
      "cost": 25
    }''';
    TraitTemplate t = Traits.buildTemplate(text);
    expect(t.reference, '360° Vision');
    expect(t.cost, 25);
    expect(t.type, TemplateType.simple);
    expect(t.alternateNames, isEmpty);
    expect(t.isSpecialized, false);
  });

  test('simple with alternate name', () {
    var text = '''{
      "reference": "Protected Sense",
      "cost": 5,
      "alternateNames": [
        "^Protected (.*)\$"
      ]
    }''';
    TraitTemplate t = Traits.buildTemplate(text);
    expect(t.reference, 'Protected Sense');
    expect(t.cost, 5);
    expect(t.type, TemplateType.simple);
    expect(t.alternateNames, orderedEquals([r'^Protected (.*)$']));
    expect(t.isSpecialized, false);
  });

  test('level', () {
    var text = '''{
      "reference": "Affliction",
      "cost": 10,
      "type": "leveled"
    }''';
    TraitTemplate t = Traits.buildTemplate(text);
    expect(t.reference, 'Affliction');
    expect(t.cost, 10);
    expect(t.type, TemplateType.leveled);
    expect(t.alternateNames, isEmpty);
    expect(t.isSpecialized, false);
  });

  test('level and specialized', () {
    var text = '''{
      "reference": "Obscure",
      "cost": 2,
      "type": "leveled",
      "isSpecialized": true,
      "alternateNames": [
        "^Obscure (?<spec>.+)\$"
      ]
    }''';
    TraitTemplate t = Traits.buildTemplate(text);
    expect(t.reference, 'Obscure');
    expect(t.cost, 2);
    expect(t.type, TemplateType.leveled);
    expect(t.alternateNames, orderedEquals([r'^Obscure (?<spec>.+)$']));
    expect(t.isSpecialized, true);
  });

  test('categorized', () {
    var text = '''{
      "reference": "Permeation",
      "type": "categorized",
      "categories": [
        {
          "name": "Very Common",
          "cost": 40,
          "items": [
            "Earth",
            "Metal",
            "Stone",
            "Wood"
          ]
        },
        {
          "name": "Common",
          "cost": 20,
          "items": [
            "Concrete",
            "Plastic",
            "Steel"
          ]
        },
        {
          "name": "Occasional",
          "cost": 10,
          "items": [
            "Glass",
            "Ice",
            "Sand",
            "Aluminum",
            "Copper"
          ]
        },
        {
          "name": "Rare",
          "cost": 5,
          "items": [
            "Bone",
            "Flesh",
            "Paper"
          ]
        }
      ],
      "alternateNames": [
        "^Permeation (?<spec>.+)\$"
      ]
    }''';

    CategorizedTemplate t = Traits.buildTemplate(text) as CategorizedTemplate;
    expect(t.reference, 'Permeation');
    expect(t.cost, null);
    expect(t.type, TemplateType.categorized);
    expect(t.alternateNames, orderedEquals([r'^Permeation (?<spec>.+)$']));
    expect(t.isSpecialized, true);
    expect(
        t.categories,
        orderedEquals([
          Category(
              name: 'Very Common',
              cost: 40,
              items: ["Earth", "Metal", "Stone", "Wood"]),
          Category(
              name: 'Common',
              cost: 20,
              items: ["Concrete", "Plastic", "Steel"]),
          Category(
              name: 'Occasional',
              cost: 10,
              items: ["Glass", "Ice", "Sand", "Aluminum", "Copper"]),
          Category(name: 'Rare', cost: 5, items: ["Bone", "Flesh", "Paper"])
        ]));
  });

  test('categorized and leveled', () {
    var text = '''{
      "reference": "Detect",
      "type": "categorizedLeveled",
      "alternateNames": ["^Detect (?<note>.+)\$"],
      "categories": [
        {
          "name": "Very Common",
          "cost": 30,
          "items": [
            "Life",
            "Minerals",
            "Energy"
          ]
        },
        {
          "name": "Common",
          "cost": 20,
          "items": [
            "Humans",
            "Minds",
            "Metals"
          ]
        },
        {
          "name": "Occasional",
          "cost": 10,
          "items": [
            "Magic",
            "Undead"
          ]
        },
        {
          "name": "Rare",
          "cost": 5,
          "items": [
            "Gold",
            "Radar",
            "Radio"
          ]
        }
      ]
    }''';

    CategorizedTemplate t = Traits.buildTemplate(text) as CategorizedTemplate;
    expect(t.reference, 'Detect');
    expect(t.cost, null);
    expect(t.type, TemplateType.categorizedLeveled);
    expect(t.alternateNames, orderedEquals([r'^Detect (?<note>.+)$']));
    expect(t.isSpecialized, true);
    expect(
        t.categories,
        orderedEquals([
          Category(
              name: 'Very Common',
              cost: 30,
              items: ["Life", "Minerals", "Energy"]),
          Category(
              name: 'Common', cost: 20, items: ["Humans", "Minds", "Metals"]),
          Category(name: 'Occasional', cost: 10, items: ["Magic", "Undead"]),
          Category(name: 'Rare', cost: 5, items: ["Gold", "Radar", "Radio"])
        ]));
  });
}
