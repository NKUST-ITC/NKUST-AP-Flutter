import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';

class ReportPage extends StatefulWidget {
  static const String routerName = '/report';

  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  late NkustLocalizations app;

  @override
  Widget build(BuildContext context) {
    app = context.t;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(app.reportProblem),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeaderCard(colorScheme),
            const SizedBox(height: 24),
            Text(
              app.reportOptions,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              colorScheme: colorScheme,
              icon: Icons.wifi_off_rounded,
              title: app.reportNetProblem,
              subtitle: app.reportNetProblemSubTitle,
              onTap: () async {
                const String url =
                    'https://docs.google.com/forms/d/e/1FAIpQLSfAOZaF-aM4XwuJRXaSp1uzZ1nZqhl7M6-oc4xWrCbM4tqcuw/viewform';
                await PlatformUtil.instance.launchUrl(url);
                AnalyticsUtil.instance.logEvent('net_problem_click');
              },
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              colorScheme: colorScheme,
              icon: Icons.bug_report_outlined,
              title: app.reportAppBug,
              subtitle: app.reportAppBugSubtitle,
              onTap: () async {
                const String url =
                    'https://github.com/NKUST-ITC/NKUST-AP-Flutter/issues/new';
                await PlatformUtil.instance.launchUrl(url);
                AnalyticsUtil.instance.logEvent('app_bug_click');
              },
            ),
            const SizedBox(height: 12),
            _buildReportCard(
              colorScheme: colorScheme,
              icon: Icons.lightbulb_outline_rounded,
              title: app.featureSuggestion,
              subtitle: app.featureSuggestionSubtitle,
              onTap: () async {
                const String url =
                    'https://github.com/NKUST-ITC/NKUST-AP-Flutter/discussions/new?category=ideas';
                await PlatformUtil.instance.launchUrl(url);
                AnalyticsUtil.instance.logEvent('feature_request_click');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            app.needHelp,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            app.selectReportOption,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onPrimaryContainer.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant.withAlpha(128),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
