import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common/utils/preferences.dart';
import 'package:nkust_ap/config/constants.dart';

class CacheUtils {
  static void savePictureData(Uint8List bytes) async {
    if (bytes == null) return;

    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    await Preferences.setString(
        '${Constants.PREF_PICTURE_DATA}_$username', base64.encode(bytes));
  }

  static Future<Uint8List?> loadPictureData() async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String base64String =
        Preferences.getString('${Constants.PREF_PICTURE_DATA}_$username', '');
    if (base64String == '') return null;
    return base64.decode(base64String);
  }
}
