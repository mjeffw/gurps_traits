import 'dart:io';

import 'package:sorcery_parser/src/trait.dart';

Future main(List<String> args) async {
  var config = File('Grimoire-Sol.txt');

  // Put each line of the file into its own string.
  var contents = await config.readAsLines();
  print('The file is ${contents.length} lines long.');

  var keywords = <String>[
    'Keywords:',
    'Rune/Effect:',
    'Full Cost:',
    'Casting Roll:',
    'Range:',
    'Duration:'
  ];

  // var traits = <String, double>{
  //   'Absolute Direction': 5,
  //   'Affliction': 10,
  //   'Burning': 5,
  //   'Control': 20,
  //   'Create Rock': 10,
  //   'Create': 20,
  //   'Crushing': 5,
  //   'Dark Vision': 25,
  //   'Detect': 5,
  //   'Insubstantiality': 80,
  //   'Jumper': 100,
  //   'Magic Resistance': 2,
  //   'Neutralize': 50,
  //   'Night Vision': 1,
  //   'Obscure': 6,
  //   'Payload': 1,
  //   'Penetrating Vision': 10,
  //   'Permeation': 40,
  //   'Protected Vision': 5,
  //   'Static': 30,
  //   'Telescopic Vision': 5,
  //   'Warp': 100,
  // };

  String p = keywords.reduce((a, b) => '$a|$b');

  var name = '';
  var statistics = '';

  contents.forEach((line) {
    if (!isStartsWithKeyword(line, keywords)) {
      if (!line.startsWith(r'*') && !line.startsWith(' ')) {
        print(line);
        name = line;
      }
      if (line.startsWith(r'  Statistics:')) {
        statistics = line;

        double calculatedTotal = 0;
        double statedTotal = 0;

        // multiple abilities are separated by ' + '
        statistics.split(' + ').forEach((ability) {
          var openParen = r'(';
          var closeParen = r')';

          double calculatedCost = 0;
          double statedCost = 0;

          var t = ability
              .substring(ability.indexOf(':') + 1, ability.indexOf(openParen))
              .trim();

          Trait trait = Traits.parse(t);

          print('  Trait: ${trait.name}');

          int traitCost = trait.cost;

          // modifiers include everything between parentheses
          var text = ability
              .substring(ability.indexOf(openParen) + 1,
                  ability.lastIndexOf(closeParen))
              .trim();

          double modifierTotal = 0;

          text.split(';').forEach((f) {
            String mod = f.trim();
            if (mod.contains(',')) {
              var lastIndexOf = mod.lastIndexOf(',');
              var name = mod.substring(0, lastIndexOf);
              var x =
                  mod.substring(lastIndexOf + 1).trim().replaceAll('−', '-');
              int value = int.parse(x.replaceAll('%', ''));
              print('    Modifier: ${name}, $value');
              modifierTotal += value;
            }
          });

          modifierTotal /= 100.0;

          if (modifierTotal < -0.80) modifierTotal = -0.8;

          calculatedCost = traitCost + (traitCost * modifierTotal);

          text = ability.substring(
              ability.indexOf(r'[') + 1, ability.indexOf(r']'));
          var endIndex = text.indexOf(r'/');
          if (endIndex == -1) endIndex = text.length;
          statedCost = double.parse(text.substring(0, endIndex).trim());

          print('  ${statedCost} : ${calculatedCost}');
          print('  ${statedCost.ceil()} : ${calculatedCost.ceil()}');
        });
      }
    }
  });
}

bool isStartsWithKeyword(String line, List<String> keywords) {
  bool found = false;
  keywords.forEach((f) {
    if (line.startsWith(f)) {
      found = true;
    }
  });
  return found;
}
