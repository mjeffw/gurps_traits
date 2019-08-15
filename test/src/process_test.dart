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
  Burning Attack 1d−1 (Cyclic, 9 cycles, 1 second intervals, +800%; No Incendiary Effect, −10%; Nuisance Effect, Dangerous to be parried, −5%; Runecasting, −30%) [34].
  ''';
    TraitComponents c = Parser().parse(content);

    // expect(c.notes, hasLength(6));
    // String x = c.notes[2];
    // int index = 0;
    // x.codeUnits.forEach((c) {
    //   print('${x.substring(index, index + 1)} : $c');
    //   index++;
    // });

    // expect(c.modifiers, hasLength(6));
    c.modifiers.forEach((f) => print(f));
    var reduce = c.modifiers
        .map((it) => ModifierComponents.parse(it))
        .map((f) => f.value)
        .reduce((a, b) => a + b);
    print('${reduce}');

    Trait t = Traits.buildTrait(c);

    var cost = t.cost + (t.cost * (reduce / 100.0).ceil());

    expect(cost, 34);
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
