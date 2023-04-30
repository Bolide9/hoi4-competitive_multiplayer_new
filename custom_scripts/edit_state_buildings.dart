/// Need run after script script edit_state_owner

import 'dart:io';

import 'constants.dart';

final _bunker = RegExp(r'\s*bunker\s*');
final _dockyard = RegExp(r'\s*dockyard\s*');
final _naval_base = RegExp(r'\s*naval_base\s*');
final _coastal_bunker = RegExp(r'\s*coastal_bunker\s*');
final _arms_factory = RegExp(r'\s*arms_factory\s*=\s*\w*');
final _industrial_complex = RegExp(r'\s*industrial_complex\s*=\s*\w*');

Future<void> main() async {
  final statesDir = Directory(pathToStates);
  final files = statesDir.listSync(recursive: true);

  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      bool isEdited = false;

      final lines = file.readAsLinesSync();
      final currentId = int.tryParse(lines.firstWhere((e) => RegExp(r'\s*id\s*=\s*\d*\s*', caseSensitive: false).hasMatch(e), orElse: () => '-1').trim().replaceAll(RegExp(r'\D'), ''));

      if (germanyOwnerStateIds.contains(currentId) || sovietOwnerStateIds.contains(currentId)) {
        print('Current file ${file.path}\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];

          /// Removing navals and dockyard for Germany (20+), because they have more then Soviet (7) on version game 1.12.*
          if (germanyNavalsForRemove.contains(currentId) && (_naval_base.hasMatch(line) || _dockyard.hasMatch(line))) {
            lines
              ..removeAt(i)
              ..insert(i, '');

            isEdited = true;
          }

          // Removing all bunkers
          if (_coastal_bunker.hasMatch(line) || _bunker.hasMatch(line)) {
            lines
              ..removeAt(i)
              ..insert(i, '');

            isEdited = true;
          }
        }

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          final excludeLine = lines.firstWhere((e) => _naval_base.hasMatch(e) || _dockyard.hasMatch(e), orElse: () => '').isNotEmpty;

          if (RegExp(r'\s*\d+\s*=\s*').hasMatch(line) && !germanyNavalsForRemove.contains(currentId) && !excludeLine) {
            lines
              ..removeAt(i)
              ..insert(i, '');

            final endIndex = lines.indexOf(lines.sublist(i).firstWhere((e) => RegExp(r'\s*}\s*').hasMatch(e)));

            if (endIndex != -1) {
              lines
                ..removeAt(endIndex)
                ..insert(endIndex, '');

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

  await Future.wait(
    [
      _countConstruction(
        owner: 'GER',
        files: files,
        stateIds: germanyOwnerStateIds,
        constructionRegexp: _industrial_complex,
      ),
      _countConstruction(
        owner: 'GER',
        files: files,
        stateIds: germanyOwnerStateIds,
        constructionRegexp: _arms_factory,
      ),
    ],
  );

  await Future.wait(
    [
      _countConstruction(
        owner: 'SOV',
        files: files,
        stateIds: sovietOwnerStateIds,
        constructionRegexp: _industrial_complex,
      ),
      _countConstruction(
        owner: 'SOV',
        files: files,
        stateIds: sovietOwnerStateIds,
        constructionRegexp: _arms_factory,
      ),
    ],
  );

  _modifyState(
    files: files,
    stateIds: sovietOwnerStateIds,
  );

  _modifyState(
    files: files,
    stateIds: germanyOwnerStateIds,
  );

  await Future.wait(
    [
      _countConstruction(
        owner: 'GER',
        files: files,
        stateIds: germanyOwnerStateIds,
        constructionRegexp: _industrial_complex,
      ),
      _countConstruction(
        owner: 'GER',
        files: files,
        stateIds: germanyOwnerStateIds,
        constructionRegexp: _arms_factory,
      ),
    ],
  );

  await Future.wait(
    [
      _countConstruction(
        owner: 'SOV',
        files: files,
        stateIds: sovietOwnerStateIds,
        constructionRegexp: _industrial_complex,
      ),
      _countConstruction(
        owner: 'SOV',
        files: files,
        stateIds: sovietOwnerStateIds,
        constructionRegexp: _arms_factory,
      ),
    ],
  );
}

/// Version game 1.12.*
/// Germany have 176 factories and 97 arms
/// Soviet have 49 factories and 31 arms
/// If function returns different values, u need go to nudge and change factories there
Future<int> _countConstruction({
  required String owner,
  required List<int> stateIds,
  required RegExp constructionRegexp,
  required List<FileSystemEntity> files,
}) async {
  int constructionCount = 0;

  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      final lines = file.readAsLinesSync();
      final currentId = int.tryParse(lines.firstWhere((e) => RegExp(r'\s*id\s*=\s*\d*\s*', caseSensitive: false).hasMatch(e), orElse: () => '-1').trim().replaceAll(RegExp(r'\D'), ''));

      if (stateIds.contains(currentId)) {
        for (var line in lines) {
          if (constructionRegexp.hasMatch(line)) {
            final lineToDelete = line.replaceAll(constructionRegexp, '');
            final count = int.tryParse(line.replaceAll(lineToDelete, '').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            constructionCount += count;
          }
        }
      }
    }
  }

  print('Current $owner has ${constructionRegexp.pattern}: $constructionCount\n');

  return constructionCount;
}

int _findEndIndex(List<String> contents, int startIndex) {
  int depth = 0;

  for (int i = startIndex; i < contents.length; i++) {
    if (RegExp(r'\s*\w*\s*=\s*{').hasMatch(contents[i])) {
      depth++;
    } else if (RegExp(r'\s*}\s*').hasMatch(contents[i])) {
      depth--;
      if (depth == 0) {
        return i + 1;
      }
    }
  }

  return -1;
}

Future<void> _modifyState({
  required List<int> stateIds,
  required List<FileSystemEntity> files,
}) async {
  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      final lines = file.readAsLinesSync();
      final currentId = int.tryParse(lines.firstWhere((e) => RegExp(r'\s*id\s*=\s*\d*\s*', caseSensitive: false).hasMatch(e), orElse: () => '-1').trim().replaceAll(RegExp(r'\D'), ''));

      if (stateIds.contains(currentId)) {
        // Find the start and end index of the "buildings" block
        final buildingsLine = lines.firstWhere((e) => RegExp(r'\s*buildings\s*=\s*{\s*').hasMatch(e), orElse: () => '-1');
        final startIndex = lines.indexOf(buildingsLine);

        if (startIndex != -1) {
          final endIndex = _findEndIndex(lines, startIndex);

          if (endIndex != -1) {
            final armsFactoryLine = lines.firstWhere((e) => _arms_factory.hasMatch(e), orElse: () => '-1');
            final armsFactoryLineIndex = lines.indexOf(armsFactoryLine) != -1 ? lines.indexOf(armsFactoryLine) : startIndex + 1;

            final industrialComplexLine = lines.firstWhere((e) => _industrial_complex.hasMatch(e), orElse: () => '-1');
            final industrialComplexLineIndex = lines.indexOf(industrialComplexLine) != -1 ? lines.indexOf(industrialComplexLine) : startIndex + 1;

            final infrastructureFactoryLine = lines.firstWhere((e) => RegExp(r'\s*infrastructure\s*=\s*').hasMatch(e), orElse: () => '-1');
            final infrastructureFactoryLineIndex = lines.indexOf(infrastructureFactoryLine) != -1 ? lines.indexOf(infrastructureFactoryLine) : startIndex + 1;

            if (lines.indexOf(armsFactoryLine) != -1) {
              lines..removeAt(lines.indexOf(armsFactoryLine));
            }

            lines
              ..insert(
                armsFactoryLineIndex,
                '\t\t\tarms_factory = 1',
              );

            if (lines.indexOf(industrialComplexLine) != -1) {
              lines..removeAt(lines.indexOf(industrialComplexLine));
            }

            lines
              ..insert(
                industrialComplexLineIndex,
                '\t\t\tindustrial_complex = 1',
              );

            if (lines.indexOf(infrastructureFactoryLine) != -1) {
              lines..removeAt(lines.indexOf(infrastructureFactoryLine));
            }

            lines
              ..insert(
                infrastructureFactoryLineIndex,
                '\t\t\tinfrastructure = 2',
              );
          }
        }

        final raf = file.openSync(mode: FileMode.write);
        raf
          ..writeStringSync(lines.join('\n'))
          ..closeSync();
      }
    }
  }
}
