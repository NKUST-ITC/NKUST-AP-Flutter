import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/utils/utils.dart';

extension BusReservationUiX on BusReservation {
  Color getColorState(BuildContext context) {
    return ApTheme.of(context).grey;
  }

  String getDate() {
    initializeDateFormatting();
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateFormat formatterTime = DateFormat('yyyy/MM/dd');
    return formatterTime.format(formatterDateTime.parse(dateTime));
  }

  String getTime() {
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateFormat formatterTime = DateFormat('HH:mm');
    return formatterTime.format(formatterDateTime.parse(dateTime));
  }

  DateTime getDateTime() {
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    return formatterDateTime.parse(dateTime);
  }

  String getDateTimeStr() {
    final DateFormat formatterDateTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateFormat formatterTime = DateFormat('yyyy/MM/dd HH:mm');
    final DateTime s = formatterDateTime.parse(dateTime);
    return formatterTime.format(s);
  }

  String getStart(NkustLocalizations? local) {
    return Utils.parserCampus(local, start);
  }

  String getEnd(NkustLocalizations? local) {
    return Utils.parserCampus(local, end);
  }
}
