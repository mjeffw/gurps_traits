enum _Type { simple, leveled }

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

class LeveledTrait extends Trait {
  int level = 1;

  get cost => template.cost * level;

  get description => '$reference $level';

  String parentheticalNotes;

  LeveledTrait(
      {String description,
      this.level,
      _Template template,
      this.parentheticalNotes})
      : super(template: template, description: description);

  static int _tryParseLevelFromText(String pattern, String text) {
    if (pattern == null) return 1;

    RegExpMatch match = RegExp(pattern).allMatches(text).first;
    if (match.groupNames.contains('level')) {
      return int.tryParse(match.namedGroup('level'));
    }
    return 1;
  }

  static String _tryParseNotesFromText(String pattern, String traitText) {
    if (pattern == null) return null;

    RegExpMatch match = RegExp(pattern).allMatches(traitText).first;
    if (match.groupNames.contains('note')) {
      return match.namedGroup('note');
    }
    return null;
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
      String alternateName = _findMatchingAlternateName(traitText);

      return LeveledTrait(
          template: this,
          level: LeveledTrait._tryParseLevelFromText(alternateName, traitText),
          parentheticalNotes:
              LeveledTrait._tryParseNotesFromText(alternateName, traitText));
    }
    return Trait(template: this, description: traitText);
  }

  bool isMatch(String text) {
    if (text == reference) return true;

    return _findMatchingAlternateName(text) != null;
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
    )
  ];
}
