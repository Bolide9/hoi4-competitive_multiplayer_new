import 'dart:io';

import 'constants.dart';

void main() async {
  final statesDir = Directory(pathToStates);
  final files = statesDir.listSync(recursive: true);

  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      final indexesForRemove = <int>[];
      final lines = file.readAsLinesSync();

      print('Current file ${file.path}\n');

      for (var i = 0; i < lines.length; i++) {
        if (lines[i].isEmpty) {
          indexesForRemove.add(i);
        }
      }

      for (var index in indexesForRemove) {
        lines.removeAt(index);
      }

      final raf = file.openSync(mode: FileMode.write);
      raf
        ..writeStringSync(lines.join('\n'))
        ..closeSync();
    }
  }
}
