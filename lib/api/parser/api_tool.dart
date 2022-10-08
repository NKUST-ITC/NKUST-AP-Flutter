String? formUrlEncoded(Map<String, dynamic>? data) {
  if (data == null) {
    return null;
  }
  String temp = '';
  data.forEach((String key, dynamic value) {
    if (temp.isEmpty) {
      temp += '&';
    }
    temp += '$key=$value';
  });
  return temp;
}
