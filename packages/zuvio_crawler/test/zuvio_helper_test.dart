import 'package:test/test.dart';
import 'package:zuvio_crawler/src/zuvio_exception.dart';
import 'package:zuvio_crawler/src/zuvio_helper.dart';

/// Every id here comes from Zuvio's own pages via a `\d+` regex, so
/// these are guard rails rather than something normal use can trip —
/// but every method that interpolates one into a URL path should
/// reject anything that isn't plain digits *before* it ever reaches
/// the network, rather than let it reshape the request path.
void main() {
  final ZuvioHelper helper = ZuvioHelper();

  test('rejects a non-numeric course id', () async {
    await expectLater(
      helper.getCurrentRollcall('123/../other'),
      throwsA(isA<ZuvioException>()),
    );
  });

  test('rejects a non-numeric bulletin id', () async {
    await expectLater(
      helper.getBulletinDetail('123?evil=1'),
      throwsA(isA<ZuvioException>()),
    );
  });

  test('rejects a non-numeric folder id', () async {
    await expectLater(
      helper.getQuestions('123', 'abc'),
      throwsA(isA<ZuvioException>()),
    );
  });

  test('rejects a non-numeric feedback id', () async {
    await expectLater(
      helper.getFeedbackThread('../admin'),
      throwsA(isA<ZuvioException>()),
    );
  });
}
