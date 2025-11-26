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
      setState(() {
        pdfState = PdfState.finish;
        data = response.data;
      });
    } catch (_) {
      setState(() {
        pdfState = PdfState.error;
        errorMessage = '查無繳費紀錄';
      });
    }
  }
}
