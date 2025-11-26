import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';

typedef SemesterCallback = void Function(Semester semester, int index);

class SemesterPicker extends StatefulWidget {
  final SemesterCallback? onSelect;
  final String? featureTag;

  const SemesterPicker({super.key, this.onSelect, this.featureTag});

  @override
  SemesterPickerState createState() => SemesterPickerState();
}

class SemesterPickerState extends State<SemesterPicker> {
  late SemesterData semesterData;
  Semester? selectSemester;

  int currentIndex = 0;
  final Set<String> _emptySemesters = <String>{};
  final Set<String> _loadingSemesters = <String>{};
  BuildContext? _sheetContext;
  StateSetter? _sheetSetState;

  @override
  void initState() {
    _getSemester();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String displayText = selectSemester != null
        ? _getShortSemesterText(selectSemester!)
        : '';

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          if (selectSemester != null) pickSemester();
          if (widget.featureTag != null) {
            AnalyticsUtil.instance
                .logEvent('${widget.featureTag}_item_picker_click');
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                displayText,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortSemesterText(Semester semester) {
    final String name = _getSemesterName(semester.value);
    if (name.isNotEmpty) {
      return '${semester.year} $name';
    }
    return semester.text;
  }

  void markSemesterEmpty(Semester semester) {
    _loadingSemesters.remove(semester.code);
    _emptySemesters.add(semester.code);
    _sheetSetState?.call(() {});
    if (mounted) setState(() {});
  }

  void markSemesterHasData(Semester semester) {
    _loadingSemesters.remove(semester.code);
    _emptySemesters.remove(semester.code);
    if (_sheetContext != null && Navigator.of(_sheetContext!).canPop()) {
      Navigator.of(_sheetContext!).pop();
      _sheetContext = null;
      _sheetSetState = null;
    }
    if (mounted) setState(() {});
  }

  void markSemesterLoading(Semester semester) {
    _loadingSemesters.add(semester.code);
    _sheetSetState?.call(() {});
    if (mounted) setState(() {});
  }

  bool isSemesterEmpty(Semester semester) {
    return _emptySemesters.contains(semester.code);
  }

  bool isSemesterLoading(Semester semester) {
    return _loadingSemesters.contains(semester.code);
  }

  Future<void> _loadSemesterData() async {
    final SemesterData? cacheData = SemesterData.load();
    if (cacheData != null) {
      semesterData = cacheData;
      widget.onSelect
          ?.call(semesterData.defaultSemester, semesterData.defaultIndex);
      if (mounted) {
        setState(() {
          selectSemester = semesterData.defaultSemester;
        });
      }
    }
  }

  Future<void> _getSemester() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      _loadSemesterData();
      return;
    }
    Helper.instance.getSemester(
      callback: GeneralCallback<SemesterData>(
        onSuccess: (SemesterData data) {
          semesterData = data;
          semesterData.save();
          final String newSemester =
              '${Helper.username}_${semesterData.defaultSemester.code}';
          PreferenceUtil.instance.setString(
            ApConstants.currentSemesterCode,
            newSemester,
          );
          if (mounted) {
            currentIndex = semesterData.defaultIndex;
            widget.onSelect?.call(
              semesterData.defaultSemester,
              semesterData.defaultIndex,
            );
            setState(() {
              selectSemester = semesterData.defaultSemester;
            });
          }
        },
        onFailure: (DioException e) {
          if (e.i18nMessage != null) {
            UiUtil.instance.showToast(context, e.i18nMessage!);
          }
          if (e.hasResponse) {
            AnalyticsUtil.instance.logApiEvent(
              'getSemester',
              e.response!.statusCode!,
              message: e.message ?? '',
            );
          }
        },
        onError: (GeneralResponse response) {
          UiUtil.instance
              .showToast(context, response.getGeneralMessage(context));
        },
      ),
    );
  }

  int _getSemesterSortValue(String value) {
    switch (value) {
      case '4':
        return 1;
      case '6':
        return 2;
      case '7':
        return 3;
      case '2':
        return 4;
      case '3':
        return 5;
      case '1':
        return 6;
      case '5':
        return 7;
      default:
        return 99;
    }
  }

  String _getSemesterName(String value) {
    switch (value) {
      case '1':
        return '上學期';
      case '2':
        return '下學期';
      case '3':
        return '寒修';
      case '4':
        return '暑修';
      case '5':
        return '先修';
      case '6':
        return '暑修(一)';
      case '7':
        return '暑修(特)';
      default:
        return '';
    }
  }

  IconData _getSemesterIcon(String value) {
    switch (value) {
      case '1':
        return Icons.looks_one_rounded;
      case '2':
        return Icons.looks_two_rounded;
      case '3':
        return Icons.ac_unit_rounded;
      case '4':
      case '6':
      case '7':
        return Icons.wb_sunny_rounded;
      case '5':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  Color _getSemesterColor(String value, ColorScheme colorScheme) {
    switch (value) {
      case '1':
        return colorScheme.primaryContainer.withAlpha(179);
      case '2':
        return colorScheme.secondaryContainer.withAlpha(179);
      case '3':
        return colorScheme.errorContainer.withAlpha(128);
      case '5':
        return colorScheme.primaryContainer.withAlpha(102);
      case '4':
      case '6':
      case '7':
        return colorScheme.tertiaryContainer.withAlpha(179);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  List<MapEntry<int, Semester>> _getSortedSemesters() {
    final List<MapEntry<int, Semester>> indexed = <MapEntry<int, Semester>>[];
    for (int i = 0; i < semesterData.data.length; i++) {
      indexed.add(MapEntry<int, Semester>(i, semesterData.data[i]));
    }

    indexed.sort((MapEntry<int, Semester> a, MapEntry<int, Semester> b) {
      final int yearA = int.tryParse(a.value.year) ?? 0;
      final int yearB = int.tryParse(b.value.year) ?? 0;

      if (yearA != yearB) {
        return yearB.compareTo(yearA);
      }

      final int semA = _getSemesterSortValue(a.value.value);
      final int semB = _getSemesterSortValue(b.value.value);
      return semA.compareTo(semB);
    });

    return indexed;
  }

  void pickSemester() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ApLocalizations ap = ApLocalizations.of(context);
    final List<MapEntry<int, Semester>> sortedSemesters = _getSortedSemesters();

    final Map<String, List<MapEntry<int, Semester>>> groupedByYear =
        <String, List<MapEntry<int, Semester>>>{};
    for (final MapEntry<int, Semester> entry in sortedSemesters) {
      final String year = entry.value.year;
      groupedByYear.putIfAbsent(year, () => <MapEntry<int, Semester>>[]);
      groupedByYear[year]!.add(entry);
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        _sheetContext = sheetContext;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            _sheetSetState = setSheetState;

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_month_rounded,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              ap.pickSemester,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withAlpha(128),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: groupedByYear.length,
                          itemBuilder: (BuildContext context, int groupIndex) {
                            final String year =
                                groupedByYear.keys.elementAt(groupIndex);
                            final List<MapEntry<int, Semester>> semesters =
                                groupedByYear[year]!;

                            return _buildYearGroup(
                              context,
                              year,
                              semesters,
                              colorScheme,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _sheetContext = null;
      _sheetSetState = null;
    });
  }

  Widget _buildYearGroup(
    BuildContext context,
    String year,
    List<MapEntry<int, Semester>> semesters,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$year 學年度',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        ...semesters.map(
          (MapEntry<int, Semester> entry) => _buildSemesterItem(
            context,
            entry.key,
            entry.value,
            colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterItem(
    BuildContext context,
    int originalIndex,
    Semester semester,
    ColorScheme colorScheme,
  ) {
    final bool isSelected = originalIndex == currentIndex;
    final bool isDefault = originalIndex == semesterData.defaultIndex;
    final bool isEmpty = isSemesterEmpty(semester);
    final bool isLoading = isSemesterLoading(semester);
    final bool isDisabled = isEmpty || isLoading;
    final String semesterName = _getSemesterName(semester.value);
    final String displayName =
        semesterName.isNotEmpty ? semesterName : semester.text;

    return Opacity(
      opacity: isEmpty ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isEmpty
              ? colorScheme.surfaceContainerHighest
              : isLoading
                  ? colorScheme.primaryContainer.withAlpha(128)
                  : isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? colorScheme.outlineVariant.withAlpha(51)
                : isLoading
                    ? colorScheme.primary.withAlpha(128)
                    : isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withAlpha(77),
            width: isSelected || isLoading ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  markSemesterLoading(semester);
                  currentIndex = originalIndex;
                  selectSemester = semesterData.data[currentIndex];
                  widget.onSelect!(semesterData.data[currentIndex], currentIndex);
                },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? colorScheme.outlineVariant.withAlpha(77)
                        : isLoading
                            ? colorScheme.primary.withAlpha(77)
                            : isSelected
                                ? colorScheme.primary
                                : _getSemesterColor(semester.value, colorScheme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : Icon(
                            isEmpty
                                ? Icons.block_rounded
                                : _getSemesterIcon(semester.value),
                            size: 22,
                            color: isEmpty
                                ? colorScheme.onSurfaceVariant
                                : isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onPrimaryContainer,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isEmpty
                                    ? colorScheme.onSurfaceVariant
                                    : isLoading
                                        ? colorScheme.primary
                                        : isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLoading) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withAlpha(26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '載入中',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ] else if (isEmpty) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.outlineVariant.withAlpha(77),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '無資料',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ] else if (isDefault) ...<Widget>[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '目前',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onTertiary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        semester.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                else if (isEmpty)
                  Icon(
                    Icons.lock_outline_rounded,
                    color: colorScheme.outlineVariant,
                    size: 20,
                  )
                else if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorScheme.primary,
                  )
                else
                  Icon(
                    Icons.circle_outlined,
                    color: colorScheme.outlineVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
