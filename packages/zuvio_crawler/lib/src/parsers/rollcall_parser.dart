import 'package:zuvio_crawler/src/models/models.dart';

final RegExp _rollcallId =
    RegExp(r'''(?:var\s+rollcall_id\s*=\s*|makeRollcall\(\s*)['"]?(\d+)['"]?''');

/// Parses `/student5/irs/rollcall/<courseId>`.
///
/// When a rollcall is running the page shows「簽到開放中」and renders the
/// active id (in `var rollcall_id = '<id>'` or a `makeRollcall('<id>')`
/// button); otherwise it shows「未開放簽到」.
ZuvioRollcall parseRollcall(String html) {
  final bool answered =
      html.contains('您已簽到') || html.contains('rollcall-refinish');
  final bool open = html.contains('簽到開放中') || html.contains('請點擊按鈕簽到');

  final String id = _rollcallId
          .allMatches(html)
          .map((RegExpMatch m) => m.group(1) ?? '')
          .firstWhere((String s) => s.isNotEmpty, orElse: () => '') ;

  if (answered && id.isNotEmpty) {
    return ZuvioRollcall(
      rollcallId: id,
      state: ZuvioRollcallState.answered,
    );
  }
  if (open && id.isNotEmpty) {
    return ZuvioRollcall(rollcallId: id, state: ZuvioRollcallState.open);
  }
  return const ZuvioRollcall.notOpen();
}
