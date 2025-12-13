import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_graphics/material_graphics.dart';

import '../../material_helper.dart';
import '../generated/gitbaker.g.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';

typedef AppRegistry = Map<String, Map>;

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  // static Widget get appIcon => appIconFromColor(Colors.blue[400]!);

  static Widget appIcon({
    required String? name,
    required Brightness brightness,
    String asset = "assets/icon/icon.png",
    String? package,
  }) => FittedBox(
    fit: BoxFit.contain,
    child: SizedBox.square(
      dimension: 112,
      child: ClipOval(
        child: Image.asset(
          asset,
          package: package,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) =>
              appIconFallback(appColorFromName(name), brightness),
        ),
      ),
    ),
  );

  static Color appColorFromName(String? name) =>
      Color.lerp(randomColor(name?.hashCode), Colors.white, 0.2)!;

  static Widget appIconFallback(Color color, Brightness brightness) =>
      ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color,
                  Color.lerp(
                    (brightness == Brightness.light
                        ? Colors.white
                        : Colors.black),
                    color,
                    0.4,
                  )!,
                ],
              ),
            ),
          ),
        ),
      );

  static Future<AppRegistry> appRegistry() async =>
      rootBundle.loadStructuredData(
        "packages/material_helper/assets/apps/registry.json",
        (value) async => (jsonDecode(value) as Map<String, dynamic>).cast(),
      );

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? packageInfo;
  AppRegistry? appRegistry;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
      if (mounted) setState(() {});
    });
    AboutScreen.appRegistry().then((value) => appRegistry = value);
    LicensesScreen.preloadLicenseRegistry();
  }

  @override
  void dispose() {
    prefs?.remove("test");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            flexibleSpace: MaterialFlexibleSpaceBar(
              title: Text(localizations.aboutScreenTitle),
              // expandedTitlePadding: EdgeInsetsGeometry.only(
              //   left: 24,
              //   bottom: 8,
              // ),
              // titleCurve: Curves.easeInSine,
            ),
            expandedHeight: 172,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ...MaterialListTile.group([
                MaterialListTile(
                  title: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: 4,
                            right: 16,
                          ),
                          child: AboutScreen.appIcon(
                            name: packageInfo?.appName,
                            brightness: Theme.brightnessOf(context),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              packageInfo?.appName ??
                                  localizations.unavailableCharacter,
                              maxLines: 3,
                            ),
                            Text(
                              packageInfo?.version ??
                                  localizations.unavailableCharacter,
                              style: TextTheme.of(context).labelMedium,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: localizations.aboutTechnicalScreenTitle,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AboutTechnicalScreen(
                                  packageInfo: packageInfo,
                                ),
                              ),
                            ),
                            icon: Icon(Icons.info_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialListTile(
                  title: Text(
                    localizations.aboutScreenDescription(
                      packageInfo?.appName ?? "This app",
                    ),
                    maxLines: 4,
                  ),
                  titleStyle: MaterialListTileTitleStyle.text,
                ),
              ]),

              ...MaterialListTile.group(
                headline: MaterialListTileHeadline(
                  Text(localizations.aboutScreenLinksHeadline),
                ),
                [
                  MaterialListTile(
                    leading: Icon(SimpleIcons.github),
                    title: Text(localizations.aboutScreenLinksGitHub),
                    onTap: () => launchUrl(
                      Uri.parse("https://github.com/JHubi1/material"),
                    ),
                  ),
                  MaterialListTile(
                    leading: Icon(Icons.bug_report_outlined),
                    title: Text(localizations.aboutScreenLinksCreateIssue),
                    subtitle: Text(
                      localizations.aboutScreenLinksCreateIssueSubtitle,
                    ),
                    onTap: () => launchUrl(
                      Uri.parse(
                        "https://github.com/JHubi1/material/issues/new",
                      ),
                    ),
                  ),
                  MaterialListTile(
                    leading: Icon(Icons.gavel_outlined),
                    title: Text(localizations.aboutScreenLinksLicenses),
                    onTap: () => showLicensesScreen(context),
                  ),
                ],
              ),

              if (appRegistry != null)
                ...MaterialListTile.group(
                  headline: MaterialListTileHeadline(
                    Text(localizations.aboutScreenOtherAppsHeadline),
                  ),
                  (appRegistry!..removeWhere(
                        (_, v) => v["package"] == packageInfo?.packageName,
                      ))
                      .entries
                      .map(
                        (e) => MaterialListTile(
                          leading: Image.asset(
                            "abc",
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, _, _) => AboutScreen.appIcon(
                              name: e.value["name"],
                              brightness: Theme.brightnessOf(context),
                              asset: "assets/apps/${e.key}.png",
                              package: "material_helper",
                            ),
                          ),
                          title: Text(
                            e.value["name"] ??
                                localizations.unavailableCharacter,
                          ),
                          subtitle: e.value["description"] != null
                              ? Text(e.value["description"]!, maxLines: 3)
                              : null,
                          onTap: () {
                            launchUrl(
                              Uri.parse(
                                "https://github.com/JHubi1/material/tree/main/apps/${e.key}",
                              ),
                            );
                            Future.delayed(
                              Durations.extralong4,
                            ).then((_) => closeInAppWebView());
                          },
                        ),
                      )
                      .toList(),
                ),

              MaterialListTileBottomSpacer(),
            ]),
          ),
        ],
      ),
    );
  }
}

class AboutTechnicalScreen extends StatefulWidget {
  final PackageInfo? packageInfo;

  const AboutTechnicalScreen({super.key, required this.packageInfo});

  @override
  State<AboutTechnicalScreen> createState() => _AboutTechnicalScreenState();
}

class _AboutTechnicalScreenState extends State<AboutTechnicalScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            flexibleSpace: MaterialFlexibleSpaceBar(
              title: Text(localizations.aboutTechnicalScreenTitle),
            ),
            expandedHeight: 172,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ...MaterialListTile.group([
                MaterialListTile(
                  title: Text(
                    localizations.aboutTechnicalScreenPackageInfoAppName,
                  ),
                  subtitle: Text(
                    widget.packageInfo?.appName ??
                        localizations.unavailableCharacter,
                  ),
                  onLongPress: () => copy(widget.packageInfo?.appName),
                ),
                MaterialListTile(
                  title: Text(
                    localizations.aboutTechnicalScreenPackageInfoPackageName,
                  ),
                  subtitle: Text(
                    widget.packageInfo?.packageName ??
                        localizations.unavailableCharacter,
                  ),
                  onLongPress: () => copy(widget.packageInfo?.packageName),
                ),
                _AboutTechnicalScreenRunTime(),
              ]),
              ...MaterialListTile.group([
                MaterialListTile(
                  title: Text(
                    localizations.aboutTechnicalScreenPackageInfoVersion,
                  ),
                  subtitle: Text(
                    widget.packageInfo?.version ??
                        localizations.unavailableCharacter,
                  ),
                  onLongPress: () => copy(widget.packageInfo?.version),
                ),
                MaterialListTile(
                  title: Text(
                    localizations.aboutTechnicalScreenPackageInfoBuildNumber,
                  ),
                  subtitle: Text(
                    widget.packageInfo?.buildNumber ??
                        localizations.unavailableCharacter,
                  ),
                  onLongPress: () => copy(widget.packageInfo?.buildNumber),
                ),
              ]),

              ...MaterialListTile.group(
                headline: MaterialListTileHeadline(
                  Text(localizations.aboutTechnicalScreenInstallationHeadline),
                ),
                [
                  MaterialListTile(
                    title: Text(
                      localizations
                          .aboutTechnicalScreenInstallationInstallerStore,
                    ),
                    subtitle: Text(
                      widget.packageInfo?.installerStore ??
                          localizations.unavailableCharacter,
                    ),
                    onLongPress: () => copy(widget.packageInfo?.installerStore),
                  ),
                  MaterialListTile(
                    title: Text(
                      localizations.aboutTechnicalScreenInstallationInstallTime,
                    ),
                    subtitle: Text(
                      dateFormat(widget.packageInfo?.installTime) ??
                          localizations.unavailableCharacter,
                    ),
                    onLongPress: () =>
                        copy(dateFormat(widget.packageInfo?.installTime)),
                  ),
                  MaterialListTile(
                    title: Text(
                      localizations.aboutTechnicalScreenInstallationUpdateTime,
                    ),
                    subtitle: Text(
                      dateFormat(widget.packageInfo?.updateTime) ??
                          localizations.unavailableCharacter,
                    ),
                    onLongPress: () =>
                        copy(dateFormat(widget.packageInfo?.updateTime)),
                  ),
                ],
              ),

              ...MaterialListTile.group(
                headline: MaterialListTileHeadline(
                  Text(localizations.aboutTechnicalScreenGitHeadline),
                ),
                [
                  MaterialListTile(
                    title: Text(localizations.aboutTechnicalScreenGitBranch),
                    subtitle: Text(GitBaker.currentBranch.name),
                    onLongPress: () => copy(GitBaker.currentBranch.name),
                  ),
                  MaterialListTile(
                    title: Text(
                      localizations.aboutTechnicalScreenGitBranchRevision,
                    ),
                    subtitle: Text(GitBaker.currentBranch.revision.toString()),
                    onLongPress: () =>
                        copy(GitBaker.currentBranch.revision.toString()),
                  ),
                  if (GitBaker.workspace.isNotEmpty)
                    MaterialListTile(
                      title: Text(
                        localizations.aboutTechnicalScreenGitLocalChanges,
                      ),
                      subtitle: Builder(
                        builder: (context) {
                          return Text(
                            gitBakerWorkspaceFormat(GitBaker.workspace),
                          );
                        },
                      ),
                      onLongPress: () =>
                          copy(gitBakerWorkspaceFormat(GitBaker.workspace)),
                    ),
                ],
              ),
              ...MaterialListTile.group([
                MaterialListTile(
                  title: Text(localizations.aboutTechnicalScreenGitCommit),
                  subtitle: Text(GitBaker.currentBranch.commits.last.hash),
                  onLongPress: () =>
                      copy(GitBaker.currentBranch.commits.last.hash),
                ),
                MaterialListTile(
                  title: Text(
                    localizations.aboutTechnicalScreenGitCommitMessage,
                  ),
                  subtitle: Text(GitBaker.currentBranch.commits.last.message),
                  onLongPress: () =>
                      copy(GitBaker.currentBranch.commits.last.message),
                ),
                MaterialListTile(
                  title: Text(localizations.aboutTechnicalScreenGitCommitTime),
                  subtitle: Text(
                    dateFormat(GitBaker.currentBranch.commits.last.date)!,
                  ),
                  onLongPress: () => copy(
                    dateFormat(GitBaker.currentBranch.commits.last.date),
                  ),
                ),
              ]),

              MaterialListTileBottomSpacer(),
            ]),
          ),
        ],
      ),
    );
  }

  String? dateFormat(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String().split("T").join(" ").split(".").first;
  }

  String gitBakerWorkspaceFormat(List<WorkspaceEntry> entries) {
    if (entries.isEmpty ||
        (entries.length == 1 && entries[0].path.endsWith("gitbaker.g.dart"))) {
      return "Clean";
    }
    final addedIndex = entries
        .whereType<WorkspaceEntryChange>()
        .where((e) => e.status.x == WorkspaceEntryStatusPart.added)
        .length;
    final addedWorking = entries
        .whereType<WorkspaceEntryChange>()
        .where((e) => e.status.y == WorkspaceEntryStatusPart.added)
        .length;
    final modifiedIndex = entries
        .whereType<WorkspaceEntryChange>()
        .where((e) => e.status.x == WorkspaceEntryStatusPart.modified)
        .length;
    final modifiedWorking = entries
        .whereType<WorkspaceEntryChange>()
        .where((e) => e.status.y == WorkspaceEntryStatusPart.modified)
        .length;
    final removedIndex = entries
        .whereType<WorkspaceEntryChange>()
        .where((e) => e.status.x == WorkspaceEntryStatusPart.deleted)
        .length;
    final removedWorking = entries
        .whereType<WorkspaceEntryChange>()
        .where((e) => e.status.y == WorkspaceEntryStatusPart.deleted)
        .length;
    final renamedCopied = entries.whereType<WorkspaceEntryRenameCopy>().length;
    final untracked = entries.whereType<WorkspaceEntryUntracked>().length;
    return [
      if (addedIndex > 0 || modifiedIndex > 0 || removedIndex > 0)
        "I${[if (addedIndex > 0) "+$addedIndex", if (modifiedIndex > 0) "\u00B1$modifiedIndex", if (removedIndex > 0) "\u2212$removedIndex"].join()}",
      if (addedWorking > 0 || modifiedWorking > 0 || removedWorking > 0)
        "W${[if (addedWorking > 0) "+$addedWorking", if (modifiedWorking > 0) "\u00B1$modifiedWorking", if (removedWorking > 0) "\u2212$removedWorking"].join()}",
      if (renamedCopied > 0) "R$renamedCopied",
      if (untracked > 0) "U$untracked",
    ].join(" ");
  }

  void copy(String? data) => copyData(context, data);
}

class _AboutTechnicalScreenRunTime extends StatefulWidget {
  const _AboutTechnicalScreenRunTime();

  @override
  State<_AboutTechnicalScreenRunTime> createState() =>
      _AboutTechnicalScreenRunTimeState();
}

class _AboutTechnicalScreenRunTimeState
    extends State<_AboutTechnicalScreenRunTime> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(Durations.short1, (_) => onUpdate());
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialListTile(
      borderTop: MaterialListTileBorder.open,
      title: Text(
        (MaterialHelperLocalizations.of(context) ??
                MaterialHelperLocalizationsEn())
            .aboutTechnicalScreenPackageInfoRunningTime,
      ),
      subtitle: Text(durationFormat(runningTime.elapsed)),
      onLongPress: () => copyData(context, durationFormat(runningTime.elapsed)),
    );
  }

  String durationFormat(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    var res = "$minutes:$seconds";
    if (hours != "00") res = "$hours:$res";
    return res;
  }
}

showAboutScreen(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AboutScreen()));
}
