import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';

class _Contributor {
  const _Contributor({
    required this.name,
    required this.englishName,
    required this.githubId,
  });

  final String name;
  final String englishName;
  final String githubId;

  String get avatarUrl => 'https://github.com/$githubId.png';
  String get githubUrl => 'https://github.com/$githubId';
}

class _AppVersion {
  const _AppVersion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.contributors,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<_Contributor> contributors;
}

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

class _Contributors {
  static const _Contributor louieLu = _Contributor(
    name: '呂紹榕',
    englishName: 'Louie Lu',
    githubId: '',
  );
  static const _Contributor johnThunder = _Contributor(
    name: '姜尚德',
    englishName: 'JohnThunder',
    githubId: '',
  );
  static const _Contributor registerAutumn = _Contributor(
    name: 'registerAutumn',
    englishName: 'registerAutumn',
    githubId: '',
  );
  static const _Contributor evans = _Contributor(
    name: '詹濬鍵',
    englishName: 'Evans',
    githubId: '',
  );
  static const _Contributor hearSilent = _Contributor(
    name: '陳建霖',
    englishName: 'HearSilent',
    githubId: 'hearsilent',
  );
  static const _Contributor chenGuanZhen = _Contributor(
    name: '陳冠蓁',
    englishName: '',
    githubId: '',
  );
  static const _Contributor xuYuRou = _Contributor(
    name: '徐羽柔',
    englishName: '',
    githubId: '',
  );
  static const _Contributor rainvisitor = _Contributor(
    name: '房志剛',
    englishName: 'Rainvisitor',
    githubId: 'abc873693',
  );
  static const _Contributor takidog = _Contributor(
    name: '林義翔',
    englishName: 'takidog',
    githubId: 'takidog',
  );
  static const _Contributor linYuHsuan = _Contributor(
    name: '林鈺軒',
    englishName: 'Lin YuHsuan',
    githubId: '',
  );
  static const _Contributor gary = _Contributor(
    name: '周鈺禮',
    englishName: 'Gary',
    githubId: '',
  );
  static const _Contributor marco = _Contributor(
    name: '黃昱翔',
    englishName: 'Marco',
    githubId: 'mlgzackfly',
  );
  static const _Contributor johnHuCC = _Contributor(
    name: '胡智強',
    englishName: 'JohnHuCC',
    githubId: 'JohnHuCC',
  );
  static const _Contributor ryanChang = _Contributor(
    name: '張栢瑄',
    englishName: 'Ryan Chang',
    githubId: '',
  );
  static const _Contributor yukimura = _Contributor(
    name: '蔡明軒',
    englishName: 'Yukimura',
    githubId: 'Yukimura0119',
  );
  static const _Contributor jasonZzz = _Contributor(
    name: '高聖傑',
    englishName: 'JasonZzz',
    githubId: 'jasonkao402',
  );
}

class _CustomAboutPageState extends State<CustomAboutPage> {
  static const List<_AppVersion> _appVersions = <_AppVersion>[
    _AppVersion(
      title: '高科校務通 v1 & v2',
      subtitle: 'NKUST AP',
      icon: Icons.looks_two_rounded,
      contributors: <_Contributor>[
        _Contributors.louieLu,
        _Contributors.johnThunder,
        _Contributors.registerAutumn,
        _Contributors.evans,
        _Contributors.hearSilent,
        _Contributors.chenGuanZhen,
        _Contributors.xuYuRou,
      ],
    ),
    _AppVersion(
      title: '高科校務通 v3',
      subtitle: 'NKUST AP Flutter',
      icon: Icons.looks_3_rounded,
      contributors: <_Contributor>[
        _Contributors.rainvisitor,
        _Contributors.takidog,
        _Contributors.linYuHsuan,
        _Contributors.gary,
        _Contributors.marco,
      ],
    ),
    _AppVersion(
      title: '中山校務通',
      subtitle: 'NSYSU AP',
      icon: Icons.school_rounded,
      contributors: <_Contributor>[
        _Contributors.rainvisitor,
        _Contributors.johnHuCC,
        _Contributors.ryanChang,
        _Contributors.yukimura,
        _Contributors.jasonZzz,
      ],
    ),
    _AppVersion(
      title: '台科校務通',
      subtitle: 'NTUST AP',
      icon: Icons.school_rounded,
      contributors: <_Contributor>[
        _Contributors.rainvisitor,
        _Contributors.takidog,
      ],
    ),
    _AppVersion(
      title: '文藻校務通',
      subtitle: 'WZU AP',
      icon: Icons.school_rounded,
      contributors: <_Contributor>[
        _Contributors.takidog,
        _Contributors.rainvisitor,
      ],
    ),
  ];

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('AboutPage', 'about_page.dart');
    super.initState();
  }

  List<String> _splitParagraphs(String content) {
    return content
        .split('\n')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ApLocalizations ap = ApLocalizations.of(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          _buildSliverAppBar(context, colorScheme, ap),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildMadeBySection(colorScheme, ap),
                  const SizedBox(height: 24),
                  _buildContentCard(
                    colorScheme: colorScheme,
                    icon: Icons.info_outline_rounded,
                    iconBgColor: colorScheme.secondaryContainer,
                    iconColor: colorScheme.secondary,
                    title: ap.about,
                    content: ap.aboutUsContent,
                  ),
                  const SizedBox(height: 16),
                  _buildContentCard(
                    colorScheme: colorScheme,
                    icon: Icons.work_outline_rounded,
                    iconBgColor: colorScheme.tertiaryContainer,
                    iconColor: colorScheme.tertiary,
                    title: ap.aboutRecruitTitle,
                    content: ap.aboutRecruitContent,
                  ),
                  const SizedBox(height: 16),
                  _buildTeamCard(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    title: ap.aboutItcTitle,
                    content: ap.aboutItcContent,
                    logoAsset: ApImageAssets.nkutstItc,
                  ),
                  const SizedBox(height: 16),
                  _buildTeamCard(
                    colorScheme: colorScheme,
                    isDark: isDark,
                    title: ap.aboutNsysuCodeClubTitle,
                    content: ap.aboutNsysuCodeClubContent,
                    logoAsset: ApImageAssets.nsysuGdsc,
                  ),
                  const SizedBox(height: 16),
                  _buildContactCard(colorScheme, ap),
                  const SizedBox(height: 16),
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

  Widget _buildMadeBySection(ColorScheme colorScheme, ApLocalizations ap) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(51)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.primary,
                  colorScheme.tertiary,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colorScheme.primary.withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.code_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            ap.aboutAuthorTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_appVersions.length} 個專案',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          children: _buildVersionCards(colorScheme),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    ApLocalizations ap,
  ) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      title: Text(ap.about),
      actions: <Widget>[
        IconButton(
          icon: Icon(ApIcon.codeIcon),
          tooltip: '開源授權',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LicensePage()),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(widget.assetImage, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withAlpha(51),
                    colorScheme.surface,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVersionCards(ColorScheme colorScheme) {
    final List<Color> gradientColors = <Color>[
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      Colors.teal,
    ];

    final List<Widget> cards = <Widget>[];

    for (int i = 0; i < _appVersions.length; i++) {
      final _AppVersion version = _appVersions[i];
      final Color accentColor = gradientColors[i % gradientColors.length];

      if (i > 0) cards.add(const SizedBox(height: 12));

      cards.add(
        _buildVersionCard(
          colorScheme: colorScheme,
          version: version,
          accentColor: accentColor,
        ),
      );
    }

    return cards;
  }

  Widget _buildVersionCard({
    required ColorScheme colorScheme,
    required _AppVersion version,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  accentColor.withAlpha(38),
                  accentColor.withAlpha(13),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(version.icon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        version.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (version.subtitle != null)
                        Text(
                          version.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: version.contributors.map((contributor) {
                return _buildContributorChip(
                  colorScheme: colorScheme,
                  contributor: contributor,
                  accentColor: accentColor,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorChip({
    required ColorScheme colorScheme,
    required _Contributor contributor,
    required Color accentColor,
  }) {
    final bool hasGithub = contributor.githubId.isNotEmpty;
    final bool hasEnglishName = contributor.englishName.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasGithub
            ? () {
                PlatformUtil.instance.launchUrl(contributor.githubUrl);
                AnalyticsUtil.instance.logEvent('contributor_click');
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(128),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withAlpha(128),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: hasGithub
                      ? Image.network(
                          contributor.avatarUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(
                            accentColor,
                            contributor.name,
                          ),
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildAvatarPlaceholder(accentColor, contributor.name),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    contributor.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (hasGithub)
                    Text(
                      '@${contributor.githubId}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  else if (hasEnglishName)
                    Text(
                      contributor.englishName,
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
      ),
    );
  }

  Widget _buildAvatarPlaceholder(Color accentColor, String name) {
    final String initial =
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Container(
      width: 36,
      height: 36,
      color: accentColor.withAlpha(51),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    final List<String> paragraphs = _splitParagraphs(content);
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCardHeader(
            colorScheme: colorScheme,
            icon: icon,
            iconBgColor: iconBgColor,
            iconColor: iconColor,
            title: title,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < paragraphs.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: 16),
                  _buildParagraphText(colorScheme, paragraphs[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: iconBgColor.withAlpha(128),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraphText(ColorScheme colorScheme, String text) {
    return SelectableText(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.7,
        color: colorScheme.onSurfaceVariant,
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
    final List<String> paragraphs = _splitParagraphs(content);
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.shadow.withAlpha(26),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(logoAsset, fit: BoxFit.contain),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < paragraphs.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: 12),
                  _buildParagraphText(colorScheme, paragraphs[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(ColorScheme colorScheme, ApLocalizations ap) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[colorScheme.primary, colorScheme.tertiary],
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    ap.aboutContactUsTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _buildContactButton(
                      icon: ApImageAssets.fb,
                      label: 'Facebook',
                      onTap: () {
                        PlatformUtil.instance.launchUrl(
                          'https://m.me/${widget.fbFanPageId}',
                        );
                        AnalyticsUtil.instance.logEvent('fb_click');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactButton(
                      icon: ApImageAssets.github,
                      label: 'GitHub',
                      onTap: () {
                        PlatformUtil.instance.launchUrl(widget.githubUrl);
                        AnalyticsUtil.instance.logEvent('github_click');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildContactButton(
                      icon: ApImageAssets.email,
                      label: 'Email',
                      onTap: () {
                        PlatformUtil.instance.launchUrl(
                          'mailto:${widget.email}',
                        );
                        AnalyticsUtil.instance.logEvent('email_click');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withAlpha(38),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(icon, fit: BoxFit.contain),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseCard(ColorScheme colorScheme, ApLocalizations ap) {
    final List<String> paragraphs = _splitParagraphs(widget.appLicense);
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCardHeader(
            colorScheme: colorScheme,
            icon: Icons.article_outlined,
            iconBgColor: colorScheme.errorContainer,
            iconColor: colorScheme.error,
            title: ap.aboutOpenSourceTitle,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < paragraphs.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: 16),
                  _buildParagraphText(colorScheme, paragraphs[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
