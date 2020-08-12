import 'dart:convert';

String formUrlEncoded(Map<String, dynamic> data) {
  if (data == null) {
    return null;
  }
  String temp = "";
  data.forEach((key, value) {
    if (temp != null) {
      temp += "&";
    }
    temp += "${key}=${value}";
  });
  return temp;
}
