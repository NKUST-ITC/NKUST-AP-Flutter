import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        bgcolor: "#434c61",
        textcolor: '#ffffff');
  }
}
