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
    print('[live] accepting any TLS cert (test process only)');
    acceptAnyTlsCertificate();
    print('[live] configuring in-memory storage');
    configureCrawlerStorage(InMemoryKeyValueStore());
  });

  test(
    'getNotifications page 1 returns at least one announcement',
    () async {
      print('[live] POST acad.nkust.edu.tw  Rcg=2072  page 1');
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

  test(
    'page 2 returns a non-overlapping window without erroring',
    () async {
      // The reported bug was "scroll past ~30 items -> 學校伺服器錯誤",
      // i.e. page >= 2 (which the endpoint now 302s for). Page 1 alone
      // never caught it.
      final NotificationsData p1 =
          await NKUSTHelper.instance.getNotifications(1);
      final NotificationsData p2 =
          await NKUSTHelper.instance.getNotifications(2);
      print('[live]   page1=${p1.data.notifications.length} '
          'page2=${p2.data.notifications.length}');

      expect(p2.data.notifications, isNotEmpty);

      final Set<String?> links1 =
          p1.data.notifications.map((Notifications n) => n.link).toSet();
      final Set<String?> links2 =
          p2.data.notifications.map((Notifications n) => n.link).toSet();
      expect(links1.intersection(links2), isEmpty);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
