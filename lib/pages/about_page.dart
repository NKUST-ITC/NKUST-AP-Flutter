import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';

class CustomAboutPage extends StatefulWidget {
  final String assetImage;
  final String fbFanPageUrl;
  final String fbFanPageId;
  final String githubUrl;
  final String githubName;
  final String email;
  final String appLicense;

  const CustomAboutPage({
    super.key,
    required this.assetImage,
    required this.fbFanPageUrl,
    required this.fbFanPageId,
    required this.githubUrl,
    required this.githubName,
    required this.email,
    required this.appLicense,
  });

  @override
  State<CustomAboutPage> createState() => _CustomAboutPageState();
}

class _CustomAboutPageState extends State<CustomAboutPage> {
  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('AboutPage', 'about_page.dart');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ApLocalizations ap = ApLocalizations.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            title: Text(ap.about),
            actions: <Widget>[
              IconButton(
                icon: Icon(ApIcon.codeIcon),
                tooltip: '開源授權',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LicensePage(),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    widget.assetImage,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          colorScheme.surface.withAlpha(204),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  _buildSection(
                    colorScheme: colorScheme,
                    icon: Icons.code_rounded,
                    title: ap.aboutAuthorTitle,
                    content: ap.aboutAuthorContent,
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    colorScheme: colorScheme,
                    icon: Icons.info_outline_rounded,
                    title: ap.about,
                    content: ap.aboutUsContent,
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    colorScheme: colorScheme,
                    icon: Icons.work_outline_rounded,
                    title: ap.aboutRecruitTitle,
                    content: ap.aboutRecruitContent,
                  ),
                  const SizedBox(height: 12),
                  _buildTeamCard(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    title: ap.aboutItcTitle,
                    content: ap.aboutItcContent,
                    logoAsset: ApImageAssets.nkutstItc,
                  ),
                  const SizedBox(height: 12),
                  _buildTeamCard(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    title: ap.aboutNsysuCodeClubTitle,
                    content: ap.aboutNsysuCodeClubContent,
                    logoAsset: ApImageAssets.nsysuGdsc,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(colorScheme, ap),
                  const SizedBox(height: 12),
                  _buildLicenseCard(colorScheme, ap),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withAlpha(128),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withAlpha(77),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard({
    required ColorScheme colorScheme,
    required bool isDark,
    required String title,
    required String content,
    required String logoAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withAlpha(77),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ColorScheme colorScheme, ApLocalizations ap) {
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  ap.aboutContactUsTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildContactButton(
                  colorScheme: colorScheme,
                  icon: ApImageAssets.fb,
                  label: 'Facebook',
                  onTap: () {
                    PlatformUtil.instance.launchUrl(
                      'https://m.me/${widget.fbFanPageId}',
                    );
                    AnalyticsUtil.instance.logEvent('fb_click');
                  },
                ),
                _buildContactButton(
                  colorScheme: colorScheme,
                  icon: ApImageAssets.github,
                  label: 'GitHub',
                  onTap: () {
                    PlatformUtil.instance.launchUrl(widget.githubUrl);
                    AnalyticsUtil.instance.logEvent('github_click');
                  },
                ),
                _buildContactButton(
                  colorScheme: colorScheme,
                  icon: ApImageAssets.email,
                  label: 'Email',
                  onTap: () {
                    PlatformUtil.instance.launchUrl(
                      'mailto:${widget.email}',
                    );
                    AnalyticsUtil.instance.logEvent('email_click');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required ColorScheme colorScheme,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface.withAlpha(179),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: <Widget>[
            Image.asset(
              icon,
              width: 36,
              height: 36,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseCard(ColorScheme colorScheme, ApLocalizations ap) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withAlpha(128),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.article_outlined,
                    size: 20,
                    color: colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ap.aboutOpenSourceTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withAlpha(77),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              widget.appLicense,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

