import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../material_helper.dart';
import '../l10n/app_localizations_en.dart';

class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  static final List<LicenseEntry> _cachedLicenseRegistry = [];
  static void _storeLicenseRegistry(List<LicenseEntry> licenses) {
    if (_cachedLicenseRegistry.isEmpty) _cachedLicenseRegistry.addAll(licenses);
  }

  static void preloadLicenseRegistry() {
    if (_cachedLicenseRegistry.isNotEmpty) return;
    LicenseRegistry.licenses.toList().then(_storeLicenseRegistry);
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    return Scaffold(
      appBar: AppBar(title: Text(localizations.licensesScreenTitle)),
      body: MaterialFutureLoadedWidget(
        animationStyle: _cachedLicenseRegistry.isEmpty
            ? MaterialLoadedWidgetAnimationStyle.all
            : MaterialLoadedWidgetAnimationStyle.none,
        future: () async {
          if (_cachedLicenseRegistry.isNotEmpty) return _cachedLicenseRegistry;
          return await LicenseRegistry.licenses.toList();
        }(),
        builder: (context, value) {
          _storeLicenseRegistry(value);

          late final List<String> packagesOrder;
          final packages = <String, List<int>>{};
          final licenses = <List<(int, String)>>[];

          for (var i = 0; i < value.length; i++) {
            final license = value[i];
            licenses.add(
              license.paragraphs.map((e) => (e.indent, e.text)).toList(),
            );

            for (final package in license.packages) {
              packages.putIfAbsent(package, () => []).add(i);
            }
          }

          packagesOrder = packages.keys.toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          return ListView(
            children: [
              ...MaterialListTile.group(
                List.generate(packages.length, (index) {
                  final package = packagesOrder.elementAt(index);
                  return MaterialListTile(
                    title: Text(package),
                    trailing: Text(packages[package]!.length.toString()),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => _LicensesDetailsScreen(
                          packageName: package,
                          licenses: packages[packagesOrder.elementAt(index)]!
                              .map((e) => licenses[e])
                              .toList(),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              MaterialListTileBottomSpacer(),
            ],
          );
        },
      ),
    );
  }
}

class _LicensesDetailsScreen extends StatelessWidget {
  final String packageName;
  final List<List<(int, String)>> licenses;
  const _LicensesDetailsScreen({
    required this.packageName,
    required this.licenses,
  });

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    final isFont = licenses.any(
      (l) => l.any((e) => e.$2.contains("Open Font License")),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.licensesDetailsScreenTitle(packageName)),
      ),
      body: Builder(
        builder: (context) {
          final textStyle = DefaultTextStyle.of(context).style.copyWith(
            fontFamily: isFont
                ? packageName.replaceAll(" ", "")
                : "GoogleSansCode",
            fontFamilyFallback: ["GoogleSansCode"],
            package: "material_graphics",
          );
          final spaceWidth = (TextPainter(
            text: TextSpan(text: " ", style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout()).width;
          final children = List.generate(licenses.length, (index) {
            final license = licenses.elementAt(index);
            var childrenChildren = List<Widget>.generate(license.length, (sub) {
              final child = Text(
                license.elementAt(sub).$2.replaceAll("\r ", "\n"),
                style: textStyle,
              );
              if (license.elementAt(sub).$1 > 0) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: license.elementAt(sub).$1 * spaceWidth,
                  ),
                  child: child,
                );
              }
              return child;
            });
            childrenChildren = List.generate(
              childrenChildren.length * 2 - 1,
              (i) => i.isEven
                  ? childrenChildren[i ~/ 2]
                  : Text("\n", style: textStyle.copyWith(height: 0.3)),
            );
            return MaterialListTile(
              title: SelectionArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: childrenChildren,
                ),
              ),
            );
          });
          return ListView(
            children: [...children, MaterialListTileBottomSpacer()],
          );
        },
      ),
    );
  }
}

void showLicensesScreen(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const LicensesScreen()));
}
