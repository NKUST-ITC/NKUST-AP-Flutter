import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final UserInfo? userInfo;
  final bool displayPicture;
  final String? imageAsset;
  final VoidCallback? onTapHeader;
  final List<Widget> children;

  const AppDrawer({
    super.key,
    this.userInfo,
    this.displayPicture = true,
    this.imageAsset,
    this.onTapHeader,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: <Widget>[
          _buildHeader(context, colorScheme, isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        bottom: false,
        child: InkWell(
          onTap: onTapHeader,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildAvatar(colorScheme, isDark),
                const SizedBox(height: 16),
                _buildUserInfo(colorScheme, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, bool isDark) {
    final bool hasImage = displayPicture && userInfo?.pictureBytes != null && userInfo!.pictureBytes!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? colorScheme.primary : colorScheme.onPrimary.withAlpha(128),
          width: 3,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withAlpha(51),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 36,
        backgroundColor: isDark ? colorScheme.primaryContainer : colorScheme.onPrimary.withAlpha(51),
        backgroundImage: hasImage ? MemoryImage(userInfo!.pictureBytes!) : null,
        child: hasImage
            ? null
            : Icon(
                Icons.person_rounded,
                size: 40,
                color: isDark ? colorScheme.primary : colorScheme.onPrimary,
              ),
      ),
    );
  }

  Widget _buildUserInfo(ColorScheme colorScheme, bool isDark) {
    final Color textColor = isDark ? colorScheme.onSurface : colorScheme.onPrimary;
    final Color subtitleColor = isDark ? colorScheme.onSurfaceVariant : colorScheme.onPrimary.withAlpha(217);

    if (userInfo == null) {
      return Text(
        '點擊登入',
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final String name = userInfo!.name ?? '';
    final String id = userInfo!.id;
    final String department = userInfo!.department ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          name,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          id,
          style: TextStyle(
            color: subtitleColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (department.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            department,
            style: TextStyle(
              color: subtitleColor.withAlpha(230),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool selected;
  final bool enabled;
  final bool isExternalLink;
  final Color? iconColor;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.isExternalLink = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color disabledColor = colorScheme.onSurface.withAlpha(97);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? colorScheme.primaryContainer.withAlpha(128) : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 24,
                  color: enabled
                      ? (iconColor ?? (selected ? colorScheme.primary : colorScheme.onSurfaceVariant))
                      : disabledColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: enabled ? (selected ? colorScheme.primary : colorScheme.onSurface) : disabledColor,
                    ),
                  ),
                ),
                if (!enabled)
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: disabledColor,
                  )
                else if (isExternalLink)
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerMenuSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<DrawerSubMenuItem> children;
  final bool initiallyExpanded;
  final bool enabled;
  final ValueChanged<bool>? onExpansionChanged;

  const DrawerMenuSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
    this.enabled = true,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color disabledColor = colorScheme.onSurface.withAlpha(97);

    if (!enabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 24, color: disabledColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: disabledColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: disabledColor,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: colorScheme.surface,
          splashColor: colorScheme.primary.withAlpha(26),
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          onExpansionChanged: onExpansionChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primaryContainer.withAlpha(38),
          collapsedBackgroundColor: colorScheme.surface,
          leading: Icon(
            icon,
            size: 24,
            color: initiallyExpanded ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: initiallyExpanded ? FontWeight.w600 : FontWeight.w500,
              color: initiallyExpanded ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          trailing: AnimatedRotation(
            turns: initiallyExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: initiallyExpanded ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerSubMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool enabled;

  const DrawerSubMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color disabledColor = colorScheme.onSurface.withAlpha(97);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: enabled
                        ? colorScheme.primaryContainer.withAlpha(102)
                        : colorScheme.surfaceContainerHighest.withAlpha(128),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: enabled ? colorScheme.primary : disabledColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: enabled ? colorScheme.onSurface.withAlpha(217) : disabledColor,
                    ),
                  ),
                ),
                Icon(
                  enabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                  size: enabled ? 20 : 16,
                  color: enabled ? colorScheme.onSurfaceVariant.withAlpha(128) : disabledColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerDivider extends StatelessWidget {
  final String? label;

  const DrawerDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (label != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          label!,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant.withAlpha(179),
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Divider(
        height: 1,
        color: colorScheme.outlineVariant.withAlpha(128),
      ),
    );
  }
}
