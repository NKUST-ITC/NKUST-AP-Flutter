import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';

void main() {
  group('ZuvioRollcallResult.fromJson', () {
    test('accepts a boolean true status', () {
      expect(
        ZuvioRollcallResult.fromJson(<String, dynamic>{'status': true}).success,
        isTrue,
      );
    });

    // Zuvio's PHP backend is inconsistent about the shape of a "true"
    // flag; a numeric or string 1/true should also read as success
    // instead of makeRollcall reporting failure on an actually-successful
    // check-in.
    test('accepts numeric and string truthy statuses', () {
      for (final dynamic value in <dynamic>[1, '1', 'true', 'TRUE']) {
        expect(
          ZuvioRollcallResult.fromJson(<String, dynamic>{'status': value})
              .success,
          isTrue,
          reason: 'status: $value should be treated as success',
        );
      }
    });

    test('treats false / 0 / other strings as failure', () {
      for (final dynamic value in <dynamic>[false, 0, '0', 'false', null]) {
        expect(
          ZuvioRollcallResult.fromJson(<String, dynamic>{'status': value})
              .success,
          isFalse,
          reason: 'status: $value should be treated as failure',
        );
      }
    });

    test('carries the raw message through unchanged', () {
      final ZuvioRollcallResult result = ZuvioRollcallResult.fromJson(
        <String, dynamic>{'status': false, 'msg': 'ROLLCALL IS NOT ONAIR'},
      );
      expect(result.message, 'ROLLCALL IS NOT ONAIR');
    });
  });
}
