@Tags(<String>['live', 'live-anonymous'])
@TestOn('vm')
library;

import 'package:ap_common_core/ap_common_core.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:test/test.dart';

import '_helpers.dart';

/// Hits acad.nkust.edu.tw with no credentials. Verifies the network path,
/// the [NKUSTHelper.getNotifications] POST shape, and the [acadParser]
/// HTML extractor still match the live server.
void main() {
  setUpAll(() {
    configureCrawlerStorage(InMemoryKeyValueStore());
  });

  test(
    'getNotifications page 1 returns at least one announcement',
    () async {
      final NotificationsData result =
          await NKUSTHelper.instance.getNotifications(1);

      expect(result.data.notifications, isNotEmpty);

      // Spot-check the first row has the expected fields populated; the
      // real server can return arbitrary Chinese-language titles, so we
      // only assert non-emptiness rather than a specific value.
      final Notifications first = result.data.notifications.first;
      expect(first.link, isNotEmpty);
      expect(first.info.title, isNotEmpty);
      expect(first.info.date, isNotEmpty);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
