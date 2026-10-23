import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'radio_dialog.dart';
import 'scrolling_alert_dialog.dart';

String checkDialogDefaultTitleGenerator<T>(
  Iterable<T> items,
  RadioDialogObjectGenerator<T, String>? titleGenerator,
) {
  final formatted = <String>[];
  for (var i in items) {
    formatted.add((titleGenerator ?? radioDialogDefaultTitleGenerator).call(i));
  }
  return formatted.map((s) => s.trim()).join(", ");
}

class CheckDialog<T extends Object> extends StatefulWidget {
  /// An optional icon to display at the top of the dialog.
  ///
  /// Typically, an [Icon] widget. Providing an icon centers the [title]'s text.
  final Widget? icon;

  /// Color for the [Icon] in the [icon] of this [AlertDialog].
  ///
  /// If null, [DialogThemeData.iconColor] is used. If that is null, defaults to
  /// color scheme's [ColorScheme.secondary] if [ThemeData.useMaterial3] is
  /// true, black otherwise.
  final Color? iconColor;

  /// The title of the dialog.
  final String title;

  /// The (optional) description of the dialog.
  final String? description;

  /// The initially selected value.
  final Iterable<T>? initialValue;

  /// The items the user can choose from.
  ///
  /// For visualization, the [Object.toString] of each item is used. Override
  /// [toString] if needed. Otherwise, use [titleGenerator] to provide custom
  /// titles.
  final Iterable<T> items;

  /// A function that generates the title for each item.
  final RadioDialogObjectGenerator<T, String>? titleGenerator;

  /// A function that generates the subtitle for each item.
  final RadioDialogObjectGenerator<T, String>? subtitleGenerator;

  /// A function that generates the icon for each item.
  final RadioDialogObjectGenerator<T, Widget?>? iconGenerator;

  /// A function that generates the enabled state for each item.
  final RadioDialogObjectGenerator<T, bool>? enabledGenerator;

  /// The semantic label of the dialog used by accessibility frameworks to
  /// announce screen transitions when the dialog is opened and closed.
  ///
  /// In iOS, if this label is not provided, a semantic label will be inferred
  /// from the [title] if it is not null.
  ///
  /// In Android, if this label is not provided, the dialog will use the
  /// [MaterialLocalizations.alertDialogLabel] as its label.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.namesRoute], for a description of how this
  ///    value is used.
  final String? semanticLabel;

  /// {@macro flutter.material.dialog.alignment}
  final AlignmentGeometry? alignment;

  /// If true, the user can submit the dialog without selecting an item.
  ///
  /// By default, [Navigator.pop] will return `null` if no item is selected or
  /// if the dialog was dismissed. Use this property together with [onSubmit]
  /// to differentiate between the two cases.
  final bool allowEmptySelection;

  /// Called when the user submits the dialog.
  ///
  /// This should not be used to receive the selected value, instead it is
  /// supposed to only be used to differentiate between the user submitting the
  /// dialog without selecting an item (with [allowEmptySelection] set to true)
  /// and the user dismissing the dialog without submitting.
  final ValueChanged<Set<T>>? onSubmit;

  CheckDialog({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.initialValue,
    required this.items,
    this.titleGenerator,
    this.subtitleGenerator,
    this.iconGenerator,
    this.enabledGenerator,
    this.semanticLabel,
    this.alignment,
    this.allowEmptySelection = false,
    this.onSubmit,
  }) : assert(
         items.length == items.toSet().length,
         "The items must be unique.",
       );

  @override
  State<CheckDialog<T>> createState() => _CheckDialogState<T>();
}

class _CheckDialogState<T extends Object> extends State<CheckDialog<T>> {
  final Set<T> _selected = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selected.addAll(widget.initialValue!.toSet());
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items.toSet();
    return ScrollingAlertDialog(
      icon: widget.icon,
      iconColor: widget.iconColor,
      title: Text(widget.title),
      semanticLabel: widget.semanticLabel,
      alignment: widget.alignment,
      contentPadding: EdgeInsets.zero,
      leading: widget.description != null
          ? Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Transform.translate(
                offset: Offset(0, -16),
                child: Text(widget.description!),
              ),
            )
          : null,
      content: ClipRRect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(items.length, (index) {
            final item = items.elementAt(index);
            final title =
                widget.titleGenerator?.call(item) ??
                radioDialogDefaultTitleGenerator(item);
            final subtitle = widget.subtitleGenerator?.call(item);
            final icon = widget.iconGenerator?.call(item);
            final enabled = widget.enabledGenerator?.call(item) ?? true;
            return ListTile(
              leading: IgnorePointer(
                child: ExcludeFocus(
                  child: SizedBox.square(
                    dimension: 24,
                    child: Checkbox(
                      value: _selected.contains(item),
                      onChanged: enabled ? (_) {} : null,
                    ),
                  ),
                ),
              ),
              title: Text(title),
              subtitle: subtitle != null ? Text(subtitle) : null,
              trailing: icon,
              enabled: enabled,
              selected: _selected.contains(item),
              minTileHeight: 48,
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              onTap: enabled
                  ? () {
                      _selected.contains(item)
                          ? _selected.remove(item)
                          : _selected.add(item);
                      if (mounted) setState(() {});
                    }
                  : null,
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: widget.allowEmptySelection || _selected.isNotEmpty
              ? () {
                  widget.onSubmit?.call(_selected);
                  Navigator.of(context).pop(_selected);
                }
              : null,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

Future<Set<T>?> showCheckDialog<T extends Object>({
  required BuildContext context,
  Widget? icon,
  Color? iconColor,
  required String title,
  String? description,
  Iterable<T>? initialValue,
  required Iterable<T> items,
  RadioDialogObjectGenerator<T, String>? titleGenerator,
  RadioDialogObjectGenerator<T, String>? subtitleGenerator,
  RadioDialogObjectGenerator<T, Widget?>? iconGenerator,
  RadioDialogObjectGenerator<T, bool>? enabledGenerator,
  String? semanticLabel,
  AlignmentGeometry? alignment,
  bool allowEmptySelection = false,
  ValueChanged<Set<T>>? onSubmit,
}) async {
  return await showDialog<Set<T>>(
    context: context,
    builder: (_) => CheckDialog<T>(
      icon: icon,
      iconColor: iconColor,
      title: title,
      description: description,
      initialValue: initialValue,
      items: items,
      titleGenerator: titleGenerator,
      subtitleGenerator: subtitleGenerator,
      iconGenerator: iconGenerator,
      enabledGenerator: enabledGenerator,
      semanticLabel: semanticLabel,
      alignment: alignment,
      allowEmptySelection: allowEmptySelection,
      onSubmit: onSubmit,
    ),
  );
}
