part of 'buttons.dart';

class ExtendedFloatingActionButton extends StatelessWidget {
  const ExtendedFloatingActionButton({
    super.key,
    this.style,
    this.settings = const .new(),
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.icon,
    required Widget this.label,
  }) : child = null;

  const ExtendedFloatingActionButton.custom({
    super.key,
    this.style,
    this.settings = const .new(),
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    required Widget this.child,
  }) : icon = null,
       label = null;

  final ButtonStylePartial<FloatingActionButtonSettings>? style;
  final FloatingActionButtonSettings settings;
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

    return ButtonContainer<FloatingActionButtonSettings>(
      style: defaultStyleOf(context).merge(style),
      settings: settings,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      child: content,
    );
  }

  static ButtonStyle<FloatingActionButtonSettings> defaultStyleFrom({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
  }) {
    final containerColor =
        ButtonStateProperty<Color, FloatingActionButtonSettings>.resolveWith(
          (states) => switch (states.settings.color) {
            .primaryContainer => colorTheme.primaryContainer,
            .secondaryContainer => colorTheme.secondaryContainer,
            .tertiaryContainer => colorTheme.tertiaryContainer,
            .primary => colorTheme.primary,
            .secondary => colorTheme.secondary,
            .tertiary => colorTheme.tertiary,
          },
        );

    final contentColor =
        ButtonStateProperty<Color, FloatingActionButtonSettings>.resolveWith(
          (states) => switch (states.settings.color) {
            .primaryContainer => colorTheme.onPrimaryContainer,
            .secondaryContainer => colorTheme.onSecondaryContainer,
            .tertiaryContainer => colorTheme.onTertiaryContainer,
            .primary => colorTheme.onPrimary,
            .secondary => colorTheme.onSecondary,
            .tertiary => colorTheme.onTertiary,
          },
        );

    return ButtonStyle.from(
      minTapTargetSize: const .all(.square(48.0)),
      constraints: .resolveWith((states) {
        final height = switch (states.settings.size) {
          .small => 56.0,
          .medium => 80.0,
          .large => 96.0,
        };
        return .new(minWidth: height, minHeight: height, maxHeight: height);
      }),
      padding: .resolveWith(
        (states) => switch (states.settings.size) {
          .small => const .symmetric(horizontal: 16.0),
          .medium => const .symmetric(horizontal: 26.0),
          .large => const .symmetric(horizontal: 28.0),
        },
      ),
      iconLabelSpace: .resolveWith(
        (states) => switch (states.settings.size) {
          .small => 8.0,
          .medium => 12.0,
          .large => 16.0,
        },
      ),
      containerShape: .resolveWith(
        (states) => CornersBorder.rounded(
          corners: .all(switch (states.settings.size) {
            .small => shapeTheme.corner.large,
            .medium => shapeTheme.corner.largeIncreased,
            .large => shapeTheme.corner.extraLarge,
          }),
        ),
      ),
      containerColor: containerColor,
      containerOutline: .resolveWith(
        (states) => .from(
          width: 0.0,
          alignment: Outline.alignmentInside,
          color: switch (states) {
            ButtonDisabledStates() => colorTheme.onSurface.withValues(
              alpha: 0.0,
            ),
            _ => containerColor.resolve(states),
          },
        ),
      ),
      containerElevation: .resolveWith(
        (states) => switch (states) {
          ButtonEnabledStates(isPressed: true) => elevationTheme.level3,
          ButtonEnabledStates(isFocused: true) => elevationTheme.level3,
          ButtonEnabledStates(isHovered: true) => elevationTheme.level4,
          _ => elevationTheme.level3,
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
        final fill = switch (states.settings.color) {
          .primary || .secondary || .tertiary => 1.0,
          _ => null,
        };
        final size = switch (states.settings.size) {
          .small => 24.0,
          .medium => 28.0,
          .large => 36.0,
        };
        final color = contentColor.resolve(states);
        return .from(
          fill: fill,
          opticalSize: size,
          size: size,
          color: color,
          opacity: 1.0,
        );
      }),
      labelTextStyle: .resolveWith((states) {
        final typeStyle = switch (states.settings.size) {
          .small => typescaleTheme.titleMedium,
          .medium => typescaleTheme.titleLarge,
          .large => typescaleTheme.headlineSmall,
        };
        final color = contentColor.resolve(states);
        return typeStyle.toTextStyle(color: color);
      }),
    );
  }

  static ButtonStyle<FloatingActionButtonSettings> defaultStyleOf(
    BuildContext context,
  ) => defaultStyleFrom(
    colorTheme: ColorTheme.of(context),
    elevationTheme: ElevationTheme.of(context),
    shapeTheme: ShapeTheme.of(context),
    stateTheme: StateTheme.of(context),
    typescaleTheme: TypescaleTheme.of(context),
  );
}
