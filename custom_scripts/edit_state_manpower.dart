import 'dart:io';

import 'constants.dart';

const newManPowerValue = '\tmanpower = 1500000';

final _manpowerRegexp = RegExp(r'\s*\s*manpower\s*=\s*');

Future<void> main() async {
  double germanyManPowersTotal = 0;
  double sovietManPowersTotal = 0;

  final statesDir = Directory(pathToStates);
  final files = statesDir.listSync(recursive: true);

  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      final lines = file.readAsLinesSync();
      final manpowerValue = lines.firstWhere((e) => _manpowerRegexp.hasMatch(e), orElse: () => '').trim();
      final manpowerValueLineIndex = lines.indexOf(lines.firstWhere((e) => _manpowerRegexp.hasMatch(e), orElse: () => ''));

      print('Current file ${file.path}\n');

      if (manpowerValueLineIndex != -1) {
        print('Current manpower $manpowerValue\n');

        lines
          ..removeAt(manpowerValueLineIndex)
          ..insert(manpowerValueLineIndex, newManPowerValue);

        print('Current manpower ${lines.firstWhere((e) => _manpowerRegexp.hasMatch(e), orElse: () => '').trim()}\n');
      }

      final currentId = int.tryParse(lines.firstWhere((e) => RegExp(r'\s*id\s*=\s*\d*\s*', caseSensitive: false).hasMatch(e), orElse: () => '-1').trim().replaceAll(RegExp(r'\D'), ''));
      final value = double.tryParse(lines.firstWhere((e) => _manpowerRegexp.hasMatch(e), orElse: () => '0').replaceAll(_manpowerRegexp, '').trim());

      if (value != null) {
        if (germanyOwnerStateIds.contains(currentId)) {
          germanyManPowersTotal = germanyManPowersTotal + value;
        } else if (sovietOwnerStateIds.contains(currentId)) {
          sovietManPowersTotal = sovietManPowersTotal + value;
        }
      }

      final raf = file.openSync(mode: FileMode.write);
      raf
        ..writeStringSync(lines.join('\n'))
        ..closeSync();
    }
  }

  print('Total manpower GER ${germanyManPowersTotal}\n');
  print('Total manpower SOV ${sovietManPowersTotal}\n');
}
