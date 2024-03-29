import 'dart:io';

import 'package:gurps_traits/gurps_traits.dart';
import 'package:test/test.dart';

class CodePointCharacter {
  String char;
  int codePoint;

  CodePointCharacter(this.char, this.codePoint);

  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is CodePointCharacter) {
      return char == other.char && codePoint == other.codePoint;
    }
    return false;
  }

  @override
  int get hashCode => char.hashCode ^ codePoint.hashCode;

  @override
  String toString() {
    return '$char:$codePoint';
  }
}

main() {
  test('modifier', () {
    var content = '''
  Statistics: Permeation (Earth; Can Carry Objects, Light Encumbrance, +20%; Runecasting, −30%) [44]. 
  ''';
    TraitComponents c = Parser().parse(content).first;

    // expect(c.notes, hasLength(6));
    // String x = c.notes[2];
    int index = 0;
    content.codeUnits.forEach((c) {
      print('${content.substring(index, index + 1)} : $c');
      index++;
    });

    // expect(c.modifiers, hasLength(6));
    c.modifiersText.forEach((f) => print(f));
    var reduce = c.modifiersText
        .map((it) => Modifier.parse(it))
        .map((f) => f.value)
        .reduce((a, b) => a + b);
    print('${reduce}');

    TemplateTrait t = Traits.buildTrait(c);

    print(t.cost); // 7, 11, 15, 19,
  });

  test('codeunits', () {
    List<String> files = [
      // 'Grimoire-Hagall.txt',
      // 'Grimoire-Sol.txt',
      'Grimoire-Tyr.txt',
      // 'Grimoire-Yr.txt',
    ];

    var r = RegExp(r'(?<name>.+?), (?<sign>.)(?<value>\d+)\%');

    files.forEach((file) {
      print('${file} ==========================');

      List<String> contents = File(file).readAsLinesSync();
      Set<CodePointCharacter> codeUnits = {};

      contents.forEach((line) {
        if (line.startsWith(RegExp(r'^\s*Statistics:'))) {
          var notes =
              line.substring(line.indexOf('(') + 1, line.lastIndexOf(')'));
          var parts = notes.split(';');
          parts.map((part) => part.trim()).forEach((it) {
            r.allMatches(it).forEach((match) {
              int codeUnit = match.namedGroup('sign').codeUnitAt(0);
              codeUnits
                  .add(CodePointCharacter(match.namedGroup('sign'), codeUnit));

              if (![43, 8722].contains(codeUnit)) {
                print('${contents.indexOf(line) + 1}:${match.group(0)}');
              }
            });
          });
        }
      });
      print(codeUnits);
    });
  });
}
