import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/global.dart';

class UserInfoPage extends StatefulWidget {
  static const String routerName = '/userInfo';
  final UserInfo userInfo;

  const UserInfoPage({super.key, required this.userInfo});

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  late UserInfo userInfo;
  bool _isRefreshing = false;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'UserInfoPage',
      'user_info_page.dart',
    );
    userInfo = widget.userInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ApLocalizations ap = context.ap;
    final AppLocalizations app = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? <Color>[
                            colorScheme.primaryContainer,
                            colorScheme.surface,
                          ]
                        : <Color>[
                            colorScheme.primary,
                            colorScheme.primaryContainer,
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 40),
                      _buildAvatar(colorScheme, isDark),
                      const SizedBox(height: 12),
                      Text(
                        userInfo.name ?? '',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? colorScheme.onSurface
                              : colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: _isRefreshing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark
                              ? colorScheme.onSurface
                              : colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
                onPressed: _isRefreshing ? null : _refreshUserInfo,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  _buildInfoCard(colorScheme, ap),
                  const SizedBox(height: 16),
                  _buildBarcodeCard(colorScheme, ap, app),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, bool isDark) {
    final bool hasImage =
        userInfo.pictureBytes != null && userInfo.pictureBytes!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? colorScheme.primary
              : colorScheme.onPrimary.withAlpha(128),
          width: 4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withAlpha(51),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: isDark
            ? colorScheme.primaryContainer
            : colorScheme.onPrimary.withAlpha(51),
        backgroundImage: hasImage ? MemoryImage(userInfo.pictureBytes!) : null,
        child: hasImage
            ? null
            : Icon(
                Icons.person_rounded,
                size: 56,
                color: isDark ? colorScheme.primary : colorScheme.onPrimary,
              ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, ApLocalizations ap) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      child: Column(
        children: <Widget>[
          _buildInfoRow(
            icon: Icons.badge_outlined,
            title: ap.studentId,
            value: userInfo.id ?? '',
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildInfoRow(
            icon: Icons.school_outlined,
            title: ap.department,
            value: userInfo.department ?? '',
            colorScheme: colorScheme,
          ),
          _buildDivider(colorScheme),
          _buildInfoRow(
            icon: Icons.class_outlined,
            title: ap.studentClass,
            value: userInfo.className ?? '',
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

  Widget _buildDivider(ColorScheme colorScheme) {
    return Divider(
      height: 1,
      indent: 72,
      color: colorScheme.outlineVariant.withAlpha(77),
    );
  }

  Widget _buildBarcodeCard(
      ColorScheme colorScheme, ApLocalizations ap, AppLocalizations app) {
    final String studentId = userInfo.id ?? '';

    if (studentId.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(77),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.badge_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                app.studentIdBarcode,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  studentId,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  app.useStudentIdInLibrary,
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
    );
  }

  Future<void> _refreshUserInfo() async {
    setState(() => _isRefreshing = true);

    final UserInfo? newUserInfo = await Helper.instance.getUsersInfo();
    if (newUserInfo != null && mounted) {
      setState(() {
        userInfo = newUserInfo.copyWith(
          pictureBytes: userInfo.pictureBytes,
        );
        _isRefreshing = false;
      });
      AnalyticsUtil.instance.logUserInfo(newUserInfo);
    } else {
      setState(() => _isRefreshing = false);
    }
  }
}
