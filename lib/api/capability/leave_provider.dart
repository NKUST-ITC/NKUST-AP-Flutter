import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';

/// Capability interface for leave/absence operations.
///
/// Implemented by: [LeaveHelper]
abstract class LeaveProvider {
  Future<LeaveData> getLeaves({required String year, required String semester});
  Future<LeaveSubmitInfoData> getSubmitInfo();
  Future<Response<dynamic>?> submit(
    LeaveSubmitData data, {
    XFile? proofImage,
  });
}
