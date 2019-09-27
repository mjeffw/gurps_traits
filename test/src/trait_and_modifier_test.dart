import 'package:gurps_traits/gurps_traits.dart';
import 'package:test/test.dart';

void main() {
  test('Innate Attack', () {
    var text = '''
Burning Attack 1d (Environmental, Storm, −40%; Nuisance Effect, Behaves erratically around conductors, −5%; Overhead, +30%; Runecasting, −30%; Surge, Arcing, +100%; Side Effect, Stunning, +50%; Takes Recharge, 5 seconds, −10%)
    ''';

    TraitComponents c = Parser().parse(text).first;
    TemplateTrait t = Traits.buildTrait(c);
    String description = t.description;

    expect(description,
        'Burning Attack 1d (Environmental, Storm, -40%; Nuisance Effect, Behaves erratically around conductors, -5%; Overhead, +30%; Runecasting, -30%; Side Effect, Stunning, +50%; Surge, Arcing, +100%; Takes Recharge, 5 seconds, -10%)');
  });
}
