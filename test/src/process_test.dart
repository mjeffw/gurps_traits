import 'dart:io';

import 'package:sorcery_parser/src/process.dart';
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
  test('description', () {
    var contents = '''
Statistics: Toxic Attack 10 points (Accessibility, On-ly on living IQ 1+ beings, −10%; Damage cannot exceed margin of victory, −50%; Malediction 2, +150%; No Signature, +20%; Runecasting, −30%) [20].    ''';

    ProcessTraitText().process(contents.split('\n'));
  });

  test('codeunits', () {
    List<String> files = [
      'Grimoire-Hagall.txt',
      'Grimoire-Sol.txt',
      'Grimoire-Tyr.txt',
      'Grimoire-Yr.txt',
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
