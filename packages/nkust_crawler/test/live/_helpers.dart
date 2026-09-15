import 'dart:io';
import 'dart:typed_data';

import 'package:ap_common_core/ap_common_core.dart';
import 'package:nkust_crawler/nkust_crawler.dart';

/// In-memory [KeyValueStore] so live tests don't pollute / read from the
/// host machine's preference storage. Wired via [configureCrawlerStorage].
class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = <String, String>{};

  @override
  String getString(String key, String fallback) => _data[key] ?? fallback;

  @override
  void setString(String key, String value) => _data[key] = value;
}

/// Loads BMP glyph templates straight off disk. Used in live tests so the
/// real Euclidean-distance solver can decode webap's captcha without
/// needing Flutter's `rootBundle`.
class FileSystemTemplateProvider implements CaptchaTemplateProvider {
  FileSystemTemplateProvider(this.directory);

  final Directory directory;

  @override
  Future<Uint8List> loadTemplate(String char) async {
    final File file = File('${directory.path}/$char.bmp');
    return file.readAsBytes();
  }
}

/// Wall-clock heuristic for "the academic semester a student is currently
/// in" on Taiwan's calendar, used by tests that need a `Semester` without
/// trusting whatever `getSemester()` returns as `defaultSemester` (the
/// live API hands back the most recent transcript-bearing term, which is
/// often last semester rather than this one).
///
/// Rule:
/// - Mar–Sep: ROC year = (calendar year − 1911) − 1, semester value = 2
/// - Oct–Dec: ROC year =  calendar year − 1911,       semester value = 1
/// - Jan–Feb: ROC year = (calendar year − 1911) − 1, semester value = 1
///
/// e.g. any time in 2026-03 to 2026-09 → 114-2; 2026-10 to 2027-02 → 115-1.
Semester currentAcademicSemester([DateTime? now]) {
  final DateTime when = now ?? DateTime.now();
  final int month = when.month;
  final int rocYear;
  final int value;
  if (month >= 3 && month <= 9) {
    rocYear = when.year - 1911 - 1;
    value = 2;
  } else if (month >= 10) {
    rocYear = when.year - 1911;
    value = 1;
  } else {
    rocYear = when.year - 1911 - 1;
    value = 1;
  }
  return Semester(
    year: rocYear.toString(),
    value: value.toString(),
    text: '$rocYear學年第${value == 1 ? '一' : '二'}學期',
  );
}

/// Masks PII (student id, name, etc.) for `print()` calls inside live
/// tests so that pasted output doesn't accidentally leak the running
/// account's data into chat / screenshots / CI logs.
///
/// - null:   `<null>`.
/// - empty:  `<empty>`.
/// - 1 char: `••`.
/// - 2 char: first char + `•` (e.g. `梁•`).
/// - ≥3 char: first char + middle bullets + last char (e.g. `C•••••••117`).
String redact(String? value) {
  if (value == null) return '<null>';
  if (value.isEmpty) return '<empty>';
  if (value.length == 1) return '••';
  if (value.length == 2) return '${value[0]}•';
  return '${value[0]}${"•" * (value.length - 2)}${value[value.length - 1]}';
}

/// Trusts the TWCA roots NKUST's certificates chain to, on top of the
/// platform's own root store.
///
/// NKUST hosts are signed by TWCA, and not every TWCA root is in every
/// platform store — `TWCA CYBER Root CA`, which the current
/// `*.nkust.edu.tw` leaf chains to, is missing from Apple's and from the
/// CI runner's Mozilla bundle. This used to be papered over by disabling
/// certificate verification for the whole test process, which also meant
/// the live tests could never catch the school moving to a CA the app
/// doesn't trust — exactly the regression that broke iOS in 2026-09.
///
/// So the harness now loads the same `assets/ca/twca_roots.pem` the app
/// ships and leaves verification on. Roots outlive leaves (the CYBER one
/// runs to 2047), so this does not need the annual refresh the old
/// bundled leaf did.
void trustNkustRoots() {
  HttpOverrides.global = _TwcaRootsHttpOverrides(findCaBundle().readAsBytesSync());
}

class _TwcaRootsHttpOverrides extends HttpOverrides {
  _TwcaRootsHttpOverrides(Uint8List roots)
      : _context = SecurityContext(withTrustedRoots: true) {
    try {
      _context.setTrustedCertificatesBytes(roots);
    } on TlsException {
      // Already present in the platform store — nothing to add.
    }
  }

  final SecurityContext _context;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(_context);
}

/// Locates `assets/ca/twca_roots.pem` regardless of whether the test is
/// run from the repo root or from `packages/nkust_crawler/`.
File findCaBundle() {
  for (final String candidate in <String>[
    'assets/ca/twca_roots.pem',
    '../../assets/ca/twca_roots.pem',
  ]) {
    final File file = File(candidate);
    if (file.existsSync()) return file;
  }
  throw StateError(
    'Could not locate assets/ca/twca_roots.pem relative to '
    '${Directory.current.path}',
  );
}

/// Locates `assets/eucdist/` regardless of whether the test is run from
/// the repo root or from `packages/nkust_crawler/`.
Directory findTemplateDir() {
  for (final String candidate in <String>[
    'assets/eucdist',
    '../../assets/eucdist',
  ]) {
    final Directory dir = Directory(candidate);
    if (dir.existsSync()) return dir;
  }
  throw StateError(
    'Could not locate assets/eucdist relative to ${Directory.current.path}',
  );
}
