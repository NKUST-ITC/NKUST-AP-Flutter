import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';

/// Capability interface for bus-related operations.
///
/// Implemented by: [BusHelper]
abstract class BusProvider {
  Future<BusData> getTimeTable({required DateTime dateTime});
  Future<BookingBusData> bookBus({required String busId});
  Future<CancelBusData> cancelBus({required String busId});
  Future<BusReservationsData> getReservations();
  Future<BusViolationRecordsData> getViolationRecords();
}
