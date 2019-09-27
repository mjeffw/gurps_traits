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

    contents.forEach((line) {
      if (!isStartsWithKeyword(line, keywords)) {
        if (!line.startsWith(r'*') && !line.startsWith(' ')) {
          mayPrint(line);
        }

        var statisticsLabel = RegExp(r'^\s*Statistics:');

        if (line.startsWith(statisticsLabel)) {
          List<TraitComponents> components = Parser().parse(line);

          components
              .forEach((f) => mayPrint('${f.name} (${f.parentheticalNotes})'));

          // create the Trait from the traitText
          List<TemplateTrait> traits =
              components.map((it) => Traits.buildTrait(it)).toList();

          // if (traits.first.reference.startsWith('Penetrating Vision')) {
          //   print('hey!');
          // }

          traits.forEach((f) => mayPrint(
              '  Trait: ${f.reference} (${f.baseCost}:${f.modifierTotal}%) [${f.cost}]'));

          int calculatedTotal =
              traits.map((f) => f.cost).reduce((a, b) => a + b);
          double statedTotal =
              components.map((f) => f.cost).reduce((a, b) => a + b);

          // assert(calculatedTotal == statedTotal.ceil());

          mayPrint(//
              '  Stated Cost: ${statedTotal.ceil()} (${statedTotal})\n'
              '  Calculated : ${calculatedTotal.ceil()} (${calculatedTotal})');

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
}
