import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/config/constants.dart';

class CacheUtils {
  CacheUtils._();

  static Future<void> savePictureData(Uint8List bytes) async {
    final String username =
        PreferenceUtil.instance.getString(Constants.prefUsername, '');
    await PreferenceUtil.instance.setString(
      '${Constants.prefPictureData}_$username',
      base64.encode(bytes),
    );
  }

  static Future<Uint8List?> loadPictureData() async {
    final String username =
        PreferenceUtil.instance.getString(Constants.prefUsername, '');
    final String base64String = PreferenceUtil.instance
        .getString('${Constants.prefPictureData}_$username', '');
    if (base64String == '') {
      return null;
    }
    return base64.decode(base64String);
  }
}
