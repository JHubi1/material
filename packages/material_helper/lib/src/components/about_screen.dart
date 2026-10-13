import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_graphics/material_graphics.dart';
import 'package:material_ui/material_ui.dart';

import '../../material_helper.dart';
import '../generated/gitbaker.g.dart';
import '../l10n/app_localizations_en.dart';

typedef AppRegistry = Map<String, Map>;

class AboutScreen extends StatefulWidget {
  final bool referenceMaterialApps;

  final String? explanation;
  final Uri? githubUrl;
  final Map<String, Object?>? gitBakerData;

  const AboutScreen({
    super.key,
    this.referenceMaterialApps = true,
    this.explanation,
    this.githubUrl,
    this.gitBakerData,
  });

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
                              style: TextTheme.of(context).bodyMedium,
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
                                  gitBakerData:
                                      widget.gitBakerData ?? GitBaker.toJson(),
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
                if (widget.referenceMaterialApps || widget.explanation != null)
                  MaterialListTile(
                    title: Text(
                      widget.explanation ??
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
                  Text(localizations.aboutScreenReferencesHeadline),
                ),
                [
                  if (widget.referenceMaterialApps ||
                      widget.githubUrl != null) ...[
                    MaterialListTile(
                      leading: Icon(SimpleIcons.github),
                      title: Text(localizations.aboutScreenReferencesGitHub),
                      onTap: () => launchUrl(
                        Uri.parse("https://github.com/JHubi1/material"),
                      ),
                    ),
                    MaterialListTile(
                      leading: Icon(Icons.bug_report_outlined),
                      title: Text(
                        localizations.aboutScreenReferencesCreateIssue,
                      ),
                      subtitle: Text(
                        localizations.aboutScreenReferencesCreateIssueSubtitle,
                      ),
                      onTap: () => launchUrl(
                        (widget.githubUrl ??
                                Uri.parse("https://github.com/JHubi1/material"))
                            .enforceDirectoryHandling()
                            .resolve("issues/new"),
                      ),
                    ),
                  ],
                  MaterialListTile(
                    leading: Icon(Icons.gavel_outlined),
                    title: Text(localizations.aboutScreenReferencesLicenses),
                    onTap: () => showLicensesScreen(context),
                  ),
                ],
              ),

              if (appRegistry != null && widget.referenceMaterialApps)
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
                          onTap: () => launchUrl(
                            Uri.parse(
                              "https://github.com/JHubi1/material/tree/main/apps/${e.key}",
                            ),
                          ),
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
  final Map<String, Object?> gitBakerData;

  const AboutTechnicalScreen({
    super.key,
    required this.packageInfo,
    required this.gitBakerData,
  });

  @override
  State<AboutTechnicalScreen> createState() => _AboutTechnicalScreenState();
}

class _AboutTechnicalScreenState extends State<AboutTechnicalScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();

    final branches = (widget.gitBakerData["branches"] as List? ?? const [])
        .map((entry) => Map<String, Object?>.from(entry as Map))
        .toList();
    final currentBranchName = widget.gitBakerData["currentBranch"] as String?;
    final currentBranch = branches.firstWhere(
      (branch) => branch["name"] == currentBranchName,
      orElse: () => <String, Object?>{},
    );
    final branchCommits = currentBranch["commits"] as List? ?? const [];
    final allCommits = (widget.gitBakerData["commits"] as List? ?? const [])
        .map((entry) => Map<String, Object?>.from(entry as Map));
    Map<String, Object?>? latestCommit;
    if (branchCommits.isNotEmpty) {
      for (final commit in allCommits) {
        if (commit["hash"] == branchCommits.last) latestCommit = commit;
      }
    }
    final workspace = (widget.gitBakerData["workspace"] as List? ?? const [])
        .map((entry) => Map<String, Object?>.from(entry as Map))
        .toList();
    final workspaceSummary = gitBakerWorkspaceFormat(workspace);

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
                    subtitle: Text(
                      currentBranchName ?? localizations.unavailableCharacter,
                    ),
                    onLongPress: () => copy(currentBranchName),
                  ),
                  MaterialListTile(
                    title: Text(
                      localizations.aboutTechnicalScreenGitBranchRevision,
                    ),
                    subtitle: Text(
                      currentBranch["revision"]?.toString() ??
                          localizations.unavailableCharacter,
                    ),
                    onLongPress: () =>
                        copy(currentBranch["revision"]?.toString()),
                  ),
                  if (workspaceSummary != "Clean")
                    MaterialListTile(
                      title: Text(
                        localizations.aboutTechnicalScreenGitLocalChanges,
                      ),
                      subtitle: Text(workspaceSummary),
                      onLongPress: () => copy(workspaceSummary),
                    ),
                ],
              ),
              ...MaterialListTile.group([
                MaterialListTile(
                  title: Text(localizations.aboutTechnicalScreenGitCommit),
                  subtitle: Text(
                    latestCommit?["hash"]?.toString() ??
                        localizations.unavailableCharacter,
                  ),
                  onLongPress: () => copy(latestCommit?["hash"]?.toString()),
                ),
                MaterialListTile(
                  title: Text(
                    localizations.aboutTechnicalScreenGitCommitMessage,
                  ),
                  subtitle: Text(
                    latestCommit?["message"]?.toString() ??
                        localizations.unavailableCharacter,
                  ),
                  onLongPress: () => copy(latestCommit?["message"]?.toString()),
                ),
                MaterialListTile(
                  title: Text(
                    localizations.aboutTechnicalScreenGitCommitTimestamp,
                  ),
                  subtitle: Text(
                    dateFormat(
                          DateTime.tryParse(
                            latestCommit?["date"]?.toString() ?? "",
                          ),
                        ) ??
                        localizations.unavailableCharacter,
                  ),
                  onLongPress: () => copy(
                    dateFormat(
                      DateTime.tryParse(
                        latestCommit?["date"]?.toString() ?? "",
                      ),
                    ),
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
    // return dateTime.toIso8601String().split("T").join(" ").split(".").first;
    return DateFormat.yMMMd(
      MaterialHelperLocalizations.of(context)?.localeName ?? "en",
    ).add_Hms().format(dateTime);
  }

  String gitBakerWorkspaceFormat(List<Map<String, Object?>> entries) {
    if (entries.isEmpty ||
        (entries.length == 1 &&
            (entries[0]["path"] as String? ?? "").endsWith(
              "gitbaker.g.dart",
            ))) {
      return "Clean";
    }
    final changes = entries.where(
      (entry) => entry["type"] == "change" || entry["type"] == "rename/copy",
    );
    final addedIndex = changes
        .where((entry) => (entry["status"] as Map?)?["x"] == "added")
        .length;
    final addedWorking = changes
        .where((entry) => (entry["status"] as Map?)?["y"] == "added")
        .length;
    final modifiedIndex = changes
        .where((entry) => (entry["status"] as Map?)?["x"] == "modified")
        .length;
    final modifiedWorking = changes
        .where((entry) => (entry["status"] as Map?)?["y"] == "modified")
        .length;
    final removedIndex = changes
        .where((entry) => (entry["status"] as Map?)?["x"] == "deleted")
        .length;
    final removedWorking = changes
        .where((entry) => (entry["status"] as Map?)?["y"] == "deleted")
        .length;
    final renamedCopied = entries
        .where((entry) => entry["type"] == "rename/copy")
        .length;
    final untracked = entries
        .where((entry) => entry["type"] == "untracked")
        .length;
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
    Timer.periodic(Duration(milliseconds: 10), (_) => onUpdate());
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
    final hours = duration.inHours.withLeadingZeros(2);
    final minutes = duration.inMinutes.remainder(60).withLeadingZeros(2);
    final seconds = duration.inSeconds.remainder(60).withLeadingZeros(2);
    var res = "$minutes:$seconds";
    if (hours != "00") res = "$hours:$res";
    return res;
  }
}

void showAboutScreen(
  BuildContext context, {
  bool referenceMaterialApps = true,
  String? explanation,
  Uri? githubUrl,
  Map<String, Object?>? gitBakerData,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AboutScreen(
        referenceMaterialApps: referenceMaterialApps,
        explanation: explanation,
        githubUrl: githubUrl,
        gitBakerData: gitBakerData,
      ),
    ),
  );
}

extension on Uri {
  Uri enforceDirectoryHandling() =>
      replace(path: path.endsWith("/") ? path : "$path/");
}
