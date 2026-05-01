import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;

/// Extracts the ASP.NET `__RequestVerificationToken` CSRF value from an
/// HTML form payload. Returns an empty string when the form either has
/// no such input or the input lacks a `value` attribute — callers that
/// genuinely need the token should treat that as an error separately.
String getCSRF(dynamic rawHtml) {
  final Document document = html.parse(rawHtml);
  for (final Element inputElement in document.getElementsByTagName('input')) {
    if ((inputElement.attributes['name'] ?? '') ==
        '__RequestVerificationToken') {
      return inputElement.attributes['value'] ?? '';
    }
  }
  return '';
}

/// Strips HTTP chunked-transfer-encoding hex length markers that leak into
/// the response body, then UTF-8 decodes the result.
///
/// WebAP and Stdsys occasionally return bodies where the chunk size lines
/// (e.g. `\r\n1F4\r\n`) are still embedded in the payload instead of being
/// consumed by the transport layer. Strip any `\r\n<hex>\r\n` segment whose
/// hex run is 1–4 characters long before decoding.
String clearTransEncoding(List<int> htmlBytes) {
  // htmlBytes is fixed-length list, need copy.
  final List<int> tempData = List<int>.from(htmlBytes);

  //Add /r/n on first word.
  tempData.insert(0, 10);
  tempData.insert(0, 13);

  int startIndex = 0;
  for (int i = 0; i < tempData.length - 1; i++) {
    //check i and i+1 is /r/n
    if (tempData[i] == 13 && tempData[i + 1] == 10) {
      if (i - startIndex - 2 <= 4 && i - startIndex - 2 > 0) {
        //check in this range word is number or A~F (Hex)
        int removeCount = 0;
        for (int strIndex = startIndex + 2; strIndex < i; strIndex++) {
          if ((tempData[strIndex] > 47 && tempData[strIndex] < 58) ||
              (tempData[strIndex] > 64 && tempData[strIndex] < 71) ||
              (tempData[strIndex] > 96 && tempData[strIndex] < 103)) {
            removeCount++;
          }
        }
        if (removeCount == i - startIndex - 2) {
          tempData.removeRange(startIndex, i + 2);
        }
        //Subtract offset
        i -= i - startIndex - 2;
        startIndex -= i - startIndex - 2;
      }
      startIndex = i;
    }
  }

  return utf8.decode(tempData, allowMalformed: true);
}
