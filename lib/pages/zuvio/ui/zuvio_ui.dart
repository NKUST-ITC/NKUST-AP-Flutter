import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Spacing & shape scale
// ---------------------------------------------------------------------------

abstract final class ZGap {
  static const double xs = 4;
  static const double s = 8;
  static const double sm = 12;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

abstract final class ZRadii {
  static const BorderRadius control = BorderRadius.all(Radius.circular(10));
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius container = BorderRadius.all(Radius.circular(20));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

const EdgeInsets zScreenPadding = EdgeInsets.symmetric(horizontal: ZGap.m);

// ---------------------------------------------------------------------------
// Date / time formatting
// ---------------------------------------------------------------------------

String zuvioDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String zuvioTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}';

String zuvioDateTime(DateTime d) => '${zuvioDate(d)} ${zuvioTime(d)}';

// ---------------------------------------------------------------------------
// Semantic colors
// ---------------------------------------------------------------------------

class ZColors {
  const ZColors._(this._scheme, this._brightness);

  final ColorScheme _scheme;
  final Brightness _brightness;

  bool get _dark => _brightness == Brightness.dark;

  Color get screen => _dark ? _scheme.surface : _scheme.surfaceContainerLowest;
  Color get surface =>
      _dark ? _scheme.surfaceContainerLow : _scheme.surface;
  Color get surfaceHi => _dark
      ? _scheme.surfaceContainerHigh
      : _scheme.surfaceContainerHighest;
  Color get outline => _scheme.outlineVariant;

  Color get textPrimary => _scheme.onSurface;
  Color get textSecondary => _scheme.onSurfaceVariant;
  Color get textFaint => _scheme.onSurfaceVariant.withValues(alpha: 0.65);

  Color get accent => _scheme.primary;
  Color get onAccent => _scheme.onPrimary;
  Color get accentSoft => _scheme.primaryContainer;
  Color get onAccentSoft => _scheme.onPrimaryContainer;

  Color get success => _dark
      ? const Color(0xFF6BD68E)
      : const Color(0xFF1E874B);
  Color get warning => _dark
      ? const Color(0xFFF2B872)
      : const Color(0xFFB26A00);
  Color get danger => _scheme.error;
}

extension ZColorsX on BuildContext {
  ZColors get zc {
    final ThemeData theme = Theme.of(this);
    return ZColors._(theme.colorScheme, theme.brightness);
  }
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

class ZText {
  const ZText._(this._theme, this._colors);

  final TextTheme _theme;
  final ZColors _colors;

  TextStyle get pageTitle =>
      (_theme.headlineSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        color: _colors.textPrimary,
        letterSpacing: -0.2,
      );

  TextStyle get heading => (_theme.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        color: _colors.textPrimary,
      );

  TextStyle get cardTitle => (_theme.titleSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        color: _colors.textPrimary,
      );

  TextStyle get body => (_theme.bodyMedium ?? const TextStyle()).copyWith(
        color: _colors.textPrimary,
        height: 1.5,
      );

  TextStyle get supporting => (_theme.bodySmall ?? const TextStyle()).copyWith(
        color: _colors.textSecondary,
        height: 1.4,
      );

  TextStyle get label => (_theme.labelMedium ?? const TextStyle()).copyWith(
        color: _colors.textFaint,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  TextStyle get metric => (_theme.headlineSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
        color: _colors.textPrimary,
        letterSpacing: -0.5,
      );
}

extension ZTextX on BuildContext {
  ZText get zt {
    final ThemeData theme = Theme.of(this);
    return ZText._(
      theme.textTheme,
      ZColors._(theme.colorScheme, theme.brightness),
    );
  }
}

// ---------------------------------------------------------------------------
// Scaffold
// ---------------------------------------------------------------------------

class ZScaffold extends StatelessWidget {
  const ZScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    return Scaffold(
      backgroundColor: zc.screen,
      appBar: AppBar(
        title: Text(title, style: context.zt.heading),
        backgroundColor: zc.screen,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
        elevation: 0,
        centerTitle: false,
        actions: actions,
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}

// ---------------------------------------------------------------------------
// Card / surface
// ---------------------------------------------------------------------------

class ZCard extends StatelessWidget {
  const ZCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(ZGap.m),
    this.emphasised = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    final Widget content = Padding(padding: padding, child: child);
    return Material(
      color: emphasised ? zc.surfaceHi : zc.surface,
      borderRadius: ZRadii.card,
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, child: content),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class ZSectionHeader extends StatelessWidget {
  const ZSectionHeader(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: ZGap.xs,
        right: ZGap.xs,
        bottom: ZGap.s,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label.toUpperCase(), style: context.zt.label)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List row
// ---------------------------------------------------------------------------

class ZListRow extends StatelessWidget {
  const ZListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ZGap.m,
            vertical: ZGap.sm,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: zc.surfaceHi,
                  borderRadius: ZRadii.control,
                ),
                child: Icon(icon, size: 20, color: zc.textSecondary),
              ),
              const SizedBox(width: ZGap.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: context.zt.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: context.zt.supporting,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: ZGap.s),
                trailing!,
              ] else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: zc.textFaint,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip
// ---------------------------------------------------------------------------

enum ZStatusTone { success, warning, danger, neutral, accent }

class ZStatusChip extends StatelessWidget {
  const ZStatusChip({super.key, required this.label, required this.tone});

  final String label;
  final ZStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    final Color color = switch (tone) {
      ZStatusTone.success => zc.success,
      ZStatusTone.warning => zc.warning,
      ZStatusTone.danger => zc.danger,
      ZStatusTone.accent => zc.accent,
      ZStatusTone.neutral => zc.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ZGap.s, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: ZRadii.pill,
      ),
      child: Text(
        label,
        style: context.zt.label.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat tile
// ---------------------------------------------------------------------------

class ZStatTile extends StatelessWidget {
  const ZStatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ZCard(
      emphasised: true,
      padding: const EdgeInsets.symmetric(vertical: ZGap.m, horizontal: ZGap.s),
      child: Column(
        children: <Widget>[
          FittedBox(child: Text(value, style: context.zt.metric)),
          const SizedBox(height: ZGap.xs),
          Text(label, style: context.zt.label),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

enum ZButtonVariant { primary, secondary, text, danger }

class ZButton extends StatelessWidget {
  const ZButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ZButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    final bool disabled = onPressed == null || loading;

    final Widget child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == ZButtonVariant.primary
                  ? zc.onAccent
                  : zc.accent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18),
                const SizedBox(width: ZGap.s),
              ],
              Text(label),
            ],
          );

    final ButtonStyle base = ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(expand ? double.infinity : 0, 48),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: ZGap.l),
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: ZRadii.control),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(
        context.zt.cardTitle.copyWith(fontWeight: FontWeight.w600),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
    );

    switch (variant) {
      case ZButtonVariant.primary:
        return FilledButton(
          onPressed: disabled ? null : onPressed,
          style: base,
          child: child,
        );
      case ZButtonVariant.danger:
        return FilledButton(
          onPressed: disabled ? null : onPressed,
          style: base.copyWith(
            backgroundColor: WidgetStatePropertyAll<Color>(zc.danger),
          ),
          child: child,
        );
      case ZButtonVariant.secondary:
        return FilledButton.tonal(
          onPressed: disabled ? null : onPressed,
          style: base,
          child: child,
        );
      case ZButtonVariant.text:
        return TextButton(
          onPressed: disabled ? null : onPressed,
          style: base.copyWith(
            minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 44)),
          ),
          child: child,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Text field
// ---------------------------------------------------------------------------

class ZTextField extends StatelessWidget {
  const ZTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
      style: context.zt.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: zc.surfaceHi,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ZGap.m,
          vertical: ZGap.m,
        ),
        border: const OutlineInputBorder(
          borderRadius: ZRadii.control,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: ZRadii.control,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ZRadii.control,
          borderSide: BorderSide(color: zc.accent, width: 1.5),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State view: loading / empty / error
// ---------------------------------------------------------------------------

enum ZViewState { loading, ready, empty, error }

class ZStateView extends StatelessWidget {
  const ZStateView({
    super.key,
    required this.state,
    required this.builder,
    this.onRetry,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyText,
    this.errorText,
    this.loading,
  });

  final ZViewState state;
  final WidgetBuilder builder;
  final Future<void> Function()? onRetry;
  final IconData emptyIcon;
  final String? emptyText;
  final String? errorText;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: switch (state) {
        ZViewState.loading => loading ??
            const Center(
              key: ValueKey<String>('z-loading'),
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
        ZViewState.ready => KeyedSubtree(
            key: const ValueKey<String>('z-ready'),
            child: builder(context),
          ),
        ZViewState.empty => _Message(
            key: const ValueKey<String>('z-empty'),
            icon: emptyIcon,
            text: emptyText ?? context.ap.noData,
            onRetry: onRetry,
            retryLabel: context.ap.retry,
          ),
        ZViewState.error => _Message(
            key: const ValueKey<String>('z-error'),
            icon: Icons.error_outline_rounded,
            text: errorText ?? context.ap.somethingError,
            onRetry: onRetry,
            retryLabel: context.ap.retry,
          ),
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    super.key,
    required this.icon,
    required this.text,
    this.onRetry,
    this.retryLabel,
  });

  final IconData icon;
  final String text;
  final Future<void> Function()? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ZGap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 44, color: zc.textFaint),
            const SizedBox(height: ZGap.m),
            Text(
              text,
              textAlign: TextAlign.center,
              style: context.zt.supporting,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: ZGap.m),
              ZButton(
                label: retryLabel ?? context.ap.retry,
                variant: ZButtonVariant.text,
                expand: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton
// ---------------------------------------------------------------------------

class ZSkeleton extends StatefulWidget {
  const ZSkeleton({
    super.key,
    this.height = 14,
    this.width = double.infinity,
    this.radius = 6,
  });

  final double height;
  final double width;
  final double radius;

  @override
  State<ZSkeleton> createState() => _ZSkeletonState();
}

class _ZSkeletonState extends State<ZSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ZColors zc = context.zc;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 0.9).animate(_c),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: zc.surfaceHi,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
