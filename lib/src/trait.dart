enum _Type { simple, leveled }

typedef String AliasParser(String name, String text);
typedef int LevelParser(String name, String text);

LevelParser defaultLevelParser = (n, t) => int.tryParse(t);
AliasParser defaultAliasParser = (n, t) => n;

class Alias {
  final String name;
  final int cost;
  Alias({this.name, this.cost});
}

///
/// A [_TraitTemplate] is the template for a specific instance of a Trait as
/// applied to a character, ability, or power.
///
class _TraitTemplate {
  ///
  /// A TraitTemplate has a reference name -- the name by which it are listed
  /// in the Basic Character book's Trait list (p.B297).
  ///
  final String reference;

  ///
  /// A TraitTemplate may also have a number of aliases that are used in
  /// describing an ability or power that differs from the reference name.
  ///
  /// E.g., 'Protected Sense' is the reference name, but a specific instance of
  /// this trait will use the name of the sense that is being protected, such
  /// as 'Protected Vision'.
  ///
  /// 'Protected Vison', 'Protected Hearing', and 'Protected Taste/Smell' all
  /// map to 'Protected Sense', for example.
  ///
  /// Sometimes, the cost of the advantage varies by alias.
  ///
  final List<Alias> aliases;

  ///
  /// Many traits have a flat cost.
  ///
  final int cost;

  final _Type type;

  final AliasParser _nameParser;

  final LevelParser _levelParser;

  _TraitTemplate(
      {this.reference,
      this.cost,
      List<Alias> aliases,
      this.type = _Type.simple,
      AliasParser aliasParser,
      LevelParser levelParser})
      : aliases = aliases ?? [Alias(name: reference)],
        _nameParser = aliasParser ?? defaultAliasParser,
        _levelParser = levelParser ?? defaultLevelParser;

  Trait createTrait({String name, String text}) {
    switch (this.type) {
      case _Type.simple:
        return Trait(template: this, text: name);
      case _Type.leveled:
        return LeveledTrait(
            template: this,
            name: _nameParser.call(name, text),
            level: _levelParser.call(name, text));
    }
    return null;
  }
}

class Trait {
  final _TraitTemplate _template;
  final String text;

  Trait({_TraitTemplate template, this.text})
      : assert(template != null),
        _template = template;

  int get cost => templateCost();

  String get name => _template.reference;

  int templateCost() {
    var alias = _template.aliases.firstWhere((it) => text.startsWith(it.name));
    return alias.cost ?? _template.cost;
  }

  int get level => null;

  String get reference => _template.reference;
}

class LeveledTrait extends Trait {
  final int level;

  LeveledTrait({_TraitTemplate template, String name, this.level})
      : assert(level != null),
        super(template: template, text: name);

  int get cost => level * templateCost();
}

///
/// For any whitespace separated list of words, the string that contains all
/// but the last word.
///
String dropLastWord(String t) => t.substring(0, t.lastIndexOf(' ')).trim();

///
/// Get the last word from the phrase and try to parse it as an integer
///
LevelParser createLevelParser = (n, t) => int.tryParse(t.split(' ').last);

LevelParser innateLevelParser = (n, t) {
  if (t.trim().isEmpty) return 1;
  // assume t is of the form 'Nd' where N is a number
  return int.tryParse(t.replaceAll('d', ''));
};

AliasParser createAliasParser = (n, t) => n + ' ' + dropLastWord(t);
AliasParser concatAliasParser = (n, t) => n + ' ' + t;
AliasParser innateAliasParser =
    (n, t) => '$n ${t.trim().isEmpty ? "1d" : t.trim()}';

class Traits {
  static Trait parse(String phrase) {
    var words = phrase.split(' ');

    for (var i = 0; i < words.length; i++) {
      var test = List<String>.generate(i + 1, (index) => words[index])
          .reduce((a, b) => a + ' ' + b);

      _TraitTemplate template = match(test);
      if (template != null) {
        String remaining = phrase.replaceFirst(test, '').trim();
        return template.createTrait(name: test, text: remaining);
      }
    }
    return null;
  }

  static _TraitTemplate match(String phrase) {
    var template =
        _traits.firstWhere((it) => it.reference == phrase, orElse: () => null);

    if (template == null) {
      template = _traits.firstWhere(
          (it) => it.aliases.map((a) => a.name).contains(phrase),
          orElse: () => null);
    }
    return template;
  }

  static List<_TraitTemplate> _traits = [
    _TraitTemplate(reference: 'Affliction', cost: 10, type: _Type.leveled),
    _TraitTemplate(
        reference: 'Create',
        cost: 20,
        type: _Type.leveled,
        aliasParser: createAliasParser,
        levelParser: createLevelParser),
    _TraitTemplate(reference: 'Dark Vision', cost: 25),
    _TraitTemplate(
        reference: 'Innate Attack',
        cost: 5,
        aliases: [
          Alias(name: 'Burning Attack'),
          Alias(name: 'Corrosion Attack', cost: 10),
          Alias(name: 'Crushing Attack'),
          Alias(name: 'Cutting Attack', cost: 7),
          Alias(name: 'Fatigue Attack', cost: 10),
          Alias(name: 'Piercing Attack'),
        ],
        aliasParser: innateAliasParser,
        levelParser: innateLevelParser,
        type: _Type.leveled),
    _TraitTemplate(reference: 'Obscure', cost: 2, type: _Type.leveled),
    _TraitTemplate(reference: 'Protected Sense', cost: 5, aliases: [
      Alias(name: 'Protected Vision'),
      Alias(name: 'Protected Hearing'),
      Alias(name: 'Protected Taste/Smell')
    ]),
    _TraitTemplate(
        reference: 'Telescopic Vision', cost: 5, type: _Type.leveled),
  ];
}
