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

  // String p = keywords.reduce((a, b) => '$a|$b');

  // var name = '';
  var statistics = '';

  contents.forEach((line) {
    if (!isStartsWithKeyword(line, keywords)) {
      if (!line.startsWith(r'*') && !line.startsWith(' ')) {
        print(line);
        // name = line;
      }

      var statisticsLabel = r'  Statistics:';

      if (line.startsWith(statisticsLabel)) {
        // remove the label from the start of the line
        statistics = line.replaceFirst(statisticsLabel, '');

        double calculatedTotal = 0;
        double statedTotal = 0;

        // multiple abilities are separated by ' + ' - split them out
        statistics.split(' + ').forEach((ability) {
          var openParen = r'(';
          var closeParen = r')';

          double calculatedCost = 0;
          double statedCost = 0;

          // Grab the characters from the start up to the first open parenthesis
          var traitText =
              ability.substring(0, ability.indexOf(openParen)).trim();

          print(traitText);

          var parentheticalText = ability.substring(
              ability.indexOf(openParen) + 1, ability.indexOf(closeParen));
          print(parentheticalText);

          // create the Trait from the traitText
          Trait trait = Traits.parse(traitText, parentheticalText);

          print('  Trait: ${trait.reference}');

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

          calculatedTotal += calculatedCost;
          statedTotal += statedCost;
        });

        print('  '
            '${statedTotal.ceil()} (${statedTotal}) : '
            '${calculatedTotal.ceil()} (${calculatedTotal})');
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
