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
    print('[live] configuring in-memory storage');
    configureCrawlerStorage(InMemoryKeyValueStore());
  });

  test(
    'getNotifications page 1 returns at least one announcement',
    () async {
      print('[live] POST acad.nkust.edu.tw  Rcg=232  Page=0');
      final NotificationsData result =
          await NKUSTHelper.instance.getNotifications(1);

      final int count = result.data.notifications.length;
      print('[live]   ← $count announcements (page=${result.data.page})');
      expect(result.data.notifications, isNotEmpty);

      final Notifications first = result.data.notifications.first;
      print('[live]   first: "${first.info.title}"');
      print('[live]          dept=${first.info.department} '
          'date=${first.info.date}');
      print('[live]          link=${first.link}');
      expect(first.link, isNotEmpty);
      expect(first.info.title, isNotEmpty);
      expect(first.info.date, isNotEmpty);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
