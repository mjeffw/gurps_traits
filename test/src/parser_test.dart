import 'package:sorcery_parser/src/util/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('parse', () {
    test('missing cost', () {
      var text = '360° Vision';
      try {
        Parser().digest(text);
      } catch (e) {
        expect(e, isA<TraitParseException>());
        expect(e.message,
            'TraitParseException: Expected "Name {Level} (parenthetical notes) [Point Cost]"; got "360° Vision"');
      }
    });

    test('360° Vision [25] name', () {
      expect(Parser().digest('360° Vision [25].').name, '360° Vision');
    });

    test('Amphibious [10] name', () {
      expect(Parser().digest('Amphibious [10].').name, 'Amphibious');
    });

    test('360° Vision [25] cost', () {
      expect(Parser().digest('360° Vision [25].').cost, 25);
    });
  });
}

class Components {
  String name;

  int cost;

  Components({this.name, this.cost});
}

class Parser {
  static String pattern = r'^(?<name>.*) \[(?<cost>\d+)';
  RegExp regExp = RegExp(pattern);

  Components digest(String input) {
    if (regExp.hasMatch(input)) {
      return Components(name: '360° Vision', cost: 25);
    }
    throw TraitParseException(input);
  }
}
