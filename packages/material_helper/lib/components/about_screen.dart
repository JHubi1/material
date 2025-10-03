import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../material_helper.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  Widget get appIcon => AspectRatio(
    aspectRatio: 1 / 1,
    child: ClipOval(
      child: Image.asset(
        "assets/icon/icon.png",
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => Stack(
          children: [
            SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.blue[500]!, Colors.grey[900]!],
                  ),
                ),
              ),
            ),
            Center(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Text(
                  "?",
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.blue[300]!,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    prefs?.remove("test");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations =
        AppLocalizations.of(context) ?? AppLocalizationsEn();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            flexibleSpace: MaterialFlexibleSpaceBar(
              title: Text(appLocalizations.aboutScreenTitle),
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
                          child: widget.appIcon,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(packageInfo?.appName ?? "–", maxLines: 3),
                            Text(
                              packageInfo?.version ?? "–",
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
                            onPressed: () {},
                            icon: Icon(Icons.info_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialListTile(
                  title: Text(appLocalizations.aboutScreenDescription),
                  titleStyle: MaterialListTileTitleStyle.text,
                ),
              ]),

              ...MaterialListTile.group(
                headline: MaterialListTileHeadline(
                  child: Text(appLocalizations.aboutScreenLinksHeadline),
                ),
                [
                  MaterialListTile(
                    leading: Icon(SimpleIcons.github),
                    title: Text(appLocalizations.aboutScreenLinksGitHub),
                    onTap: () => launchUrl(
                      Uri.parse("https://github.com/JHubi1/material"),
                    ),
                  ),
                  MaterialListTile(
                    leading: Icon(Icons.bug_report),
                    title: Text(appLocalizations.aboutScreenLinksCreateIssue),
                    subtitle: Text(
                      appLocalizations.aboutScreenLinksCreateIssueSubtitle,
                    ),
                    onTap: () {},
                  ),
                  MaterialListTile(
                    leading: Icon(Icons.gavel),
                    title: Text(appLocalizations.aboutScreenLinksLicenses),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: packageInfo?.appName,
                        applicationVersion: packageInfo?.version,
                        applicationLegalese: "Copyright 2025 JHubi1",
                      );
                    },
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

showAboutScreen(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AboutScreen()));
}

class TestScreen extends StatelessWidget {
  final int index;

  const TestScreen({super.key, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Debuggen über WLAN ${index + 1}")),
      body: ListTile(title: Text("Nice to meet you!")),
    );
  }
}
