import 'package:material_ui/material_ui.dart';

import '../../material_helper.dart';
import '../l10n/app_localizations_en.dart';

typedef SettingsScreenWidgetBuilder =
    Widget Function(BuildContext context, SettingsScreenBuildEvent event);
typedef SettingsScreenScreenBuilder = SettingsConfig Function();
typedef SettingsScreenDependantValueBuilder<T, S> = T Function(S state);

class SettingsScreen extends StatefulWidget {
  static SettingsConfig? globalConfig;
  final SettingsScreenScreenBuilder config;

  SettingsScreen({super.key, SettingsScreenScreenBuilder? config})
    : assert(config != null || globalConfig != null, "No config provided"),
      config = config ?? (() => globalConfig ?? SettingsConfig());
  const SettingsScreen._inherit({required this.config});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    final effectiveConfig = widget.config();
    final event = SettingsScreenBuildEvent._(
      onChanged: _onUpdate,
      openNewScreen: (config) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SettingsScreen._inherit(config: config),
        ),
      ),
      unavailableCharacter: localizations.unavailableCharacter,
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ((effectiveConfig.expandAppBar ?? true)
              ? SliverAppBar.large
              : SliverAppBar.new)(
            flexibleSpace: MaterialFlexibleSpaceBar(
              title: Text(
                effectiveConfig.title ?? localizations.settingsScreenTitle,
              ),
            ),
            pinned: true,
            expandedHeight: (effectiveConfig.expandAppBar ?? true) ? 172 : null,
            actions: effectiveConfig.actions,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              if (effectiveConfig.description != null)
                MaterialListTile(
                  title: Text(effectiveConfig.description!),
                  titleStyle: MaterialListTileTitleStyle.text,
                ),
              ...?effectiveConfig.sections?.expand(
                (e) => e.build(context, event),
              ),
              MaterialListTileBottomSpacer(),
            ]),
          ),
        ],
      ),
    );
  }
}

Future<void> showSettingsScreen(
  BuildContext context, {
  SettingsScreenScreenBuilder? config,
}) => Navigator.of(
  context,
).push(MaterialPageRoute(builder: (context) => SettingsScreen(config: config)));

class SettingsConfig {
  final String? title;
  final bool? expandAppBar;
  final String? description;
  final List<Widget>? actions;
  final List<SettingsSection>? sections;

  SettingsConfig({
    this.title,
    this.expandAppBar,
    this.description,
    this.actions,
    this.sections,
  });

  SettingsConfig copyWith({
    String? title,
    bool? expandAppBar,
    String? description,
    List<Widget>? actions,
    List<SettingsSection>? sections,
  }) {
    return SettingsConfig(
      title: title ?? this.title,
      expandAppBar: expandAppBar ?? this.expandAppBar,
      description: description ?? this.description,
      actions: actions ?? this.actions,
      sections: sections ?? this.sections,
    );
  }

  SettingsConfig merge(SettingsConfig? other) {
    if (other == null) return this;
    return copyWith(
      title: other.title,
      expandAppBar: other.expandAppBar,
      description: other.description,
      actions: other.actions,
      sections: other.sections,
    );
  }
}

class SettingsScreenBuildEvent {
  final void Function() onChanged;
  final void Function(SettingsScreenScreenBuilder config) openNewScreen;
  final String unavailableCharacter;

  SettingsScreenBuildEvent._({
    required this.onChanged,
    required this.openNewScreen,
    required this.unavailableCharacter,
  });
}

abstract class _BuildableObject<T> {
  // inherited from [SettingsScreenWidgetBuilder]
  T build(BuildContext context, SettingsScreenBuildEvent event);
  const _BuildableObject();
}

class SettingsSection extends _BuildableObject<List<Widget>> {
  final String? headline;
  final List<SettingsOption> options;

  const SettingsSection({this.headline, required this.options});

  @override
  List<Widget> build(BuildContext context, SettingsScreenBuildEvent event) {
    return MaterialListTile.group(
      headline: headline != null
          ? MaterialListTileHeadline(Text(headline!))
          : null,
      options.map((e) => e.build(context, event)).toList(),
    );
  }
}

abstract class SettingsOption extends _BuildableObject<Widget> {
  final Widget? icon;
  final String title;
  final String? subtitle;

  const SettingsOption({this.icon, required this.title, this.subtitle});
}

class CustomSettingsOption extends SettingsOption {
  final MaterialListTileTitleStyle titleStyle;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  const CustomSettingsOption({
    super.icon,
    required super.title,
    this.titleStyle = MaterialListTileTitleStyle.normal,
    super.subtitle,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) =>
      MaterialListTile(
        leading: icon,
        title: Text(title),
        titleStyle: titleStyle,
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onTap,
        onLongPress: onLongPress,
      );
}

class SettingsOptionBuilder extends SettingsOption {
  final bool wrapWithListTile;
  final SettingsScreenWidgetBuilder? builder;

  const SettingsOptionBuilder({
    this.wrapWithListTile = true,
    required this.builder,
  }) : super(title: "");

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) {
    final widget = builder?.call(context, event) ?? SizedBox.shrink();
    return wrapWithListTile ? MaterialListTile(title: widget) : widget;
  }
}

class SwitchSettingsOption extends SettingsOption {
  final bool value;
  final ValueChanged<bool> onChanged;
  final SettingsScreenDependantValueBuilder<bool, bool>? enabled;

  const SwitchSettingsOption({
    super.icon,
    required super.title,
    super.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled,
  });

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) {
    return MaterialSwitchListTile(
      value: value,
      onChanged: (enabled?.call(value) ?? true)
          ? (value) {
              onChanged(value);
              event.onChanged();
            }
          : null,
      secondary: icon,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
    );
  }
}

class SplitSwitchSettingsOption extends SwitchSettingsOption {
  final SettingsScreenScreenBuilder newScreen;

  const SplitSwitchSettingsOption({
    super.icon,
    required super.title,
    super.subtitle,
    required super.value,
    required this.newScreen,
    required super.onChanged,
    super.enabled,
  });

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) {
    final effectiveOnChanged = (enabled?.call(value) ?? true)
        ? (value) {
            onChanged(value);
            event.onChanged();
          }
        : null;
    return MaterialSplitSwitchListTile(
      value: value,
      onTap: () => event.openNewScreen(newScreen.call),
      onChanged: effectiveOnChanged,
      secondary: icon,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
    );
  }
}

class InputSettingsOption extends SettingsOption {
  final String? dialogTitle;
  final String? dialogSubtitle;

  final String? dialogPrefixText;
  final Widget? dialogPrefixIcon;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool allowEmpty;
  final String? dialogPlaceholder;
  final String? dialogSuffixText;
  final Widget? dialogSuffixIcon;

  final ValueValidator<String>? validator;
  final ValueValidatorSimple<String>? quickValidator;
  final ValueManipulator<String>? manipulator;

  final bool obscure;
  final int maxLines;
  final bool autocorrect;
  final List<String>? autofillHints;
  final TextCapitalization capitalization;
  final TextInputType keyboardType;
  final PromptDialogAction? action;

  const InputSettingsOption({
    super.icon,
    required super.title,
    this.dialogTitle,
    this.dialogSubtitle,
    this.dialogPrefixText,
    this.dialogPrefixIcon,
    required this.value,
    required this.onChanged,
    this.allowEmpty = false,
    this.dialogPlaceholder,
    this.dialogSuffixText,
    this.dialogSuffixIcon,
    this.validator,
    this.quickValidator,
    this.manipulator,
    this.obscure = false,
    this.maxLines = 1,
    this.autocorrect = true,
    this.autofillHints,
    this.capitalization = TextCapitalization.sentences,
    this.keyboardType = TextInputType.text,
    this.action,
  });

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    return MaterialListTile(
      leading: icon,
      title: Text(title),
      subtitle: Text(
        value != null && value!.isNotEmpty
            ? value!
            : event.unavailableCharacter,
      ),
      onTap: () async {
        final res = await showPromptDialog(
          context: context,
          title: dialogTitle ?? localizations.setValue(title),
          description: dialogSubtitle,
          prefixText: dialogPrefixText,
          prefixIcon: dialogPrefixIcon,
          content: value,
          placeholder: dialogPlaceholder,
          suffixText: dialogSuffixText,
          suffixIcon: dialogSuffixIcon,
          validator: validator,
          quickValidator: quickValidator ?? (s) => allowEmpty || s.isNotEmpty,
          manipulator: manipulator,
          obscure: obscure,
          maxLines: maxLines,
          autocorrect: autocorrect,
          autofillHints: autofillHints,
          capitalization: capitalization,
          keyboardType: keyboardType,
          action: action,
        );
        if (res == null || res == value) return;
        onChanged(res);
        event.onChanged();
      },
      onLongPress: allowEmpty
          ? () {
              onChanged("");
              event.onChanged();
            }
          : null,
    );
  }
}

class NumInputSettingsOption<T extends num> extends InputSettingsOption {
  NumInputSettingsOption({
    super.icon,
    required super.title,
    required super.dialogTitle,
    super.dialogSubtitle,
    super.dialogPrefixText,
    super.dialogPrefixIcon,
    required T value,
    required ValueChanged<T> onChanged,
    super.allowEmpty,
    super.dialogPlaceholder,
    super.dialogSuffixText,
    super.dialogSuffixIcon,
    ValueValidator<T>? validator,
    ValueValidatorSimple<T>? quickValidator,
    super.obscure,
    super.autofillHints,
    TextInputType? keyboardType,
    super.action,
  }) : super(
         value: value.toString(),
         onChanged: (value) => onChanged.call(numParse<T>(value)),
         validator: (s) {
           T num;
           try {
             num = numParse<T>(s);
           } catch (_) {
             return "Not a valid number.";
           }
           return validator?.call(num);
         },
         quickValidator: (s) {
           T num;
           try {
             num = numParse<T>(s);
           } catch (_) {
             return false;
           }
           return quickValidator?.call(num) ?? true;
         },
         autocorrect: false,
         capitalization: TextCapitalization.none,
         keyboardType:
             keyboardType ?? TextInputType.numberWithOptions(decimal: T != int),
       );

  static T numParse<T extends num>(String s) => T == int
      ? int.parse(s) as T
      : T == double
      ? double.parse(s) as T
      : num.parse(s) as T;
}

class RadioSettingsOption<T extends Object> extends SettingsOption {
  final String? dialogTitle;
  final String? dialogSubtitle;

  final T? value;
  final Iterable<T> items;

  final RadioDialogObjectGenerator<T, String>? titleGenerator;
  final RadioDialogObjectGenerator<T, String>? subtitleGenerator;
  final RadioDialogObjectGenerator<T, Widget?>? iconGenerator;
  final RadioDialogObjectGenerator<T, bool>? enabledGenerator;

  final ValueChanged<T?> onChanged;
  final bool allowEmpty;

  const RadioSettingsOption({
    super.icon,
    required super.title,
    this.dialogTitle,
    this.dialogSubtitle,
    required this.value,
    required this.items,
    this.titleGenerator,
    this.subtitleGenerator,
    this.iconGenerator,
    this.enabledGenerator,
    required this.onChanged,
    this.allowEmpty = false,
  });

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    return MaterialListTile(
      leading: icon,
      title: Text(title),
      subtitle: Text(
        value != null
            ? (titleGenerator ??
                      titleGenerator ??
                      radioDialogDefaultTitleGenerator)
                  .call(value!)
            : event.unavailableCharacter,
      ),
      onTap: () async {
        var didSubmit = false;
        final res = await showRadioDialog<T>(
          context: context,
          title: dialogTitle ?? localizations.setValue(title),
          description: dialogSubtitle,
          initialValue: value,
          items: items,
          titleGenerator: titleGenerator,
          subtitleGenerator: subtitleGenerator,
          iconGenerator: iconGenerator,
          enabledGenerator: enabledGenerator,
          toggleable: allowEmpty,
          allowEmptySelection: allowEmpty,
          onSubmit: (_) => didSubmit = true,
        );

        if (!didSubmit || res == value) return;
        onChanged(res);
        event.onChanged();
      },
      onLongPress: allowEmpty
          ? () {
              onChanged(null);
              event.onChanged();
            }
          : null,
    );
  }
}

class CheckSettingsOption<T extends Object> extends SettingsOption {
  final String? dialogTitle;
  final String? dialogSubtitle;

  final Iterable<T> value;
  final Iterable<T> items;

  final RadioDialogObjectGenerator<T, String>? titleGenerator;
  final RadioDialogObjectGenerator<T, String>? subtitleGenerator;
  final RadioDialogObjectGenerator<T, Widget?>? iconGenerator;
  final RadioDialogObjectGenerator<T, bool>? enabledGenerator;

  final ValueChanged<Set<T>> onChanged;
  final bool allowEmpty;

  const CheckSettingsOption({
    super.icon,
    required super.title,
    this.dialogTitle,
    this.dialogSubtitle,
    required this.value,
    required this.items,
    this.titleGenerator,
    this.subtitleGenerator,
    this.iconGenerator,
    this.enabledGenerator,
    required this.onChanged,
    this.allowEmpty = false,
  });

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) {
    final localizations =
        MaterialHelperLocalizations.of(context) ??
        MaterialHelperLocalizationsEn();
    return MaterialListTile(
      leading: icon,
      title: Text(title),
      subtitle: Text(
        value.isNotEmpty
            ? checkDialogDefaultTitleGenerator(value, titleGenerator)
            : event.unavailableCharacter,
      ),
      onTap: () async {
        var didSubmit = false;
        final res = await showCheckDialog<T>(
          context: context,
          title: dialogTitle ?? localizations.setValue(title),
          description: dialogSubtitle,
          initialValue: value,
          items: items,
          titleGenerator: titleGenerator,
          subtitleGenerator: subtitleGenerator,
          iconGenerator: iconGenerator,
          enabledGenerator: enabledGenerator,
          allowEmptySelection: allowEmpty,
          onSubmit: (_) => didSubmit = true,
        );

        if (!didSubmit || res == value) return;
        onChanged(res ?? {});
        event.onChanged();
      },
      onLongPress: allowEmpty
          ? () {
              onChanged({});
              event.onChanged();
            }
          : null,
    );
  }
}

class NavigationSettingsOption extends SettingsOption {
  final SettingsScreenScreenBuilder newScreen;

  const NavigationSettingsOption({
    super.icon,
    required super.title,
    super.subtitle,
    required this.newScreen,
  });

  @override
  Widget build(BuildContext context, SettingsScreenBuildEvent event) {
    return MaterialListTile(
      leading: icon,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: () => event.openNewScreen(newScreen),
    );
  }
}
