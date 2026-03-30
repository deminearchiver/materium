part of 'buttons.dart';

class IconButton extends StatelessWidget {
  const IconButton({
    super.key,
    this.style,
    this.settings = const .new(),
    this.isSelected,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    required Widget this.icon,
  }) : child = null;

  const IconButton.custom({
    super.key,
    this.style,
    this.settings = const .new(),
    this.isSelected,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    required Widget this.child,
  }) : icon = null;

  final ButtonStylePartial<IconButtonSettings>? style;
  final IconButtonSettings settings;
  final bool? isSelected;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final Widget? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    assert((icon == null) != (child == null));
    final Widget content = child ?? ButtonContent(icon: icon);

    return ButtonContainer<IconButtonSettings>(
      style: defaultStyleOf(context).merge(style),
      settings: settings,
      isSelected: isSelected,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      child: content,
    );
  }

  static ButtonStyle<IconButtonSettings> defaultStyleFrom({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
  }) {
    final height = ButtonStateProperty<double, IconButtonSettings>.resolveWith(
      (states) => switch (states.settings.size) {
        .extraSmall => 32.0,
        .small => 40.0,
        .medium => 56.0,
        .large => 96.0,
        .extraLarge => 136.0,
      },
    );

    final width = ButtonStateProperty<double, IconButtonSettings>.resolveWith(
      (states) => switch (states.settings.width) {
        .normal => height.resolve(states),
        .narrow => switch (states.settings.size) {
          .extraSmall => 28.0,
          .small => 32.0,
          .medium => 48.0,
          .large => 64.0,
          .extraLarge => 104.0,
        },
        .wide => switch (states.settings.size) {
          .extraSmall => 40.0,
          .small => 52.0,
          .medium => 72.0,
          .large => 128.0,
          .extraLarge => 184.0,
        },
      },
    );

    final iconSize =
        ButtonStateProperty<double, IconButtonSettings>.resolveWith(
          (states) => switch (states.settings.size) {
            .extraSmall => 20.0,
            .small => 24.0,
            .medium => 24.0,
            .large => 32.0,
            .extraLarge => 40.0,
          },
        );

    final enabledContainerColor =
        ButtonStateProperty<Color, IconButtonSettings>.resolveWith((states) {
          Color defaultColor() => switch (states.settings.color) {
            .filled => colorTheme.primary,
            .tonal => colorTheme.secondaryContainer,
            .outlined => Colors.transparent,
            .standard => Colors.transparent,
          };
          Color unselectedColor() => switch (states.settings.color) {
            .filled => colorTheme.surfaceContainer,
            .tonal => colorTheme.secondaryContainer,
            .outlined => Colors.transparent,
            .standard => Colors.transparent,
          };
          Color selectedColor() => switch (states.settings.color) {
            .filled => colorTheme.primary,
            .tonal => colorTheme.secondary,
            .outlined => colorTheme.inverseSurface,
            .standard => Colors.transparent,
          };
          return switch (states) {
            ToggleButtonStates(isSelected: false) => unselectedColor(),
            ToggleButtonStates(isSelected: true) => selectedColor(),
            _ => defaultColor(),
          };
        });

    final contentColor =
        ButtonStateProperty<Color, IconButtonSettings>.resolveWith((states) {
          Color defaultColor() => switch (states.settings.color) {
            .filled => colorTheme.onPrimary,
            .tonal => colorTheme.onSecondaryContainer,
            .outlined => colorTheme.onSurfaceVariant,
            .standard => colorTheme.onSurfaceVariant,
          };
          Color unselectedColor() => switch (states.settings.color) {
            .filled => colorTheme.onSurfaceVariant,
            .tonal => colorTheme.onSecondaryContainer,
            .outlined => colorTheme.onSurfaceVariant,
            .standard => colorTheme.onSurfaceVariant,
          };
          Color selectedColor() => switch (states.settings.color) {
            .filled => colorTheme.onPrimary,
            .tonal => colorTheme.onSecondary,
            .outlined => colorTheme.inverseOnSurface,
            .standard => colorTheme.primary,
          };
          return switch (states) {
            ButtonDisabledStates() => colorTheme.onSurface,
            ToggleButtonStates(isSelected: false) => unselectedColor(),
            ToggleButtonStates(isSelected: true) => selectedColor(),
            _ => defaultColor(),
          };
        });

    final contentOpacity =
        ButtonStateProperty<double, IconButtonSettings>.resolveWith(
          (states) => switch (states) {
            ButtonDisabledStates() => stateTheme.disabledStateLayerOpacity,
            _ => 1.0,
          },
        );

    return ButtonStyle.from(
      minTapTargetSize: const .all(.square(48.0)),
      constraints: .resolveWith((states) {
        final resolvedWidth = width.resolve(states);
        final resolvedHeight = height.resolve(states);
        return .new(
          minWidth: resolvedWidth,
          minHeight: resolvedHeight,
          maxHeight: resolvedHeight,
        );
      }),
      padding: .resolveWith((states) {
        final resolvedIconSize = iconSize.resolve(states);
        return .symmetric(
          horizontal: (width.resolve(states) - resolvedIconSize) / 2.0,
          vertical: (height.resolve(states) - resolvedIconSize) / 2.0,
        );
      }),
      iconLabelSpace: const .all(0.0),
      containerShape: .resolveWith((states) {
        final corner = switch (states) {
          ButtonEnabledStates(isPressed: true) => _ButtonDefaults.cornerPressed(
            shapeTheme,
            states.settings.size,
          ),
          ToggleButtonStates(isSelected: true) =>
            switch (states.settings.shape) {
              .round => _ButtonDefaults.cornerSquare(
                shapeTheme,
                states.settings.size,
              ),
              .square => _ButtonDefaults.cornerRound(shapeTheme),
            },
          _ => switch (states.settings.shape) {
            .round => _ButtonDefaults.cornerRound(shapeTheme),
            .square => _ButtonDefaults.cornerSquare(
              shapeTheme,
              states.settings.size,
            ),
          },
        };
        return CornersBorder.rounded(corners: .all(corner));
      }),
      containerColor: .resolveWith(
        (states) => switch (states) {
          ButtonDisabledStates() => colorTheme.onSurface.withValues(alpha: 0.1),
          _ => enabledContainerColor.resolve(states),
        },
      ),
      containerOutline: .resolveWith((states) {
        Outline defaultOutline() => .from(
          width: 0.0,
          alignment: Outline.alignmentInside,
          color: switch (states) {
            ButtonDisabledStates() => colorTheme.onSurface.withValues(
              alpha: 0.0,
            ),
            _ => enabledContainerColor.resolve(states),
          },
        );

        Outline outlinedOutline() => .from(
          width: switch (states.settings.size) {
            .extraSmall => 1.0,
            .small => 1.0,
            .medium => 1.0,
            .large => 2.0,
            .extraLarge => 3.0,
          },
          alignment: Outline.alignmentInside,
          color: colorTheme.outlineVariant,
        );
        return switch (states.settings.color) {
          .outlined => switch (states) {
            ToggleButtonStates(isSelected: true) => defaultOutline(),
            _ => outlinedOutline(),
          },
          _ => defaultOutline(),
        };
      }),
      containerElevation: .all(elevationTheme.level0),
      containerShadowColor: .all(colorTheme.shadow),
      stateLayerColor: contentColor,
      stateLayerOpacity: .resolveWith(
        (states) => switch (states) {
          ButtonDisabledStates() => 0.0,
          ButtonEnabledStates(isPressed: true) =>
            stateTheme.pressedStateLayerOpacity,
          ButtonEnabledStates(isFocused: true) =>
            stateTheme.focusStateLayerOpacity,
          ButtonEnabledStates(isHovered: true) =>
            stateTheme.hoverStateLayerOpacity,
          _ => 0.0,
        },
      ),
      iconTheme: .resolveWith((states) {
        final fill = switch (states) {
          ToggleButtonStates(isSelected: false) => 0.0,
          ToggleButtonStates(isSelected: true) => 1.0,
          _ => switch (states.settings.color) {
            .filled => 1.0,
            _ => null,
          },
        };
        final size = iconSize.resolve(states);
        final color = contentColor.resolve(states);
        final opacity = contentOpacity.resolve(states);
        return .from(
          fill: fill,
          opticalSize: size,
          size: size,
          color: color,
          opacity: opacity,
        );
      }),
      labelTextStyle: const .all(TextStyle()),
    );
  }

  static ButtonStyle<IconButtonSettings> defaultStyleOf(BuildContext context) =>
      defaultStyleFrom(
        colorTheme: ColorTheme.of(context),
        elevationTheme: ElevationTheme.of(context),
        shapeTheme: ShapeTheme.of(context),
        stateTheme: StateTheme.of(context),
      );
}
