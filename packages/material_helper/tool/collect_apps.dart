import 'dart:convert';
import 'dart:io';

void main(_) {
  Directory.current = Directory(
    "${File(Platform.script.toFilePath()).parent.parent.parent.parent.path}/apps",
  );
  final apps = <String, Map<String, String?>>{};
  final icons = <String, String>{};
  for (var app in Directory.current.listSync()) {
    final dir = Directory(app.path);
    final basename = dir.path.split(Platform.pathSeparator).last;
    final description = File("${dir.path}/pubspec.yaml")
        .readAsStringSync()
        .split("\n")
        .firstWhere(
          (line) => line.trim().startsWith("description:"),
          orElse: () => "",
        )
        .split("description:")[1]
        .trim()
        .replaceAll(RegExp(r'^"|"$'), "")
        .toNullIfEmpty();
    final packageName = File("${dir.path}/android/app/build.gradle")
        .readAsStringSync()
        .split("\n")
        .firstWhere(
          (line) => line.trim().startsWith("namespace"),
          orElse: () => "",
        )
        .split('"')[1]
        .split('"')[0]
        .toNullIfEmpty();
    final appName = File("${dir.path}/android/app/src/main/AndroidManifest.xml")
        .readAsStringSync()
        .split("\n")
        .firstWhere(
          (line) => line.trim().contains('android:label="'),
          orElse: () => "",
        )
        .split('android:label="')[1]
        .split('"')[0]
        .toNullIfEmpty();
    final icon = File("${dir.path}/assets/icon/icon.png");
    if (appName == null || packageName == null) {
      stderr.writeln("Skipping $basename, missing appName or packageName");
      continue;
    }
    apps[basename] = {
      "name": appName,
      "description": description,
      "package": packageName,
    };
    if (icon.existsSync()) icons[basename] = icon.path;
  }

  Directory.current = Directory(
    "${File(Platform.script.toFilePath()).parent.parent.path}/assets/apps",
  )..createSync(recursive: true);
  File(
    "registry.json",
  ).writeAsStringSync(JsonEncoder.withIndent(" " * 2).convert(apps));
  for (var entry in icons.entries) {
    File(entry.value).copySync("${Directory.current.path}/${entry.key}.png");
  }
}

extension on String {
  String? toNullIfEmpty() => isEmpty ? null : this;
}
