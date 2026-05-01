import 'package:ap_common/ap_common.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;

/// HTML parsers for `vms.nkust.edu.tw` bus pages and grid endpoints.
///
/// Extracted from the original `MobileNkustParser` so the VMS bus
/// scraper can live on its own without pulling in the mobile.nkust.edu.tw
/// portal scraping code that targets a different site entirely.
class VmsBusParser {
  /// Parses the VMS bus timetable page for top-level booking state
  /// (`canReserve`, optional description banner).
  static Map<String, dynamic> busInfo(String? rawHtml) {
    final Document document = html.parse(rawHtml);
    final String canNotReserveText =
        document.getElementById('BusMemberStop')!.attributes['value']!;
    final bool canReserve = !bool.fromEnvironment(canNotReserveText);
    final List<Element> elements =
        document.getElementsByClassName('alert alert-danger alert-dismissible');
    String description = '';
    if (elements.isNotEmpty) {
      description = elements.first.text;
    }
    return <String, dynamic>{
      'canReserve': canReserve,
      'description': description.trim().replaceAll(' ', ''),
    };
  }

  /// Parses one route's timetable grid (rows of departures).
  static List<Map<String, dynamic>> busTimeTable(
    dynamic rawHtml, {
    String? time,
    String? startStation,
    String? endStation,
  }) {
    final Document document = html.parse(rawHtml);

    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    for (final Element trElement
        in document.getElementsByTagName('tr').sublist(1)) {
      final Map<String, dynamic> temp = <String, dynamic>{};

      // Element can't get ById. so build new parser object.
      final Document inputDocument = html.parse(trElement.outerHtml);
      temp['canBook'] = true;

      if (inputDocument.getElementById('ReserveEnable')!.attributes['value'] ==
          null) {
        //can't book.
        temp['canBook'] = false;
      }
      temp['busId'] =
          inputDocument.getElementById('BusId')!.attributes['value'];
      temp['cancelKey'] =
          inputDocument.getElementById('ReserveId')!.attributes['value'];
      temp['isReserve'] = inputDocument
                  .getElementById('ReserveStateCode')!
                  .attributes['value'] ==
              '0' &&
          inputDocument.getElementById('ReserveId')!.attributes['value'] != '0';

      final List<Element> tdElements =
          trElement.getElementsByTagName('td').sublist(1);

      final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');

      temp['departureTime'] =
          format.parse('$time ${tdElements[0].text}').toIso8601String();
      temp['reserveCount'] = int.parse(tdElements[1].text);
      temp['homeCharteredBus'] = false;
      temp['specialTrain'] = '';
      temp['description'] = '';
      temp['startStation'] = startStation;
      temp['endStation'] = endStation;
      temp['limitCount'] = 999;

      if (tdElements[2].text != '') {
        if (tdElements[2].getElementsByTagName('button').isNotEmpty) {
          final String typeString = tdElements[2]
              .getElementsByTagName('button')[0]
              .text
              .replaceAll(' ', '')
              .replaceAll('\n', '');
          if (typeString == '返鄉專車') {
            temp['homeCharteredBus'] = true;
          }
          if (typeString == '試辦專車') {
            temp['specialTrain'] = '2';
          }
          temp['description'] = tdElements[2]
              .getElementsByTagName('button')[0]
              .attributes['data-content'];
        }
      }
      result.add(temp);
    }
    return result;
  }

  /// Parses the user's existing bus reservations (one request per route).
  static List<Map<String, dynamic>> busUserRecords(
    String rawHtml, {
    required String startStation,
    required String endStation,
  }) {
    final Document document = html.parse(rawHtml);
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];

    for (final Element trElement in document.getElementsByTagName('tr')) {
      final Map<String, dynamic> temp = <String, dynamic>{};
      temp['cancelKey'] =
          trElement.getElementsByTagName('input')[0].attributes['value'];
      final List<Element> tdElements = trElement.getElementsByTagName('td');

      temp['dateTime'] = '${tdElements[1].text.substring(0, 10)} '
          '${tdElements[1].text.substring(14)}';
      temp['state'] = '';
      temp['travelState'] = '';
      temp['start'] = startStation;
      temp['end'] = endStation;
      result.add(temp);
    }

    return result;
  }

  /// Parses the paid/unpaid violation records grid.
  static List<Map<String, dynamic>> busViolationRecords(
    String rawHtml, {
    required bool paidStatus,
  }) {
    final Document document = html.parse(rawHtml);
    final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
    final DateFormat format = DateFormat('yyyy/MM/dd HH:mm');

    for (final Element trElement in document.getElementsByTagName('tr')) {
      final Map<String, dynamic> temp = <String, dynamic>{};

      final List<Element> tdElements = trElement.getElementsByTagName('td');
      final Element timeElement = tdElements[1].getElementsByTagName('div')[0];
      temp['isPayment'] = paidStatus;
      final List<String> startAndGoal = tdElements[3].text.split(' 到 ');
      temp['startStation'] = startAndGoal[0];
      temp['endStation'] = startAndGoal[1];
      temp['amountend'] = int.parse(tdElements[4].text);
      temp['homeCharteredBus'] = false;

      temp['time'] = format.parse(
        '${timeElement.text.substring(0, 10)} '
        '${timeElement.text.substring(14)}',
      );
      result.add(temp);
    }
    return result;
  }
}
