import 'dart:async';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/stdsys_helper.dart';
import 'package:nkust_ap/utils/global.dart';

class EnrollmentLetterPage extends StatefulWidget {
  static const String routerName = '/enrollmentLetter';

  const EnrollmentLetterPage({super.key});

  @override
  State<EnrollmentLetterPage> createState() => _EnrollmentLetterPageState();
}

class _EnrollmentLetterPageState extends State<EnrollmentLetterPage> {
  PdfState pdfState = PdfState.loading;

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.enrollmentLetter),
      ),
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
      final Response<Uint8List> response =
          await StdsysHelper.instance.getEnrollmentLetter();
      setState(() {
        pdfState = PdfState.finish;
        data = response.data;
      });
    } catch (e) {
      setState(() {
        pdfState = PdfState.error;
        errorMessage = '查無繳費紀錄';
      });
      rethrow;
    }
  }
}
