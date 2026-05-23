import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State {
  loading,
  finish,
  error,
  empty,
  offline,
  custom,
}

class HistoryTranscriptPage extends StatefulWidget {
  static const String routerName = '/history_transcript';

  const HistoryTranscriptPage({super.key});

  @override
  State<HistoryTranscriptPage> createState() => _HistoryTranscriptPageState();
}

class _HistoryTranscriptPageState extends State<HistoryTranscriptPage> {
  _State state = _State.loading;
  PdfState pdfState = PdfState.loading;
  late NkustLocalizations app;
  Uint8List? data;
  Semester? selectSemester;
  SemesterData? semesterData;
  final SemesterPickerController _pickerController = SemesterPickerController();
  String get courseNotifyCacheKey => PreferenceUtil.instance.getString(
        ApConstants.currentSemesterCode,
        ApConstants.semesterLatest,
      );
  String? errorMessage;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'HistoryTranscriptPage',
      'history_transcript_page.dart',
    );
    _getSemester();
    super.initState();
  }

  Future<void> _getSemester() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      final SemesterData? cacheData = SemesterData.load();
      if (cacheData != null && mounted) {
        setState(() {
          semesterData = cacheData.copyWith(
            currentIndex: cacheData.defaultIndex,
          );
          selectSemester = semesterData!.defaultSemester;
        });
      }
      return;
    }
    try {
      final SemesterData data = await Helper.instance.getSemester();
      data.save();
      if (mounted) {
        setState(() {
          semesterData = data.copyWith(currentIndex: data.defaultIndex);
          selectSemester = data.defaultSemester;
        });
        _getTranscriptData();
      }
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (mounted) {
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
      }
      if (e is ServerException && e.httpStatusCode != null) {
        AnalyticsUtil.instance.logApiEvent(
          'getSemester',
          e.httpStatusCode!,
          message: e.message,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    app = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(app.enrollmentLetter),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: semesterData == null ? null :
            SemesterPicker(
              semesterData: semesterData!,
              currentIndex: semesterData!.currentIndex,
              featureTag: 'historytranscript',
              controller: _pickerController,
              onSelect: (Semester semester, int index) {
                setState(() {
                  selectSemester = semester;
                  semesterData = semesterData?.copyWith(currentIndex: index);
                  state = _State.loading;
                });
                _getTranscriptData();
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: semesterData == null
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.search),
              onPressed: () {
                SemesterPicker.show(
                  context: context,
                  semesterData: semesterData!,
                  currentIndex: semesterData!.currentIndex,
                  controller: _pickerController,
                  onSelect: (Semester semester, int index) {
                    setState(() {
                      selectSemester = semester;
                      semesterData =
                          semesterData?.copyWith(currentIndex: index);
                      state = _State.loading;
                    });
                    _getTranscriptData();
                  },
                );
              },
            ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _getTranscriptData();
                AnalyticsUtil.instance.logEvent('refresh_swipe');
                return;
              },
              child: _body(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      case _State.empty:
      case _State.error:
      case _State.offline:
      case _State.custom:
        return InkWell(
          onTap: () {
            if (state == _State.empty) {
              if (semesterData != null) {
                SemesterPicker.show(
                  context: context,
                  semesterData: semesterData!,
                  currentIndex: semesterData!.currentIndex,
                  controller: _pickerController,
                  onSelect: (Semester semester, int index) {
                    setState(() {
                      selectSemester = semester;
                      semesterData =
                          semesterData?.copyWith(currentIndex: index);
                      state = _State.loading;
                    });
                    _getTranscriptData();
                  },
                );
              }
            } else {
              _getTranscriptData();
            }
            AnalyticsUtil.instance.logEvent('retry_click');
          },
        );
      case _State.finish:
        return PdfView(
          state: pdfState,
          data: data,
          errorMessage: errorMessage,
          onRefresh: () {
            setState(() => pdfState = PdfState.loading);
            _getTranscriptData();
          },
        );
    }
  }

  Future<void> _getTranscriptData() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    try {
      final Response<Uint8List> response =
          await Helper.instance.getHistoryTranscript(semester: selectSemester!);
      final Uint8List? responseData = response.data;
      if (mounted) {
        if (responseData == null || responseData.isEmpty) {
          setState(() {
            state = _State.empty;
            pdfState = PdfState.error;
            errorMessage = app.noData;
            _pickerController.markSemesterEmpty(selectSemester!);
          });
          return;
        }
        final bool isValidPdf = responseData.length >= 4 &&
            responseData[0] == 0x25 &&
            responseData[1] == 0x50 &&
            responseData[2] == 0x44 &&
            responseData[3] == 0x46;
        if (!isValidPdf) {
          final String text = utf8.decode(responseData);
          if (text.contains('不開放')) {
            setState(() {
              pdfState = PdfState.error;
              state = _State.finish;
              errorMessage = app.notOpened;
              _pickerController.markSemesterEmpty(selectSemester!);
            });
            return;
          }
          setState(() {
            pdfState = PdfState.error;
            state = _State.error;
            errorMessage = app.invalidPdfFormat;
          });
          return;
        }
        final String rawtext = latin1.decode(responseData);
        if (rawtext.contains('Length 0') || rawtext.contains('Length 151')) {
            setState(() {
            pdfState = PdfState.error;
            state = _State.finish;
            errorMessage = ap.noData;
            _pickerController.markSemesterEmpty(selectSemester!);
          });
          return;
        }
        setState(() {
          pdfState = PdfState.finish;
          state = _State.finish;
          data = responseData;
          _pickerController.markSemesterHasData(selectSemester!);
        });
      }
    } on ApException catch (e) {
      if (e is CancelledException) return;
      setState(() {
        pdfState = PdfState.error;
        state = _State.error;
        // Keep the 404 special case (no enrollment letter available for
        // this student) mapped to a dedicated user message.
        if (e is ServerException && e.httpStatusCode == 404) {
          errorMessage = app.noData;
        } else {
          errorMessage = e.toLocalizedMessage(context);
        }
      });
    }
  }
}
