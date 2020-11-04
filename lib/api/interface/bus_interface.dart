import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';

abstract class BusInterface {
  Future<GeneralResponse> login({String username, String password});

  Future<GeneralResponse> logout();

  Future<BusData> getTimeTable(
      {DateTime fromDateTime, String year, String month, String day});

  Future<BookingBusData> bookBus({String busId});

  Future<CancelBusData> cancelBusReservation({String busId});

  Future<BusReservationsData> getBusReservations();

  Future<BusViolationRecordsData> getBusViolationRecords();
}
