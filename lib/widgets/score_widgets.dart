import 'dart:math';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';

enum CustomScoreState { loading, finish, error, empty, offlineEmpty, custom }

class CustomScoreScaffold extends StatefulWidget {
  final CustomScoreState state;
  final ScoreData? scoreData;
  final String? customHint;
  final String? customStateHint;
  final Widget? itemPicker;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearchButtonClick;

  const CustomScoreScaffold({
    super.key,
    required this.state,
    this.scoreData,
    this.customHint,
    this.customStateHint,
    this.itemPicker,
    this.onRefresh,
    this.onSearchButtonClick,
  });

  @override
  State<CustomScoreScaffold> createState() => _CustomScoreScaffoldState();
}

class _CustomScoreScaffoldState extends State<CustomScoreScaffold> {
  bool _isAnalysisView = true;

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
            Text(ap.score),
            if (widget.itemPicker != null) ...<Widget>[
              const SizedBox(width: 12),
              widget.itemPicker!,
            ],
          ],
        ),
        actions: <Widget>[
          if (widget.state == CustomScoreState.finish)
            IconButton(
              icon: Icon(
                _isAnalysisView ? Icons.list_alt_rounded : Icons.analytics_outlined,
              ),
              tooltip: _isAnalysisView ? '科目詳情' : '成績總覽',
              onPressed: () {
                setState(() => _isAnalysisView = !_isAnalysisView);
              },
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (widget.customHint != null && widget.customHint!.isNotEmpty) _buildHintBanner(colorScheme),
          Expanded(
            child: _buildContent(context, colorScheme, ap),
          ),
        ],
      ),
    );
  }

  Widget _buildHintBanner(ColorScheme colorScheme) {
    return Container(
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
    );
  }

  Widget _buildContent(
    BuildContext context,
    ColorScheme colorScheme,
    ApLocalizations ap,
  ) {
    switch (widget.state) {
      case CustomScoreState.loading:
        return _buildLoadingState(colorScheme);
      case CustomScoreState.error:
        return _buildErrorState(
          colorScheme,
          ap.clickToRetry,
          Icons.error_outline_rounded,
        );
      case CustomScoreState.empty:
        return _buildErrorState(
          colorScheme,
          ap.scoreEmpty,
          Icons.assignment_outlined,
        );
      case CustomScoreState.offlineEmpty:
        return _buildErrorState(
          colorScheme,
          ap.noOfflineData,
          Icons.cloud_off_rounded,
        );
      case CustomScoreState.custom:
        return _buildErrorState(
          colorScheme,
          widget.customStateHint ?? ap.somethingError,
          Icons.warning_amber_rounded,
        );
      case CustomScoreState.finish:
        return _buildScoreContent(context, colorScheme, ap);
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
            '載入成績中...',
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
    ColorScheme colorScheme,
    String message,
    IconData icon,
  ) {
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

  Widget _buildScoreContent(
    BuildContext context,
    ColorScheme colorScheme,
    ApLocalizations ap,
  ) {
    if (widget.scoreData == null) return const SizedBox.shrink();

    if (_isAnalysisView) {
      return _ScoreAnalysisTab(
        scoreData: widget.scoreData!,
        onRefresh: widget.onRefresh,
      );
    } else {
      return _ScoreListTab(
        scoreData: widget.scoreData!,
        onRefresh: widget.onRefresh,
      );
    }
  }
}

class _ScoreAnalysisTab extends StatelessWidget {
  final ScoreData scoreData;
  final VoidCallback? onRefresh;

  const _ScoreAnalysisTab({required this.scoreData, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ApLocalizations ap = ApLocalizations.of(context);
    final ScoreAnalysis analysis = ScoreAnalysis(scoreData);

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _buildMainSummaryCard(colorScheme, ap, analysis),
            const SizedBox(height: 16),
            _buildPRCard(colorScheme, analysis),
            const SizedBox(height: 16),
            _buildStatisticsCard(colorScheme, analysis),
            const SizedBox(height: 16),
            _buildDistributionCard(colorScheme, analysis),
            const SizedBox(height: 16),
            _buildCreditSummaryCard(colorScheme, analysis),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSummaryCard(
    ColorScheme colorScheme,
    ApLocalizations ap,
    ScoreAnalysis analysis,
  ) {
    final Detail detail = scoreData.detail;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.primary.withAlpha(38),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildMainItem(
                    colorScheme,
                    Icons.star_rounded,
                    ap.average,
                    detail.average?.toStringAsFixed(2) ?? '-',
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: colorScheme.onPrimaryContainer.withAlpha(51),
                ),
                Expanded(
                  child: _buildMainItem(
                    colorScheme,
                    Icons.school_rounded,
                    ap.conductScore,
                    detail.conduct?.toStringAsFixed(0) ?? '-',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha(179),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildRankItem(
                    colorScheme,
                    ap.classRank,
                    detail.classRank ?? '-',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: colorScheme.outlineVariant.withAlpha(128),
                ),
                Expanded(
                  child: _buildRankItem(
                    colorScheme,
                    ap.departmentRank,
                    detail.departmentRank ?? '-',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainItem(
    ColorScheme colorScheme,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: <Widget>[
        Icon(icon, size: 28, color: colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onPrimaryContainer.withAlpha(179),
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(ColorScheme colorScheme, String label, String value) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildPRCard(ColorScheme colorScheme, ScoreAnalysis analysis) {
    final int pr = analysis.estimatedPR;
    final Color prColor = _getPRColor(colorScheme, pr);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: prColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: 28,
                    color: prColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '估計 PR 值',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PR $pr',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: prColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: prColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    analysis.prLevel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: prColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pr / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[prColor.withAlpha(179), prColor],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              '※ PR 值為根據平均成績估算，僅供參考',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant.withAlpha(179),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPRColor(ColorScheme colorScheme, int pr) {
    if (pr >= 90) return const Color(0xFF4CAF50);
    if (pr >= 75) return const Color(0xFF8BC34A);
    if (pr >= 50) return colorScheme.primary;
    if (pr >= 25) return const Color(0xFFFF9800);
    return colorScheme.error;
  }

  Widget _buildStatisticsCard(ColorScheme colorScheme, ScoreAnalysis analysis) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.bar_chart_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '成績統計',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(77)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildStatItem(
                        colorScheme,
                        '最高分',
                        analysis.maxScore.toStringAsFixed(0),
                        Icons.arrow_upward_rounded,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        colorScheme,
                        '最低分',
                        analysis.minScore.toStringAsFixed(0),
                        Icons.arrow_downward_rounded,
                        colorScheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildStatItem(
                        colorScheme,
                        '標準差',
                        analysis.standardDeviation.toStringAsFixed(2),
                        Icons.analytics_outlined,
                        colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        colorScheme,
                        '科目數',
                        analysis.totalSubjects.toString(),
                        Icons.menu_book_rounded,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(
    ColorScheme colorScheme,
    ScoreAnalysis analysis,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.pie_chart_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '成績分佈',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(77)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _buildDistributionBar(
                  colorScheme,
                  '90-100 (優秀)',
                  analysis.distribution['90-100'] ?? 0,
                  analysis.totalSubjects,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 10),
                _buildDistributionBar(
                  colorScheme,
                  '80-89 (良好)',
                  analysis.distribution['80-89'] ?? 0,
                  analysis.totalSubjects,
                  const Color(0xFF8BC34A),
                ),
                const SizedBox(height: 10),
                _buildDistributionBar(
                  colorScheme,
                  '70-79 (普通)',
                  analysis.distribution['70-79'] ?? 0,
                  analysis.totalSubjects,
                  colorScheme.primary,
                ),
                const SizedBox(height: 10),
                _buildDistributionBar(
                  colorScheme,
                  '60-69 (及格)',
                  analysis.distribution['60-69'] ?? 0,
                  analysis.totalSubjects,
                  const Color(0xFFFF9800),
                ),
                const SizedBox(height: 10),
                _buildDistributionBar(
                  colorScheme,
                  '0-59 (不及格)',
                  analysis.distribution['0-59'] ?? 0,
                  analysis.totalSubjects,
                  colorScheme.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(
    ColorScheme colorScheme,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final double percentage = total > 0 ? count / total : 0;

    return Row(
      children: <Widget>[
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '$count 科',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditSummaryCard(
    ColorScheme colorScheme,
    ScoreAnalysis analysis,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.account_balance_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '學分統計',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withAlpha(77)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildCreditItem(
                    colorScheme,
                    '修習學分',
                    analysis.totalCredits.toStringAsFixed(1),
                    colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildCreditItem(
                    colorScheme,
                    '及格學分',
                    analysis.passedCredits.toStringAsFixed(1),
                    const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: _buildCreditItem(
                    colorScheme,
                    '不及格學分',
                    analysis.failedCredits.toStringAsFixed(1),
                    colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditItem(
    ColorScheme colorScheme,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ScoreListTab extends StatelessWidget {
  final ScoreData scoreData;
  final VoidCallback? onRefresh;

  const _ScoreListTab({required this.scoreData, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: scoreData.scores.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildScoreItem(colorScheme, scoreData.scores[index]);
        },
      ),
    );
  }

  Widget _buildScoreItem(ColorScheme colorScheme, Score score) {
    final String scoreStr = score.semesterScore ?? '';
    final double? scoreValue = double.tryParse(scoreStr);
    final bool isPassed = scoreValue != null && scoreValue >= 60;
    final Color scoreColor = scoreValue == null
        ? colorScheme.onSurfaceVariant
        : isPassed
            ? _getScoreColor(scoreValue)
            : colorScheme.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    score.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      _buildTag(
                        colorScheme,
                        score.required ?? '',
                        colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${score.units} 學分',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  score.semesterScore ?? '-',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                if (score.middleScore != null && score.middleScore!.isNotEmpty)
                  Text(
                    '期中: ${score.middleScore}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFF2196F3);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Widget _buildTag(ColorScheme colorScheme, String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.replaceAll('【', '').replaceAll('】', ''),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class ScoreAnalysis {
  final ScoreData scoreData;
  late List<double> _scores;
  late int _totalSubjects;

  ScoreAnalysis(this.scoreData) {
    _scores = <double>[];
    for (final Score score in scoreData.scores) {
      final double? value = double.tryParse(score.semesterScore ?? '');
      if (value != null) {
        _scores.add(value);
      }
    }
    _totalSubjects = _scores.length;
  }

  int get totalSubjects => _totalSubjects;

  double get maxScore => _scores.isEmpty ? 0 : _scores.reduce(max);

  double get minScore => _scores.isEmpty ? 0 : _scores.reduce(min);

  double get average {
    if (_scores.isEmpty) return 0;
    return _scores.reduce((double a, double b) => a + b) / _scores.length;
  }

  double get standardDeviation {
    if (_scores.isEmpty) return 0;
    final double avg = average;
    final double sumSquares = _scores.fold<double>(
      0,
      (double sum, double score) => sum + (score - avg) * (score - avg),
    );
    return sqrt(sumSquares / _scores.length);
  }

  int get estimatedPR {
    final double avg = scoreData.detail.average ?? average;
    if (avg >= 95) return 99;
    if (avg >= 90) return 95;
    if (avg >= 85) return 88;
    if (avg >= 80) return 78;
    if (avg >= 75) return 65;
    if (avg >= 70) return 50;
    if (avg >= 65) return 35;
    if (avg >= 60) return 22;
    if (avg >= 55) return 12;
    return 5;
  }

  String get prLevel {
    final int pr = estimatedPR;
    if (pr >= 90) return '頂尖';
    if (pr >= 75) return '優秀';
    if (pr >= 50) return '中等';
    if (pr >= 25) return '待加強';
    return '需努力';
  }

  Map<String, int> get distribution {
    final Map<String, int> dist = <String, int>{
      '90-100': 0,
      '80-89': 0,
      '70-79': 0,
      '60-69': 0,
      '0-59': 0,
    };

    for (final double score in _scores) {
      if (score >= 90) {
        dist['90-100'] = dist['90-100']! + 1;
      } else if (score >= 80) {
        dist['80-89'] = dist['80-89']! + 1;
      } else if (score >= 70) {
        dist['70-79'] = dist['70-79']! + 1;
      } else if (score >= 60) {
        dist['60-69'] = dist['60-69']! + 1;
      } else {
        dist['0-59'] = dist['0-59']! + 1;
      }
    }

    return dist;
  }

  double get totalCredits {
    double credits = 0;
    for (final Score score in scoreData.scores) {
      final double? unit = double.tryParse(score.units);
      if (unit != null) credits += unit;
    }
    return credits;
  }

  double get passedCredits {
    double credits = 0;
    for (final Score score in scoreData.scores) {
      final double? scoreValue = double.tryParse(score.semesterScore ?? '');
      final double? unit = double.tryParse(score.units);
      if (scoreValue != null && scoreValue >= 60 && unit != null) {
        credits += unit;
      }
    }
    return credits;
  }

  double get failedCredits {
    double credits = 0;
    for (final Score score in scoreData.scores) {
      final double? scoreValue = double.tryParse(score.semesterScore ?? '');
      final double? unit = double.tryParse(score.units);
      if (scoreValue != null && scoreValue < 60 && unit != null) {
        credits += unit;
      }
    }
    return credits;
  }
}
