import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:test/test.dart';

void main() {
  group('NoOpCrashReporter', () {
    test('swallows errors silently', () {
      const CrashReporter reporter = NoOpCrashReporter();
      expect(
        () => reporter.recordError(
          Exception('boom'),
          StackTrace.current,
          reason: 'unit test',
        ),
        returnsNormally,
      );
    });
  });
}
