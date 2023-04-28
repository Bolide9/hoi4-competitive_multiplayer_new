import 'dart:io';

import 'constants.dart';

final dockyard = RegExp(r'\s*dockyard\s*');
final naval_base = RegExp(r'\s*naval_base\s*');
final arms_factory = RegExp(r'\s*arms_factory\s*');
final coastal_bunker = RegExp(r'\s*coastal_bunker\s*');
final industrial_complex = RegExp(r'\s*industrial_complex\s*');

void main() async {
  final statesDir = Directory(pathToStates);
  final files = statesDir.listSync(recursive: true);

  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      bool isEdited = false;

      print('Current file ${file.path}\n');

      final lines = file.readAsLinesSync();
      final currentId = int.tryParse(lines.firstWhere((e) => RegExp(r'\s*id\s*=\s*\d*\s*', caseSensitive: false).hasMatch(e), orElse: () => '-1').trim().replaceAll(RegExp(r'\D'), ''));

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];

        /// Removing navals and dockyard for Germany (20+), because they have more then Soviet (7) on version game 1.12.*
        if (germanyNavalsForRemove.contains(currentId) && (naval_base.hasMatch(line) || dockyard.hasMatch(line))) {
          lines
            ..removeAt(i)
            ..insert(i, '');

          isEdited = true;
        }

        // Removing all bunkers
        if (coastal_bunker.hasMatch(line)) {
          lines
            ..removeAt(i)
            ..insert(i, '');

          isEdited = true;
        }

        /// reduce arms and factories for Germany because they have 176 factories and 97 arms on version game 1.12.*
        /// Soviet have 49 factories and 31 arms
        if (industrial_complex.hasMatch(line)) {
          int? count = int.tryParse(line.replaceAll(RegExp(r'[^0-9]'), ''));

          if (count != null && count > 1) {
            count -= 1;
            lines
              ..removeAt(i)
              ..insert(i, '\t\tindustrial_complex = $count');
            isEdited = true;
          }
        } else if (arms_factory.hasMatch(line)) {
          int? count = int.tryParse(line.replaceAll(RegExp(r'[^0-9]'), ''));

          if (count != null && count > 1) {
            count -= 1;
            lines
              ..removeAt(i)
              ..insert(i, '\t\tarms_factory = $count');
            isEdited = true;
          }
        }
      }

      if (isEdited) {
        final raf = file.openSync(mode: FileMode.write);
        raf
          ..writeStringSync(lines.join('\n'))
          ..closeSync();
      }
    }
  }
}
