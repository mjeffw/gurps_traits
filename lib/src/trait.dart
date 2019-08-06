import 'dart:convert';

import 'package:sorcery_parser/src/data/trait_data.dart';
import 'package:sorcery_parser/src/parser.dart';
import 'package:sorcery_parser/src/util/die_roll.dart';
import 'package:sorcery_parser/src/util/exceptions.dart';

// Some helper constants and declarations.

///
/// Enumeration of the types of [Trait]s handled by this code. The string
/// value of a [TemplateType] is used when externalizing the list of Traits.
///
enum TemplateType {
  simple,
  leveled,
  innateAttack,
  categorizedLeveled,
  categorized
}

// Helper functions.

///
/// Regrettable that we have to do this because this project is pure Dart.
/// Flutter has a collection utility package with this method.
///
bool _listEquals(List<dynamic> one, List<dynamic> other) {
  if (identical(one, other)) return true;
  if (one.runtimeType != other.runtimeType || one.length != other.length) {
    return false;
  }
  for (var i = 0; i < one.length; i++) {
    if (one[i] != other[i]) return false;
  }
  return true;
}

TemplateType convertToTemplateTypeEnum(String c) => (c == null)
    ? TemplateType.simple
    : TemplateType.values.firstWhere((e) => _unqualifiedStringValue(e) == c);

String _unqualifiedStringValue(TemplateType type) =>
    type.toString().split(r'.')[1];

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
  /// [TraitTemplate].
  ///
  TraitTemplate template;

  String _description;

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

  ///
  /// Any parenthetical notes for this [Trait].
  ///
  String specialization;

  Trait({this.template, String description, this.specialization})
      : this._description = description;
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

  LeveledTrait({TraitTemplate template, int level, String specialization})
      : assert(level != null && level > 0),
        _level = level,
        super(template: template, specialization: specialization);

  static String _tryParseSpecialization(String pattern, String traitText) {
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

  CategorizedTrait({TraitTemplate template, String item})
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

  CategorizedLeveledTrait({TraitTemplate template, int level, String item})
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

  InnateAttack({TraitTemplate template, this.dice, this.type})
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

  static _tryParseDiceFromText(String diceText) {
    var regExp = RegExp(DICE_PATTERN);
    if (diceText != null && regExp.hasMatch(diceText)) {
      return DieRoll.fromString(regExp.firstMatch(diceText).group(1),
          normalize: false);
    }

    regExp = RegExp(r'(\d+)');
    if (diceText != null && regExp.hasMatch(diceText)) {
      var tryParse = int.tryParse(regExp.firstMatch(diceText).group(1));
      return DieRoll(adds: tryParse, normalize: false);
    }

    return DieRoll(dice: 1);
  }
}

///
/// Each instance of a [Trait] of a particular type has a single template,
/// which defines its cost and its reference name.
///
class TraitTemplate {
  ///
  /// A [TraitTemplate] has a reference name -- the name by which it are listed
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
  final TemplateType type;

  final isSpecialized;

  TraitTemplate(
      {this.reference,
      this.cost,
      List<String> alternateNames,
      TemplateType type = TemplateType.simple,
      bool isSpecialized = false})
      : type = type,
        alternateNames = alternateNames ?? [],
        isSpecialized = isSpecialized ?? false;

  ///
  /// Create the appropriate [Trait] based on the the text.
  ///
  Trait parse(TraitComponents components) {
    String specialization = components.specialties;
    if (isSpecialized) {
      if (components.specialties == null) {
        // see if there are any alternate name formats with specialization
        String pattern = _findMatchingAlternateName(components.name);
        if (pattern != null) {
          RegExp r = RegExp(pattern);
          RegExpMatch match = r.firstMatch(components.name);
          if (match.groupNames.contains('spec')) {
            specialization = match.namedGroup('spec');
          }
        }
      }
    }
    if (type == TemplateType.leveled) {
      return LeveledTrait(
          template: this,
          level: components.level ?? 1,
          specialization: specialization);
    } else if (type == TemplateType.innateAttack) {
      return InnateAttack(
          template: this,
          type: InnateAttack._tryParseTypeFromText(components.name),
          dice: InnateAttack._tryParseDiceFromText(components.damage));
    }
    return Trait(
        template: this,
        description: components.name,
        specialization: specialization);
  }

  ///
  /// Return [true] if the text matches either the reference name or any of the alternate
  /// regular expressions.
  ///
  bool _isMatch(String text) =>
      (text == reference) ? true : _findMatchingAlternateName(text) != null;

  ///
  /// For the given text, return the first alternate name regexp that matches.
  /// If none match, return null.
  ///
  String _findMatchingAlternateName(String text) => alternateNames
      ?.firstWhere((it) => RegExp(it).hasMatch(text), orElse: () => null);

  static TraitTemplate buildTemplate(Map<String, dynamic> json) {
    return TraitTemplate(
        reference: json['reference'],
        cost: json['cost'],
        type: convertToTemplateTypeEnum(json['type']),
        isSpecialized: json['isSpecialized'],
        alternateNames: json['alternateNames'] == null
            ? null
            : (json['alternateNames'] as List<dynamic>)
                .map((it) => it.toString())
                .toList());
  }
}

class Category {
  final String name;
  final int cost;
  final List<String> items;

  Category({this.name, this.cost, this.items});

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    return other is Category &&
        this.name == other.name &&
        this.cost == other.cost &&
        _listEquals(this.items, other.items);
  }

  @override
  int get hashCode => name.hashCode ^ cost.hashCode ^ items.hashCode;

  factory Category.fromJSON(Map<String, dynamic> json) {
    List<String> items =
        (json['items'] as List<dynamic>).map((it) => it.toString()).toList();

    return Category(name: json['name'], cost: json['cost'], items: items);
  }

  static List<Category> listFromJSON(List<dynamic> list) {
    var x = list.map((it) => Category.fromJSON(it)).toList();
    return x;
  }
}

class CategorizedTemplate extends TraitTemplate {
  final List<Category> categories;

  CategorizedTemplate(
      {String reference,
      TemplateType type,
      List<String> alternateNames,
      this.categories})
      : super(
            reference: reference,
            alternateNames: alternateNames,
            type: type,
            isSpecialized: true);

  @override
  Trait parse(TraitComponents components) {
    String pattern = _findMatchingAlternateName(components.name);

    String category;
    if (components.specialties == null) {
      if (pattern != null) {
        category =
            LeveledTrait._tryParseSpecialization(pattern, components.name);
      }
    } else {
      category = components.specialties;
    }

    if (type == TemplateType.categorizedLeveled) {
      return CategorizedLeveledTrait(
          template: this,
          level: components.level == null ? 1 : components.level,
          item: category);
    }

    // ...else default to CategorizedTrait
    return CategorizedTrait(template: this, item: category);
  }

  static CategorizedTemplate buildTemplate(Map<String, dynamic> json) {
    List<Category> categories = Category.listFromJSON(json['categories']);

    return CategorizedTemplate(
        reference: json['reference'],
        type: convertToTemplateTypeEnum(json['type']),
        categories: categories,
        alternateNames: json['alternateNames'] == null
            ? null
            : (json['alternateNames'] as List<dynamic>)
                .map((it) => it.toString())
                .toList());
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
        .firstWhere((it) => it._isMatch(components.name), orElse: () => null);

    return template?.parse(components);
  }

  static List<TraitTemplate> _templates = [];
}
