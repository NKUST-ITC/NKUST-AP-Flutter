import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/models/event_info_response.dart';

class EventSendCallback<T> extends GeneralCallback<T> {
  final Function(EventInfoResponse e) onNeedPick;

  EventSendCallback({
    required super.onFailure,
    required super.onError,
    required super.onSuccess,
    required this.onNeedPick,
  });
}
