import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:nkust_crawler/src/models/leave_data.dart';
import 'package:nkust_crawler/src/models/leave_submit_data.dart';
import 'package:nkust_crawler/src/models/leave_submit_info_data.dart';

/// Image upload payload for leave submission. Decoupled from any specific
/// Flutter / image_picker type so the crawler layer can stay
/// platform-agnostic — callers convert their own [XFile]/[File]/whatever
/// into this shape before submitting.
typedef LeaveProofImage = ({Uint8List bytes, String filename, String mime});

/// Capability interface for leave/absence operations.
///
/// Implemented by: [LeaveHelper]
abstract class LeaveProvider {
  Future<LeaveData> getLeaves({required String year, required String semester});
  Future<LeaveSubmitInfoData> getSubmitInfo();
  Future<Response<dynamic>?> submit(
    LeaveSubmitData data, {
    LeaveProofImage? proofImage,
  });
}
