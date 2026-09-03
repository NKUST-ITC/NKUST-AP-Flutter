import 'dart:typed_data';

import 'package:ap_common_core/ap_common_core.dart';

/// Capability interface for fetching user profile info and picture.
///
/// Implemented by: [WebApHelper], [StdsysHelper]
abstract class UserInfoProvider {
  Future<UserInfo> getUserInfo();
  Future<Uint8List?> getUserPicture(String? pictureUrl);
}
