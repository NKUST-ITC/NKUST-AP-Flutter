/// Pure-Dart NKUST scraping toolkit.
///
/// This package contains the crawler logic (helpers, parsers, models,
/// captcha algorithm) extracted from the nkust_ap Flutter app so it can be
/// reused from server-side / CLI / future native clients without dragging
/// in the Flutter SDK.
library;

// Abstractions
export 'src/abstractions/captcha_template_provider.dart';
export 'src/abstractions/crash_reporter.dart';
export 'src/abstractions/key_value_store.dart';

// Capabilities
export 'src/capabilities/bus_provider.dart';
export 'src/capabilities/course_provider.dart';
export 'src/capabilities/leave_provider.dart';
export 'src/capabilities/score_provider.dart';
export 'src/capabilities/semester_provider.dart';
export 'src/capabilities/user_info_provider.dart';

// Exceptions
export 'src/exceptions/ap_status_code.dart';
export 'src/exceptions/api_exception.dart';

// Interceptors
export 'src/interceptors/safe_cookie_manager.dart';

// Models
export 'src/models/booking_bus_data.dart';
export 'src/models/bus_data.dart';
export 'src/models/bus_reservations_data.dart';
export 'src/models/bus_violation_records_data.dart';
export 'src/models/cancel_bus_data.dart';
export 'src/models/crawler_selector.dart';
export 'src/models/error_response.dart';
export 'src/models/event_callback.dart';
export 'src/models/event_info_response.dart';
export 'src/models/item.dart';
export 'src/models/leave_campus_data.dart';
export 'src/models/leave_data.dart';
export 'src/models/leave_submit_data.dart';
export 'src/models/leave_submit_info_data.dart';
export 'src/models/login_response.dart';
export 'src/models/midterm_alerts_data.dart';
export 'src/models/models.dart';
export 'src/models/reward_and_penalty_data.dart';
export 'src/models/room_data.dart';
export 'src/models/schedule_data.dart';

// Parsers
export 'src/parsers/ap_parser.dart';
export 'src/parsers/leave_parser.dart';
export 'src/parsers/nkust_parser.dart';
export 'src/parsers/parser_utils.dart';
export 'src/parsers/stdsys_parser.dart';
export 'src/parsers/vms_bus_parser.dart';

// Registry
export 'src/registry/scraper_registry.dart';

// Session
export 'src/session/relogin_mixin.dart';
export 'src/session/session_state.dart';
