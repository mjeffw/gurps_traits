import 'dart:convert';
import 'dart:math';

import 'package:dart_utils/dart_util.dart';
import 'package:gurps_dice/gurps_dice.dart';

import '../gurps_traits.dart';
import 'data/trait_data.dart';
import 'template.dart';
import 'util/exceptions.dart';

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
  /// Modifiers.
  ///
  final List<ModifierComponents> modifiers;

  ///
  /// Return the canonical reference name of the [Trait].
  ///
  get reference => template.reference;

  int get baseCost => template.cost;

  get modifierTotal =>
      max(-80, modifiers.map((it) => it.value).fold(0, (a, b) => a + b) as int);

  double get _modifierFactor => modifierTotal / 100.0;

  ///
  /// Return the effective cost of the [Trait], including any levels or
  /// variations.
  ///
  int get cost =>
      Maths.setPrecision(baseCost * (1 + _modifierFactor), 4).ceil();

  ///
  /// Return the description of the [Trait] as used in a statistics block.
  ///
  get description => _description ?? reference;

  const Trait(
      {this.template,
      String description,
      String specialization,
      List<ModifierComponents> modifiers})
      : this._description = description,
        this.specialization = specialization,
        this.modifiers = modifiers ?? const [];
}

///
/// A [LeveledTrait] is a [Trait] that increases in effects and cost in 'levels'.
///
/// The cost of a level is fixed and is calculated as (CostPerLevel × Levels).
///
class LeveledTrait extends Trait {
  ///
  /// Level of this trait.
  ///
  final int level;

  ///
  /// Return the effective cost of the [Trait], including the level.
  ///
  @override
  int get cost =>
      Maths.setPrecision(baseCost * level * (_modifierFactor + 1.0), 4).ceil();

  ///
  /// Return the description of the [Trait] as used in a statistics block. For
  /// [LeveledTrait]s this is the reference name plus level.
  ///
  /// E.g.: Damage Resistance 2 or Affliction 1.
  ///
  @override
  get description => '$reference $level';

  const LeveledTrait(
      {TraitTemplate template,
      int level = 1,
      String specialization,
      List<ModifierComponents> modifiers})
      : assert(level != null && level > 0),
        level = level,
        super(
            template: template,
            specialization: specialization,
            modifiers: modifiers);

  static String tryParseSpecialization(String pattern, String traitText) =>
      RegExpEx.getNamedGroup(RegExp(pattern).firstMatch(traitText), 'spec');
}

///
/// This mixin uses a list of [Category] to calculate its cost.
///
abstract class HasCategory {
  List<Category> get _categories;

  String get specialization;

  int get baseCost => _categories
      .firstWhere((it) => it.items.contains(specialization),
          orElse: () => throw ValueNotFoundException(
              'Element not found in category', specialization))
      .cost;
}

class CategorizedTrait extends Trait with HasCategory {
  @override
  CategorizedTemplate get template => super.template as CategorizedTemplate;

  @override
  List<Category> get _categories => template.categories;

  CategorizedTrait(
      {TraitTemplate template, String item, List<ModifierComponents> modifiers})
      : super(template: template, specialization: item, modifiers: modifiers);
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
class CategorizedLeveledTrait extends LeveledTrait with HasCategory {
  @override
  CategorizedTemplate get template => super.template as CategorizedTemplate;

  @override
  List<Category> get _categories => template.categories;

  CategorizedLeveledTrait(
      {TraitTemplate template,
      int level,
      String item,
      List<ModifierComponents> modifiers})
      : super(
            template: template,
            level: level,
            specialization: item,
            modifiers: modifiers);
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
  static final Map<InnateAttackType, int> _costPerDie = const {
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

  const InnateAttack(
      {TraitTemplate template,
      this.dice,
      this.type,
      List<ModifierComponents> modifiers})
      : super(template: template, modifiers: modifiers);

  ///
  /// Return the description of the [Trait] as used in a statistics block. For
  /// [InnateAttack] it consists of the Damage Type plus 'Attack' plus DieRoll.
  ///
  @override
  get description => '${StringEx.toTitleCase(enumToString(type))} Attack $dice';

  ///
  /// Cost is calculated as cost per die x die including partial dice.
  ///
  /// The value of an Innate Attack that causes partial dice of damage (see
  /// p.B62 for details) is calculated as follows.
  ///
  /// 1. Figure out how many effective levels of the Innate Attack are
  ///    being bought (e.g., a 3d-2 attack equates to buying 2.4 levels).
  /// 2. Multiply the per-level cost of the Innate Attack by the effective
  ///    number of levels.
  /// 3. Round the cost up to the nearest point.
  /// 4. Apply the net value of all modifiers.
  /// 5. Round the cost up (again) to the nearest point.
  ///
  @override
  int get baseCost {
    double effectiveLevels = (dice.numberOfDice == 0)
        ? (dice.adds * 0.25)
        : (dice.numberOfDice + dice.adds * 0.3);
    var costPerDie = _costPerDie[type];
    return (costPerDie * effectiveLevels).ceil();
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

typedef TraitTemplate BuildTemplate(Map<String, dynamic> map);

///
/// This class acts as the central collection of Traits.
///
class Traits {
  static Map<TemplateType, BuildTemplate> _router = {
    TemplateType.simple: TraitTemplate.buildTemplate,
    TemplateType.leveled: TraitTemplate.buildTemplate,
    TemplateType.categorized: CategorizedTemplate.buildTemplate,
    TemplateType.categorizedLeveled: CategorizedTemplate.buildTemplate,
    TemplateType.innateAttack: TraitTemplate.buildTemplate,
  };

  static TraitTemplate buildTemplate(String text) =>
      _buildTemplateFromJson(json.decode(text));

  static TraitTemplate _buildTemplateFromJson(Map<String, dynamic> json) =>
      _router[convertToTemplateTypeEnum(json['type'])].call(json);

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

    return template?.buildTraitFrom(components);
  }

  static List<TraitTemplate> _templates = [];
}
