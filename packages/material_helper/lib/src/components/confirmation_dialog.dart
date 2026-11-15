import 'package:material_ui/material_ui.dart';

import '../../material_helper.dart';
import '../l10n/app_localizations_en.dart';

class ConfirmationDialogPositiveAction {
  final String? custom;
  final String type;

  const ConfirmationDialogPositiveAction(String text)
    : custom = text,
      type = "custom";
  const ConfirmationDialogPositiveAction._(this.type) : custom = null;

  static const continueAction = ConfirmationDialogPositiveAction._("continue");
  static const confirmAction = ConfirmationDialogPositiveAction._("confirm");
  static const okAction = ConfirmationDialogPositiveAction._("ok");

  String _resolve(BuildContext context) => switch (type) {
    "continue" => MaterialLocalizations.of(context).continueButtonLabel,
    "confirm" =>
      (MaterialHelperLocalizations.of(context) ??
              MaterialHelperLocalizationsEn())
          .confirmationDialogActionContinue,
    "ok" => MaterialLocalizations.of(context).okButtonLabel,
    "custom" => custom!,
    _ => throw UnimplementedError(),
  };
}

enum ConfirmationDialogPromotedAction { positive, negative }

Future<bool> showConfirmationDialog({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  required Widget content,
  ConfirmationDialogPositiveAction positiveAction = .confirmAction,
  Set<ConfirmationDialogPromotedAction> promotedActions = const {},
  EdgeInsetsGeometry? contentPadding,
  String? semanticLabel,
  AlignmentGeometry? alignment,
}) async {
  final defaultAction = promotedActions.length == 1
      ? promotedActions.first
      : null;
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ScrollingAlertDialog(
      icon: icon,
      iconColor: iconColor,
      title: Text(title),
      content: content,
      contentPadding: contentPadding,
      actions: [
        (promotedActions.contains(ConfirmationDialogPromotedAction.negative)
            ? FilledButton.new
            : TextButton.new)(
          autofocus: defaultAction == .negative,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        (promotedActions.contains(ConfirmationDialogPromotedAction.positive)
            ? FilledButton.new
            : TextButton.new)(
          autofocus: defaultAction == .positive,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(positiveAction._resolve(context)),
        ),
      ],
      semanticLabel: semanticLabel,
      alignment: alignment,
    ),
  );
  return result ?? false;
}
