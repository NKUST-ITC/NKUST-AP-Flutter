import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:nkust_ap/models/event_info_response.dart';
import 'package:nkust_ap/models/general_response.dart';

class EventInfoCallback {
  final Function(DioError e) onFailure;
  final Function(GeneralResponse e) onError;
  final Function(EventInfoResponse data) onSuccess;

  EventInfoCallback({
    @required this.onFailure,
    @required this.onError,
    @required this.onSuccess,
  });
}

class EventSendCallback {
  final Function(DioError e) onFailure;
  final Function(EventInfoResponse e) onError;
  final Function(EventSendResponse data) onSuccess;

  EventSendCallback({
    @required this.onFailure,
    @required this.onError,
    @required this.onSuccess,
  });
}
