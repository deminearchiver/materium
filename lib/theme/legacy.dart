import 'dart:math' as math;

import 'package:materium/flutter.dart';

enum LegacyButtonSize { extraSmall, small, medium, large, extraLarge }

enum LegacyButtonShape { round, square }

enum LegacyButtonColor { elevated, filled, tonal, outlined, text }

enum LegacyMenuVariant { standard, vibrant }

enum LegacyIconButtonWidth { narrow, normal, wide }

enum LegacyIconButtonColor { filled, tonal, outlined, standard }

enum LegacyTextFieldType { filled, outlined }

abstract final class LegacyThemeFactory {
  static ThemeData createTheme({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
    Color? scaffoldBackgroundColor,
  }) {
    scaffoldBackgroundColor ??= colorTheme.surface;
    final modalBarrierColor = colorTheme.scrim.withValues(alpha: 0.32);
    return ThemeData(
      colorScheme: colorTheme.toLegacy(),
      visualDensity: .standard,
      splashFactory: InkSparkle.splashFactory,
      textTheme: typescaleTheme.toBaselineTextTheme(),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorTheme.primary.withValues(alpha: 0.4),
        cursorColor: colorTheme.primary,
        selectionHandleColor: colorTheme.primary,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(4.0),
        radius: const .circular(2.0),
        minThumbLength: 48.0,
        crossAxisMargin: 4.0,
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return colorTheme.outline;
        }),
      ),
      iconTheme: IconThemeDataLegacy(
        color: colorTheme.onSurface,
        opacity: 1.0,
        size: 24.0,
        opticalSize: 24.0,
        grade: 0.0,
        fill: 1.0,
        weight: 400.0,
        applyTextScaling: false,
        shadows: const [],
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorTheme.surfaceContainer,
        elevation: elevationTheme.level0,
        height: 64.0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: colorTheme.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeDataLegacy(
            color: isSelected
                ? colorTheme.onSecondaryContainer
                : colorTheme.onSurfaceVariant,
            fill: isSelected ? 1.0 : 0.0,
            size: 24.0,
            opticalSize: 24.0,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          final typeStyle = isSelected
              ? typescaleTheme.labelMediumEmphasized
              : typescaleTheme.labelMedium;
          return typeStyle.toTextStyle(
            color: isSelected
                ? colorTheme.secondary
                : colorTheme.onSurfaceVariant,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        // ignore: deprecated_member_use
        year2023: false,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        constraints: const BoxConstraints(minHeight: 24.0),
        padding: const .symmetric(horizontal: 8.0),
        decoration: ShapeDecoration(
          shape: CornersBorder.rounded(
            corners: .all(shapeTheme.corner.extraSmall),
          ),
          color: colorTheme.inverseSurface,
        ),
        textAlign: .start,
        textStyle: typescaleTheme.bodySmall.toTextStyle(
          color: colorTheme.inverseOnSurface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorTheme.surfaceContainerHigh,
        clipBehavior: .antiAlias,
        elevation: elevationTheme.level0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: CornersBorder.rounded(
          corners: .all(shapeTheme.corner.extraLarge),
        ),
        titleTextStyle: typescaleTheme.headlineSmall.toTextStyle(
          color: colorTheme.onSurface,
        ),
        constraints: const BoxConstraints(minWidth: 280.0, maxWidth: 560.0),
        insetPadding: const .all(56.0),
        barrierColor: modalBarrierColor,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        clipBehavior: .antiAlias,
        shape: CornersBorder.rounded(corners: shapeTheme.corner.extraLargeTop),
        surfaceTintColor: Colors.transparent,
        shadowColor: colorTheme.shadow,
        backgroundColor: colorTheme.surfaceContainerLow,
        elevation: elevationTheme.level3,
        modalBarrierColor: modalBarrierColor,
        modalBackgroundColor: colorTheme.surfaceContainerLow,
        modalElevation: elevationTheme.level0,
        dragHandleSize: const Size(32.0, 4.0),
        dragHandleColor: colorTheme.onSurfaceVariant,
        constraints: const BoxConstraints(maxWidth: 640.0),
      ),
      dividerTheme: DividerThemeData(
        color: colorTheme.outlineVariant,
        thickness: 1.0,
        radius: .zero,
      ),
      sliderTheme: SliderThemeData(
        // ignore: deprecated_member_use
        year2023: false,
        overlayColor: Colors.transparent,
        padding: .zero,
        showValueIndicator: .onDrag,
        valueIndicatorShape: const _SliderValueIndicatorShapeYear2024(),
        valueIndicatorColor: colorTheme.inverseSurface,
        valueIndicatorTextStyle: typescaleTheme.labelLarge.toTextStyle(
          color: colorTheme.inverseOnSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: .floating,
        shape: CornersBorder.rounded(
          corners: .all(shapeTheme.corner.extraSmall),
        ),
      ),
      menuTheme: createMenuTheme(
        colorTheme: colorTheme,
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        variant: .standard,
      ),
      menuButtonTheme: createMenuButtonTheme(
        colorTheme: colorTheme,
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
        variant: .standard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: createButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          typescaleTheme: typescaleTheme,
          size: .small,
          shape: .round,
          color: .elevated,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: createButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          typescaleTheme: typescaleTheme,
          size: .small,
          shape: .round,
          color: .filled,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: createButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          typescaleTheme: typescaleTheme,
          size: .small,
          shape: .round,
          color: .outlined,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: createButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          typescaleTheme: typescaleTheme,
          size: .small,
          shape: .round,
          color: .text,
        ),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final value in TargetPlatform.values)
            value: switch (value) {
              _ => FadeForwardsPageTransitionsBuilder(
                backgroundColor: scaffoldBackgroundColor,
              ),
            },
        },
      ),
    );
  }

  static ButtonStyle createButtonStyle({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
    LegacyButtonSize size = .small,
    LegacyButtonShape shape = .round,
    LegacyButtonColor color = .filled,
    bool? isSelected,
    MaterialTapTargetSize tapTargetSize = .padded,
    TextStyle? textStyle,
    TextStyle? unselectedTextStyle,
    TextStyle? selectedTextStyle,
    Color? containerColor,
    Color? unselectedContainerColor,
    Color? selectedContainerColor,
    Color? contentColor,
    Color? unselectedContentColor,
    Color? selectedContentColor,
  }) {
    final isUnselectedNotDefault = isSelected == false;
    final isUnselectedDefault = isSelected != true;
    final isSelectedNotDefault = isSelected == true;
    final isSelectedDefault = isSelected != false;

    final minWidth = 48.0;
    final minHeight = switch (size) {
      .extraSmall => 32.0,
      .small => 40.0,
      .medium => 56.0,
      .large => 96.0,
      .extraLarge => 136.0,
    };

    final EdgeInsetsGeometry padding = switch (size) {
      .extraSmall => const .symmetric(horizontal: 12.0, vertical: 6.0),
      .small => const .symmetric(horizontal: 16.0, vertical: 10.0),
      .medium => const .symmetric(horizontal: 24.0, vertical: 16.0),
      .large => const .symmetric(horizontal: 48.0, vertical: 32.0),
      .extraLarge => const .symmetric(horizontal: 64.0, vertical: 48.0),
    };

    final cornerRound = shapeTheme.corner.full;
    final cornerSquare = switch (size) {
      .extraSmall => shapeTheme.corner.medium,
      .small => shapeTheme.corner.medium,
      .medium => shapeTheme.corner.large,
      .large => shapeTheme.corner.extraLarge,
      .extraLarge => shapeTheme.corner.extraLarge,
    };
    final corner = isSelectedNotDefault
        ? switch (shape) {
            .round => cornerSquare,
            .square => cornerRound,
          }
        : switch (shape) {
            .round => cornerRound,
            .square => cornerSquare,
          };

    final iconSize = switch (size) {
      .extraSmall => 20.0,
      .small => 20.0,
      .medium => 24.0,
      .large => 32.0,
      .extraLarge => 40.0,
    };

    final typeStyle = switch (size) {
      .extraSmall => typescaleTheme.labelLarge,
      .small => typescaleTheme.labelLarge,
      .medium => typescaleTheme.titleMedium,
      .large => typescaleTheme.headlineSmall,
      .extraLarge => typescaleTheme.headlineLarge,
    };

    final resolvedTextStyle =
        switch (isSelected) {
          null => textStyle,
          false => unselectedTextStyle,
          true => selectedTextStyle,
        } ??
        typeStyle.toTextStyle();

    final backgroundColor =
        switch (isSelected) {
          null => containerColor,
          false => unselectedContainerColor,
          true => selectedContainerColor,
        } ??
        switch (color) {
          .elevated =>
            isSelectedNotDefault
                ? colorTheme.primary
                : colorTheme.surfaceContainerLow,
          .filled =>
            isSelectedDefault
                ? colorTheme.primary
                : colorTheme.surfaceContainer,
          .tonal =>
            isSelectedNotDefault
                ? colorTheme.secondary
                : colorTheme.secondaryContainer,
          .outlined =>
            isSelectedNotDefault
                ? colorTheme.inverseSurface
                : Colors.transparent,
          .text => Colors.transparent,
        };
    final foregroundColor =
        switch (isSelected) {
          null => contentColor,
          false => unselectedContentColor,
          true => selectedContentColor,
        } ??
        switch (color) {
          .elevated =>
            isSelectedNotDefault ? colorTheme.onPrimary : colorTheme.primary,
          .filled =>
            isSelectedDefault
                ? colorTheme.onPrimary
                : colorTheme.onSurfaceVariant,
          .tonal =>
            isSelectedNotDefault
                ? colorTheme.onSecondary
                : colorTheme.onSecondaryContainer,
          .outlined =>
            isSelectedNotDefault
                ? colorTheme.inverseOnSurface
                : colorTheme.onSurfaceVariant,
          .text => colorTheme.primary,
        };
    final disabledBackgroundColor = colorTheme.onSurface.withValues(
      alpha: 0.10,
    );
    final disabledForegroundColor = colorTheme.onSurface.withValues(
      alpha: 0.38,
    );
    final outlineWidth = switch (size) {
      .extraSmall => 1.0,
      .small => 1.0,
      .medium => 1.0,
      .large => 2.0,
      .extraLarge => 3.0,
    };
    final side = switch (color) {
      .outlined when isUnselectedDefault => BorderSide(
        style: BorderStyle.solid,
        color: colorTheme.outlineVariant,
        width: outlineWidth,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
      _ => BorderSide(
        style: BorderStyle.none,
        color: colorTheme.background,
        width: 0.0,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    };
    return ButtonStyle(
      animationDuration: Duration.zero,
      alignment: Alignment.center,
      enableFeedback: true,
      iconAlignment: IconAlignment.start,
      mouseCursor: WidgetStateMouseCursor.clickable,
      tapTargetSize: tapTargetSize,
      elevation: const WidgetStatePropertyAll(0.0),
      shadowColor: WidgetStateColor.transparent,
      minimumSize: WidgetStatePropertyAll(Size(minWidth, minHeight)),
      fixedSize: const WidgetStatePropertyAll(null),
      maximumSize: const WidgetStatePropertyAll(Size.infinite),
      padding: WidgetStatePropertyAll(padding),
      iconSize: WidgetStatePropertyAll(iconSize),
      shape: WidgetStatePropertyAll(
        CornersBorder.rounded(corners: .all(corner)),
      ),
      side: WidgetStatePropertyAll(side),
      overlayColor: WidgetStateLayerColor(
        color: WidgetStatePropertyAll(foregroundColor),
        opacity: stateTheme.stateLayerOpacity,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? disabledBackgroundColor
            : backgroundColor,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? disabledForegroundColor
            : foregroundColor,
      ),
      textStyle: WidgetStatePropertyAll(resolvedTextStyle),
    );
  }

  static ButtonStyle createIconButtonStyle({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    LegacyButtonSize size = .small,
    LegacyButtonShape shape = .round,
    LegacyIconButtonWidth width = .normal,
    LegacyIconButtonColor color = .filled,
    bool? isSelected,
    MaterialTapTargetSize tapTargetSize = .padded,
    LegacyButtonShape? unselectedShape,
    LegacyButtonShape? selectedShape,
    Color? disabledContainerColor,
    Color? containerColor,
    Color? unselectedDisabledContainerColor,
    Color? unselectedContainerColor,
    Color? selectedDisabledContainerColor,
    Color? selectedContainerColor,
    double? disabledContainerElevation,
    double? containerElevation,
    Color? disabledIconColor,
    Color? iconColor,
    Color? unselectedDisabledIconColor,
    Color? unselectedIconColor,
    Color? selectedDisabledIconColor,
    Color? selectedIconColor,
  }) {
    final isUnselectedNotDefault = isSelected == false;
    final isUnselectedDefault = isSelected != true;
    final isSelectedNotDefault = isSelected == true;
    final isSelectedDefault = isSelected != false;

    final resolvedHeight = switch (size) {
      .extraSmall => 32.0,
      .small => 40.0,
      .medium => 56.0,
      .large => 96.0,
      .extraLarge => 136.0,
    };

    final resolvedIconSize = switch (size) {
      .extraSmall => 20.0,
      .small => 24.0,
      .medium => 24.0,
      .large => 32.0,
      .extraLarge => 40.0,
    };

    final resolvedWidth = switch ((size, width)) {
      (_, .normal) => resolvedHeight,
      (.extraSmall, .narrow) => 28.0,
      (.extraSmall, .wide) => 40.0,
      (.small, .narrow) => 32.0,
      (.small, .wide) => 52.0,
      (.medium, .narrow) => 48.0,
      (.medium, .wide) => 72.0,
      (.large, .narrow) => 64.0,
      (.large, .wide) => 128.0,
      (.extraLarge, .narrow) => 104.0,
      (.extraLarge, .wide) => 184.0,
    };

    final resolvedPadding = EdgeInsetsGeometry.symmetric(
      horizontal: (resolvedWidth - resolvedIconSize) / 2.0,
      vertical: (resolvedHeight - resolvedIconSize) / 2.0,
    );

    final cornerRound = shapeTheme.corner.full;
    final cornerSquare = switch (size) {
      .extraSmall => shapeTheme.corner.medium,
      .small => shapeTheme.corner.medium,
      .medium => shapeTheme.corner.large,
      .large => shapeTheme.corner.extraLarge,
      .extraLarge => shapeTheme.corner.extraLarge,
    };

    final corner = isSelectedNotDefault
        ? selectedShape != null
              ? switch (selectedShape) {
                  .round => cornerRound,
                  .square => cornerSquare,
                }
              : switch (shape) {
                  .round => cornerSquare,
                  .square => cornerRound,
                }
        : unselectedShape != null
        ? switch (unselectedShape) {
            .round => cornerRound,
            .square => cornerSquare,
          }
        : switch (shape) {
            .round => cornerRound,
            .square => cornerSquare,
          };

    final resolvedDisabledBackgroundColor =
        switch (isSelected) {
          null => disabledContainerColor,
          false => unselectedDisabledContainerColor,
          true => selectedDisabledContainerColor,
        } ??
        colorTheme.onSurface.withValues(alpha: 0.10);

    final resolvedDisabledElevation =
        switch (isSelected) {
          _ => disabledContainerElevation,
        } ??
        elevationTheme.level0;
    final resolvedElevation =
        switch (isSelected) {
          _ => containerElevation,
        } ??
        elevationTheme.level0;

    final resolvedBackgroundColor =
        switch (isSelected) {
          null => containerColor,
          false => unselectedContainerColor,
          true => selectedContainerColor,
        } ??
        switch (color) {
          .filled =>
            isSelectedDefault
                ? colorTheme.primary
                : colorTheme.surfaceContainer,
          .tonal =>
            isSelectedNotDefault
                ? colorTheme.secondary
                : colorTheme.secondaryContainer,
          .outlined =>
            isSelectedNotDefault
                ? colorTheme.inverseSurface
                : Colors.transparent,
          .standard => Colors.transparent,
        };

    final resolvedDisabledIconColor =
        switch (isSelected) {
          null => disabledIconColor,
          false => unselectedDisabledIconColor,
          true => selectedDisabledIconColor,
        } ??
        colorTheme.onSurface.withValues(alpha: 0.38);

    final resolvedIconColor =
        switch (isSelected) {
          null => iconColor,
          false => unselectedIconColor,
          true => selectedIconColor,
        } ??
        switch (color) {
          .filled =>
            isSelectedDefault
                ? colorTheme.onPrimary
                : colorTheme.onSurfaceVariant,
          .tonal =>
            isSelectedNotDefault
                ? colorTheme.onSecondary
                : colorTheme.onSecondaryContainer,
          .outlined =>
            isSelectedNotDefault
                ? colorTheme.inverseOnSurface
                : colorTheme.onSurfaceVariant,
          .standard =>
            isSelectedNotDefault
                ? colorTheme.primary
                : colorTheme.onSurfaceVariant,
        };

    final outlineWidth = switch (size) {
      .extraSmall => 1.0,
      .small => 1.0,
      .medium => 1.0,
      .large => 2.0,
      .extraLarge => 3.0,
    };
    final side = switch (color) {
      .outlined when isUnselectedDefault => BorderSide(
        style: BorderStyle.solid,
        color: colorTheme.outlineVariant,
        width: outlineWidth,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
      _ => BorderSide(
        style: BorderStyle.none,
        color: colorTheme.background,
        width: 0.0,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    };
    return ButtonStyle(
      animationDuration: Duration.zero,
      alignment: Alignment.center,
      enableFeedback: true,
      iconAlignment: IconAlignment.start,
      mouseCursor: WidgetStateMouseCursor.clickable,
      tapTargetSize: tapTargetSize,
      elevation: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? resolvedDisabledElevation
            : resolvedElevation,
      ),
      shadowColor: WidgetStatePropertyAll(colorTheme.shadow),
      minimumSize: const WidgetStatePropertyAll(.zero),
      fixedSize: WidgetStatePropertyAll(Size(resolvedWidth, resolvedHeight)),
      maximumSize: const WidgetStatePropertyAll(.infinite),
      padding: const WidgetStatePropertyAll(.zero),
      iconSize: WidgetStatePropertyAll(resolvedIconSize),
      shape: WidgetStatePropertyAll(
        CornersBorder.rounded(corners: .all(corner)),
      ),
      side: WidgetStatePropertyAll(side),
      overlayColor: WidgetStateLayerColor(
        color: WidgetStatePropertyAll(resolvedIconColor),
        opacity: stateTheme.stateLayerOpacity,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? resolvedDisabledBackgroundColor
            : resolvedBackgroundColor,
      ),
      iconColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? resolvedDisabledIconColor
            : resolvedIconColor,
      ),
    );
  }

  static MenuThemeData createMenuTheme({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    LegacyMenuVariant variant = LegacyMenuVariant.standard,
  }) {
    return MenuThemeData(
      style: MenuStyle(
        visualDensity: VisualDensity.standard,
        padding: const WidgetStatePropertyAll(.fromLTRB(4.0, 2.0, 4.0, 2.0)),
        shape: WidgetStatePropertyAll(
          CornersBorder.rounded(corners: .all(shapeTheme.corner.large)),
        ),
        backgroundColor: WidgetStatePropertyAll(switch (variant) {
          LegacyMenuVariant.standard => colorTheme.surfaceContainerLow,
          LegacyMenuVariant.vibrant => colorTheme.tertiaryContainer,
        }),
        elevation: WidgetStatePropertyAll(elevationTheme.level2),
        shadowColor: WidgetStatePropertyAll(colorTheme.shadow),
        side: const WidgetStatePropertyAll(BorderSide.none),
      ),
    );
  }

  static MenuButtonThemeData createMenuButtonTheme({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
    LegacyMenuVariant variant = LegacyMenuVariant.standard,
  }) {
    final containerShape = WidgetStatePropertyAll(
      CornersBorder.rounded(corners: .all(shapeTheme.corner.medium)),
    );
    final containerColor = WidgetStateProperty.resolveWith((states) {
      final isFocused = states.contains(WidgetState.focused);
      return switch (variant) {
        LegacyMenuVariant.standard =>
          isFocused
              ? colorTheme.tertiaryContainer
              : colorTheme.surfaceContainerLow,
        LegacyMenuVariant.vibrant =>
          isFocused ? colorTheme.tertiary : colorTheme.tertiaryContainer,
      };
    });
    final iconColor = WidgetStateProperty.resolveWith((states) {
      final isFocused = states.contains(WidgetState.focused);
      return switch (variant) {
        LegacyMenuVariant.standard =>
          isFocused
              ? colorTheme.onTertiaryContainer
              : colorTheme.onSurfaceVariant,
        LegacyMenuVariant.vibrant =>
          isFocused ? colorTheme.onTertiary : colorTheme.onTertiaryContainer,
      };
    });
    final labelTextStyle = WidgetStateProperty.resolveWith((states) {
      final isFocused = states.contains(WidgetState.focused);
      return (isFocused
              ? typescaleTheme.labelLargeEmphasized
              : typescaleTheme.labelLarge)
          .toTextStyle();
    });
    final labelTextColor = WidgetStateProperty.resolveWith((states) {
      final isFocused = states.contains(WidgetState.focused);
      return switch (variant) {
        LegacyMenuVariant.standard =>
          isFocused ? colorTheme.onTertiaryContainer : colorTheme.onSurface,
        LegacyMenuVariant.vibrant =>
          isFocused ? colorTheme.onTertiary : colorTheme.onTertiaryContainer,
      };
    });
    final stateLayerColor = WidgetStateLayerColor(
      color: WidgetStateProperty.resolveWith((states) {
        final isFocused = states.contains(WidgetState.focused);
        return switch (variant) {
          LegacyMenuVariant.standard =>
            isFocused ? colorTheme.onTertiaryContainer : colorTheme.onSurface,
          LegacyMenuVariant.vibrant =>
            isFocused ? colorTheme.onTertiary : colorTheme.onTertiaryContainer,
        };
      }),
      opacity: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return stateTheme.pressedStateLayerOpacity;
        }
        if (states.contains(WidgetState.hovered)) {
          return stateTheme.hoverStateLayerOpacity;
        }
        if (states.contains(WidgetState.focused)) {
          return stateTheme.focusStateLayerOpacity;
        }
        return 0.0;
      }),
    );
    return MenuButtonThemeData(
      style: ButtonStyle(
        animationDuration: Duration.zero,
        minimumSize: const WidgetStatePropertyAll(Size(0.0, 44.0)),
        maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 44.0)),
        padding: const WidgetStatePropertyAll(.fromLTRB(12.0, 0.0, 12.0, 0.0)),
        tapTargetSize: MaterialTapTargetSize.padded,
        mouseCursor: WidgetStateMouseCursor.clickable,
        shape: containerShape,
        backgroundColor: containerColor,
        iconSize: const WidgetStatePropertyAll(24.0),
        iconColor: iconColor,
        textStyle: labelTextStyle,
        foregroundColor: labelTextColor,
        overlayColor: stateLayerColor,
      ),
    );
  }
}

class _SliderValueIndicatorShapeYear2024 extends SliderComponentShape {
  const _SliderValueIndicatorShapeYear2024();

  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    TextPainter? labelPainter,
    double? textScaleFactor,
  }) {
    assert(labelPainter != null);
    assert(textScaleFactor != null && textScaleFactor >= 0);
    return _pathPainter.getPreferredSize(labelPainter!, textScaleFactor!);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) => _pathPainter.paint(
    parentBox: parentBox,
    canvas: context.canvas,
    center: center,
    scale: activationAnimation.value,
    labelPainter: labelPainter,
    textScaleFactor: textScaleFactor,
    sizeWithOverflow: sizeWithOverflow,
    backgroundPaintColor: sliderTheme.valueIndicatorColor!,
    strokePaintColor: sliderTheme.valueIndicatorStrokeColor,
  );

  static const _SliderValueIndicatorPathPainterYear2024 _pathPainter =
      _SliderValueIndicatorPathPainterYear2024();
}

class _SliderValueIndicatorPathPainterYear2024 {
  const _SliderValueIndicatorPathPainterYear2024();

  Size getPreferredSize(TextPainter labelPainter, double textScaleFactor) =>
      Size(
        math.max(_minLabelWidth, labelPainter.width) +
            _labelPadding.horizontal * textScaleFactor,
        (labelPainter.height + _labelPadding.vertical) * textScaleFactor,
      );

  double getHorizontalShift({
    required RenderBox parentBox,
    required Offset center,
    required TextPainter labelPainter,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required double scale,
  }) {
    assert(!sizeWithOverflow.isEmpty);

    const edgePadding = 8.0;
    final rectangleWidth = _upperRectangleWidth(labelPainter, scale);

    /// Value indicator draws on the Overlay and by using the global Offset
    /// we are making sure we use the bounds of the Overlay instead of the Slider.
    final globalCenter = parentBox.localToGlobal(center);

    // The rectangle must be shifted towards the center so that it minimizes the
    // chance of it rendering outside the bounds of the render box. If the shift
    // is negative, then the lobe is shifted from right to left, and if it is
    // positive, then the lobe is shifted from left to right.
    final overflowLeft = math.max(
      0.0,
      rectangleWidth / 2.0 - globalCenter.dx + edgePadding,
    );
    final overflowRight = math.max(
      0.0,
      rectangleWidth / 2.0 -
          (sizeWithOverflow.width - globalCenter.dx - edgePadding),
    );

    if (rectangleWidth < sizeWithOverflow.width) {
      return overflowLeft - overflowRight;
    } else if (overflowLeft - overflowRight > 0.0) {
      return overflowLeft - (edgePadding * textScaleFactor);
    } else {
      return -overflowRight + (edgePadding * textScaleFactor);
    }
  }

  double _upperRectangleWidth(TextPainter labelPainter, double scale) {
    final unscaledWidth =
        math.max(_minLabelWidth, labelPainter.width) + _labelPadding.horizontal;
    return unscaledWidth * scale;
  }

  double _upperRectangleHeight(TextPainter labelPainter, double scale) {
    final unscaledHeight = labelPainter.height + _labelPadding.vertical;
    return unscaledHeight * scale;
  }

  void paint({
    required RenderBox parentBox,
    required Canvas canvas,
    required Offset center,
    required double scale,
    required TextPainter labelPainter,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required Color backgroundPaintColor,
    Color? strokePaintColor,
  }) {
    // Zero scale essentially means "do not draw anything", so it's safe to just return.
    if (scale == 0.0) return;

    assert(!sizeWithOverflow.isEmpty);

    final rectangleWidth = _upperRectangleWidth(labelPainter, scale);
    final rectangleHeight = _upperRectangleHeight(labelPainter, scale);
    final halfRectangleHeight = rectangleHeight / 2.0;
    final horizontalShift = getHorizontalShift(
      parentBox: parentBox,
      center: center,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      scale: scale,
    );

    final upperRect = Rect.fromLTWH(
      -rectangleWidth / 2 + horizontalShift,
      -_rectYOffset - rectangleHeight,
      rectangleWidth,
      rectangleHeight,
    );

    final fillPaint = Paint()
      ..style = .fill
      ..color = backgroundPaintColor;

    canvas
      ..save()
      // Prepare the canvas for the base of the tooltip, which is relative to the
      // center of the thumb.
      ..translate(center.dx, center.dy - _labelPadding.bottom - 4.0)
      ..scale(scale, scale);

    final rrect = RRect.fromRectAndRadius(
      upperRect,
      .circular(upperRect.height / 2),
    );
    if (strokePaintColor != null) {
      final strokePaint = Paint()
        ..style = .stroke
        ..color = strokePaintColor
        ..strokeWidth = 1.0;
      canvas.drawRRect(rrect, strokePaint);
    }

    canvas.drawRRect(rrect, fillPaint);

    // The label text is centered within the value indicator.
    final bottomTipToUpperRectTranslateY =
        -halfRectangleHeight / 2.0 - upperRect.height;
    canvas.translate(0.0, bottomTipToUpperRectTranslateY);

    final boxCenter = Offset(horizontalShift, upperRect.height / 2.3);
    final halfLabelPainterOffset = Offset(
      labelPainter.width / 2.0,
      labelPainter.height / 2.0,
    );
    final labelOffset = boxCenter - halfLabelPainterOffset;
    labelPainter.paint(canvas, labelOffset);

    canvas.restore();
  }

  static const EdgeInsets _labelPadding = .symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  static const _minLabelWidth = 16.0;

  static const _rectYOffset = 12.0;
}
