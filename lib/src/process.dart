import 'dart:math';

import 'parser.dart';
import 'trait.dart';

class ProcessTraitText {
  final keywords = <String>[
    'Keywords:',
    'Rune/Effect:',
    'Full Cost:',
    'Casting Roll:',
    'Range:',
    'Duration:'
  ];

  void process(List<String> contents) {
    mayPrint('The file is ${contents.length} lines long.');

    var statistics = '';

    contents.forEach((line) {
      if (!isStartsWithKeyword(line, keywords)) {
        if (!line.startsWith(r'*') && !line.startsWith(' ')) {
          mayPrint(line);
        }

        var statisticsLabel = RegExp(r'^\s+Statistics:');

        if (line.startsWith(statisticsLabel)) {
          // remove the label from the start of the line
          statistics = line.replaceFirst(statisticsLabel, '');

          double calculatedTotal = 0;
          double statedTotal = 0;

          // multiple abilities are separated by ' + ' - split them out
          statistics.split(' + ').forEach((String stat) {
            var ability = stat.trim();

            TraitComponents components = Parser().parse(ability);
            mayPrint(components.name);
            mayPrint(components.parentheticalNotes);

            // create the Trait from the traitText
            Trait trait = Traits.buildTrait(components);
            mayPrint('  Trait: ${trait.reference}');

            calculatedTotal +=
                trait.cost + (trait.cost * _getModifierFactor(components));
            statedTotal += components.cost;
          });

          mayPrint('  '
              'Stated Cost: ${statedTotal.ceil()} (${statedTotal})\n'
              '  '
              'Calculated : ${calculatedTotal.ceil()} (${calculatedTotal})');

          if (calculatedTotal.ceil() != statedTotal.ceil()) {
            output.forEach((line) => print(line));
          }
          output.clear();
        }
      }
    });
  }

  double _getModifierFactor(TraitComponents components) {
    List<ModifierComponents> values =
        components.modifiers.map((it) => ModifierComponents.parse(it)).toList();

    int modifierTotal = values.map((it) => it.value).fold(0, (a, b) => a + b);

    double modifierFactor = max(modifierTotal.toDouble() / 100.0, -0.8);
    return modifierFactor;
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
}
