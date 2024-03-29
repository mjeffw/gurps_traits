import 'dart:convert';
import 'dart:math';

import 'package:dart_utils/dart_util.dart';
import 'package:gurps_dice/gurps_dice.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';

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
  /// Any parenthetical notes for this [Trait].
  ///
  final String specialization;

  ///
  /// Name of the trait.
  ///
  final String name;

  ///
  /// Modifiers.
  ///
  final List<Modifier> modifiers;

  ///
  /// The canonical reference name of the [Trait].
  ///
  final String reference;

  ///
  /// The cost of the trait before levels or modifiers are applied.
  ///
  final int baseCost;

  ///
  /// Page number of the trait.
  ///
  final String page;

  ///
  /// The integer value that is the sum of all modifiers. Negative modifiers
  /// are limited to -80 or greater.
  ///
  int get modifierTotal =>
      max(-80, modifiers.map((it) => it.value).fold(0, (a, b) => a + b) as int);

  ///
  /// The modifier total as a fraction. Modifiers are written as percentages;
  /// this returns the value as a decimal. (E.g., a 45% modifier would be
  /// returned as 0.45).
  ///
  double get _modifierFactor => modifierTotal / 100.0;

  ///
  /// Return the effective cost of the [Trait], including any levels or
  /// variations.
  ///
  int get cost =>
      Maths.setPrecision(baseCost * (1 + _modifierFactor), 4).ceil();

  ///
  /// Textual description as found in a stat block, "Burning Attack 1d" or
  /// "Create 2 (Water)", for example.
  ///
  String get description => (_hasParentheticalText())
      ? nameAndLevel
      : '$nameAndLevel $parentheticalText';

  bool _hasParentheticalText() => modifiers.isEmpty && _specializationIsEmpty;

  bool get _specializationIsEmpty =>
      specialization == null || specialization.isEmpty;

  String get nameAndLevel => '${name ?? reference}';

  String get modifiersDescription {
    modifiers.sort((a, b) => a.description.compareTo(b.description));
    return modifiers.map((it) => it.description).join('; ');
  }

  String get parentheticalText {
    String temp = <String>[
      if (!_specializationIsEmpty) specialization,
      if (modifiers.isNotEmpty) modifiersDescription
    ].join('; ');

    return '($temp)';
  }

  const Trait(
      {this.name,
      this.specialization,
      List<Modifier> modifiers,
      this.baseCost,
      this.page,
      this.reference})
      : this.modifiers = modifiers ?? const [];

  Trait copyWith({List<Modifier> modifiers}) {
    return Trait(
        name: this.name,
        specialization: this.specialization,
        modifiers: modifiers ?? this.modifiers);
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Trait &&
            this.name == other.name &&
            this.page == other.page &&
            this.reference == other.reference &&
            this.specialization == other.specialization &&
            this.baseCost == other.baseCost &&
            listsEqual(this.modifiers, other.modifiers));
  }

  @override
  int get hashCode =>
      hashObjects([name, page, reference, specialization, baseCost, modifiers]);
}

class TemplateTrait extends Trait {
  ///
  /// Some of the behavior or state of a [TemplateTrait] is based on the corresponding
  /// [TraitTemplate].
  ///
  final TraitTemplate template;

  ///
  /// The canonical reference name of the [TemplateTrait].
  ///
  String get reference => template.reference;

  ///
  /// The cost of the trait before levels or modifiers are applied.
  ///
  int get baseCost => template.cost;

  ///
  /// Page number of the trait.
  ///
  String get page => template.page;

  const TemplateTrait(
      {this.template,
      String name,
      String specialization,
      List<Modifier> modifiers})
      : super(name: name, specialization: specialization, modifiers: modifiers);

  @override
  Trait copyWith({List<Modifier> modifiers}) {
    return TemplateTrait(
        template: this.template,
        name: this.name,
        specialization: this.specialization,
        modifiers: modifiers ?? this.modifiers);
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is TemplateTrait &&
            this.template == other.template &&
            this.specialization == other.specialization &&
            listsEqual(this.modifiers, other.modifiers));
  }

  @override
  int get hashCode => hash3(template, specialization, modifiers);
}

///
/// A [LeveledTrait] is a [TemplateTrait] that increases in effects and cost in 'levels'.
///
/// The cost of a level is fixed and is calculated as (CostPerLevel × Levels).
///
class LeveledTrait extends TemplateTrait {
  ///
  /// Level of this trait.
  ///
  final int level;

  ///
  /// Return the effective cost of the [TemplateTrait], including the level.
  ///
  @override
  int get cost =>
      Maths.setPrecision(baseCost * level * (_modifierFactor + 1.0), 4).ceil();

  ///
  /// Return the description of the [TemplateTrait] as used in a statistics block. For
  /// [LeveledTrait]s this is the reference name plus level.
  ///
  /// E.g.: Damage Resistance 2 or Affliction 1.
  ///
  @override
  String get nameAndLevel => '${name ?? reference} $level';

  const LeveledTrait(
      {TraitTemplate template,
      int level = 1,
      String specialization,
      List<Modifier> modifiers,
      String name})
      : assert(level != null && level > 0),
        level = level,
        super(
            name: name,
            template: template,
            specialization: specialization,
            modifiers: modifiers);

  @override
  Trait copyWith({List<Modifier> modifiers}) {
    return LeveledTrait(
        template: this.template,
        level: this.level,
        name: this.name,
        specialization: this.specialization,
        modifiers: modifiers ?? this.modifiers);
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is LeveledTrait &&
            this.template == other.template &&
            this.level == other.level &&
            this.specialization == other.specialization &&
            listsEqual(this.modifiers, other.modifiers));
  }

  @override
  int get hashCode => hash4(template, specialization, modifiers, level);

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

class CategorizedTrait extends TemplateTrait with HasCategory {
  @override
  CategorizedTemplate get template => super.template as CategorizedTemplate;

  @override
  List<Category> get _categories => template.categories;

  @override
  String get name => '${super.name} ($specialization)';

  CategorizedTrait(
      {TraitTemplate template,
      String item,
      List<Modifier> modifiers,
      String name})
      : super(
            template: template,
            specialization: item,
            modifiers: modifiers,
            name: name);

  @override
  Trait copyWith({List<Modifier> modifiers}) {
    return CategorizedTrait(
        template: this.template,
        item: this.specialization,
        name: this.name,
        modifiers: modifiers ?? this.modifiers);
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is CategorizedTrait &&
            this.template == other.template &&
            this.specialization == other.specialization &&
            listsEqual(this.modifiers, other.modifiers));
  }

  @override
  int get hashCode => hash3(template, specialization, modifiers);
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
      List<Modifier> modifiers})
      : super(
            template: template,
            level: level,
            specialization: item,
            modifiers: modifiers);

  @override
  Trait copyWith({List<Modifier> modifiers}) {
    return CategorizedLeveledTrait(
        template: this.template,
        level: this.level,
        item: this.specialization,
        modifiers: modifiers ?? this.modifiers);
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is CategorizedLeveledTrait &&
            this.template == other.template &&
            this.level == other.level &&
            this.specialization == other.specialization &&
            listsEqual(this.modifiers, other.modifiers));
  }

  @override
  int get hashCode => hash4(template, specialization, modifiers, level);
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
/// The [TemplateTrait] that represents an Innate Attack instance.
///
/// The cost of an [InnateAttack] depends on the type of damage and the number
/// of Dice of damage (including partial dice).
///
class InnateAttack extends TemplateTrait {
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
      {TraitTemplate template, this.dice, this.type, List<Modifier> modifiers})
      : super(template: template, modifiers: modifiers);

  @override
  Trait copyWith({List<Modifier> modifiers, DieRoll dice}) {
    return InnateAttack(
        template: this.template,
        dice: dice ?? this.dice,
        type: this.type,
        modifiers: modifiers ?? this.modifiers);
  }

  ///
  /// Return the description of the [TemplateTrait] as used in a statistics block. For
  /// [InnateAttack] it consists of the Damage Type plus 'Attack' plus DieRoll.
  ///
  // @override
  // get description => '${StringEx.toTitleCase(enumToString(type))} Attack $dice';

  String get nameAndLevel =>
      '${StringEx.toTitleCase(enumToString(type))} Attack $dice';

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

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is InnateAttack &&
            this.template == other.template &&
            this.dice == other.dice &&
            this.specialization == other.specialization &&
            listsEqual(this.modifiers, other.modifiers));
  }

  @override
  int get hashCode => hash4(template, specialization, modifiers, dice);

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

  static TemplateTrait buildTrait(TraitComponents components) {
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
