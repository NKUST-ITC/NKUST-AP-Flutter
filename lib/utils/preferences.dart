import 'package:encrypt/encrypt.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final encrypter = Encrypter(
    AES(
      Constants.key,
      Constants.iv,
      mode: AESMode.cbc,
    ),
  );

  static Future<Null> setStringSecurity(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, encrypter.encrypt(data).base64);
  }

  static Future<String> getStringSecurity(
      String key, String defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString(key) ?? '';
    if (data == '')
      return defaultValue;
    else
      return encrypter.decrypt64(data);
  }

  static Future<Null> setString(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  static Future<String> getString(String key, String defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  static Future<Null> setInt(String key, int data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, data);
  }

  static Future<int> getInt(String key, int defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? defaultValue;
  }

  static Future<Null> setDouble(String key, double data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, data);
  }

  static Future<double> getDouble(String key, double defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? defaultValue;
  }

  static Future<Null> setBool(String key, bool data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, data);
  }

  static Future<bool> getBool(String key, bool defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<Null> setStringList(String key, List<String> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, data);
  }

  static Future<List<String>> getStringList(
      String key, List<String> defaultValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? defaultValue;
  }
}
