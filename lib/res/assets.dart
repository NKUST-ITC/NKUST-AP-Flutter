import 'dart:convert';

import 'package:flutter/services.dart';

class ImageAssets {
  static const String basePath = 'assets/images';

  static const String kuasap1 = '$basePath/kuasap.webp';
  static const String kuasap2 = '$basePath/kuasap2.webp';
  static const String kuasap3 = '$basePath/kuasap3.webp';
  static const String drawerIconLight = '$basePath/drawer-icon.webp';
  static const String drawerIconDark = '$basePath/drawer-icon.webp';
  static const String K = '$basePath/K.webp';
  static const String dashLineLight = '$basePath/dash_line.webp';
  static const String dashLineDarkTheme = '$basePath/dash_line_dark_theme.webp';

  static String sectionJiangong = '$basePath/section_jiangong.webp';
  static String sectionYanchao = '$basePath/section_yanchao.webp';
  static String sectionFirst1 = '$basePath/section_first1.webp';
  static String sectionFirst2 = '$basePath/section_first2.webp';
  static String sectionNanzi = '$basePath/section_nanzi.webp';
  static String sectionQijin = '$basePath/section_qijin.webp';
}

class FileAssets {
  static const String basePath = 'assets';

  static const String leaveCampusData = '$basePath/leave_campus_data.json';
  static const String scheduleData = '$basePath/schedule_data.json';
  static const String changelog = '$basePath/changelog.json';

  static Future<Map<String, dynamic>> get changelogData async {
    return jsonDecode(await rootBundle.loadString(changelog));
  }
}
