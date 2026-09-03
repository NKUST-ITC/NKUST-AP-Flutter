import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/utils/utils.dart';

extension BusTimeUiX on BusTime {
  String getSpecialTrainTitle(NkustLocalizations? local) {
    switch (specialTrain) {
      case '1':
        return local!.specialBus;
      case '2':
        return local!.trialBus;
      default:
        return '';
    }
  }

  @Deprecated('legacy config')
  String getEndEnrollDateTime() {
    initializeDateFormatting();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss ');
    return dateFormat.format(endEnrollDateTime!);
  }

  Color getColorState(BuildContext context) {
    return isReserve
        ? ApTheme.of(context).blueAccent
        : canReserve()
            ? ApTheme.of(context).grey
            : ApTheme.of(context).disabled;
  }

  String getReserveState(NkustLocalizations? local) {
    return isReserve
        ? local!.reserved
        : canReserve()
            ? local!.reserve
            : local!.canNotReserve;
  }

  String getDate() {
    initializeDateFormatting();
    final DateFormat formatterTime = DateFormat('yyyy-MM-dd');
    return formatterTime.format(departureTime);
  }

  String getTime() {
    initializeDateFormatting();
    final DateFormat formatterTime = DateFormat('HH:mm', 'zh');
    return formatterTime.format(departureTime);
  }

  String? getStart(NkustLocalizations? local) {
    return Utils.parserCampus(local, startStation);
  }

  String? getEnd(NkustLocalizations? local) {
    return Utils.parserCampus(local, endStation);
  }
}
