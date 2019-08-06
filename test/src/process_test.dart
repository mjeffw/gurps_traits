import 'package:sorcery_parser/src/process.dart';
import 'package:test/test.dart';

main() {
  test('description', () {
    var contents = '''
Light
Keywords: None.
Rune/Effect: Sól/Light [3] + Create (−2).
Full Cost: 9 pts for level 1 + 3 pts/additional level.
Casting Roll: Use Innate Attack (Gaze) to aim.
Range: 100 yards.
Duration: One minute.
  You can summon light equivalent to full daylight; you may make this light manifest anywhere within 100 yards. The light is bright enough to eliminate all darkness penalties in a 10-yard radius. By concentrating, you can move this “zone of light” at up to (spell level) yards per second. Does not count as an ‘on’ spell.
  Statistics: Create Visible Light 1 (Accessibility, Limited to a 10-yard radius for one minute, −40%; Runecasting, −30%; Ranged, +40%; Reduced Fatigue Cost 1, +20%) [9]. 
  Additional levels add Mobile (+40%) [+3].
    ''';

    ProcessTraitText().process(contents.split('\n'));
  });
}
