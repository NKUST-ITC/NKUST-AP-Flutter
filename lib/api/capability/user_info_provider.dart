import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';

/// Capability interface for fetching user profile info and picture.
///
/// Implemented by: [WebApHelper], [StdsysHelper], [MobileNkustHelper]
abstract class UserInfoProvider {
  Future<UserInfo> getUserInfo();
  Future<Uint8List?> getUserPicture(String? pictureUrl);
}
