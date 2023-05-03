import 'dart:io';

import 'constants.dart';

final _resourcesRegexp = RegExp(r'\s*resources\s*=\s*');

final _newResourcesValues = '''
\t\tresources={
\t\t\t\t oil=20
\t\t\t\t steel=20
\t\t\t\t tungsten=20
\t\t\t\t chromium=20
\t\t\t\t aluminium=20
\t\t}
''';

Future<void> main() async {
  final statesDir = Directory(pathToStates);
  final files = statesDir.listSync(recursive: true);

  for (var file in files) {
    if (file is File && file.path.endsWith(".txt")) {
      final lines = file.readAsLinesSync();
      final startLineIndex = lines.indexOf(lines.firstWhere((e) => _resourcesRegexp.hasMatch(e), orElse: () => '-1'));

      if (startLineIndex != -1) {
        final subList = lines.sublist(startLineIndex);
        final endLineIndex = subList.indexOf(subList.firstWhere((e) => RegExp(r'\s*}\s*').hasMatch(e), orElse: () => '-1'));
        if (endLineIndex != -1) {
          lines
            ..removeRange(startLineIndex, (endLineIndex + startLineIndex) + 1)
            ..insert(startLineIndex, _newResourcesValues);
        } else {
          lines.insert(lines.indexOf(lines.last), _newResourcesValues);
        }
      } else {
        lines.insert(lines.indexOf(lines.last), _newResourcesValues);
      }

      final raf = file.openSync(mode: FileMode.write);
      raf
        ..writeStringSync(lines.join('\n'))
        ..closeSync();
    }
  }
}
