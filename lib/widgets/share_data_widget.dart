import 'package:flutter/widgets.dart';

class ShareDataWidget extends InheritedWidget {
  String username = '';
  bool isOfflineLogin = false;

  ShareDataWidget({Widget child}) : super(child: child);

  static ShareDataWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ShareDataWidget);
  }

  @override
  bool updateShouldNotify(ShareDataWidget oldWidget) {
    return oldWidget.username != username;
  }
}
