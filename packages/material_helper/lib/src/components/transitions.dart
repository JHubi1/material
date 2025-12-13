import 'package:flutter/material.dart';

abstract class Transitions {
  static Widget fromBottom(
    Widget child,
    Animation<double> animation,
  ) => SlideTransition(
    position: Tween(begin: Offset(0, 1.5), end: Offset.zero).animate(animation),
    child: MatrixTransition(
      alignment: Alignment.center,
      animation: animation,
      onTransform: (animationValue) {
        if (animationValue < 1) {
          return Matrix4.diagonal3Values(
            Tween<double>(begin: 1, end: 0.3).transform(1 - animationValue),
            1,
            1,
          );
        } else if (animationValue > 1.02) {
          return Matrix4.diagonal3Values(
            1,
            Tween<double>(begin: 1, end: 0.3).transform(animationValue - 1.02),
            1,
          );
        } else {
          return Matrix4.diagonal3Values(1, 1, 1);
        }
      },
      child: child,
    ),
  );
}
