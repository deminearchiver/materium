import 'dart:math' as math;

import 'package:materium/flutter.dart';

enum LegacyButtonSize { extraSmall, small, medium, large, extraLarge }

enum LegacyButtonShape { round, square }

enum LegacyButtonColor { elevated, filled, tonal, outlined, text }

enum MenuVariant { standard, vibrant }

abstract final class LegacyThemeFactory {
  static ThemeData create({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
  }) {
    final modalBarrierColor = colorTheme.scrim.withValues(alpha: 0.32);
    return ThemeData(
      colorScheme: colorTheme.toLegacy(),
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      textTheme: typescaleTheme.toBaselineTextTheme(),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorTheme.primary.withValues(alpha: 0.4),
        cursorColor: colorTheme.primary,
        selectionHandleColor: colorTheme.primary,
      ),
      // TODO: remove this after migration to CustomScrollbar
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(4.0),
        radius: const Radius.circular(2.0),
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: ShapeDecoration(
          shape: CornersBorder.rounded(
            corners: Corners.all(shapeTheme.corner.extraSmall),
          ),
          color: colorTheme.inverseSurface,
        ),
        textAlign: TextAlign.start,
        textStyle: typescaleTheme.bodySmall.toTextStyle(
          color: colorTheme.inverseOnSurface,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorTheme.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        elevation: elevationTheme.level0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: CornersBorder.rounded(
          corners: Corners.all(shapeTheme.corner.extraLarge),
        ),
        titleTextStyle: typescaleTheme.headlineSmall.toTextStyle(
          color: colorTheme.onSurface,
        ),
        constraints: const BoxConstraints(minWidth: 280.0, maxWidth: 560.0),
        insetPadding: const EdgeInsets.all(56.0),
        barrierColor: modalBarrierColor,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        clipBehavior: Clip.antiAlias,
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
        radius: BorderRadius.zero,
      ),
      sliderTheme: SliderThemeData(
        // ignore: deprecated_member_use
        year2023: false,
        overlayColor: Colors.transparent,
        padding: EdgeInsets.zero,
        showValueIndicator: ShowValueIndicator.onDrag,
        valueIndicatorShape: const _SliderValueIndicatorShapeYear2024(),
        valueIndicatorColor: colorTheme.inverseSurface,
        valueIndicatorTextStyle: typescaleTheme.labelLarge.toTextStyle(
          color: colorTheme.inverseOnSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: CornersBorder.rounded(
          corners: Corners.all(shapeTheme.corner.extraSmall),
        ),
      ),
      menuTheme: createMenuTheme(
        colorTheme: colorTheme,
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        variant: MenuVariant.standard,
      ),
      menuButtonTheme: createMenuButtonTheme(
        colorTheme: colorTheme,
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
        variant: MenuVariant.standard,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          // TODO: replace with  a custom transition system and add support for background color
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(
            backgroundColor: colorTheme.surfaceContainer,
          ),
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
    TextStyle? textStyle,
    TextStyle? unselectedTextStyle,
    TextStyle? selectedTextStyle,
    Color? containerColor,
    Color? unselectedContainerColor,
    Color? selectedContainerColor,
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

    final padding = switch (size) {
      .extraSmall => const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 6.0,
      ),
      .small => const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      .medium => const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      .large => const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
      .extraLarge => const EdgeInsets.symmetric(
        horizontal: 64.0,
        vertical: 48.0,
      ),
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
    final foregroundColor = switch (color) {
      .elevated =>
        isSelectedNotDefault ? colorTheme.onPrimary : colorTheme.primary,
      .filled =>
        isSelectedDefault ? colorTheme.onPrimary : colorTheme.onSurfaceVariant,
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
      tapTargetSize: MaterialTapTargetSize.padded,
      elevation: const WidgetStatePropertyAll(0.0),
      shadowColor: WidgetStateColor.transparent,
      minimumSize: WidgetStatePropertyAll(Size(minWidth, minHeight)),
      fixedSize: const WidgetStatePropertyAll(null),
      maximumSize: const WidgetStatePropertyAll(Size.infinite),
      padding: WidgetStatePropertyAll(padding),
      iconSize: const WidgetStatePropertyAll(24.0),
      shape: WidgetStatePropertyAll(
        CornersBorder.rounded(corners: Corners.all(corner)),
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

  static MenuThemeData createMenuTheme({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    MenuVariant variant = MenuVariant.standard,
  }) {
    return MenuThemeData(
      style: MenuStyle(
        visualDensity: VisualDensity.standard,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
        ),
        shape: WidgetStatePropertyAll(
          CornersBorder.rounded(corners: Corners.all(shapeTheme.corner.large)),
        ),
        backgroundColor: WidgetStatePropertyAll(switch (variant) {
          MenuVariant.standard => colorTheme.surfaceContainerLow,
          MenuVariant.vibrant => colorTheme.tertiaryContainer,
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
    MenuVariant variant = MenuVariant.standard,
  }) {
    final containerShape = WidgetStatePropertyAll(
      CornersBorder.rounded(corners: Corners.all(shapeTheme.corner.medium)),
    );
    final containerColor = WidgetStateProperty.resolveWith((states) {
      final isFocused = states.contains(WidgetState.focused);
      return switch (variant) {
        MenuVariant.standard =>
          isFocused
              ? colorTheme.tertiaryContainer
              : colorTheme.surfaceContainerLow,
        MenuVariant.vibrant =>
          isFocused ? colorTheme.tertiary : colorTheme.tertiaryContainer,
      };
    });
    final iconColor = WidgetStateProperty.resolveWith((states) {
      final isFocused = states.contains(WidgetState.focused);
      return switch (variant) {
        MenuVariant.standard =>
          isFocused
              ? colorTheme.onTertiaryContainer
              : colorTheme.onSurfaceVariant,
        MenuVariant.vibrant =>
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
        MenuVariant.standard =>
          isFocused ? colorTheme.onTertiaryContainer : colorTheme.onSurface,
        MenuVariant.vibrant =>
          isFocused ? colorTheme.onTertiary : colorTheme.onTertiaryContainer,
      };
    });
    final stateLayerColor = WidgetStateLayerColor(
      color: WidgetStateProperty.resolveWith((states) {
        final isFocused = states.contains(WidgetState.focused);
        return switch (variant) {
          MenuVariant.standard =>
            isFocused ? colorTheme.onTertiaryContainer : colorTheme.onSurface,
          MenuVariant.vibrant =>
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
        padding: const WidgetStatePropertyAll(
          EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
        ),
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

  static const _SliderValueIndicatorPathPainterYear2024 _pathPainter =
      _SliderValueIndicatorPathPainterYear2024();

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
  }) {
    final Canvas canvas = context.canvas;
    final double scale = activationAnimation.value;
    _pathPainter.paint(
      parentBox: parentBox,
      canvas: canvas,
      center: center,
      scale: scale,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      backgroundPaintColor: sliderTheme.valueIndicatorColor!,
      strokePaintColor: sliderTheme.valueIndicatorStrokeColor,
    );
  }
}

class _SliderValueIndicatorPathPainterYear2024 {
  const _SliderValueIndicatorPathPainterYear2024();

  static const EdgeInsets _labelPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const double _minLabelWidth = 16.0;
  static const double _rectYOffset = 12.0;

  Size getPreferredSize(TextPainter labelPainter, double textScaleFactor) {
    final width =
        math.max(_minLabelWidth, labelPainter.width) +
        _labelPadding.horizontal * textScaleFactor;
    final height =
        (labelPainter.height + _labelPadding.vertical) * textScaleFactor;
    return Size(width, height);
  }

  double getHorizontalShift({
    required RenderBox parentBox,
    required Offset center,
    required TextPainter labelPainter,
    required double textScaleFactor,
    required Size sizeWithOverflow,
    required double scale,
  }) {
    assert(!sizeWithOverflow.isEmpty);

    const double edgePadding = 8.0;
    final double rectangleWidth = _upperRectangleWidth(labelPainter, scale);

    /// Value indicator draws on the Overlay and by using the global Offset
    /// we are making sure we use the bounds of the Overlay instead of the Slider.
    final Offset globalCenter = parentBox.localToGlobal(center);

    // The rectangle must be shifted towards the center so that it minimizes the
    // chance of it rendering outside the bounds of the render box. If the shift
    // is negative, then the lobe is shifted from right to left, and if it is
    // positive, then the lobe is shifted from left to right.
    final double overflowLeft = math.max(
      0,
      rectangleWidth / 2 - globalCenter.dx + edgePadding,
    );
    final double overflowRight = math.max(
      0,
      rectangleWidth / 2 -
          (sizeWithOverflow.width - globalCenter.dx - edgePadding),
    );

    if (rectangleWidth < sizeWithOverflow.width) {
      return overflowLeft - overflowRight;
    } else if (overflowLeft - overflowRight > 0) {
      return overflowLeft - (edgePadding * textScaleFactor);
    } else {
      return -overflowRight + (edgePadding * textScaleFactor);
    }
  }

  double _upperRectangleWidth(TextPainter labelPainter, double scale) {
    final double unscaledWidth =
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
    if (scale == 0.0) {
      // Zero scale essentially means "do not draw anything", so it's safe to just return.
      return;
    }
    assert(!sizeWithOverflow.isEmpty);

    final rectangleWidth = _upperRectangleWidth(labelPainter, scale);
    final rectangleHeight = _upperRectangleHeight(labelPainter, scale);
    final halfRectangleHeight = rectangleHeight / 2.0;
    final double horizontalShift = getHorizontalShift(
      parentBox: parentBox,
      center: center,
      labelPainter: labelPainter,
      textScaleFactor: textScaleFactor,
      sizeWithOverflow: sizeWithOverflow,
      scale: scale,
    );

    final Rect upperRect = Rect.fromLTWH(
      -rectangleWidth / 2 + horizontalShift,
      -_rectYOffset - rectangleHeight,
      rectangleWidth,
      rectangleHeight,
    );

    final Paint fillPaint = Paint()..color = backgroundPaintColor;

    canvas.save();
    // Prepare the canvas for the base of the tooltip, which is relative to the
    // center of the thumb.
    canvas.translate(center.dx, center.dy - _labelPadding.bottom - 4.0);
    canvas.scale(scale, scale);

    final RRect rrect = RRect.fromRectAndRadius(
      upperRect,
      Radius.circular(upperRect.height / 2),
    );
    if (strokePaintColor != null) {
      final Paint strokePaint = Paint()
        ..color = strokePaintColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, strokePaint);
    }

    canvas.drawRRect(rrect, fillPaint);

    // The label text is centered within the value indicator.
    final double bottomTipToUpperRectTranslateY =
        -halfRectangleHeight / 2 - upperRect.height;
    canvas.translate(0, bottomTipToUpperRectTranslateY);
    final Offset boxCenter = Offset(horizontalShift, upperRect.height / 2.3);
    final Offset halfLabelPainterOffset = Offset(
      labelPainter.width / 2,
      labelPainter.height / 2,
    );
    final Offset labelOffset = boxCenter - halfLabelPainterOffset;
    labelPainter.paint(canvas, labelOffset);
    canvas.restore();
  }
}
