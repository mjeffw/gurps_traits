// Some helper constants and declarations.

import 'package:dart_utils/dart_util.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/core.dart';

import '../gurps_traits.dart';

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
    type.toString().replaceFirst('TemplateType.', '');

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

  ///
  /// True, if this template requires specialization.
  ///
  final bool isSpecialized;

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
  Trait buildTraitFrom(TraitComponents components) {
    String specialization = components.specialties;
    if (isSpecialized && components.specialties == null) {
      // see if there are any alternate name formats with specialization
      String pattern = _findMatchingAlternateName(components.name);
      if (pattern != null) {
        RegExpMatch match = RegExp(pattern).firstMatch(components.name);
        if (match.groupNames.contains('spec')) {
          specialization = match.namedGroup('spec');
        }
      }
    }

    if (type == TemplateType.leveled) {
      return LeveledTrait(
          template: this,
          level: components.level ?? 1,
          specialization: specialization,
          modifiers: components.modifiers);
    } else if (type == TemplateType.innateAttack) {
      return InnateAttack(
          template: this,
          type: InnateAttack.tryParseTypeFromText(components.name),
          dice: InnateAttack.tryParseDiceFromText(components.damage),
          modifiers: components.modifiers);
    }
    return Trait(
        template: this,
        name: components.name,
        specialization: specialization,
        modifiers: components.modifiers);
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

  ///
  /// Create a [TraitTemplate] from the given JSON.
  ///
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

///
/// [Category] represents a named group of options or specialties. Each also
/// determines the cost of the Trait.
///
class Category {
  ///
  /// Name of the [Category].
  ///
  final String name;

  ///
  /// Cost of the [Trait] if its specialties match one of the items in this
  /// category.
  ///
  final int cost;

  ///
  /// The list of items that match this category.
  ///
  final List<String> items;

  Category({this.name, this.cost, this.items});

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    return other is Category &&
        this.name == other.name &&
        this.cost == other.cost &&
        listsEqual(this.items, other.items);
  }

  @override
  int get hashCode => hash3(name, cost, items);

  ///
  /// Create a [Category] from JSON data
  ///
  factory Category.fromJSON(Map<String, dynamic> json) => Category(
      name: json['name'],
      cost: json['cost'],
      items: JsonEx.toListOfStrings(json['items']));

  ///
  /// Create a list of [Category] from a JSON list.
  ///
  static List<Category> listFromJSON(List<dynamic> list) =>
      list.map((it) => Category.fromJSON(it)).toList();
}

///
/// A [TraitTemplate] that uses a list of [Category] to determine cost.
///
class CategorizedTemplate extends TraitTemplate {
  ///
  /// The list of [Category].
  ///
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
  Trait buildTraitFrom(TraitComponents components) {
    String category =
        _getCategory(components, _findMatchingAlternateName(components.name));

    return (type == TemplateType.categorizedLeveled)
        ? CategorizedLeveledTrait(
            template: this,
            level: components.level ?? 1,
            item: category,
            modifiers: components.modifiers)
        : CategorizedTrait(
            template: this, item: category, modifiers: components.modifiers);
  }

  String _getCategory(TraitComponents components, String pattern) {
    if (components.specialties == null) {
      if (pattern != null) {
        return LeveledTrait.tryParseSpecialization(pattern, components.name);
      }
    } else {
      return components.specialties;
    }
    return null;
  }

  static CategorizedTemplate buildTemplate(Map<String, dynamic> json) =>
      CategorizedTemplate(
          reference: json['reference'],
          type: convertToTemplateTypeEnum(json['type']),
          categories: Category.listFromJSON(json['categories']),
          alternateNames: json['alternateNames'] == null
              ? null
              : JsonEx.toListOfStrings(json['alternateNames']));
}
