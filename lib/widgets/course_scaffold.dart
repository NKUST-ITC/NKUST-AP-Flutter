import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/widgets/course_table.dart';

enum CustomCourseState { loading, finish, error, empty, offlineEmpty, custom }

class CustomCourseScaffold extends StatefulWidget {
  final CustomCourseState state;
  final CourseData courseData;
  final String? title;
  final Widget? itemPicker;
  final String? customHint;
  final String? customStateHint;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearchButtonClick;

  const CustomCourseScaffold({
    super.key,
    required this.state,
    required this.courseData,
    this.title,
    this.itemPicker,
    this.customHint,
    this.customStateHint,
    this.onRefresh,
    this.onSearchButtonClick,
  });

  @override
  State<CustomCourseScaffold> createState() => _CustomCourseScaffoldState();
}

class _CustomCourseScaffoldState extends State<CustomCourseScaffold> {
  bool _isTableView = true;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ApLocalizations ap = ApLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            Flexible(
              child: Text(
                widget.title ?? ap.course,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.itemPicker != null) ...<Widget>[
              const SizedBox(width: 8),
              widget.itemPicker!,
            ],
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _isTableView ? Icons.list_rounded : Icons.grid_view_rounded,
            ),
            tooltip: _isTableView ? '列表模式' : '表格模式',
            onPressed: () {
              setState(() => _isTableView = !_isTableView);
            },
          ),
        ],
      ),
      body: _buildBody(colorScheme, ap),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, ApLocalizations ap) {
    return Column(
      children: <Widget>[
        if (widget.customHint != null && widget.customHint!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.customHint!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: _buildContent(colorScheme, ap),
        ),
      ],
    );
  }

  Widget _buildContent(ColorScheme colorScheme, ApLocalizations ap) {
    switch (widget.state) {
      case CustomCourseState.loading:
        return _buildLoadingState(colorScheme);
      case CustomCourseState.error:
        return _buildErrorState(
            colorScheme, ap.clickToRetry, Icons.error_outline_rounded);
      case CustomCourseState.empty:
        return _buildErrorState(
            colorScheme, ap.courseEmpty, Icons.event_busy_rounded);
      case CustomCourseState.offlineEmpty:
        return _buildErrorState(
            colorScheme, ap.noOfflineData, Icons.cloud_off_rounded);
      case CustomCourseState.custom:
        return _buildErrorState(
          colorScheme,
          widget.customStateHint ?? ap.somethingError,
          Icons.warning_amber_rounded,
        );
      case CustomCourseState.finish:
        return _buildCourseContent();
    }
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '載入課表中...',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      ColorScheme colorScheme, String message, IconData icon) {
    return InkWell(
      onTap: widget.onRefresh,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(77),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '點擊重試',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseContent() {
    if (_isTableView) {
      return CourseTableWidget(
        courseData: widget.courseData,
        onRefresh: widget.onRefresh,
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async {
          widget.onRefresh?.call();
        },
        child: CourseListWidget(courseData: widget.courseData),
      );
    }
  }
}
