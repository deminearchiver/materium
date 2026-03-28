part of 'buttons.dart';

abstract class ButtonStylePartial<S extends Object?> with Diagnosticable {
  const ButtonStylePartial();

  const factory ButtonStylePartial.from({
    ButtonStateProperty<Size?, S>? minTapTargetSize,
    ButtonStateProperty<BoxConstraints?, S>? constraints,
    ButtonStateProperty<EdgeInsetsGeometry?, S>? padding,
    ButtonStateProperty<double?, S>? iconLabelSpace,
    ButtonStateProperty<OutlinedBorder?, S>? containerShape,
    ButtonStateProperty<Color?, S>? containerColor,
    ButtonStateProperty<OutlinePartial?, S>? containerOutline,
    ButtonStateProperty<double?, S>? containerElevation,
    ButtonStateProperty<Color?, S>? containerShadowColor,
    ButtonStateProperty<Color?, S>? stateLayerColor,
    ButtonStateProperty<double?, S>? stateLayerOpacity,
    ButtonStateProperty<IconThemeDataPartial?, S>? iconTheme,
    ButtonStateProperty<TextStyle?, S>? labelTextStyle,
  }) = _ButtonStylePartial<S>;

  ButtonStateProperty<Size?, S>? get minTapTargetSize;

  ButtonStateProperty<BoxConstraints?, S>? get constraints;

  ButtonStateProperty<EdgeInsetsGeometry?, S>? get padding;

  ButtonStateProperty<double?, S>? get iconLabelSpace;

  ButtonStateProperty<OutlinedBorder?, S>? get containerShape;

  ButtonStateProperty<Color?, S>? get containerColor;

  ButtonStateProperty<OutlinePartial?, S>? get containerOutline;

  ButtonStateProperty<double?, S>? get containerElevation;

  ButtonStateProperty<Color?, S>? get containerShadowColor;

  ButtonStateProperty<Color?, S>? get stateLayerColor;

  ButtonStateProperty<double?, S>? get stateLayerOpacity;

  ButtonStateProperty<IconThemeDataPartial?, S>? get iconTheme;

  ButtonStateProperty<TextStyle?, S>? get labelTextStyle;

  ButtonStylePartial<S> copyWith({
    covariant ButtonStateProperty<Size?, S>? minTapTargetSize,
    covariant ButtonStateProperty<BoxConstraints?, S>? constraints,
    covariant ButtonStateProperty<EdgeInsetsGeometry?, S>? padding,
    covariant ButtonStateProperty<double?, S>? iconLabelSpace,
    covariant ButtonStateProperty<OutlinedBorder?, S>? containerShape,
    covariant ButtonStateProperty<Color?, S>? containerColor,
    covariant ButtonStateProperty<OutlinePartial?, S>? containerOutline,
    covariant ButtonStateProperty<double?, S>? containerElevation,
    covariant ButtonStateProperty<Color?, S>? containerShadowColor,
    covariant ButtonStateProperty<Color?, S>? stateLayerColor,
    covariant ButtonStateProperty<double?, S>? stateLayerOpacity,
    covariant ButtonStateProperty<IconThemeDataPartial?, S>? iconTheme,
    covariant ButtonStateProperty<TextStyle?, S>? labelTextStyle,
  }) =>
      minTapTargetSize != null ||
          constraints != null ||
          padding != null ||
          iconLabelSpace != null ||
          containerShape != null ||
          containerColor != null ||
          containerOutline != null ||
          containerElevation != null ||
          containerShadowColor != null ||
          stateLayerColor != null ||
          stateLayerOpacity != null ||
          iconTheme != null ||
          labelTextStyle != null
      ? .from(
          minTapTargetSize: minTapTargetSize ?? this.minTapTargetSize,
          constraints: constraints ?? this.constraints,
          padding: padding ?? this.padding,
          iconLabelSpace: iconLabelSpace ?? this.iconLabelSpace,
          containerShape: containerShape ?? this.containerShape,
          containerColor: containerColor ?? this.containerColor,
          containerOutline: containerOutline ?? this.containerOutline,
          containerElevation: containerElevation ?? this.containerElevation,
          containerShadowColor:
              containerShadowColor ?? this.containerShadowColor,
          stateLayerColor: stateLayerColor ?? this.stateLayerColor,
          stateLayerOpacity: stateLayerOpacity ?? this.stateLayerOpacity,
          iconTheme: iconTheme ?? this.iconTheme,
          labelTextStyle: labelTextStyle ?? this.labelTextStyle,
        )
      : this;

  ButtonStylePartial<S> mergeWith({
    ButtonStateProperty<Size?, S>? minTapTargetSize,
    ButtonStateProperty<BoxConstraints?, S>? constraints,
    ButtonStateProperty<EdgeInsetsGeometry?, S>? padding,
    ButtonStateProperty<double?, S>? iconLabelSpace,
    ButtonStateProperty<OutlinedBorder?, S>? containerShape,
    ButtonStateProperty<Color?, S>? containerColor,
    ButtonStateProperty<OutlinePartial?, S>? containerOutline,
    ButtonStateProperty<double?, S>? containerElevation,
    ButtonStateProperty<Color?, S>? containerShadowColor,
    ButtonStateProperty<Color?, S>? stateLayerColor,
    ButtonStateProperty<double?, S>? stateLayerOpacity,
    ButtonStateProperty<IconThemeDataPartial?, S>? iconTheme,
    ButtonStateProperty<TextStyle?, S>? labelTextStyle,
  }) =>
      minTapTargetSize != null ||
          constraints != null ||
          padding != null ||
          iconLabelSpace != null ||
          containerShape != null ||
          containerColor != null ||
          containerOutline != null ||
          containerElevation != null ||
          containerShadowColor != null ||
          stateLayerColor != null ||
          stateLayerOpacity != null ||
          iconTheme != null ||
          labelTextStyle != null
      ? .from(
          minTapTargetSize:
              minTapTargetSize?.orElseMaybe(this.minTapTargetSize?.resolve) ??
              this.minTapTargetSize,
          constraints:
              constraints?.orElseMaybe(this.constraints?.resolve) ??
              this.constraints,
          padding: padding?.orElseMaybe(this.padding?.resolve) ?? this.padding,
          iconLabelSpace:
              iconLabelSpace?.orElseMaybe(this.iconLabelSpace?.resolve) ??
              this.iconLabelSpace,
          containerShape:
              containerShape?.orElseMaybe(this.containerShape?.resolve) ??
              this.containerShape,
          containerColor:
              containerColor?.orElseMaybe(this.containerColor?.resolve) ??
              this.containerColor,
          containerOutline:
              containerOutline
                  ?.orElseMaybe(this.containerOutline?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.containerOutline?.resolve(states)?.merge(value) ??
                        value,
                  ) ??
              this.containerOutline,
          containerElevation:
              containerElevation?.orElseMaybe(
                this.containerElevation?.resolve,
              ) ??
              this.containerElevation,
          containerShadowColor:
              containerShadowColor?.orElseMaybe(
                this.containerShadowColor?.resolve,
              ) ??
              this.containerShadowColor,
          stateLayerColor:
              stateLayerColor?.orElseMaybe(this.stateLayerColor?.resolve) ??
              this.stateLayerColor,
          stateLayerOpacity:
              stateLayerOpacity?.orElseMaybe(this.stateLayerOpacity?.resolve) ??
              this.stateLayerOpacity,
          iconTheme:
              iconTheme
                  ?.orElseMaybe(this.iconTheme?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.iconTheme?.resolve(states)?.merge(value) ?? value,
                  ) ??
              this.iconTheme,
          labelTextStyle:
              labelTextStyle
                  ?.orElseMaybe(this.labelTextStyle?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.labelTextStyle?.resolve(states)?.merge(value) ??
                        value,
                  ) ??
              this.labelTextStyle,
        )
      : this;

  ButtonStylePartial<S> merge(ButtonStylePartial<S>? other) => other != null
      ? mergeWith(
          minTapTargetSize: other.minTapTargetSize,
          constraints: other.constraints,
          padding: other.padding,
          iconLabelSpace: other.iconLabelSpace,
          containerShape: other.containerShape,
          containerColor: other.containerColor,
          containerOutline: other.containerOutline,
          containerElevation: other.containerElevation,
          containerShadowColor: other.containerShadowColor,
          stateLayerColor: other.stateLayerColor,
          stateLayerOpacity: other.stateLayerOpacity,
          iconTheme: other.iconTheme,
          labelTextStyle: other.labelTextStyle,
        )
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Size?, S>>(
          "minTapTargetSize",
          minTapTargetSize,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<BoxConstraints?, S>>(
          "constraints",
          constraints,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<EdgeInsetsGeometry?, S>>(
          "padding",
          padding,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<double?, S>>(
          "iconLabelSpace",
          iconLabelSpace,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<OutlinedBorder?, S>>(
          "containerShape",
          containerShape,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Color?, S>>(
          "containerColor",
          containerColor,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<OutlinePartial?, S>>(
          "containerOutline",
          containerOutline,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<double?, S>>(
          "containerElevation",
          containerElevation,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Color?, S>>(
          "containerShadowColor",
          containerShadowColor,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Color?, S>>(
          "stateLayerColor",
          stateLayerColor,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<double?, S>>(
          "stateLayerOpacity",
          stateLayerOpacity,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<IconThemeDataPartial?, S>>(
          "iconTheme",
          iconTheme,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<TextStyle?, S>>(
          "labelTextStyle",
          labelTextStyle,
          defaultValue: null,
        ),
      );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ButtonStylePartial<S> &&
          minTapTargetSize == other.minTapTargetSize &&
          constraints == other.constraints &&
          padding == other.padding &&
          iconLabelSpace == other.iconLabelSpace &&
          containerShape == other.containerShape &&
          containerColor == other.containerColor &&
          containerOutline == other.containerOutline &&
          containerElevation == other.containerElevation &&
          containerShadowColor == other.containerShadowColor &&
          stateLayerColor == other.stateLayerColor &&
          stateLayerOpacity == other.stateLayerOpacity &&
          iconTheme == other.iconTheme &&
          labelTextStyle == other.labelTextStyle;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    minTapTargetSize,
    constraints,
    padding,
    iconLabelSpace,
    containerShape,
    containerColor,
    containerOutline,
    containerElevation,
    containerShadowColor,
    stateLayerColor,
    stateLayerOpacity,
    iconTheme,
    labelTextStyle,
  );
}

class _ButtonStylePartial<S extends Object?> extends ButtonStylePartial<S> {
  const _ButtonStylePartial({
    this.minTapTargetSize,
    this.constraints,
    this.padding,
    this.iconLabelSpace,
    this.containerShape,
    this.containerColor,
    this.containerOutline,
    this.containerElevation,
    this.containerShadowColor,
    this.stateLayerColor,
    this.stateLayerOpacity,
    this.iconTheme,
    this.labelTextStyle,
  });

  @override
  final ButtonStateProperty<Size?, S>? minTapTargetSize;

  @override
  final ButtonStateProperty<BoxConstraints?, S>? constraints;

  @override
  final ButtonStateProperty<EdgeInsetsGeometry?, S>? padding;

  @override
  final ButtonStateProperty<double?, S>? iconLabelSpace;

  @override
  final ButtonStateProperty<OutlinedBorder?, S>? containerShape;

  @override
  final ButtonStateProperty<Color?, S>? containerColor;

  @override
  final ButtonStateProperty<OutlinePartial?, S>? containerOutline;

  @override
  final ButtonStateProperty<double?, S>? containerElevation;

  @override
  final ButtonStateProperty<Color?, S>? containerShadowColor;

  @override
  final ButtonStateProperty<Color?, S>? stateLayerColor;

  @override
  final ButtonStateProperty<double?, S>? stateLayerOpacity;

  @override
  final ButtonStateProperty<IconThemeDataPartial?, S>? iconTheme;

  @override
  final ButtonStateProperty<TextStyle?, S>? labelTextStyle;
}

abstract class ButtonStyleConcrete<S extends Object?>
    extends ButtonStylePartial<S> {
  const ButtonStyleConcrete();

  const factory ButtonStyleConcrete.from({
    required ButtonStateProperty<Size, S> minTapTargetSize,
    required ButtonStateProperty<BoxConstraints, S> constraints,
    required ButtonStateProperty<EdgeInsetsGeometry, S> padding,
    required ButtonStateProperty<double, S> iconLabelSpace,
    required ButtonStateProperty<OutlinedBorder, S> containerShape,
    required ButtonStateProperty<Color, S> containerColor,
    required ButtonStateProperty<Outline, S> containerOutline,
    required ButtonStateProperty<double, S> containerElevation,
    required ButtonStateProperty<Color, S> containerShadowColor,
    required ButtonStateProperty<Color, S> stateLayerColor,
    required ButtonStateProperty<double, S> stateLayerOpacity,
    required ButtonStateProperty<IconThemeDataPartial, S> iconTheme,
    required ButtonStateProperty<TextStyle, S> labelTextStyle,
  }) = _ButtonStyleConcrete<S>;

  @override
  ButtonStateProperty<Size, S> get minTapTargetSize;

  @override
  ButtonStateProperty<BoxConstraints, S> get constraints;

  @override
  ButtonStateProperty<EdgeInsetsGeometry, S> get padding;

  @override
  ButtonStateProperty<double, S> get iconLabelSpace;

  @override
  ButtonStateProperty<OutlinedBorder, S> get containerShape;

  @override
  ButtonStateProperty<Color, S> get containerColor;

  @override
  ButtonStateProperty<Outline, S> get containerOutline;

  @override
  ButtonStateProperty<double, S> get containerElevation;

  @override
  ButtonStateProperty<Color, S> get containerShadowColor;

  @override
  ButtonStateProperty<Color, S> get stateLayerColor;

  @override
  ButtonStateProperty<double, S> get stateLayerOpacity;

  @override
  ButtonStateProperty<IconThemeDataPartial, S> get iconTheme;

  @override
  ButtonStateProperty<TextStyle, S> get labelTextStyle;

  @override
  ButtonStyleConcrete<S> copyWith({
    covariant ButtonStateProperty<Size, S>? minTapTargetSize,
    covariant ButtonStateProperty<BoxConstraints, S>? constraints,
    covariant ButtonStateProperty<EdgeInsetsGeometry, S>? padding,
    covariant ButtonStateProperty<double, S>? iconLabelSpace,
    covariant ButtonStateProperty<OutlinedBorder, S>? containerShape,
    covariant ButtonStateProperty<Color, S>? containerColor,
    covariant ButtonStateProperty<Outline, S>? containerOutline,
    covariant ButtonStateProperty<double, S>? containerElevation,
    covariant ButtonStateProperty<Color, S>? containerShadowColor,
    covariant ButtonStateProperty<Color, S>? stateLayerColor,
    covariant ButtonStateProperty<double, S>? stateLayerOpacity,
    covariant ButtonStateProperty<IconThemeDataPartial, S>? iconTheme,
    covariant ButtonStateProperty<TextStyle, S>? labelTextStyle,
  }) =>
      minTapTargetSize != null ||
          constraints != null ||
          padding != null ||
          iconLabelSpace != null ||
          containerShape != null ||
          containerColor != null ||
          containerOutline != null ||
          containerElevation != null ||
          containerShadowColor != null ||
          stateLayerColor != null ||
          stateLayerOpacity != null ||
          iconTheme != null ||
          labelTextStyle != null
      ? .from(
          minTapTargetSize: minTapTargetSize ?? this.minTapTargetSize,
          constraints: constraints ?? this.constraints,
          padding: padding ?? this.padding,
          iconLabelSpace: iconLabelSpace ?? this.iconLabelSpace,
          containerShape: containerShape ?? this.containerShape,
          containerColor: containerColor ?? this.containerColor,
          containerOutline: containerOutline ?? this.containerOutline,
          containerElevation: containerElevation ?? this.containerElevation,
          containerShadowColor:
              containerShadowColor ?? this.containerShadowColor,
          stateLayerColor: stateLayerColor ?? this.stateLayerColor,
          stateLayerOpacity: stateLayerOpacity ?? this.stateLayerOpacity,
          iconTheme: iconTheme ?? this.iconTheme,
          labelTextStyle: labelTextStyle ?? this.labelTextStyle,
        )
      : this;

  @override
  ButtonStyleConcrete<S> mergeWith({
    ButtonStateProperty<Size?, S>? minTapTargetSize,
    ButtonStateProperty<BoxConstraints?, S>? constraints,
    ButtonStateProperty<EdgeInsetsGeometry?, S>? padding,
    ButtonStateProperty<double?, S>? iconLabelSpace,
    ButtonStateProperty<OutlinedBorder?, S>? containerShape,
    ButtonStateProperty<Color?, S>? containerColor,
    ButtonStateProperty<OutlinePartial?, S>? containerOutline,
    ButtonStateProperty<double?, S>? containerElevation,
    ButtonStateProperty<Color?, S>? containerShadowColor,
    ButtonStateProperty<Color?, S>? stateLayerColor,
    ButtonStateProperty<double?, S>? stateLayerOpacity,
    ButtonStateProperty<IconThemeDataPartial?, S>? iconTheme,
    ButtonStateProperty<TextStyle?, S>? labelTextStyle,
  }) =>
      minTapTargetSize != null ||
          constraints != null ||
          padding != null ||
          iconLabelSpace != null ||
          containerShape != null ||
          containerColor != null ||
          containerOutline != null ||
          containerElevation != null ||
          containerShadowColor != null ||
          stateLayerColor != null ||
          stateLayerOpacity != null ||
          iconTheme != null ||
          labelTextStyle != null
      ? .from(
          minTapTargetSize:
              minTapTargetSize?.orElse(this.minTapTargetSize.resolve) ??
              this.minTapTargetSize,
          constraints:
              constraints?.orElse(this.constraints.resolve) ?? this.constraints,
          padding: padding?.orElse(this.padding.resolve) ?? this.padding,
          iconLabelSpace:
              iconLabelSpace?.orElse(this.iconLabelSpace.resolve) ??
              this.iconLabelSpace,
          containerShape:
              containerShape?.orElse(this.containerShape.resolve) ??
              this.containerShape,
          containerColor:
              containerColor?.orElse(this.containerColor.resolve) ??
              this.containerColor,
          containerOutline:
              containerOutline
                  ?.orElse(this.containerOutline.resolve)
                  .mapValue(
                    (states, value) =>
                        this.containerOutline.resolve(states).merge(value),
                  ) ??
              this.containerOutline,
          containerElevation:
              containerElevation?.orElse(this.containerElevation.resolve) ??
              this.containerElevation,
          containerShadowColor:
              containerShadowColor?.orElse(this.containerShadowColor.resolve) ??
              this.containerShadowColor,
          stateLayerColor:
              stateLayerColor?.orElse(this.stateLayerColor.resolve) ??
              this.stateLayerColor,
          stateLayerOpacity:
              stateLayerOpacity?.orElse(this.stateLayerOpacity.resolve) ??
              this.stateLayerOpacity,
          iconTheme:
              iconTheme
                  ?.orElse(this.iconTheme.resolve)
                  .mapValue(
                    (states, value) =>
                        this.iconTheme.resolve(states).merge(value),
                  ) ??
              this.iconTheme,
          labelTextStyle:
              labelTextStyle
                  ?.orElse(this.labelTextStyle.resolve)
                  .mapValue(
                    (states, value) =>
                        this.labelTextStyle.resolve(states).merge(value),
                  ) ??
              this.labelTextStyle,
        )
      : this;

  @override
  ButtonStyleConcrete<S> merge(ButtonStylePartial<S>? other) => other != null
      ? mergeWith(
          minTapTargetSize: other.minTapTargetSize,
          constraints: other.constraints,
          padding: other.padding,
          iconLabelSpace: other.iconLabelSpace,
          containerShape: other.containerShape,
          containerColor: other.containerColor,
          containerOutline: other.containerOutline,
          containerElevation: other.containerElevation,
          containerShadowColor: other.containerShadowColor,
          stateLayerColor: other.stateLayerColor,
          stateLayerOpacity: other.stateLayerOpacity,
          iconTheme: other.iconTheme,
          labelTextStyle: other.labelTextStyle,
        )
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Size, S>>(
          "minTapTargetSize",
          minTapTargetSize,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<BoxConstraints, S>>(
          "constraints",
          constraints,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<EdgeInsetsGeometry, S>>(
          "padding",
          padding,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<double, S>>(
          "iconLabelSpace",
          iconLabelSpace,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<OutlinedBorder, S>>(
          "containerShape",
          containerShape,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Color, S>>(
          "containerColor",
          containerColor,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Outline, S>>(
          "containerOutline",
          containerOutline,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<double, S>>(
          "containerElevation",
          containerElevation,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Color, S>>(
          "containerShadowColor",
          containerShadowColor,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<Color, S>>(
          "stateLayerColor",
          stateLayerColor,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<double, S>>(
          "stateLayerOpacity",
          stateLayerOpacity,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<IconThemeDataPartial, S>>(
          "iconTheme",
          iconTheme,
        ),
      )
      ..add(
        DiagnosticsProperty<ButtonStateProperty<TextStyle, S>>(
          "labelTextStyle",
          labelTextStyle,
        ),
      );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ButtonStyleConcrete<S> &&
          minTapTargetSize == other.minTapTargetSize &&
          constraints == other.constraints &&
          padding == other.padding &&
          iconLabelSpace == other.iconLabelSpace &&
          containerShape == other.containerShape &&
          containerColor == other.containerColor &&
          containerOutline == other.containerOutline &&
          containerElevation == other.containerElevation &&
          containerShadowColor == other.containerShadowColor &&
          stateLayerColor == other.stateLayerColor &&
          stateLayerOpacity == other.stateLayerOpacity &&
          iconTheme == other.iconTheme &&
          labelTextStyle == other.labelTextStyle;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    minTapTargetSize,
    constraints,
    padding,
    iconLabelSpace,
    containerShape,
    containerColor,
    containerOutline,
    containerElevation,
    containerShadowColor,
    stateLayerColor,
    stateLayerOpacity,
    iconTheme,
    labelTextStyle,
  );
}

class _ButtonStyleConcrete<S extends Object?> extends ButtonStyleConcrete<S> {
  const _ButtonStyleConcrete({
    required this.minTapTargetSize,
    required this.constraints,
    required this.padding,
    required this.iconLabelSpace,
    required this.containerShape,
    required this.containerColor,
    required this.containerOutline,
    required this.containerElevation,
    required this.containerShadowColor,
    required this.stateLayerColor,
    required this.stateLayerOpacity,
    required this.iconTheme,
    required this.labelTextStyle,
  });

  @override
  final ButtonStateProperty<Size, S> minTapTargetSize;

  @override
  final ButtonStateProperty<BoxConstraints, S> constraints;

  @override
  final ButtonStateProperty<EdgeInsetsGeometry, S> padding;

  @override
  final ButtonStateProperty<double, S> iconLabelSpace;

  @override
  final ButtonStateProperty<OutlinedBorder, S> containerShape;

  @override
  final ButtonStateProperty<Color, S> containerColor;

  @override
  final ButtonStateProperty<Outline, S> containerOutline;

  @override
  final ButtonStateProperty<double, S> containerElevation;

  @override
  final ButtonStateProperty<Color, S> containerShadowColor;

  @override
  final ButtonStateProperty<Color, S> stateLayerColor;

  @override
  final ButtonStateProperty<double, S> stateLayerOpacity;

  @override
  final ButtonStateProperty<IconThemeDataPartial, S> iconTheme;

  @override
  final ButtonStateProperty<TextStyle, S> labelTextStyle;
}
