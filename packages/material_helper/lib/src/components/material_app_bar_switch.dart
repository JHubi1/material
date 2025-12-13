import 'package:flutter/material.dart';
import '../../material_helper.dart';

class MaterialAppBarSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final ListTileControlAffinity? controlAffinity;

  const MaterialAppBarSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.controlAffinity,
  });

  @override
  Widget build(BuildContext context) {
    final Widget control = IgnorePointer(
      child: ExcludeFocus(
        child: Switch(value: value, onChanged: onChanged),
      ),
    );

    final ListTileThemeData listTileTheme = ListTileTheme.of(context);
    final ListTileControlAffinity effectiveControlAffinity =
        controlAffinity ??
        listTileTheme.controlAffinity ??
        ListTileControlAffinity.platform;
    Widget? leading, trailing;
    (leading, trailing) = switch (effectiveControlAffinity) {
      ListTileControlAffinity.leading => (control, null),
      ListTileControlAffinity.trailing ||
      ListTileControlAffinity.platform => (null, control),
    };

    return MergeSemantics(
      child: MaterialListTile(
        leading: leading,
        title: Text(title, maxLines: 1),
        trailing: trailing,
        enabled: onChanged != null,
        onTap: onChanged != null ? () => onChanged!.call(!value) : null,
      ),
    );
  }

  static Size get preferredSize => const Size(double.infinity, 64);
}
