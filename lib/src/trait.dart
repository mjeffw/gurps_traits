import 'package:sorcery_parser/src/util/die_roll.dart';

const String regexDieRoll = r'(\d+d(?:(?:\+|-)\d+)?)';

enum _Type { simple, leveled, innateAttack }

enum InnateAttackType { crushing }

String enumToString(InnateAttackType it) =>
    it.toString().substring(it.toString().indexOf(r'.') + 1);

String toTitleCase(String t) =>
    t.replaceRange(0, 1, t.substring(0, 1).toUpperCase());

///
/// A [Trait] is an instance of a GURPS trait as applied to a character,
/// ability, or power.
///
/// The [Trait] includes any customization necessary to determine its cost
/// before modifiers. For example, leveled traits will include the number of
/// levels and traits with variations will have the variation selected.
///
class Trait {
  _Template template;

  get reference => template.reference;

  get cost => template.cost;

  String description;

  Trait({this.template, this.description});
}

///
/// A [LeveledTrait] is a [Trait] that increases in effects and cost in 'levels'.
///
/// The cost of a level is fixed and is calculated as (CostPerLevel x Levels).
///
class LeveledTrait extends Trait {
  int _level = 1;

  @override
  get cost => template.cost * _level;

  @override
  get description => '$reference $_level';

  get level => _level;

  String parentheticalNotes;

  LeveledTrait({_Template template, int level, this.parentheticalNotes})
      : assert(level != null && level > 0),
        _level = level,
        super(template: template);

  static int _tryParseLevelFromText(String pattern, String text) {
    if (pattern == null) return 1;

    RegExpMatch match = RegExp(pattern).firstMatch(text);
    if (match.groupNames.contains('level')) {
      return int.tryParse(match.namedGroup('level'));
    }
    return 1;
  }

  static String _tryParseNotesFromText(String pattern, String traitText) {
    if (pattern == null) return null;

    RegExpMatch match = RegExp(pattern).firstMatch(traitText);
    if (match.groupNames.contains('note')) {
      return match.namedGroup('note');
    }
    return null;
  }
}

class InnateAttack extends Trait {
  Map<InnateAttackType, int> _costPerDie = {
    InnateAttackType.crushing: 5,
  };

  DieRoll dice;

  InnateAttackType type;

  InnateAttack({_Template template, this.dice, this.type})
      : super(template: template);

  @override
  get description => '${toTitleCase(enumToString(type))} Attack $dice';

  @override
  get cost {
    return (_costPerDie[type] * (dice.numberOfDice + dice.adds * 0.3)).ceil();
  }

  static InnateAttackType _tryParseTypeFromText(String traitText) {
    var r = RegExp(r'^(.*) Attack');
    if (r.hasMatch(traitText)) {
      return InnateAttackType.values.firstWhere((it) =>
          enumToString(it) == r.firstMatch(traitText).group(1).toLowerCase());
    }
    return null;
  }

  static _tryParseDiceFromText(String traitText) {
    var regExp = RegExp(r' ' + regexDieRoll);
    if (regExp.hasMatch(traitText)) {
      return DieRoll.fromString(regExp.firstMatch(traitText).group(1),
          normalize: false);
    }
    return DieRoll(dice: 1, adds: 0, normalize: false);
  }
}

class _Template {
  ///
  /// A [_Template] has a reference name -- the name by which it are listed
  /// in the Basic Character book's Trait list (p.B297).
  ///
  final String reference;

  ///
  /// Many traits have a flat cost.
  ///
  final int cost;

  ///
  /// Some Traits can be referred to via a number of different names
  ///
  final List<String> alternateNames;

  final _Type type;

  _Template({this.reference, this.cost, this.alternateNames, this.type});

  Trait parse(String traitText) {
    if (type == _Type.leveled) {
      String pattern = _findMatchingAlternateName(traitText);

      return LeveledTrait(
          template: this,
          level: LeveledTrait._tryParseLevelFromText(pattern, traitText),
          parentheticalNotes:
              LeveledTrait._tryParseNotesFromText(pattern, traitText));
    } else if (type == _Type.innateAttack) {
      return InnateAttack(
          template: this,
          type: InnateAttack._tryParseTypeFromText(traitText),
          dice: InnateAttack._tryParseDiceFromText(traitText));
    }
    return Trait(template: this, description: traitText);
  }

  bool isMatch(String text) {
    return (text == reference)
        ? true
        : _findMatchingAlternateName(text) != null;
  }

  String _findMatchingAlternateName(String text) {
    return alternateNames?.firstWhere((it) => RegExp(it).hasMatch(text),
        orElse: () => null);
  }
}

class Traits {
  static Trait parse(String traitText) {
    _Template template = _templates.firstWhere((it) => it.isMatch(traitText),
        orElse: () => null);

    return template?.parse(traitText);
  }

  static List<_Template> _templates = [
    _Template(reference: 'Dark Vision', cost: 25, alternateNames: []),
    _Template(
        reference: 'Protected Sense',
        cost: 5,
        alternateNames: [r'^Protected (.*)?$']),
    _Template(
      reference: 'Obscure',
      cost: 2,
      type: _Type.leveled,
      alternateNames: [
        r'^Obscure (?:(?<note>.+) )?(?<level>\d+)$',
        r'^Obscure (?<note>.+)$'
      ],
    ),
    _Template(
      reference: 'Affliction',
      cost: 10,
      type: _Type.leveled,
      alternateNames: [r'^Affliction (?<level>\d+)$'],
    ),
    _Template(
      reference: 'Innate Attack',
      type: _Type.innateAttack,
      alternateNames: [r'^Crushing Attack .*$'],
    )
  ];
}
