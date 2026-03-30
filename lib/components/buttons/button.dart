part of 'buttons.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    this.style,
    this.settings = const .new(),
    this.isSelected,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.icon,
    required Widget this.label,
  }) : child = null;

  const Button.custom({
    super.key,
    this.style,
    this.settings = const .new(),
    this.isSelected,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    required Widget this.child,
  }) : icon = null,
       label = null;

  final ButtonStylePartial<ButtonSettings>? style;
  final ButtonSettings settings;
  final bool? isSelected;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final Widget? icon;
  final Widget? label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // TODO: simplify the logical expression perhaps?
    assert(
      (icon == null && label == null && child != null) ||
          (label != null && child == null),
    );
    final Widget content = child ?? ButtonContent(icon: icon, label: label);

    return ButtonContainer<ButtonSettings>(
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

  static ButtonStyle<ButtonSettings> defaultStyleFrom({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
  }) {
    final enabledContainerColor =
        ButtonStateProperty<Color, ButtonSettings>.resolveWith((states) {
          Color defaultColor() => switch (states.settings.color) {
            .elevated => colorTheme.surfaceContainerLow,
            .filled => colorTheme.primary,
            .tonal => colorTheme.secondaryContainer,
            .outlined => Colors.transparent,
            .text => Colors.transparent,
          };
          Color? unselectedColor() => switch (states.settings.color) {
            .elevated => colorTheme.surfaceContainerLow,
            .filled => colorTheme.surfaceContainer,
            .tonal => colorTheme.secondaryContainer,
            .outlined => Colors.transparent,
            .text => null,
          };
          Color? selectedColor() => switch (states.settings.color) {
            .elevated => colorTheme.primary,
            .filled => colorTheme.primary,
            .tonal => colorTheme.secondary,
            .outlined => colorTheme.inverseSurface,
            .text => null,
          };
          return switch (states) {
            ToggleButtonStates(isSelected: false) =>
              unselectedColor() ?? defaultColor(),
            ToggleButtonStates(isSelected: true) =>
              selectedColor() ?? defaultColor(),
            _ => defaultColor(),
          };
        });

    final contentColor = ButtonStateProperty<Color, ButtonSettings>.resolveWith(
      (states) {
        Color defaultColor() => switch (states.settings.color) {
          .elevated => colorTheme.primary,
          .filled => colorTheme.onPrimary,
          .tonal => colorTheme.onSecondaryContainer,
          .outlined => colorTheme.onSurfaceVariant,
          .text => colorTheme.primary,
        };
        Color? unselectedColor() => switch (states.settings.color) {
          .elevated => colorTheme.primary,
          .filled => colorTheme.onSurfaceVariant,
          .tonal => colorTheme.onSecondaryContainer,
          .outlined => colorTheme.onSurfaceVariant,
          .text => null,
        };
        Color? selectedColor() => switch (states.settings.color) {
          .elevated => colorTheme.onPrimary,
          .filled => colorTheme.onPrimary,
          .tonal => colorTheme.onSecondary,
          .outlined => colorTheme.inverseOnSurface,
          .text => null,
        };
        return switch (states) {
          ButtonDisabledStates() => colorTheme.onSurface,
          ToggleButtonStates(isSelected: false) =>
            unselectedColor() ?? defaultColor(),
          ToggleButtonStates(isSelected: true) =>
            selectedColor() ?? defaultColor(),
          _ => defaultColor(),
        };
      },
    );

    final contentOpacity =
        ButtonStateProperty<double, ButtonSettings>.resolveWith(
          (states) => switch (states) {
            ButtonDisabledStates() => stateTheme.disabledStateLayerOpacity,
            _ => 1.0,
          },
        );

    return ButtonStyle.from(
      minTapTargetSize: const .all(.square(48.0)),
      constraints: .resolveWith((states) {
        const minWidth = 48.0;
        final minHeight = switch (states.settings.size) {
          .extraSmall => 32.0,
          .small => 40.0,
          .medium => 56.0,
          .large => 96.0,
          .extraLarge => 136.0,
        };
        return .new(minWidth: minWidth, minHeight: minHeight);
      }),
      padding: .resolveWith(
        (states) => switch (states.settings.size) {
          .extraSmall => const .symmetric(horizontal: 12.0, vertical: 6.0),
          .small => const .symmetric(horizontal: 16.0, vertical: 10.0),
          .medium => const .symmetric(horizontal: 24.0, vertical: 16.0),
          .large => const .symmetric(horizontal: 48.0, vertical: 32.0),
          .extraLarge => const .symmetric(horizontal: 64.0, vertical: 48.0),
        },
      ),
      iconLabelSpace: .resolveWith(
        (states) => switch (states.settings.size) {
          .extraSmall => 4.0,
          .small => 8.0,
          .medium => 8.0,
          .large => 12.0,
          .extraLarge => 16.0,
        },
      ),
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

        double outlinedOutlineWidth() => switch (states.settings.size) {
          .extraSmall => 1.0,
          .small => 1.0,
          .medium => 1.0,
          .large => 2.0,
          .extraLarge => 3.0,
        };

        Outline outlinedDefaultOutline() => .from(
          width: outlinedOutlineWidth(),
          alignment: Outline.alignmentInside,
          color: colorTheme.outlineVariant,
        );

        Outline outlinedSelectedOutline() => .from(
          width: outlinedOutlineWidth(),
          alignment: Outline.alignmentInside,
          color: switch (states) {
            ButtonDisabledStates() => colorTheme.onSurface.withValues(
              alpha: 0.0,
            ),
            _ => enabledContainerColor.resolve(states),
          },
        );

        return switch (states.settings.color) {
          .outlined => switch (states) {
            ToggleButtonStates(isSelected: true) => outlinedSelectedOutline(),
            _ => outlinedDefaultOutline(),
          },
          _ => defaultOutline(),
        };
      }),
      containerElevation: .resolveWith(
        (states) => switch (states.settings.color) {
          // TODO: hovered elevation is no longer part of the spec.
          .elevated => switch (states) {
            ButtonDisabledStates() => elevationTheme.level0,
            ButtonEnabledStates(isPressed: true) => elevationTheme.level1,
            ButtonEnabledStates(isFocused: true) => elevationTheme.level1,
            ButtonEnabledStates(isHovered: true) => elevationTheme.level2,
            _ => elevationTheme.level1,
          },
          _ => elevationTheme.level0,
        },
      ),
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
        final size = switch (states.settings.size) {
          .extraSmall => 20.0,
          .small => 20.0,
          .medium => 24.0,
          .large => 32.0,
          .extraLarge => 40.0,
        };
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
      labelTextStyle: .resolveWith((states) {
        final typeStyle = switch (states.settings.size) {
          .extraSmall => typescaleTheme.labelLarge,
          .small => typescaleTheme.labelLarge,
          .medium => typescaleTheme.titleMedium,
          .large => typescaleTheme.headlineSmall,
          .extraLarge => typescaleTheme.headlineLarge,
        };
        final opacity = contentOpacity.resolve(states);
        final color = contentColor.resolve(states).withValues(alpha: opacity);
        return typeStyle.toTextStyle(color: color);
      }),
    );
  }

  static ButtonStyle<ButtonSettings> defaultStyleOf(BuildContext context) =>
      defaultStyleFrom(
        colorTheme: ColorTheme.of(context),
        elevationTheme: ElevationTheme.of(context),
        shapeTheme: ShapeTheme.of(context),
        stateTheme: StateTheme.of(context),
        typescaleTheme: TypescaleTheme.of(context),
      );
}
