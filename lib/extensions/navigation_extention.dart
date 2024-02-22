import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension NavigationExtension on BuildContext {
  /// Navigates to a new view with various options.
  ///
  /// - `view`: The widget representing the new view.
  /// - `clearStack`: If true, clears the entire navigation stack before pushing the new view.
  /// - `replaceView`: If true, replaces the current route with the new view.
  /// - `cupertino`: If true, uses CupertinoPageRoute; otherwise, uses MaterialPageRoute.
  /// - `animate`: If true, applies a custom animation (e.g., fade) when pushing the new view.
  Future pushView(Widget view,
      {bool clearStack = false,
      bool replaceView = false,
      bool cupertino = false,
      bool animate = false}) {
    if (clearStack) {
      // Push the view and remove all previous routes from the stack.
      return Navigator.of(this).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => view), (route) => false);
    } else if (replaceView) {
      // Push the view and replace the current route with it.
      return Navigator.of(this)
          .pushReplacement(MaterialPageRoute(builder: (_) => view));
    } else if (animate) {
      // Push the view with a custom animation (e.g., fade).
      return Navigator.of(this).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => view,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } else {
      // Push the view with either MaterialPageRoute or CupertinoPageRoute.
      return Navigator.of(this).push(cupertino
          ? CupertinoPageRoute(builder: (_) => view)
          : MaterialPageRoute(builder: (_) => view));
    }
  }

  /// Pops one or more routes from the navigation stack.
  ///
  /// - `count`: If specified, pops back the specified number of routes.
  /// - `value`: An optional return value to be passed to the previous route when popping.
  void popView({int? count, dynamic value}) {
    if (count != null) {
      // Pop back a specified number of routes from the stack.
      int c = 0;
      return Navigator.of(this).popUntil((_) => c++ >= count);
    }
    // Pop the current route with an optional return value.
    return Navigator.pop(this, value);
  }
}
