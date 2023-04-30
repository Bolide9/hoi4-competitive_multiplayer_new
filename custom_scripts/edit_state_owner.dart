/// Removing set_demilitarized_zone's for [sovietOwnerStateIds] and [germanyOwnerStateIds]
/// removing controller, add_core_of and change owner's
/// and removind delay actions example: 1939.1.1 { air_base = 1 }

import 'dart:io';

import 'constants.dart';

const _sovietOwner = '\t\towner = SOV';
const _germanyOwner = '\t\towner = GER';

final _ownerRegexp = RegExp(r'\s*owner\s*=');

final _coreOfRegexp = RegExp(r'\s*add_core_of\s*=');

final _controllerRegexp = RegExp(r'\s*controller\s*=');

final _delayedOwnerRegexp = RegExp(r'\s*\d{1,4}\.\d{1,2}\.\d{1,2}\s*=');

Future<void> main() async {
  final statesDir = Directory(pathToStates);
  final files = statesDir.listSync(recursive: true);

  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      final lines = file.readAsLinesSync();

      print('Current file ${file.path}\n');

      await _changeStateOwner(
        file: file,
        lines: lines,
      );
    }
  }

  print('Germany owner states count: ${germanyOwnerStateIds.length}\nSoviet owner states count: ${sovietOwnerStateIds.length}');
}

Future<void> _changeStateOwner({
  required File file,
  required List<String> lines,
}) async {
  bool isEdited = false;

  final currentId = _getIdByLines(lines);
  final linesToRemove = <int>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (germanyOwnerStateIds.contains(currentId) || sovietOwnerStateIds.contains(currentId)) {
      if (_ownerRegexp.hasMatch(line)) {
        final currentOwner = line.replaceAll(_ownerRegexp, '').trim();
        final newOwner = germanyOwnerStateIds.contains(currentId) ? _germanyOwner : _sovietOwner;

        if (newOwner.replaceAll(_ownerRegexp, '').trim() != currentOwner) {
          lines
            ..removeAt(i)
            ..insert(i, newOwner);

          isEdited = true;
        }
      }

      if (_coreOfRegexp.hasMatch(line) || _controllerRegexp.hasMatch(line)) {
        lines
          ..removeAt(i)
          ..insert(i, '');
        isEdited = true;
      }

      if (_delayedOwnerRegexp.hasMatch(line)) {
        final startIndex = i;
        final endIndex = _calculateDelayeds(lines, i);
        if (endIndex != null) {
          for (var j = startIndex; j < endIndex; j++) {
            linesToRemove.add(j);
          }

          isEdited = true;
        }
      }
    } else {
      if (_coreOfRegexp.hasMatch(line) || _controllerRegexp.hasMatch(line) || _ownerRegexp.hasMatch(line)) {
        lines
          ..removeAt(i)
          ..insert(i, '');
        isEdited = true;
      }
    }
  }

  final newLines = <String>[];
  for (var i = 0; i < lines.length; i++) {
    if (!linesToRemove.contains(i)) {
      newLines.add(lines[i]);
    }
  }

  // Removing demilitarized zone
  newLines.removeWhere((line) => RegExp(r'\s*set_demilitarized_zone\s*').hasMatch(line));

  if (isEdited) {
    final raf = file.openSync(mode: FileMode.write);
    raf
      ..writeStringSync(newLines.join('\n'))
      ..closeSync();
  }
}

int? _getIdByLines(List<String> lines) =>
    int.tryParse(lines.firstWhere((e) => RegExp(r'\s*id\s*=\s*\d*\s*', caseSensitive: false).hasMatch(e), orElse: () => '-1').trim().replaceAll(RegExp(r'\D'), ''));

int? _calculateDelayeds(
  List<String> lines,
  int i,
) {
  int c = 0;

  for (var j = i + 1; j < lines.length; j++) {
    final line2 = lines[j].trim();

    if (RegExp(r'\s*\w*\s*=\s*{').hasMatch(line2)) {
      c += 1;
    } else if (RegExp(r'\s*}\s*').hasMatch(line2)) {
      if (c >= 1) {
        c -= 1;
      } else {
        return j + 1;
      }
    }
  }

  return null;
}
