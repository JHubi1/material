import 'package:flutter/material.dart';

import 'package:material_helper/material_helper.dart';

void main() {
  runApp(const AppMain());
}

class AppMain extends StatefulWidget {
  const AppMain({super.key});

  @override
  State<AppMain> createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  @override
  void initState() {
    super.initState();

    Preferences.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) =>
      ThemedMaterialApp(title: "Material Test", home: ScreenMain());
}

class ScreenMain extends StatelessWidget {
  const ScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hello World!'),
            ListTile(title: ThemeModeSwitcher()),
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(prefs?.getBool("test")?.toString() ?? "null"),
                  ),
                );
              },
              child: Text("Database Test"),
            ),
            TextButton(
              onPressed: () {
                showAboutScreen(context);
              },
              child: Text("About"),
            ),
          ],
        ),
      ),
    );
  }
}
