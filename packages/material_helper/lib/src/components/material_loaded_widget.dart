import 'dart:async';

import 'package:material_ui/material_ui.dart';
import '../../material_helper.dart';

enum MaterialLoadedWidgetAnimationStyle { none, fade, all }

abstract class MaterialLoadedWidget extends StatelessWidget {
  final MaterialLoadedWidgetAnimationStyle animationStyle;
  final double loaderSize;
  final BoxConstraints? loaderConstraints;
  final Widget Function(BuildContext context, Widget child)? loaderBuilder;

  const MaterialLoadedWidget({
    super.key,
    this.animationStyle = MaterialLoadedWidgetAnimationStyle.none,
    this.loaderSize = MaterialLoadingIndicatorSizes.large,
    this.loaderConstraints,
    this.loaderBuilder,
  });

  Widget _buildLoader(
    BuildContext context, {
    bool? state,
    required Widget? child,
  }) {
    state ??= child != null;
    if (child == null) state = false;

    Widget fallback = _MaterialLoadingBody(
      key: ValueKey("loading"),
      size: loaderSize,
      constraints: loaderConstraints,
    );
    if (loaderBuilder != null) {
      fallback = loaderBuilder!(context, fallback);
    }

    if (animationStyle == MaterialLoadedWidgetAnimationStyle.none) {
      return state ? child! : fallback;
    } else {
      final finalWidget = state
          ? _MaterialLoadingSwitchContainer(
              key: ValueKey("content"),
              child: child!,
            )
          : fallback;
      return AnimatedSwitcher(
        duration: animationStyle == MaterialLoadedWidgetAnimationStyle.all
            ? Durations.medium4
            : Durations.medium1,
        transitionBuilder: (child, animation) {
          var widget = child;

          if (child.key == const ValueKey("content") &&
              animationStyle == MaterialLoadedWidgetAnimationStyle.all &&
              !animation.isForwardOrCompleted) {
            final curved = CurveTween(curve: Curves.easeInOutCubicEmphasized);
            widget = SlideTransition(
              position: Tween(
                begin: Offset(0.0, 0.06),
                end: Offset.zero,
              ).chain(curved).animate(animation),
              child: Material(child: widget),
            );
          }

          return FadeTransition(opacity: animation, child: widget);
        },
        child: finalWidget,
      );
    }
  }
}

class MaterialChildLoadedWidget extends MaterialLoadedWidget {
  final Widget? child;
  const MaterialChildLoadedWidget({
    super.key,
    super.animationStyle,
    super.loaderSize,
    super.loaderConstraints,
    super.loaderBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => _buildLoader(context, child: child);
}

class MaterialLoadedWidgetBuilder extends MaterialLoadedWidget {
  final Widget? Function(BuildContext context) builder;
  const MaterialLoadedWidgetBuilder({
    super.key,
    super.animationStyle,
    super.loaderSize,
    super.loaderConstraints,
    super.loaderBuilder,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) =>
      _buildLoader(context, child: builder(context));
}

class MaterialFutureLoadedWidget<T> extends MaterialLoadedWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T value) builder;

  const MaterialFutureLoadedWidget({
    super.key,
    required this.future,
    super.animationStyle = MaterialLoadedWidgetAnimationStyle.all,
    super.loaderSize,
    super.loaderConstraints,
    super.loaderBuilder,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => _MaterialFutureLoadedWidgetBody<T>(
    future: future,
    builder: builder,
    buildLoader: _buildLoader,
  );
}

class MaterialCompleterLoadedWidget<T> extends MaterialFutureLoadedWidget<T> {
  MaterialCompleterLoadedWidget({
    super.key,
    required Completer<T> completer,
    super.animationStyle = MaterialLoadedWidgetAnimationStyle.all,
    super.loaderSize,
    super.loaderConstraints,
    super.loaderBuilder,
    required super.builder,
  }) : super(future: completer.future);
}

class _MaterialFutureLoadedWidgetBody<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T value) builder;
  final Widget Function(BuildContext, {bool state, required Widget? child})
  buildLoader;

  const _MaterialFutureLoadedWidgetBody({
    super.key,
    required this.future,
    required this.builder,
    required this.buildLoader,
  });

  @override
  State<_MaterialFutureLoadedWidgetBody<T>> createState() =>
      _MaterialFutureLoadedWidgetBodyState<T>();
}

class _MaterialFutureLoadedWidgetBodyState<T>
    extends State<_MaterialFutureLoadedWidgetBody<T>> {
  int _futureLock = 0;

  bool isLoaded = false;
  T? value;

  @override
  void initState() {
    widget.future.then(_processFuture(_futureLock));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _MaterialFutureLoadedWidgetBody<T> oldWidget) {
    if (oldWidget.future != widget.future) {
      _futureLock++;
      isLoaded = false;
      value = null;
      widget.future.then(_processFuture(_futureLock));
    }
    super.didUpdateWidget(oldWidget);
  }

  void Function(T value) _processFuture(int lock) => (T value) {
    if (!mounted || _futureLock != lock) return;
    isLoaded = true;
    this.value = value;
    if (mounted) setState(() {});
  };

  @override
  Widget build(BuildContext context) => widget.buildLoader(
    context,
    state: isLoaded,
    child: isLoaded ? widget.builder(context, value as T) : null,
  );
}

class _MaterialLoadingSwitchContainer extends StatelessWidget {
  final Widget child;
  const _MaterialLoadingSwitchContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

class _MaterialLoadingBody extends StatelessWidget {
  final double? size;
  final BoxConstraints? constraints;
  const _MaterialLoadingBody({
    super.key,
    required this.size,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    Widget loader = Center(
      child: MaterialLoadingIndicator(
        size: size ?? MaterialLoadingIndicatorSizes.large,
      ),
    );

    if (constraints != null) {
      loader = ConstrainedBox(constraints: constraints!, child: loader);
    }

    return loader;
  }
}
