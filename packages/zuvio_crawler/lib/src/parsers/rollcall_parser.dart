import 'package:zuvio_crawler/src/models/models.dart';

final RegExp _rollcallId =
    RegExp(r'''var\s+rollcall_id\s*=\s*['"]([^'"]*)['"]''');
final RegExp _answeredMakeRollcall =
    RegExp(r'''makeRollcall\(\s*['"]?(\d+)['"]?\s*\)''');

/// Parses `/student5/irs/rollcall/<courseId>`.
///
/// When a rollcall is running the page renders `var rollcall_id = '<id>'`
/// (and a submit button wired to `makeRollcall('<id>')`); when none is
/// running the id is an empty string.
ZuvioRollcall parseRollcall(String html) {
  final String? inlineId = _rollcallId.firstMatch(html)?.group(1);
  final String? btnId = _answeredMakeRollcall.firstMatch(html)?.group(1);
  final String id = (inlineId != null && inlineId.isNotEmpty)
      ? inlineId
      : (btnId ?? '');
  if (id.isEmpty) return const ZuvioRollcall.notOpen();

  final bool answered = html.contains('i-r-f-b-answered') ||
      html.contains('rollcall-refinish') && html.contains('g-f-b-b-answered');
  return ZuvioRollcall(
    rollcallId: id,
    state: answered ? ZuvioRollcallState.answered : ZuvioRollcallState.open,
  );
}
