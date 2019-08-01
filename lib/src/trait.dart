import 'package:sorcery_parser/src/util/die_roll.dart';
import 'package:sorcery_parser/src/util/exceptions.dart';

// Some helper constants and declarations.

///
/// A regular expression that matches die rolls, such as 1d, 3d-2, 4d+1, etc.
///
const String regexDieRoll = r'(\d+d(?:(?:\+|-)\d+)?)';

///
/// A regular expression that matches N point(s) -- that is, an integer
/// followed by the words 'point' or 'points'.
///
const String regexPoints = r'(\d+) point(?:s)?';

///
/// Enumeration of the types of [Trait]s handled by this code. The string
/// value of a [_Type] is used when externalizing the list of Traits.
///
enum _Type { simple, leveled, innateAttack, categorizedLeveled }

// Helper functions.

///
/// Converts a string into Title Case.
///
String toTitleCase(String text) => RegExp(r'\w+')
    .allMatches(text)
    .map(getWord)
    .map(capitalizeWord)
    .reduce((a, b) => '$a $b');

///
/// Return the substring matched by this [RegExpMatch].
///
String getWord(RegExpMatch match) =>
    match.input.substring(match.start, match.end);

///
/// Convert the first character of this word to UpperCase.
///
String capitalizeWord(String word) =>
    word.replaceRange(0, 1, word.substring(0, 1).toUpperCase());

///
/// A [Trait] is an instance of a GURPS trait as applied to a character,
/// ability, or power.
///
/// The [Trait] includes any customization necessary to determine its cost
/// before modifiers. For example, leveled traits will include the number of
/// levels and traits with variations will have the variation selected.
///
class Trait {
  ///
  /// Some of the behavior or state of a [Trait] is based on the corresponding
  /// [_Template].
  ///
  _Template template;

  ///
  /// Return the canonical reference name of the [Trait].
  ///
  get reference => template.reference;

  ///
  /// Return the effective cost of the [Trait], including any levels or
  /// variations.
  ///
  get cost => template.cost;

  ///
  /// Return the description of the [Trait] as used in a statistics block.
  ///
  String description;

  Trait({this.template, this.description});
}

///
/// A [LeveledTrait] is a [Trait] that increases in effects and cost in 'levels'.
///
/// The cost of a level is fixed and is calculated as (CostPerLevel × Levels).
///
class LeveledTrait extends Trait {
  int _level = 1;

  ///
  /// Return the effective cost of the [Trait], including the level.
  ///
  @override
  get cost => template.cost * _level;

  ///
  /// Return the description of the [Trait] as used in a statistics block. For
  /// [LeveledTrait]s this is the reference name plus level.
  ///
  /// E.g.: Damage Resistance 2 or Affliction 1.
  ///
  @override
  get description => '$reference $_level';

  ///
  /// Number of levels of the [Trait].
  ///
  get level => _level;

  ///
  /// Any parenthetical notes for this [Trait].
  ///
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

///
/// A [CategorizedLeveledTrait] is a [LeveledTrait] that uses broad categories
/// of effects to determine the cost per level.
///
/// For example, the 'Create <Something>' advantage uses categories like
/// 'Large' (40/level), 'Medium' (20/level), 'Small' (10/level), and
/// 'Specific Item' (5/level).
///
/// For example, 'Create Solid' lets the user create any solid substance. This
/// would fit the Large category and would cost 40 points per level. 'Create
/// Earth' would be Medium and fit the Medium category for 20 points per level.
/// 'Create Rock' might be Small and cost 10 per level, and 'Create Quartz'
/// might be a specific item, and be worth 5 points per level.
///
class CategorizedLeveledTrait extends LeveledTrait {
  @override
  _CategorizedTemplate get template => super.template as _CategorizedTemplate;

  @override
  get cost =>
      template.categoryLevels
          .firstWhere((it) => it.items.contains(parentheticalNotes),
              orElse: () => throw ValueNotFoundException(
                  'Element not found in category levels',
                  parentheticalNotes))
          .costPerLevel *
      level;

  CategorizedLeveledTrait({_Template template, int level, String element})
      : super(template: template, level: level, parentheticalNotes: element);
}

///
/// Enumeration of all types of Innate Attack.
///
enum InnateAttackType {
  burning,
  corrosion,
  crushing,
  cutting,
  fatigue,
  impaling,
  small_piercing,
  piercing,
  large_piercing,
  huge_piercing,
  toxic
}

///
/// Convert the toString() output of an [InnateAttackType] value into an
/// English phrase.
///
String enumToString(InnateAttackType it) => it
    .toString()
    .substring(it.toString().indexOf(r'.') + 1)
    .replaceAll('_', ' ');

///
/// The [Trait] that represents an Innate Attack instance.
///
/// The cost of an [InnateAttack] depends on the type of damage and the number
/// of Dice of damage (including partial dice).
///
class InnateAttack extends Trait {
  ///
  /// Map the [InnateAttackType] to a cost per die.
  ///
  Map<InnateAttackType, int> _costPerDie = {
    InnateAttackType.burning: 5,
    InnateAttackType.corrosion: 10,
    InnateAttackType.crushing: 5,
    InnateAttackType.cutting: 7,
    InnateAttackType.fatigue: 10,
    InnateAttackType.impaling: 8,
    InnateAttackType.small_piercing: 3,
    InnateAttackType.piercing: 5,
    InnateAttackType.large_piercing: 6,
    InnateAttackType.huge_piercing: 8,
    InnateAttackType.toxic: 4,
  };

  ///
  /// The number of Dice of damage caused by this Innate Attack.
  ///
  /// Partial dice translates into adds to the number of dice. For example,
  /// 3d+2 is 3 dice and 2 'partial dice'.
  ///
  DieRoll dice;

  ///
  /// The type of damage of this Innate Attack.
  ///
  InnateAttackType type;

  InnateAttack({_Template template, this.dice, this.type})
      : super(template: template);

  ///
  /// Return the description of the [Trait] as used in a statistics block. For
  /// [InnateAttack] it consists of the Damage Type plus 'Attack' plus DieRoll.
  ///
  @override
  get description => '${toTitleCase(enumToString(type))} Attack $dice';

  ///
  /// Cost is calculated as cost per die x die including partial dice.
  ///
  @override
  get cost {
    if (dice.numberOfDice == null) {
      return (_costPerDie[type] * (dice.adds * 0.25)).ceil();
    }
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
    regExp = RegExp(r' ' + regexPoints);
    if (regExp.hasMatch(traitText)) {
      var tryParse = int.tryParse(regExp.firstMatch(traitText).group(1));
      return DieRoll(adds: tryParse, normalize: false);
    }
    return DieRoll(dice: 1, adds: 0, normalize: false);
  }
}

///
/// Each instance of a [Trait] of a particular type has a single template,
/// which defines its cost and its reference name.
///
class _Template {
  ///
  /// A [_Template] has a reference name -- the name by which it are listed
  /// in the Basic Character book's Trait list (p.B297).
  ///
  final String reference;

  ///
  /// Many traits have a flat cost. For leveled traits this is cost per level.
  ///
  final int cost;

  ///
  /// Some Traits can be referred to via a number of different names
  ///
  final List<String> alternateNames;

  ///
  /// The type of Trait represented by this template.
  ///
  final _Type type;

  _Template({this.reference, this.cost, this.alternateNames, this.type});

  ///
  /// Create the appropriate [Trait] based on the the text.
  ///
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

  ///
  /// Return [true] if the text matches either the reference name or any of the alternate
  /// regular expressions.
  ///
  bool isMatch(String text) =>
      (text == reference) ? true : _findMatchingAlternateName(text) != null;

  ///
  /// For the given text, return the first alternate name regexp that matches.
  /// If none match, return null.
  ///
  String _findMatchingAlternateName(String text) => alternateNames
      ?.firstWhere((it) => RegExp(it).hasMatch(text), orElse: () => null);
}

class _CategoryLevel {
  final String name;
  final int costPerLevel;
  final List<String> items;

  _CategoryLevel({this.name, this.costPerLevel, this.items});
}

class _CategorizedTemplate extends _Template {
  final List<_CategoryLevel> categoryLevels;

  _CategorizedTemplate(
      {String reference,
      _Type type,
      List<String> alternateNames,
      this.categoryLevels})
      : super(reference: reference, alternateNames: alternateNames, type: type);

  Trait parse(String traitText) {
    String pattern = _findMatchingAlternateName(traitText);
    if (pattern == null) throw Error();

    return CategorizedLeveledTrait(
        template: this,
        level: LeveledTrait._tryParseLevelFromText(pattern, traitText),
        element: LeveledTrait._tryParseNotesFromText(pattern, traitText));
  }
}

///
/// This class acts as the central collection of Traits.
///
class Traits {
  ///
  /// Given the trait statistics text before the parenthetical notes, create an
  /// appropriate [Trait].
  ///
  static Trait parse(String traitText) {
    _Template template = _templates.firstWhere((it) => it.isMatch(traitText),
        orElse: () => null);

    return template?.parse(traitText);
  }

  static List<_Template> _templates = [
    _Template(
      reference: 'Affliction',
      cost: 10,
      type: _Type.leveled,
      alternateNames: [r'^Affliction (?<level>\d+)$'],
    ),
    _CategorizedTemplate(
        reference: 'Create',
        type: _Type.categorizedLeveled,
        categoryLevels: [
          _CategoryLevel(name: 'Large', costPerLevel: 40, items: [
            'Solid',
            'Liquid',
            'Gas',
            'Organic',
            'Inorganic',
            'Electomagnetic Waves',
            'Physical Waves'
          ]),
          _CategoryLevel(name: 'Medium', costPerLevel: 20, items: [
            'Acid',
            'Biochemicals',
            'Drugs',
            'Earth',
            'Metal',
            'Electricity',
            'Sound',
            'Long-Wave EM',
            'Light',
            'Short-Wave EM',
            'Radiation'
          ]),
          _CategoryLevel(name: 'Small', costPerLevel: 10, items: [
            'Ferrous Metals',
            'Fire',
            'Rock',
            'Fossil Fuels',
            'Wood',
            'Gamma Rays',
            'Infrared',
            'Ultrasonics',
            'Visible Light'
          ]),
          _CategoryLevel(name: 'Specific Item', costPerLevel: 5, items: [
            'Iron',
            'Salt',
            'Water',
            'Air',
            'Brine',
          ]),
        ],
        alternateNames: [
          r'^Create (?:(?<note>.+) )?(?<level>\d+)$',
          r'^Create (?<note>.+)'
        ]),
    _Template(reference: 'Dark Vision', cost: 25, alternateNames: []),
    _Template(
      reference: 'Innate Attack',
      type: _Type.innateAttack,
      alternateNames: [
        r'^Burning Attack(?: .*)?$',
        r'^Corrosion Attack(?: .*)?$',
        r'^Crushing Attack(?: .*)?$',
        r'^Cutting Attack(?: .*)?$',
        r'^Fatigue Attack(?: .*)?$',
        r'^Impaling Attack(?: .*)?$',
        r'^Small Piercing Attack(?: .*)?$',
        r'^Piercing Attack(?: .*)?$',
        r'^Large Piercing Attack(?: .*)?$',
        r'^Huge Piercing Attack(?: .*)?$',
        r'^Toxic Attack(?: .*)?$',
      ],
    ),
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
        reference: 'Protected Sense',
        cost: 5,
        alternateNames: [r'^Protected (.*)?$']),
    _Template(reference: 'Warp', cost: 100),
  ];
}
