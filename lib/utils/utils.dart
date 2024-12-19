import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as image_utils;
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

class Utils {
  static Future<void> clearSetting() async {
    PreferenceUtil.instance.setBool(Constants.prefAutoLogin, false);
  }

  static Future<void> setBusNotify(
    BuildContext context,
    List<BusReservation>? busReservations,
  ) async {
    final AppLocalizations app = AppLocalizations.of(context);
    if (NotificationUtil.instance.isSupport) {
      for (int i = 0;
          i <
              PreferenceUtil.instance
                  .getInt(Constants.notificationBusIndexOffset, 0);
          i++) {
        await NotificationUtil.instance.cancelNotify(
          id: Constants.notificationBusId + i,
        );
      }
      final int len = busReservations?.length ?? 0;
      PreferenceUtil.instance.setInt(Constants.notificationBusIndexOffset, len);
      for (int i = 0; i < len; i++) {
        await NotificationUtil.instance.schedule(
          id: Constants.notificationBusId + i,
          androidChannelId: '${Constants.notificationBusId}',
          androidChannelDescription: app.busNotify,
          dateTime: busReservations![i]
              .getDateTime()
              .subtract(const Duration(minutes: 30)),
          title: app.busNotify,
          content: sprintf(
            app.busNotifyContent,
            <String>[
              busReservations[i].getStart(app),
              busReservations[i].getEnd(app),
            ],
          ),
        );
      }
    }
  }

  static Future<void> cancelBusNotify() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(Constants.notificationBusId);
  }

  static Future<File> resizeImageByDart(File source) async {
    final image_utils.Image image =
        image_utils.decodeImage(source.readAsBytesSync())!;
    final double sourceSize = source.lengthSync() / 1024 / 1024;
    final double rate = sourceSize / Constants.imageResizeRate;
    final image_utils.Image thumbnail = image_utils.copyResize(
      image,
      width: (image.width / rate).ceil(),
      height: (image.height / rate).ceil(),
    );
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File result = File('${appDocDir.path}/proof.jpg')
      ..writeAsBytesSync(image_utils.encodeJpg(thumbnail));
    return result;
  }

  static Future<File> resizeImageByNative(File file) async {
    //TODO maybe remove
    // final Directory appDocDir = await getTemporaryDirectory();
    // final String tmpPath = '${appDocDir.path}/proof.jpg';
    // var result = await FlutterImageCompress.compressAndGetFile(
    //   file.absolute.path,
    //   tmpPath,
    //   quality: 70,
    // );
    return file;
  }

  static String parserImageFileType(String last) {
    if (last.contains('jpg') || last.contains('jpeg')) {
      return 'jpeg';
    } else if (last.contains('png')) {
      return 'png';
    } else if (last.contains('bmp')) {
      return 'bmp';
    } else if (last.contains('gif')) {
      return 'gif';
    } else if (last.contains('ico')) {
      return 'vnd.microsoft.icon';
    } else if (last.contains('svg')) {
      return 'svg+xml';
    } else if (last.contains('tif') || last.contains('tiff')) {
      return 'tiff';
    } else if (last.contains('webp')) {
      return 'webp';
    } else {
      return 'unkwon';
    }
  }

  static String parserCampus(AppLocalizations? local, String campus) {
    switch (campus) {
      case '建工':
        return local!.jiangong;
      case '燕巢':
        return local!.yanchao;
      case '第一':
        return local!.first;
      case '楠梓':
        return local!.nanzi;
      case '旗津':
        return local!.qijin;
      default:
        return campus;
    }
  }
}
