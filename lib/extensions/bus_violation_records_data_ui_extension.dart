import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/utils/utils.dart';

extension ReservationUiX on Reservation {
  String? startStationText(BuildContext context) {
    return Utils.parserCampus(context.t, startStation);
  }

  String? endStationText(NkustLocalizations local) {
    return Utils.parserCampus(local, endStation);
  }
}
