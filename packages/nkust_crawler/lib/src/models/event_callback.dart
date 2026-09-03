import 'package:nkust_crawler/src/models/event_info_response.dart';

class EventSendCallback<T> {
  final Function(T data) onSuccess;
  final Function(dynamic e) onFailure;
  final Function(dynamic e) onError;
  final Function(EventInfoResponse e) onNeedPick;

  EventSendCallback({
    required this.onFailure,
    required this.onError,
    required this.onSuccess,
    required this.onNeedPick,
  });
}
