import 'dart:async';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/ap_helper.dart';
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
  late AppLocalizations app;
  Uint8List? data;
  late EnrollmentLetterLang selectedLang;
  String? errorMessage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'EnrollmentLetterPage',
      'enrollment_letter_page.dart',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      selectedLang = _defaultLangForLocale(Localizations.localeOf(context));
      _getEnrollmentLetter();
    }
  }

  EnrollmentLetterLang _defaultLangForLocale(Locale locale) {
    return switch (locale.languageCode) {
      'zh' || 'ja' => EnrollmentLetterLang.chinese,
      _ => EnrollmentLetterLang.english,
    };
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.enrollmentLetter),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OptionPickerBottomSheet.fromOptions(
              title: context.ap.language,
              titleIcon: Icons.translate_rounded,
              buttonIcon: Icons.language_rounded,
              options: [
                PickerOption(value: 0, label: app.traditionalChinese),
                const PickerOption(value: 1, label: 'English'),
              ],
              selectedValue: selectedLang.index,
              onSelect: (v) {
                setState(() {
                  selectedLang = EnrollmentLetterLang.values[v];
                  pdfState = PdfState.loading;
                });
                _getEnrollmentLetter();
              },
            ),
          ),
        ],
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
          await StdsysHelper.instance.getEnrollmentLetter(selectedLang);
      final responseData = response.data;
      if (responseData == null || responseData.isEmpty) {
        setState(() {
          pdfState = PdfState.error;
          errorMessage = app.noEnrollmentData;
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
          errorMessage =
              isHtml ? app.noEnrollmentAvailable : app.invalidPdfFormat;
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
        errorMessage = e.response?.statusCode == 404
            ? app.noEnrollmentData
            : app.networkError.replaceAll('%s', e.message ?? '');
      });
    } catch (e) {
      setState(() {
        pdfState = PdfState.error;
        errorMessage = app.loadFailed.replaceAll('%s', e.toString());
      });
    }
  }
}
