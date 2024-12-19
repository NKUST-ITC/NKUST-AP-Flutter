import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';

abstract class LeaveInterface {
  Future<GeneralResponse> login({
    required String username,
    required String password,
  });

  Future<GeneralResponse> logout();

  Future<LeaveData> getLeaves({
    required String year,
    required String value,
  });

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo();

  Future<GeneralResponse> leavesSubmit(
    LeaveSubmitData data, {
    required XFile proofImage,
  });
}
