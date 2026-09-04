/// Pure-Dart Zuvio IRS (irs.zuvio.com.tw) scraping toolkit.
///
/// Zuvio is a cross-university classroom-response platform; this package
/// keeps its login / course / rollcall / history logic Flutter-free so
/// it can be reused outside the nkust_ap app.
library;

export 'src/models/models.dart';
export 'src/parsers/course_info_parser.dart' show parseCourseInfo;
export 'src/zuvio_client.dart' show ZuvioClient;
export 'src/zuvio_exception.dart';
export 'src/zuvio_helper.dart' show ZuvioHelper;
