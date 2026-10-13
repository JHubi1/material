/// Helper library to add a padding tween to [FlexibleSpaceBar].
///
/// The code here is blatantly "stolen" from the Flutter SDK:
/// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/flexible_space_bar.dart
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

EdgeInsetsGeometryTween _defaultPaddingTween({
  required bool effectiveCenterTitle,
  required double leadingPadding,
}) => EdgeInsetsGeometryTween(
  begin: EdgeInsetsDirectional.only(start: 24, bottom: 8),
  end: EdgeInsetsDirectional.only(
    start: effectiveCenterTitle ? 0 : leadingPadding,
    bottom: 16,
  ),
);

class MaterialFlexibleSpaceBar extends StatefulWidget {
  const MaterialFlexibleSpaceBar({
    super.key,
    this.title,
    this.background,
    this.centerTitle,
    this.titlePadding,
    this.titlePaddingTween,
    this.collapseMode = CollapseMode.parallax,
    this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
    this.expandedTitleScale = 1.5,
  }) : assert(
         expandedTitleScale >= 1,
         "expandedTitleScale must be greater than or equal to 1.",
       );

  final Widget? title;
  final Widget? background;
  final bool? centerTitle;
  final CollapseMode collapseMode;
  final List<StretchMode> stretchModes;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometryTween? titlePaddingTween;
  final double expandedTitleScale;

  @override
  State<MaterialFlexibleSpaceBar> createState() =>
      _MaterialFlexibleSpaceBarState();
}

class _MaterialFlexibleSpaceBarState extends State<MaterialFlexibleSpaceBar> {
  bool _getEffectiveCenterTitle(ThemeData theme) {
    return widget.centerTitle ??
        switch (theme.platform) {
          TargetPlatform.android ||
          TargetPlatform.fuchsia ||
          TargetPlatform.linux ||
          TargetPlatform.windows => false,
          TargetPlatform.iOS || TargetPlatform.macOS => true,
        };
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) {
      return Alignment.bottomCenter;
    }
    return switch (Directionality.of(context)) {
      TextDirection.rtl => Alignment.bottomRight,
      TextDirection.ltr => Alignment.bottomLeft,
    };
  }

  double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
    switch (widget.collapseMode) {
      case CollapseMode.pin:
        return -(settings.maxExtent - settings.currentExtent);
      case CollapseMode.none:
        return 0.0;
      case CollapseMode.parallax:
        final deltaExtent = settings.maxExtent - settings.minExtent;
        return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

        final children = <Widget>[];

        final deltaExtent = settings.maxExtent - settings.minExtent;

        final t = clampDouble(
          1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent,
          0.0,
          1.0,
        );

        if (widget.background != null) {
          final double fadeStart = math.max(
            0.0,
            1.0 - kToolbarHeight / deltaExtent,
          );
          const fadeEnd = 1.0;
          assert(
            fadeStart <= fadeEnd,
            "fadeStart must be less than or equal to fadeEnd",
          );
          final opacity = settings.maxExtent == settings.minExtent
              ? 1.0
              : 1.0 - Interval(fadeStart, fadeEnd).transform(t);
          var height = settings.maxExtent;

          if (widget.stretchModes.contains(StretchMode.zoomBackground) &&
              constraints.maxHeight > height) {
            height = constraints.maxHeight;
          }
          final topPadding = _getCollapsePadding(t, settings);
          children.add(
            Positioned(
              top: topPadding,
              left: 0.0,
              right: 0.0,
              height: height,
              child: _FlexibleSpaceHeaderOpacity(
                alwaysIncludeSemantics: true,
                opacity: opacity,
                child: widget.background,
              ),
            ),
          );

          if (widget.stretchModes.contains(StretchMode.blurBackground) &&
              constraints.maxHeight > settings.maxExtent) {
            final blurAmount =
                (constraints.maxHeight - settings.maxExtent) / 10;
            children.add(
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ),
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            );
          }
        }

        if (widget.title != null) {
          final theme = Theme.of(context);

          Widget? title;
          switch (theme.platform) {
            case TargetPlatform.iOS:
            case TargetPlatform.macOS:
              title = widget.title;
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
            case TargetPlatform.linux:
            case TargetPlatform.windows:
              title = Semantics(namesRoute: true, child: widget.title);
          }

          if (widget.stretchModes.contains(StretchMode.fadeTitle) &&
              constraints.maxHeight > settings.maxExtent) {
            final stretchOpacity =
                1 -
                clampDouble(
                  (constraints.maxHeight - settings.maxExtent) / 100,
                  0.0,
                  1.0,
                );
            title = Opacity(opacity: stretchOpacity, child: title);
          }

          final opacity = settings.toolbarOpacity;
          if (opacity > 0.0) {
            var titleStyle = theme.useMaterial3
                ? theme.textTheme.titleLarge!
                : theme.primaryTextTheme.titleLarge!;
            titleStyle = titleStyle.copyWith(
              color: titleStyle.color!.withValues(alpha: opacity),
            );
            final effectiveCenterTitle = _getEffectiveCenterTitle(theme);
            final leadingPadding = (settings.hasLeading ?? true) ? 72.0 : 0.0;
            final padding =
                widget.titlePadding ??
                (widget.titlePaddingTween ??
                        _defaultPaddingTween(
                          effectiveCenterTitle: effectiveCenterTitle,
                          leadingPadding: leadingPadding,
                        ))
                    .chain(CurveTween(curve: Curves.easeInSine))
                    .transform(t);
            final scaleValue = Tween<double>(
              begin: widget.expandedTitleScale,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInSine)).transform(t);
            final scaleTransform = Matrix4.identity()
              ..scaleByDouble(scaleValue, scaleValue, 1.0, 1);
            final titleAlignment = _getTitleAlignment(effectiveCenterTitle);
            children.add(
              Padding(
                padding: padding,
                child: Transform(
                  alignment: titleAlignment,
                  transform: scaleTransform,
                  child: Align(
                    alignment: titleAlignment,
                    child: DefaultTextStyle(
                      style: titleStyle,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              return SizedBox(
                                width: constraints.maxWidth / scaleValue,
                                child: Align(
                                  alignment: titleAlignment,
                                  child: title,
                                ),
                              );
                            },
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return ClipRect(child: Stack(children: children));
      },
    );
  }
}

class _FlexibleSpaceHeaderOpacity extends SingleChildRenderObjectWidget {
  const _FlexibleSpaceHeaderOpacity({
    required this.opacity,
    required super.child,
    required this.alwaysIncludeSemantics,
  });

  final double opacity;
  final bool alwaysIncludeSemantics;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFlexibleSpaceHeaderOpacity(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderFlexibleSpaceHeaderOpacity renderObject,
  ) {
    renderObject
      ..alwaysIncludeSemantics = alwaysIncludeSemantics
      ..opacity = opacity;
  }
}

class _RenderFlexibleSpaceHeaderOpacity extends RenderOpacity {
  _RenderFlexibleSpaceHeaderOpacity({
    super.opacity,
    super.alwaysIncludeSemantics,
  });

  @override
  bool get isRepaintBoundary => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    if ((opacity * 255).roundToDouble() <= 0) {
      layer = null;
      return;
    }
    assert(needsCompositing, "The render object needs compositing.");
    layer = context.pushOpacity(
      offset,
      (opacity * 255).round(),
      super.paint,
      oldLayer: layer as OpacityLayer?,
    );
    assert(() {
      layer!.debugCreator = debugCreator;
      return true;
    }(), "");
  }
}
