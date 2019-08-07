import 'dart:io';

import 'package:sorcery_parser/src/process.dart';

Future main(List<String> args) async {
  var files = [
    'Grimoire-Hagall.txt',
    'Grimoire-Sol.txt',
    'Grimoire-Tyr.txt',
    'Grimoire-Yr.txt'
  ];

  List<String> contents = files
      .map((file) => File(file).readAsLinesSync())
      .expand((string) => string)
      .toList();

  ProcessTraitText().process(contents);
}
