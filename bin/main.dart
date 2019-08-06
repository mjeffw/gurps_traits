import 'dart:io';

import 'package:sorcery_parser/src/parser.dart';
import 'package:sorcery_parser/src/trait.dart';

Future main(List<String> args) async {
  var files = [
    'Grimoire Tyr.txt',
    'Grimoire-Hagall.txt',
    'Grimoire-Sol.txt',
    'Grimoire-Yr.txt'
  ];

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
          var ability = stat.trim();

          TraitComponents components = Parser().parse(ability);

          mayPrint(components.name);
          mayPrint(components.parentheticalNotes);

          if (components.name == 'Charisma') {
            print('!');
          }

          // create the Trait from the traitText
          Trait trait = Traits.buildTrait(components);

          mayPrint('  Trait: ${trait.reference}');

          List<int> values = components.modifiers
              .map((it) => ModifierComponents.parse(it))
              .map((it) => it.value)
              .toList();

          double modifierTotal = values.isEmpty
              ? 0.0
              : values.reduce((a, b) => a + b).toDouble() / 100.0;

          if (modifierTotal < -0.80) modifierTotal = -0.8;

          calculatedTotal += trait.cost + (trait.cost * modifierTotal);
          statedTotal += components.cost;
        });

        mayPrint('  '
            'Stated Cost: ${statedTotal.ceil()} (${statedTotal}) \n  '
            'Calculated : ${calculatedTotal.ceil()} (${calculatedTotal})');

        // if (calculatedTotal.ceil() != statedTotal.ceil()) {
        output.forEach((line) => print(line));
        // }
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
