import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nkust_ap/app.dart';

class ShareDataWidget extends InheritedWidget {
  final MyAppState data;

  const ShareDataWidget({
    required this.data,
    required Widget child,
  }) : super(child: child);

  static ShareDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  @override
  bool updateShouldNotify(ShareDataWidget oldWidget) {
    return true;
  }
}
