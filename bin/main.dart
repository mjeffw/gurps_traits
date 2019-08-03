import 'dart:io';

import 'package:sorcery_parser/src/trait.dart';

Future main(List<String> args) async {
  var files = ['Grimoire-Hagall.txt', 'Grimoire-Sol.txt', 'Grimoire-Yr.txt'];

  List<String> contents = files
      .map((file) => File(file).readAsLinesSync())
      .expand((string) => string)
      .toList();

  mayPrint('The file is ${contents.length} lines long.');

  var keywords = <String>[
    'Keywords:',
    'Rune/Effect:',
    'Full Cost:',
    'Casting Roll:',
    'Range:',
    'Duration:'
  ];

  var statistics = '';

  contents.forEach((line) {
    if (!isStartsWithKeyword(line, keywords)) {
      if (!line.startsWith(r'*') && !line.startsWith(' ')) {
        mayPrint(line);
      }

      var statisticsLabel = r'  Statistics:';

      if (line.startsWith(statisticsLabel)) {
        // remove the label from the start of the line
        statistics = line.replaceFirst(statisticsLabel, '');

        double calculatedTotal = 0;
        double statedTotal = 0;

        if (line.contains('Immunity to Sunburn')) {
          print('!');
        }

        // multiple abilities are separated by ' + ' - split them out
        statistics.split(' + ').forEach((String stat) {
          const openParen = r'(';
          const closeParen = r')';
          const openBrace = r'[';

          double calculatedCost = 0;
          double statedCost = 0;

          var ability = stat.trim();

          // Grab the characters from the start up to the first open parenthesis
          var indexOf = ability.indexOf(openParen);
          if (indexOf == -1) {
            indexOf = ability.indexOf(openBrace);
          }
          if (indexOf == -1) {
            indexOf = ability.length;
          }
          var traitText = ability.substring(0, indexOf).trim();

          mayPrint(traitText);

          var parentheticalText = '';
          if (ability.contains(openParen)) {
            parentheticalText = ability.substring(
                ability.indexOf(openParen) + 1,
                ability.lastIndexOf(closeParen));
          }

          mayPrint(parentheticalText);

          // create the Trait from the traitText
          Trait trait = Traits.parse(traitText, parentheticalText);

          mayPrint('  Trait: ${trait.reference}');

          int traitCost = trait.cost;

          // modifiers include everything between parentheses

          double modifierTotal = 0;

          if (parentheticalText != null && parentheticalText.isNotEmpty) {
            parentheticalText.split(';').forEach((f) {
              String mod = f.trim();
              if (mod.contains(',')) {
                var lastIndexOf = mod.lastIndexOf(',');
                var name = mod.substring(0, lastIndexOf);
                var x =
                    mod.substring(lastIndexOf + 1).trim().replaceAll('−', '-');
                int value = int.parse(x.replaceAll('%', ''));
                mayPrint('    Modifier: ${name}, $value');
                modifierTotal += value;
              }
            });
          }

          modifierTotal /= 100.0;

          if (modifierTotal < -0.80) modifierTotal = -0.8;

          calculatedCost = traitCost + (traitCost * modifierTotal);

          var text = ability.substring(
              ability.indexOf(r'[') + 1, ability.indexOf(r']'));
          var endIndex = text.indexOf(r'/');
          if (endIndex == -1) endIndex = text.length;
          statedCost = double.parse(text.substring(0, endIndex).trim());

          calculatedTotal += calculatedCost;
          statedTotal += statedCost;
        });

        mayPrint('  '
            '${statedTotal.ceil()} (${statedTotal}) : '
            '${calculatedTotal.ceil()} (${calculatedTotal})');

        if (calculatedTotal.ceil() != statedTotal.ceil()) {
          output.forEach((line) => print(line));
        }
        output.clear();
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

List<String> output = [];

void mayPrint(String line) {
  output.add(line);
}
