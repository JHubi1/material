import 'package:flutter/material.dart';

Future<void> showInfoDialog({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  required Widget content,
  double? elevation,
  Color? shadowColor,
  Color? surfaceTintColor,
  String? semanticLabel,
  ShapeBorder? shape,
  AlignmentGeometry? alignment,
}) async {
  return await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      icon: icon,
      iconColor: iconColor,
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: content,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      semanticLabel: semanticLabel,
      shape: shape,
      alignment: alignment,
      scrollable: true,
    ),
  );
}
