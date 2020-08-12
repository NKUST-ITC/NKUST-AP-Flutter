import 'dart:io';

import 'package:ap_common/config/ap_constants.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/models/version_info.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:ap_common/utils/notification_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:app_review/app_review.dart';
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
    //limit Android and iOS system
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      for (BusReservation i in busReservations) {
        await NotificationUtils.schedule(
          id: Constants.NOTIFICATION_BUS_ID,
          androidChannelId: '${Constants.NOTIFICATION_BUS_ID}',
          androidChannelDescription: app.busNotify,
          androidResourceIcon: Constants.ANDROID_DEFAULT_NOTIFICATION_NAME,
          dateTime: i.getDateTime(),
          title: app.busNotify,
          content: sprintf(
            app.busNotifyContent,
            [i.getStart(app), i.getEnd(app)],
          ),
          beforeMinutes: 30,
        );
      }
    } else {
      //TODO implement other platform system local notification
    }
  }

  static Future<void> cancelBusNotify() async {
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(Constants.NOTIFICATION_BUS_ID);
  }

  static void showAppReviewSheet(BuildContext context) async {
    // await Future.delayed(Duration(seconds: 1));
    final app = ApLocalizations.of(context);
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  app.ratingDialogTitle,
                  style: TextStyle(
                      color: ApTheme.of(context).blue, fontSize: 20.0),
                ),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                      color: ApTheme.of(context).grey,
                      height: 1.3,
                      fontSize: 18.0),
                  children: [
                    TextSpan(text: app.ratingDialogContent),
                  ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    app.later,
                    style: TextStyle(
                        color: ApTheme.of(context).blue, fontSize: 16.0),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    AppReview.requestReview.then((a) {});
                  },
                  child: Text(
                    app.rateNow,
                    style: TextStyle(
                        color: ApTheme.of(context).blue, fontSize: 16.0),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      //TODO implement other platform system local notification
    }
  }

  static checkRemoteConfig(BuildContext context, Function apiHostUpdate) async {
    await Future.delayed(Duration(milliseconds: 100));
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
    final app = AppLocalizations.of(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var currentVersion =
        Preferences.getString(Constants.PREF_CURRENT_VERSION, '');
    if (currentVersion != packageInfo.buildNumber) {
      DialogUtils.showUpdateContent(
        context,
        AppLocalizations.of(context).updateNoteContent,
      );
      Preferences.setString(
          Constants.PREF_CURRENT_VERSION, packageInfo.buildNumber);
    }
    if (!Constants.isInDebugMode) {
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
      } on FetchThrottledException catch (exception) {} catch (exception) {}
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
