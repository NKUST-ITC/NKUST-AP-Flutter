import 'package:nkust_crawler/src/models/booking_bus_data.dart';
import 'package:nkust_crawler/src/models/bus_data.dart';
import 'package:nkust_crawler/src/models/bus_reservations_data.dart';
import 'package:nkust_crawler/src/models/bus_violation_records_data.dart';
import 'package:nkust_crawler/src/models/cancel_bus_data.dart';

/// Capability interface for bus-related operations.
///
/// Implemented by: [VmsBusHelper]
abstract class BusProvider {
  Future<BusData> getTimeTable({required DateTime dateTime});
  Future<BookingBusData> bookBus({required String busId});
  Future<CancelBusData> cancelBus({required String busId});
  Future<BusReservationsData> getReservations();
  Future<BusViolationRecordsData> getViolationRecords();
}
