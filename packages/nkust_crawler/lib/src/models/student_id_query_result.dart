/// Outcome of a student-id lookup on
/// `stdsys.nkust.edu.tw/student/QueryStudentId`.
///
/// The lookup is fronted by Cloudflare Turnstile and verified server-side, so
/// it cannot be driven by a plain HTTP request — the host app runs it in a
/// WebView and feeds the resulting page to
/// [StdsysParser.queryStudentIdResultParser].
class StudentIdQueryResult {
  const StudentIdQueryResult.success({
    required String this.id,
    this.name,
  })  : message = null,
        isSuccess = true;

  const StudentIdQueryResult.failure([this.message])
      : id = null,
        name = null,
        isSuccess = false;

  final bool isSuccess;

  /// Student id, only set when [isSuccess].
  final String? id;

  /// Student name, only set when [isSuccess] and the page exposed it.
  final String? name;

  /// Message rendered by the server (e.g. 查無此人 / 機器人驗證失敗), only set
  /// when the lookup failed.
  final String? message;

  @override
  String toString() => isSuccess
      ? 'StudentIdQueryResult.success(id: $id, name: $name)'
      : 'StudentIdQueryResult.failure($message)';
}
