import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common_core/ap_common_core.dart';
import 'package:dio/dio.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:test/test.dart';

/// Answers the acad `mobilercglist` POST with a canned list and counts
/// how many times it's actually hit.
class _AcadAdapter implements HttpClientAdapter {
  int posts = 0;

  static String _rows(int n) {
    final StringBuffer b = StringBuffer('<table class="listTB table"><tbody>');
    for (int i = 0; i < n; i++) {
      b.write(
        '<tr>'
        '<td data-th="日期"><div class="d-txt">2026-09-${i + 1} </div></td>'
        '<td data-th="標題"><div class="d-txt"><div class="mtitle">'
        '<a href="https://acad.nkust.edu.tw/p/406-1063-$i,r2072.php">'
        '公告 $i</a></div></div></td>'
        '<td data-th="資料建立者"><div class="d-txt">課務組</div></td>'
        '</tr>',
      );
    }
    b.write('</tbody></table>');
    return b.toString();
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.toString().contains('mobilercglist')) {
      posts++;
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{'content': _rows(40)}),
        200,
      );
    }
    return ResponseBody.fromString('', 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  NKUSTHelper newHelper(_AcadAdapter adapter) {
    final NKUSTHelper helper = NKUSTHelper();
    helper.dio = Dio(BaseOptions(responseType: ResponseType.plain))
      ..httpClientAdapter = adapter;
    return helper;
  }

  test('scrolling to later pages reuses one fetch of the full list', () async {
    final _AcadAdapter adapter = _AcadAdapter();
    final NKUSTHelper helper = newHelper(adapter);

    final NotificationsData p1 = await helper.getNotifications(1);
    final NotificationsData p2 = await helper.getNotifications(2);
    final NotificationsData p3 = await helper.getNotifications(3);

    expect(adapter.posts, 1);
    expect(p1.data.notifications, hasLength(15));
    expect(p2.data.notifications, hasLength(15));
    expect(p3.data.notifications, hasLength(10));

    final Set<String?> l1 =
        p1.data.notifications.map((Notifications n) => n.link).toSet();
    final Set<String?> l2 =
        p2.data.notifications.map((Notifications n) => n.link).toSet();
    expect(l1.intersection(l2), isEmpty);
  });

  test('page 1 always refetches (initial load / pull-to-refresh)', () async {
    final _AcadAdapter adapter = _AcadAdapter();
    final NKUSTHelper helper = newHelper(adapter);

    await helper.getNotifications(1);
    await helper.getNotifications(2);
    await helper.getNotifications(1);

    expect(adapter.posts, 2);
  });

  test('past the end returns an empty window, no error', () async {
    final _AcadAdapter adapter = _AcadAdapter();
    final NKUSTHelper helper = newHelper(adapter);

    await helper.getNotifications(1);
    final NotificationsData far = await helper.getNotifications(99);
    expect(far.data.notifications, isEmpty);
  });
}
