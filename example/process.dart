import 'dart:math';

import 'package:gurps_traits/gurps_traits.dart';

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

        var statisticsLabel = RegExp(r'^\s*Statistics:');

        if (line.startsWith(statisticsLabel)) {

          List<TraitComponents> components = Parser().parse(statistics);

          components
              .forEach((f) => mayPrint('${f.name} ${f.parentheticalNotes})'));

          // create the Trait from the traitText
          List<Trait> traits =
              components.map((it) => Traits.buildTrait(it)).toList();

          traits.forEach((f) => mayPrint('  Trait: ${f.reference}'));

          int calculatedTotal =
              traits.map((f) => f.cost).reduce((a, b) => a + b);
          double statedTotal =
              components.map((f) => f.cost).reduce((a, b) => a + b);

          mayPrint('  '
              'Stated Cost: ${statedTotal.ceil()} (${statedTotal})\n'
              '  '
              'Calculated : ${calculatedTotal.ceil()} (${calculatedTotal})');

          // if (calculatedTotal.ceil() != statedTotal.ceil()) {
          output.forEach((line) => print(line));
          // }
          output.clear();
        }
      }
    });
  }

  double _getModifierFactor(TraitComponents components) {
    List<ModifierComponents> values =
        components.modifiersText.map((it) => ModifierComponents.parse(it)).toList();

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
