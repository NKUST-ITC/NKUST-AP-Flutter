import 'package:image_picker/image_picker.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';

abstract class WebApInterface {
  Future<GeneralResponse> login();

  Future<LeaveData> getLeaves({String year, String value});

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo();

  Future<GeneralResponse> leavesSubmit(LeaveSubmitData data,
      {PickedFile proofImage});
}
