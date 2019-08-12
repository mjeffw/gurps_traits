import 'dart:convert';

import 'package:gurps_dice/gurps_dice.dart';

import '../gurps_traits.dart';
import 'data/trait_data.dart';
import 'template.dart';
import 'util/exceptions.dart';
import 'util/util.dart';

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
  /// [TraitTemplate].
  ///
  final TraitTemplate template;

  final String _description;

  ///
  /// Any parenthetical notes for this [Trait].
  ///
  final String specialization;

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
  get description => _description ?? reference;

  const Trait({this.template, String description, this.specialization})
      : this._description = description;
}

///
/// A [LeveledTrait] is a [Trait] that increases in effects and cost in 'levels'.
///
/// The cost of a level is fixed and is calculated as (CostPerLevel × Levels).
///
class LeveledTrait extends Trait {
  final int _level;

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

  const LeveledTrait(
      {TraitTemplate template, int level = 1, String specialization})
      : assert(level != null && level > 0),
        _level = level,
        super(template: template, specialization: specialization);

  static String tryParseSpecialization(String pattern, String traitText) {
    if (pattern == null) return null;

    RegExpMatch match = RegExp(pattern).firstMatch(traitText);
    if (match.groupNames.contains('spec')) {
      return match.namedGroup('spec');
    }
    return null;
  }
}

class CategorizedTrait extends Trait {
  @override
  CategorizedTemplate get template => super.template as CategorizedTemplate;

  @override
  get cost => template.categories
      .firstWhere((it) => it.items.contains(specialization),
          orElse: () => throw ValueNotFoundException(
              'Element not found in category', specialization))
      .cost;

  const CategorizedTrait({TraitTemplate template, String item})
      : super(template: template, specialization: item);
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
  CategorizedTemplate get template => super.template as CategorizedTemplate;

  @override
  get cost =>
      template.categories
          .firstWhere((it) => it.items.contains(specialization),
              orElse: () => throw ValueNotFoundException(
                  'Element not found in category levels', specialization))
          .cost *
      level;

  const CategorizedLeveledTrait(
      {TraitTemplate template, int level, String item})
      : super(template: template, level: level, specialization: item);
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
  final Map<InnateAttackType, int> _costPerDie = const {
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
  final DieRoll dice;

  ///
  /// The type of damage of this Innate Attack.
  ///
  final InnateAttackType type;

  const InnateAttack({TraitTemplate template, this.dice, this.type})
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
    if (dice.numberOfDice == null || dice.numberOfDice == 0) {
      return (_costPerDie[type] * (dice.adds * 0.25)).ceil();
    }
    return (_costPerDie[type] * (dice.numberOfDice + dice.adds * 0.3)).ceil();
  }

  static InnateAttackType tryParseTypeFromText(String traitText) {
    var r = RegExp(r'^(.*) Attack');
    if (r.hasMatch(traitText)) {
      return InnateAttackType.values.firstWhere((it) =>
          enumToString(it) == r.firstMatch(traitText).group(1).toLowerCase());
    }
    return null;
  }

  static tryParseDiceFromText(String diceText) {
    var regExp = RegExp(DICE_PATTERN);
    if (diceText != null && regExp.hasMatch(diceText)) {
      return DieRoll.fromString(regExp.firstMatch(diceText).group(1),
          normalize: false);
    }

    regExp = RegExp(r'(\d+)');
    if (diceText != null && regExp.hasMatch(diceText)) {
      var tryParse = int.tryParse(regExp.firstMatch(diceText).group(1));
      return DieRoll(adds: tryParse, normalized: false);
    }

    return DieRoll(dice: 1);
  }

  static InnateAttack copyWith(InnateAttack t, {DieRoll dice}) {
    return InnateAttack(
        type: t.type, dice: dice ?? t.dice, template: t.template);
  }
}

class Traits {
  static Map<TemplateType, BuildTemplate> _router = {
    TemplateType.simple: TraitTemplate.buildTemplate,
    TemplateType.leveled: TraitTemplate.buildTemplate,
    TemplateType.categorized: CategorizedTemplate.buildTemplate,
    TemplateType.categorizedLeveled: CategorizedTemplate.buildTemplate,
    TemplateType.innateAttack: TraitTemplate.buildTemplate,
  };

  static TraitTemplate buildTemplate(String text) {
    var map = json.decode(text);

    return _buildTemplateFromJson(map);
  }

  static TraitTemplate _buildTemplateFromJson(Map<String, dynamic> json) {
    var type = convertToTemplateTypeEnum(json['type']);
    return _router[type].call(json);
  }

  static Trait buildTrait(TraitComponents components) {
    if (_templates.isEmpty) {
      var data = json.decode(trait_data);
      var traits = data['traits'] as List<dynamic>;
      traits
          .map((it) => _buildTemplateFromJson(it))
          .forEach((it) => _templates.add(it));
    }

    TraitTemplate template = _templates
        .firstWhere((it) => it.isMatch(components.name), orElse: () => null);

    return template?.parse(components);
  }

  static List<TraitTemplate> _templates = [];
}
