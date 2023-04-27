import 'dart:io';

import 'constants.dart';

const sovietOwner = '\t\towner = SOV';
const germanyOwner = '\t\towner = GER';

const sovietCore = '\t\tadd_core_of = SOV';
const germanyCore = '\t\tadd_core_of = GER';

final ownerRegexp = RegExp(r'\s*owner\s*=');

final coreOfRegexp = RegExp(r'\s*add_core_of\s*=');

final controllerRegexp = RegExp(r'\s*controller\s*=');

final gerOwnerRegexp = RegExp(r'\s*owner\s*=\s*GER\s*');

final sovOwnerRegexp = RegExp(r'\s*owner\s*=\s*SOV\s*');

void main() async {
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
}

Future<void> _changeStateOwner({
  required File file,
  required List<String> lines,
}) async {
  final currentId = _getIdByLines(lines);

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    if (germanyOwnerStateIds.contains(currentId) || sovietOwnerStateIds.contains(currentId)) {
      if (ownerRegexp.hasMatch(line)) {
        lines
          ..removeAt(i)
          ..insert(i, germanyOwnerStateIds.contains(currentId) ? germanyOwner : sovietOwner);
      }

      if (coreOfRegexp.hasMatch(line) || controllerRegexp.hasMatch(line)) {
        lines
          ..removeAt(i)
          ..insert(i, '');
      }
    } else {
      if (coreOfRegexp.hasMatch(line) || controllerRegexp.hasMatch(line) || ownerRegexp.hasMatch(line)) {
        lines
          ..removeAt(i)
          ..insert(i, '');
      }
    }
  }

  final raf = file.openSync(mode: FileMode.write);
  raf
    ..writeStringSync(lines.join('\n'))
    ..closeSync();
}

int? _getIdByLines(List<String> lines) =>
    int.tryParse(lines.firstWhere((e) => RegExp(r'\s*id\s*=\s*\d*\s*', caseSensitive: false).hasMatch(e), orElse: () => '-1').trim().replaceAll(RegExp(r'\D'), ''));

String _getOwnerByLines(List<String> lines) => lines.firstWhere((e) => e.contains('owner'), orElse: () => '').trim();

String _getCoreOfByLines(List<String> lines) => lines.firstWhere((e) => e.contains('add_core_of'), orElse: () => '').trim();
