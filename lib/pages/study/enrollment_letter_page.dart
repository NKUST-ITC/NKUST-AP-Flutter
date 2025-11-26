import 'dart:async';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/utils/global.dart';

class EnrollmentLetterPage extends StatefulWidget {
  static const String routerName = '/enrollmentLetter';

  const EnrollmentLetterPage({super.key});

  @override
  State<EnrollmentLetterPage> createState() => _EnrollmentLetterPageState();
}

class _EnrollmentLetterPageState extends State<EnrollmentLetterPage> {
  PdfState pdfState = PdfState.loading;
  late AppLocalizations app;
  Uint8List? data;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'EnrollmentLetterPage',
      'enrollment_letter_page.dart',
    );
    _getEnrollmentLetter();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(app.enrollmentLetter)),
      body: PdfView(
        state: pdfState,
        data: data,
        errorMessage: errorMessage,
        onRefresh: () {
          setState(() => pdfState = PdfState.loading);
          _getEnrollmentLetter();
        },
      ),
    );
  }

  Future<void> _getEnrollmentLetter() async {
    try {
      final response = await WebApHelper.instance.getEnrollmentLetter();
      final responseData = response.data;
      if (responseData == null || responseData.isEmpty) {
        setState(() {
          pdfState = PdfState.error;
          errorMessage = '查無在學證明資料';
        });
        return;
      }
      final bool isValidPdf = responseData.length >= 4 &&
          responseData[0] == 0x25 &&
          responseData[1] == 0x50 &&
          responseData[2] == 0x44 &&
          responseData[3] == 0x46;
      if (!isValidPdf) {
        final bool isHtml = responseData[0] == 0x3c;
        setState(() {
          pdfState = PdfState.error;
          errorMessage = isHtml ? '尚無在學證明可下載\n請確認是否已申請在學證明' : '無法取得有效的 PDF 文件';
        });
        return;
      }
      setState(() {
        pdfState = PdfState.finish;
        data = responseData;
      });
    } on GeneralResponse catch (e) {
      setState(() {
        pdfState = PdfState.error;
        errorMessage = e.message;
      });
    } on DioException catch (e) {
      setState(() {
        pdfState = PdfState.error;
        errorMessage = e.response?.statusCode == 404 ? '查無在學證明資料' : '網路錯誤：${e.message}';
      });
    } catch (e) {
      setState(() {
        pdfState = PdfState.error;
        errorMessage = '載入失敗：$e';
      });
    }
  }
}
