import 'package:dart_utils/dart_util.dart';
import 'package:gurps_dice/gurps_dice.dart';

import 'util/exceptions.dart';

///
/// [ModifierComponents] represent the various components of a modifier, as
/// found in the parenthetical notes portion of the trait text.
///
/// Modifiers formally fit the format "<name>, (<details>,) <sign><value>%",
/// <name> is the name of the modifier, (<details>,) is an optional list of
/// notes for this modifier, and <sign><value>% is the integer value of the
/// modifier, in percentile form.
///
class ModifierComponents {
  static final regExpModifier =
      RegExp('^(?<name>.+),\\s+(?<sign>$R_SIGN)(?<value>$R_DIGITS)%\$');

  static ModifierComponents parse(String input) {
    if (regExpModifier.hasMatch(input)) {
      RegExpMatch match = regExpModifier.firstMatch(input);
      return ModifierComponents(
        name: _name(match.namedGroup('name')),
        value: _value(match.namedGroup('sign'), match.namedGroup('value')),
        detail: _detail(match.namedGroup('name')),
      );
    } else {
      throw ModifierFormatException(input);
    }
  }

  static bool hasMatch(String s) =>
      ModifierComponents.regExpModifier.hasMatch(s);

  ///
  /// Name is the first comma-separated component of the text.
  ///
  static String _name(String match) => match.split(',')[0];

  ///
  /// Detail is the remaining comma-separated components of the text after the
  /// first, not including the percentile value.
  ///
  static _detail(String match) =>
      match.replaceFirst('${_name(match)}, ', '').trim();

  ///
  /// Value is the final component of the text, and is composed of a sign
  /// character ('+' or '-'), and an integer.
  ///
  static _value(String sign, String value) =>
      (sign == '-' ? -1 : 1) * int.tryParse(value);
  String name;
  String detail;
  int value;

  ModifierComponents({this.name, this.value, this.detail});
}

///
/// [TraitComponents] represent the various components of a trait.
///
/// Traits formally fit the format "Name {Level} (parenthetical-notes)
/// [<Point-Cost>]".
///
/// * Name is the name of the trait.
/// * {Level} is an optional level value (for traits that are leveled).
/// * (<parenthetical-notes>) is an optional list of skill specialties, named
///   varieties or degrees of advantages or disadvantages, lists of enhance-
///   ments and limitations, and so on.
/// * Point-Cost the character point cost of the trait, including any
///   modifiers.
///
class TraitComponents {
  ///
  /// The raw text input to the parser.
  ///
  String rawText;

  ///
  /// Name of the trait.
  ///
  String name;

  ///
  /// Cost of the trait.
  ///
  double cost;

  ///
  /// Level of the trait, if it is leveled. Otherwise, null.
  ///
  int level;

  ///
  /// Any parenthetical notes, or null.
  ///
  String parentheticalNotes;

  ///
  /// Damage value, or null, for traits that need damage.
  ///
  /// Damage is of the format '3d-1' (dice + adds) or 'X point(s)'.
  ///
  String damage;

  TraitComponents(
      {this.name,
      this.cost,
      this.level,
      this.rawText,
      this.parentheticalNotes,
      this.damage});

  ///
  /// Parenthetical notes are separated by semi-colons.
  ///
  List<String> get notes => StringEx.splitNullSafe(parentheticalNotes, ';')
      .map((s) => s.trim())
      .toList();

  ///
  /// Parse out any modifiers from the parenthetical notes.
  ///
  List<String> get modifiers =>
      notes.where((s) => ModifierComponents.hasMatch(s)).toList();

  ///
  /// Trait specialties, named varieties or degrees of advantages or disad-
  /// vantages. This should be the first note as long as it is not a modifier.
  ///
  get specialties {
    if (parentheticalNotes != null) {
      var note = notes[0];
      if (!modifiers.contains(note)) {
        return note;
      }
    }
    return null;
  }
}

// == Regular Expression patterns for parsing ==

const _TRAITONLY = r'(?<name>.+)'; // any
const _TRAIT = r'(?<name>.+?)'; // any
const _NOTES = r'\s+\((?<notes>.*)\)'; // space + ( + any  + )
const _COST =
    r'(?:\s+\[(?<cost>\d+(?:\.\d{0,2})?)(?:/level)?\])'; // space + [ + digits + ]

const String _LEVEL = '(?<level>$R_DIGITS)';
const String DICE_PATTERN = '(?<dieroll>$dieRollPattern)';
// '(?<dice>${R_DIGITS}d($R_NUMBER)?)';
const String POINTS_PATTERN = '(?:(?<points>$R_DIGITS)\\s+point(?:s)?)';

///
/// A factory that consumes a String and returns an instance of TraitComponents.
///
class Parser {
  static String namePattern = '^$_TRAITONLY';
  static String nameCostPattern = '^$_TRAIT$_COST';
  static String nameNotesPattern = '^$_TRAIT$_NOTES';
  static String nameNotesCostPattern = '^$_TRAIT$_NOTES$_COST';

  static RegExp regExpLevel =
      RegExp('^$_TRAIT(?:\\s+$_LEVEL|$DICE_PATTERN|$POINTS_PATTERN)\$');

  ///
  /// Ordered list of regular expressions to try matching against input.
  ///
  List<RegExp> regExps = [
    RegExp(nameNotesCostPattern),
    RegExp(nameNotesPattern),
    RegExp(nameCostPattern),
    RegExp(namePattern),
  ];

  ///
  /// Given some text, parse and return the Trait components.
  ///
  TraitComponents parse(String text) {
    RegExpMatch match = firstMatch(regExps, _cleanInput(text));

    var components = TraitComponents(
        rawText: match.group(0),
        name: match.namedGroup('name').trim(),
        cost: _matchHasNamedGroup(match)
            ? double.tryParse(match.namedGroup('cost'))
            : null,
        parentheticalNotes: match.groupNames.contains('notes')
            ? match.namedGroup('notes').replaceAll('−', '-')
            : null);

    _updateForLevelsOrDamage(components);

    return components;
  }

  ///
  /// Return the first match from the ordered list of regular expressions [regExps].
  ///
  /// Throw TraitParseException if no match is found.
  ///
  RegExpMatch firstMatch(List<RegExp> regExps, String source) => regExps
      .firstWhere((regExp) => regExp.hasMatch(source),
          orElse: () => throw TraitFormatException(source))
      .firstMatch(source);

  ///
  /// Return ```true``` if the match contains a non-null value for cost.
  ///
  bool _matchHasNamedGroup(RegExpMatch match) =>
      RegExpEx.hasNamedGroup(match, 'cost') && match.namedGroup('cost') != null;

  ///
  /// Sanitize input for processing. This includes replacing the minus symbol with a dash.
  ///
  String _cleanInput(String input) => input.trim().replaceAll('—', '-');

  ///
  /// The name portion of the trait may contain text that describes the level,
  /// or dice or points of damage for Traits like Innate Attack.
  ///
  void _updateForLevelsOrDamage(TraitComponents components) {
    if (regExpLevel.hasMatch(components.name)) {
      RegExpMatch match = regExpLevel.firstMatch(components.name);

      if (RegExpEx.hasNamedGroup(match, 'level')) {
        components.level = int.tryParse(match.namedGroup('level'));
      } else if (RegExpEx.hasNamedGroup(match, 'dieroll')) {
        components.damage = match.namedGroup('dieroll');
      } else if (RegExpEx.hasNamedGroup(match, 'points')) {
        components.damage = match.namedGroup('points');
      }
      components.name = match.namedGroup('name');
    }
  }
}
