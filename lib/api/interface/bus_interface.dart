import 'package:flutter/foundation.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_data.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';

abstract class BusInterface {
  Future<GeneralResponse> login({
    @required String username,
    @required String password,
  });

  Future<GeneralResponse> logout();

  Future<BusData> getTimeTable({
    @required DateTime fromDateTime,
    @required String year,
    @required String month,
    @required String day,
  });

  Future<BookingBusData> bookBus({
    @required String busId,
  });

  Future<CancelBusData> cancelBusReservation({
    @required String busId,
  });

  Future<BusReservationsData> getBusReservations();

  Future<BusViolationRecordsData> getBusViolationRecords();
}
