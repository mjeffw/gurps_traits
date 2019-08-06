import 'package:sorcery_parser/src/process.dart';
import 'package:test/test.dart';

main() {
  test('description', () {
    var contents = '''
Sleep
Keywords: Resisted (Will).
Rune/Effect: Tyr/Mind [4] + Control (−1).
Full Cost: 36 points.
Casting Roll: Innate Attack (Gaze) to aim. 
Range: 100 yards. 
Duration: 3 minutes.
  The subject falls asleep for 3 minutes, if he fails a Will roll. After this, he can be woken normally, but he will not necessarily wake up right away, especially if already tired. The Innate Attack (Gaze) roll is at −1 per yard distance from caster to subject.
  Statistics: Affliction 1 (Will; Based on Will, +20%; Fixed Duration, +0%; Malediction, +100%; No Signature, +20%; Sleep, +150%; Runecasting, ‑30%) [36].
    ''';

    ProcessTraitText().process(contents.split('\n'));
  });
}
