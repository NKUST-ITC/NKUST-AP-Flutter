import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common/widgets/item_picker.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/pages/study/room_course_page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

class libraryPage extends StatefulWidget {
  @override
  _libraryState createState() => _libraryState();
}
class _libraryState extends State<libraryPage> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: 'https://www.lib.nkust.edu.tw/portal/portal_login.php',
      withZoom: true,
      appBar: AppBar(title: Text("虛擬閱覽證")),
    );
  }
}