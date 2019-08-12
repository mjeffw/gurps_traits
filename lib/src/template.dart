// Some helper constants and declarations.

import '../gurps_traits.dart';
import 'util/util.dart';

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

TemplateType convertToTemplateTypeEnum(String c) => (c == null)
    ? TemplateType.simple
    : TemplateType.values.firstWhere((e) => _unqualifiedStringValue(e) == c);

String _unqualifiedStringValue(TemplateType type) =>
    type.toString().split(r'.')[1];

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

  const TraitTemplate(
      {this.reference,
      this.cost,
      List<String> alternateNames,
      TemplateType type = TemplateType.simple,
      bool isSpecialized = false})
      : type = type,
        alternateNames = alternateNames ?? const [],
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
          type: InnateAttack.tryParseTypeFromText(components.name),
          dice: InnateAttack.tryParseDiceFromText(components.damage));
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
  bool isMatch(String text) =>
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
        listEquals(this.items, other.items);
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
            LeveledTrait.tryParseSpecialization(pattern, components.name);
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
