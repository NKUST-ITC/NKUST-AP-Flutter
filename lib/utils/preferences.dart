import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final encrypter = Encrypter(
    AES(
      Constants.key,
      mode: AESMode.cbc,
    ),
  );

  static SharedPreferences prefs;

  static init() async {
    if (kIsWeb) {
      prefs = await SharedPreferences.getInstance();
    } else if (Platform.isIOS || Platform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      prefs = await SharedPreferences.getInstance();
      var currentVersion =
          Preferences.getString(Constants.PREF_CURRENT_VERSION, '0');
      if (currentVersion == '0') return;
      var buildNumber = int.parse(currentVersion);
      if (buildNumber <= 30202) {
        prefs.clear();
      }
    }
  }

  static Future<Null> setStringSecurity(String key, String data) async {
    await prefs?.setString(
        key, encrypter.encrypt(data, iv: Constants.iv).base64);
  }

  static String getStringSecurity(String key, String defaultValue) {
    String data = prefs?.getString(key) ?? '';
    if (data == '')
      return defaultValue;
    else
      return encrypter.decrypt64(data, iv: Constants.iv);
  }

  static Future<Null> setString(String key, String data) async {
    await prefs?.setString(key, data);
  }

  static String getString(String key, String defaultValue) {
    return prefs?.getString(key) ?? defaultValue;
  }

  static Future<Null> setInt(String key, int data) async {
    await prefs?.setInt(key, data);
  }

  static int getInt(String key, int defaultValue) {
    return prefs?.getInt(key) ?? defaultValue;
  }

  static Future<Null> setDouble(String key, double data) async {
    await prefs?.setDouble(key, data);
  }

  static double getDouble(String key, double defaultValue) {
    return prefs?.getDouble(key) ?? defaultValue;
  }

  static Future<Null> setBool(String key, bool data) async {
    await prefs?.setBool(key, data);
  }

  static bool getBool(String key, bool defaultValue) {
    return prefs?.getBool(key) ?? defaultValue;
  }

  static Future<Null> setStringList(String key, List<String> data) async {
    await prefs?.setStringList(key, data);
  }

  static List<String> getStringList(String key, List<String> defaultValue) {
    return prefs?.getStringList(key) ?? defaultValue;
  }
}
