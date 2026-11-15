import 'package:material_ui/material_ui.dart';

import 'scrolling_alert_dialog.dart';

Future<void> showAlertDialog({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  required Widget content,
  EdgeInsetsGeometry? contentPadding,
  String? semanticLabel,
  AlignmentGeometry? alignment,
}) async {
  return await showDialog(
    context: context,
    builder: (_) => ScrollingAlertDialog(
      icon: icon,
      iconColor: iconColor,
      title: Text(title),
      content: content,
      contentPadding: contentPadding,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
      semanticLabel: semanticLabel,
      alignment: alignment,
    ),
  );
}
