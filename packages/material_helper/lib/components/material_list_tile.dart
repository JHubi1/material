import 'package:flutter/material.dart';

import 'material_list_tile_headline.dart';

/// An enumeration of the styles of borders for [MaterialListTile].
///
/// {@template jhubi1.material.MaterialListTileBorder}
/// For the [MaterialListTileBorder.open] style, the rounded corners will
/// be minimal.
///
/// The [MaterialListTileBorder.closed] on the other hand will have more rounded
/// corners. This will make the tile look more like a separate entity.
///
/// If this property is null then the [MaterialListTileBorder.closed] border is
/// used.
/// {@endtemplate}
enum MaterialListTileBorder { open, closed }

enum MaterialListTileTitleStyle { normal, text }

/// An inherited widget that defines the border styles for [MaterialListTile]
/// widgets.
class MaterialListTileBorderStyle extends InheritedWidget {
  /// The style of the top list tile border.
  ///
  /// {@macro jhubi1.material.MaterialListTileBorder}
  final MaterialListTileBorder? borderTop;

  /// The style of the bottom list tile border.
  ///
  /// {@macro jhubi1.material.MaterialListTileBorder}
  final MaterialListTileBorder? borderBottom;

  const MaterialListTileBorderStyle({
    super.key,
    this.borderTop,
    this.borderBottom,
    required super.child,
  });

  static MaterialListTileBorderStyle? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MaterialListTileBorderStyle>();
  }

  static MaterialListTileBorderStyle of(BuildContext context) {
    final MaterialListTileBorderStyle? result = maybeOf(context);
    assert(result != null, "No MaterialListTileBorderStyle found in context");
    return result!;
  }

  @override
  bool updateShouldNotify(MaterialListTileBorderStyle oldWidget) =>
      borderTop != oldWidget.borderTop ||
      borderBottom != oldWidget.borderBottom;
}

/// A ListTile widget in a Material Expressive like style.
///
/// {@template jhubi1.material.MaterialListTile}
/// This widget is quite a bit restricting and should definitely not be forced
/// into everything. But for a structured screen, this is perfect.
///
/// You should set the [borderTop] and [borderBottom] properties accordingly
/// to get the desired look. See [MaterialListTileBorder] for more information.
///
/// For stylistic consistency, if an icon is used, it should be using the
/// outlined variant of the icon.
/// {@endtemplate}
class MaterialListTile extends StatelessWidget {
  /// A widget to display before the title.
  ///
  /// Typically an [Icon] or a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  ///
  /// This should not wrap. To enforce the single line limit, use
  /// [Text.maxLines].
  final Widget? title;

  /// The style of the title.
  ///
  /// If [MaterialListTileTitleStyle.normal] is used, the title will have a
  /// slightly bolder font weight. This is preferred.
  final MaterialListTileTitleStyle titleStyle;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  ///
  /// If [isThreeLine] is false, this should not wrap.
  ///
  /// If [isThreeLine] is true, this should be configured to take a maximum of
  /// two lines. For example, you can use [Text.maxLines] to enforce the number
  /// of lines.
  ///
  /// The subtitle's default [TextStyle] depends on [TextTheme.bodyMedium] except
  /// [TextStyle.color]. The [TextStyle.color] depends on the value of [enabled]
  /// and [selected].
  ///
  /// When [enabled] is false, the text color is set to [ThemeData.disabledColor].
  ///
  /// When [selected] is false, the text color is set to [ListTileTheme.textColor]
  /// if it's not null and to [TextTheme.bodySmall]'s color if [ListTileTheme.textColor]
  /// is null.
  final Widget? subtitle;

  /// A widget to display after the title.
  ///
  /// Typically an [Icon] widget.
  ///
  /// To show right-aligned metadata (assuming left-to-right reading order;
  /// left-aligned for right-to-left reading order), consider using a [Row] with
  /// [CrossAxisAlignment.baseline] alignment whose first item is [Expanded] and
  /// whose second child is the metadata text, instead of using the [trailing]
  /// property.
  final Widget? trailing;

  /// Whether this list tile is intended to display three lines of text.
  ///
  /// If true, then [subtitle] must be non-null (since it is expected to give
  /// the second and third lines of text).
  ///
  /// If false, the list tile is treated as having one line if the subtitle is
  /// null and treated as having two lines if the subtitle is non-null.
  ///
  /// When using a [Text] widget for [title] and [subtitle], you can enforce
  /// line limits using [Text.maxLines].
  ///
  /// See also:
  ///
  /// * [ListTileTheme.of], which returns the nearest [ListTileTheme]'s
  ///   [ListTileThemeData].
  final bool? isThreeLine;

  /// The style of the top list tile border.
  ///
  /// {@macro jhubi1.material.MaterialListTileBorder}
  final MaterialListTileBorder? borderTop;

  /// The style of the bottom list tile border.
  ///
  /// {@macro jhubi1.material.MaterialListTileBorder}
  final MaterialListTileBorder? borderBottom;

  /// Defines the color used for icons and text when the list tile is selected.
  ///
  /// If this property is null then [ListTileThemeData.selectedColor]
  /// is used. If that is also null then [ColorScheme.primary] is used.
  ///
  /// See also:
  ///
  /// * [ListTileTheme.of], which returns the nearest [ListTileTheme]'s
  ///   [ListTileThemeData].
  final Color? selectedColor;

  /// Defines the default color for [leading] and [trailing] icons.
  ///
  /// If this property is null and [selected] is false then [ListTileThemeData.iconColor]
  /// is used. If that is also null and [ThemeData.useMaterial3] is true, [ColorScheme.onSurfaceVariant]
  /// is used, otherwise if [ThemeData.brightness] is [Brightness.light], [Colors.black54] is used,
  /// and if [ThemeData.brightness] is [Brightness.dark], the value is null.
  ///
  /// If this property is null and [selected] is true then [ListTileThemeData.selectedColor]
  /// is used. If that is also null then [ColorScheme.primary] is used.
  ///
  /// If this color is a [WidgetStateColor] it will be resolved against
  /// [WidgetState.selected] and [WidgetState.disabled] states.
  ///
  /// See also:
  ///
  /// * [ListTileTheme.of], which returns the nearest [ListTileTheme]'s
  ///   [ListTileThemeData].
  final Color? iconColor;

  /// Defines the text color for the [title], [subtitle], [leading], and [trailing].
  ///
  /// If this property is null and [selected] is false then [ListTileThemeData.textColor]
  /// is used. If that is also null then default text color is used for the [title], [subtitle]
  /// [leading], and [trailing]. Except for [subtitle], if [ThemeData.useMaterial3] is false,
  /// [TextTheme.bodySmall] is used.
  ///
  /// If this property is null and [selected] is true then [ListTileThemeData.selectedColor]
  /// is used. If that is also null then [ColorScheme.primary] is used.
  ///
  /// If this color is a [WidgetStateColor] it will be resolved against
  /// [WidgetState.selected] and [WidgetState.disabled] states.
  ///
  /// See also:
  ///
  /// * [ListTileTheme.of], which returns the nearest [ListTileTheme]'s
  ///   [ListTileThemeData].
  final Color? textColor;

  /// The text style for ListTile's [title].
  ///
  /// If this property is null, then [ListTileThemeData.titleTextStyle] is used.
  /// If that is also null and [ThemeData.useMaterial3] is true, [TextTheme.bodyLarge]
  /// with [ColorScheme.onSurface] will be used. Otherwise, If ListTile style is
  /// [ListTileStyle.list], [TextTheme.titleMedium] will be used and if ListTile style
  /// is [ListTileStyle.drawer], [TextTheme.bodyLarge] will be used.
  final TextStyle? titleTextStyle;

  /// The text style for ListTile's [subtitle].
  ///
  /// If this property is null, then [ListTileThemeData.subtitleTextStyle] is used.
  /// If that is also null and [ThemeData.useMaterial3] is true, [TextTheme.bodyMedium]
  /// with [ColorScheme.onSurfaceVariant] will be used, otherwise [TextTheme.bodyMedium]
  /// with [TextTheme.bodySmall] color will be used.
  final TextStyle? subtitleTextStyle;

  /// The text style for ListTile's [leading] and [trailing].
  ///
  /// If this property is null, then [ListTileThemeData.leadingAndTrailingTextStyle] is used.
  /// If that is also null and [ThemeData.useMaterial3] is true, [TextTheme.labelSmall]
  /// with [ColorScheme.onSurfaceVariant] will be used, otherwise [TextTheme.bodyMedium]
  /// will be used.
  final TextStyle? leadingAndTrailingTextStyle;

  /// Whether this list tile is interactive.
  ///
  /// If false, this list tile is styled with the disabled color from the
  /// current [Theme] and the [onTap] and [onLongPress] callbacks are
  /// inoperative.
  final bool enabled;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  /// Called when the user long-presses on this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureLongPressCallback? onLongPress;

  /// {@macro flutter.material.inkwell.onFocusChange}
  final ValueChanged<bool>? onFocusChange;

  /// {@template flutter.material.ListTile.mouseCursor}
  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateMouseCursor],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.selected].
  ///  * [WidgetState.disabled].
  /// {@endtemplate}
  ///
  /// If null, then the value of [ListTileThemeData.mouseCursor] is used. If
  /// that is also null, then [WidgetStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// If this tile is also [enabled] then icons and text are rendered with the same color.
  ///
  /// By default the selected color is the theme's primary color. The selected color
  /// can be overridden with a [ListTileTheme].
  ///
  /// {@tool dartpad}
  /// Here is an example of using a [StatefulWidget] to keep track of the
  /// selected index, and using that to set the [selected] property on the
  /// corresponding [ListTile].
  ///
  /// ** See code in examples/api/lib/material/list_tile/list_tile.selected.0.dart **
  /// {@end-tool}
  final bool selected;

  /// The color for the tile's [Material] when it has the input focus.
  final Color? focusColor;

  /// The color for the tile's [Material] when a pointer is hovering over it.
  final Color? hoverColor;

  /// The color of splash for the tile's [Material].
  final Color? splashColor;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@template flutter.material.ListTile.tileColor}
  /// Defines the background color of `ListTile` when [selected] is false.
  ///
  /// If this property is null and [selected] is false then [ListTileThemeData.tileColor]
  /// is used. If that is also null and [selected] is true, [selectedTileColor] is used.
  /// When that is also null, the [ListTileTheme.selectedTileColor] is used, otherwise
  /// [Colors.transparent] is used.
  ///
  /// {@endtemplate}
  final Color? tileColor;

  /// Defines the background color of `ListTile` when [selected] is true.
  ///
  /// When the value if null, the [selectedTileColor] is set to [ListTileTheme.selectedTileColor]
  /// if it's not null and to [Colors.transparent] if it's null.
  final Color? selectedTileColor;

  /// {@template flutter.material.ListTile.enableFeedback}
  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// When null, the default value is true.
  /// {@endtemplate}
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  const MaterialListTile({
    super.key,
    this.leading,
    this.title,
    this.titleStyle = MaterialListTileTitleStyle.normal,
    this.subtitle,
    this.trailing,
    this.isThreeLine,
    this.borderTop,
    this.borderBottom,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.leadingAndTrailingTextStyle,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.onFocusChange,
    this.mouseCursor,
    this.selected = false,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.focusNode,
    this.autofocus = false,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final materialListTileBorderStyle = MaterialListTileBorderStyle.maybeOf(
      context,
    );
    final borderTop =
        this.borderTop ??
        materialListTileBorderStyle?.borderTop ??
        MaterialListTileBorder.closed;
    final borderBottom =
        this.borderBottom ??
        materialListTileBorderStyle?.borderBottom ??
        MaterialListTileBorder.closed;

    const radiusClosed = 16.0;
    const radiusOpen = 4.0;

    final topRadius = Radius.circular(
      borderTop == MaterialListTileBorder.closed ? radiusClosed : radiusOpen,
    );
    final bottomRadius = Radius.circular(
      borderBottom == MaterialListTileBorder.closed ? radiusClosed : radiusOpen,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: topRadius,
        topRight: topRadius,
        bottomLeft: bottomRadius,
        bottomRight: bottomRadius,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 1, left: 16, right: 16),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        isThreeLine: isThreeLine,
        selectedColor: selectedColor ?? colorScheme.onPrimaryContainer,
        iconColor: iconColor,
        textColor: textColor,
        titleTextStyle:
            titleTextStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: titleStyle == MaterialListTileTitleStyle.normal
                  ? FontWeight.w500
                  : null,
            ),
        subtitleTextStyle: subtitleTextStyle,
        leadingAndTrailingTextStyle: leadingAndTrailingTextStyle,
        enabled: enabled,
        onTap: onTap,
        onLongPress: onLongPress,
        onFocusChange: onFocusChange,
        mouseCursor: mouseCursor,
        selected: selected,
        focusColor: focusColor,
        hoverColor: hoverColor,
        splashColor: splashColor,
        focusNode: focusNode,
        autofocus: autofocus,
        tileColor:
            tileColor ??
            (theme.brightness == Brightness.light
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerHighest),
        selectedTileColor: selectedTileColor ?? colorScheme.primaryContainer,
        enableFeedback: enableFeedback,

        shape: shape,
        contentPadding: EdgeInsets.only(top: 2, bottom: 2, left: 16, right: 16),
      ),
    );
  }

  static List<Widget> group(
    List<MaterialListTile> tiles, {
    MaterialListTileHeadline? headline,
  }) {
    return [
      if (headline != null) headline,
      ...List.generate(
        tiles.length,
        (index) => MaterialListTileBorderStyle(
          borderTop: index != 0 ? MaterialListTileBorder.open : null,
          borderBottom: index != tiles.length - 1
              ? MaterialListTileBorder.open
              : null,
          child: tiles[index],
        ),
      ),
    ];
  }
}

class MaterialListTileBottomSpacer extends StatelessWidget {
  const MaterialListTileBottomSpacer({super.key});
  @override
  Widget build(BuildContext context) =>
      SafeArea(top: false, left: false, right: false, child: SizedBox.shrink());
}
