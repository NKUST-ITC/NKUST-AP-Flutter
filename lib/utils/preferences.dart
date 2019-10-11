import 'dart:html' as web;
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

  static web.Storage _localStorage;

  static init() async {
    if (kIsWeb) {
      _localStorage = web.window.localStorage;
    } else if (Platform.isIOS || Platform.isAndroid) {
      prefs = await SharedPreferences.getInstance();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
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
    if (kIsWeb)
      _localStorage[key] = encrypter.encrypt(data, iv: Constants.iv).base64;
    else
      await prefs?.setString(
          key, encrypter.encrypt(data, iv: Constants.iv).base64);
  }

  static String getStringSecurity(String key, String defaultValue) {
    String data = '';
    if (kIsWeb)
      data = _localStorage[key] ?? '';
    else
      data = prefs?.getString(key) ?? '';
    if (data == '')
      return defaultValue;
    else
      return encrypter.decrypt64(data, iv: Constants.iv);
  }

  static Future<Null> setString(String key, String data) async {
    if (kIsWeb)
      _localStorage[key] = data;
    else
      await prefs?.setString(key, data);
  }

  static String getString(String key, String defaultValue) {
    if (kIsWeb)
      return (_localStorage[key]) ?? defaultValue;
    else
      return prefs?.getString(key) ?? defaultValue;
  }

  static Future<Null> setInt(String key, int data) async {
    if (kIsWeb)
      _localStorage[key] = data.toString();
    else
      await prefs?.setInt(key, data);
  }

  static int getInt(String key, int defaultValue) {
    if (kIsWeb) {
      int value;
      try {
        value = int.parse(_localStorage[key]);
      } catch (e) {
        value = defaultValue;
      }
      return value ?? defaultValue;
    } else
      return prefs?.getInt(key) ?? defaultValue;
  }

  static Future<Null> setDouble(String key, double data) async {
    if (kIsWeb)
      _localStorage[key] = data.toString();
    else
      await prefs?.setDouble(key, data);
  }

  static double getDouble(String key, double defaultValue) {
    if (kIsWeb) {
      double value;
      try {
        value = double.parse(_localStorage[key]);
      } catch (e) {
        value = defaultValue;
      }
      return value ?? defaultValue;
    }
    return prefs?.getDouble(key) ?? defaultValue;
  }

  static Future<Null> setBool(String key, bool data) async {
    if (kIsWeb)
      _localStorage[key] = data.toString();
    else
      await prefs?.setBool(key, data);
  }

  static bool getBool(String key, bool defaultValue) {
    if (kIsWeb) {
      bool value;
      switch (_localStorage[key]) {
        case 'true':
          value = true;
          break;
        case 'false':
          value = false;
          break;
        default:
          value = defaultValue;
          break;
      }
      return value ?? defaultValue;
    } else
      return prefs?.getBool(key) ?? defaultValue;
  }

  static Future<Null> setStringList(String key, List<String> data) async {
    await prefs?.setStringList(key, data);
  }

  static List<String> getStringList(String key, List<String> defaultValue) {
    return prefs?.getStringList(key) ?? defaultValue;
  }
}
