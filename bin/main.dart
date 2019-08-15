import 'dart:io';

import '../example/process.dart';

Future main(List<String> args) async {
  var files = [
    'Grimoire-Ur.txt',
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
