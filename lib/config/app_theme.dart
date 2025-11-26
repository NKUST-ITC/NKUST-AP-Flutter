import 'package:flutter/material.dart';

class ThemeColor {
  const ThemeColor({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;
}

class AppTheme {
  static const List<ThemeColor> themeColors = <ThemeColor>[
    ThemeColor(name: '高科藍', color: Color(0xFF0066CC)),
    ThemeColor(name: '海洋藍', color: Color(0xFF0077B6)),
    ThemeColor(name: '翠綠', color: Color(0xFF2E7D32)),
    ThemeColor(name: '珊瑚橙', color: Color(0xFFE64A19)),
    ThemeColor(name: '典雅紫', color: Color(0xFF7B1FA2)),
    ThemeColor(name: '玫瑰紅', color: Color(0xFFC2185B)),
    ThemeColor(name: '青色', color: Color(0xFF00838F)),
    ThemeColor(name: '琥珀', color: Color(0xFFFF8F00)),
    ThemeColor(name: '靛藍', color: Color(0xFF303F9F)),
    ThemeColor(name: '棕褐', color: Color(0xFF5D4037)),
  ];

  static const int customColorIndex = -1;
  static int currentColorIndex = 0;
  static Color? customColor;

  static Color get seedColor {
    if (currentColorIndex == customColorIndex && customColor != null) {
      return customColor!;
    }
    if (currentColorIndex >= 0 && currentColorIndex < themeColors.length) {
      return themeColors[currentColorIndex].color;
    }
    return themeColors[0].color;
  }

  static String get currentColorName {
    if (currentColorIndex == customColorIndex && customColor != null) {
      return '自訂色';
    }
    if (currentColorIndex >= 0 && currentColorIndex < themeColors.length) {
      return themeColors[currentColorIndex].name;
    }
    return themeColors[0].name;
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isLight ? colorScheme.primary : colorScheme.surface,
        foregroundColor: isLight ? colorScheme.onPrimary : colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isLight ? colorScheme.onPrimary : colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(
          color: isLight ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withAlpha(31),
          disabledForegroundColor: colorScheme.onSurface.withAlpha(97),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 1,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        visualDensity: VisualDensity.compact,
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconColor: colorScheme.onSurfaceVariant,
        collapsedIconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        collapsedTextColor: colorScheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: 3,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: colorScheme.outline, width: 0.5),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: colorScheme.outline, width: 2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: isLight ? colorScheme.onPrimary : colorScheme.primary,
        unselectedLabelColor: isLight ? colorScheme.onPrimary.withAlpha(179) : colorScheme.onSurfaceVariant,
        indicatorColor: isLight ? colorScheme.onPrimary : colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 12,
        ),
      ),
    );
  }
}

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color currentColor = _hsvColor.toColor();

    return AlertDialog(
      title: const Text('選擇主題色'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: currentColor.withAlpha(128),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: _hsvColor.value > 0.5 && _hsvColor.saturation < 0.5 ? Colors.black87 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildHueSlider(colorScheme),
            const SizedBox(height: 16),
            _buildSaturationSlider(colorScheme),
            const SizedBox(height: 16),
            _buildValueSlider(colorScheme),
            const SizedBox(height: 24),
            _buildPresetColors(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, currentColor),
          child: const Text('確定'),
        ),
      ],
    );
  }

  Widget _buildHueSlider(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '色相',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xFFFF0000),
                Color(0xFFFFFF00),
                Color(0xFF00FF00),
                Color(0xFF00FFFF),
                Color(0xFF0000FF),
                Color(0xFFFF00FF),
                Color(0xFFFF0000),
              ],
            ),
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 24,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: _hsvColor.hue,
              min: 0,
              max: 360,
              onChanged: (double value) {
                setState(() {
                  _hsvColor = _hsvColor.withHue(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaturationSlider(ColorScheme colorScheme) {
    final Color endColor = HSVColor.fromAHSV(1, _hsvColor.hue, 1, 1).toColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '飽和度',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: <Color>[Colors.white, endColor],
            ),
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 24,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: _hsvColor.saturation,
              min: 0,
              max: 1,
              onChanged: (double value) {
                setState(() {
                  _hsvColor = _hsvColor.withSaturation(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueSlider(ColorScheme colorScheme) {
    final Color endColor = HSVColor.fromAHSV(1, _hsvColor.hue, _hsvColor.saturation, 1).toColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '亮度',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: <Color>[Colors.black, endColor],
            ),
          ),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 24,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
            ),
            child: Slider(
              value: _hsvColor.value,
              min: 0,
              max: 1,
              onChanged: (double value) {
                setState(() {
                  _hsvColor = _hsvColor.withValue(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetColors() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppTheme.themeColors.map((ThemeColor themeColor) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _hsvColor = HSVColor.fromColor(themeColor.color);
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: themeColor.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: themeColor.color.withAlpha(77),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
