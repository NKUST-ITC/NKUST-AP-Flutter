import 'dart:io';

import 'package:ap_common/config/ap_constants.dart';
import 'package:ap_common/models/version_info.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:ap_common/utils/notification_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_utils.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image/image.dart' as ImageUtils;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class Utils {
  static void clearSetting() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.PREF_AUTO_LOGIN, false);
  }

  static Future<void> setBusNotify(
      BuildContext context, List<BusReservation> busReservations) async {
    var app = AppLocalizations.of(context);
    if (NotificationUtils.isSupport) {
      for (int i = 0;
          i < Preferences.getInt(Constants.NOTIFICATION_BUS_INDEX_OFFSET, 0);
          i++)
        await NotificationUtils.cancelCourseNotify(
            id: Constants.NOTIFICATION_BUS_ID + i);
      final len = busReservations?.length ?? 0;
      Preferences.setInt(Constants.NOTIFICATION_BUS_INDEX_OFFSET, len);
      for (int i = 0; i < len; i++) {
        await NotificationUtils.schedule(
          id: Constants.NOTIFICATION_BUS_ID + i,
          androidChannelId: '${Constants.NOTIFICATION_BUS_ID}',
          androidChannelDescription: app.busNotify,
          androidResourceIcon: Constants.ANDROID_DEFAULT_NOTIFICATION_NAME,
          dateTime:
              busReservations[i].getDateTime().subtract(Duration(minutes: 30)),
          title: app.busNotify,
          content: sprintf(
            app.busNotifyContent,
            [
              busReservations[i].getStart(app),
              busReservations[i].getEnd(app),
            ],
          ),
        );
      }
    }
  }

  static Future<void> cancelBusNotify() async {
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(Constants.NOTIFICATION_BUS_ID);
  }

  static checkRemoteConfig(BuildContext context, Function apiHostUpdate) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (!FirebaseUtils.isSupportRemoteConfig) return;
    final app = AppLocalizations.of(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var currentVersion =
        Preferences.getString(Constants.PREF_CURRENT_VERSION, '');
    if (currentVersion != packageInfo.buildNumber) {
      DialogUtils.showUpdateContent(
        context,
        "v${packageInfo.version}\n"
        "${AppLocalizations.of(context).updateNoteContent}",
      );
      Preferences.setString(
          Constants.PREF_CURRENT_VERSION, packageInfo.buildNumber);
    }
    if (!kDebugMode) {
      try {
        final RemoteConfig remoteConfig = await RemoteConfig.instance;
        await remoteConfig.fetch(expiration: const Duration(seconds: 10));
        await remoteConfig.activateFetched();
        String apiHostLocal =
            Preferences.getString(Constants.API_HOST, Helper.HOST);
        String apiHostRemote = remoteConfig.getString(Constants.API_HOST);
        await Preferences.setString(Constants.API_HOST, apiHostRemote);
        if (apiHostLocal != apiHostRemote) {
          Helper.resetInstance();
          apiHostUpdate();
        }
        print(remoteConfig.getInt(ApConstants.APP_VERSION));
        DialogUtils.showNewVersionContent(
          context: context,
          appName: app.appName,
          iOSAppId: '1439751462',
          defaultUrl: 'https://www.facebook.com/NKUST.ITC/',
          versionInfo: VersionInfo(
            code: remoteConfig.getInt(ApConstants.APP_VERSION),
            isForceUpdate: remoteConfig.getBool(ApConstants.IS_FORCE_UPDATE),
            content: remoteConfig.getString(ApConstants.NEW_VERSION_CONTENT),
          ),
        );
      } on FetchThrottledException catch (_) {} catch (exception) {}
    }
  }

  static Future<File> resizeImageByDart(File source) async {
    ImageUtils.Image image = ImageUtils.decodeImage(source.readAsBytesSync());
    double sourceSize = source.lengthSync() / 1024 / 1024;
    double rate = sourceSize / Constants.IMAGE_RESIZE_RATE;
    ImageUtils.Image thumbnail = ImageUtils.copyResize(
      image,
      width: (image.width / rate).ceil(),
      height: (image.height / rate).ceil(),
    );
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File result = File('${appDocDir.path}/proof.jpg')
      ..writeAsBytesSync(ImageUtils.encodeJpg(thumbnail));
    return result;
  }

  static Future<File> resizeImageByNative(File file) async {
    Directory appDocDir = await getTemporaryDirectory();
    String tmpPath = '${appDocDir.path}/proof.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tmpPath,
      quality: 70,
    );
    return result;
  }

  static String parserImageFileType(String last) {
    if (last.contains('jpg') || last.contains('jpeg'))
      return 'jpeg';
    else if (last.contains('png'))
      return 'png';
    else if (last.contains('bmp'))
      return 'bmp';
    else if (last.contains('gif'))
      return 'gif';
    else if (last.contains('ico'))
      return 'vnd.microsoft.icon';
    else if (last.contains('svg'))
      return 'svg+xml';
    else if (last.contains('tif') || last.contains('tiff'))
      return 'tiff';
    else if (last.contains('webp'))
      return 'webp';
    else
      return 'unkwon';
  }

  static String parserCampus(AppLocalizations local, String campus) {
    switch (campus) {
      case "建工":
        return local.jiangong;
      case "燕巢":
        return local.yanchao;
      case "第一":
        return local.first;
      case '楠梓':
        return local.nanzi;
      case '旗津':
        return local.qijin;
      default:
        return campus;
    }
  }
}
