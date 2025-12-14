import 'package:material/src/material/flutter.dart';

abstract interface class ListItemStates {}

abstract interface class SegmentedListItemStates implements ListItemStates {
  bool get isFirst;
  bool get isLast;
}

abstract interface class InteractiveListItemStates implements ListItemStates {}

abstract interface class InteractiveListItemEnabledStates
    implements InteractiveListItemStates {
  bool get isHovered;
  bool get isFocused;
  bool get isPressed;
}

abstract interface class InteractiveListItemDisabledStates
    implements InteractiveListItemStates {}

abstract interface class SelectableListItemStates implements ListItemStates {
  bool get isSelected;
}

abstract interface class DraggableListItemStates implements ListItemStates {
  bool get isDragged;
}

typedef ListItemStateProperty<T extends Object?> =
    StateProperty<T, ListItemStates>;

abstract class ListItemThemeDataPartial with Diagnosticable {
  const ListItemThemeDataPartial();

  const factory ListItemThemeDataPartial.from({
    ListItemStateProperty<ShapeBorder?>? containerShape,
    ListItemStateProperty<Color?>? containerColor,
    ListItemStateProperty<Color?>? stateLayerColor,
    ListItemStateProperty<double?>? stateLayerOpacity,
    ListItemStateProperty<IconThemeDataPartial?>? leadingIconTheme,
    ListItemStateProperty<TextStyle?>? leadingTextStyle,
    ListItemStateProperty<TextStyle?>? overlineTextStyle,
    ListItemStateProperty<TextStyle?>? headlineTextStyle,
    ListItemStateProperty<TextStyle?>? supportingTextStyle,
    ListItemStateProperty<TextStyle?>? trailingTextStyle,
    ListItemStateProperty<IconThemeDataPartial?>? trailingIconTheme,
  }) = _ListItemThemeDataPartial;

  ListItemStateProperty<ShapeBorder?>? get containerShape;

  ListItemStateProperty<Color?>? get containerColor;

  ListItemStateProperty<Color?>? get stateLayerColor;

  ListItemStateProperty<double?>? get stateLayerOpacity;

  ListItemStateProperty<IconThemeDataPartial?>? get leadingIconTheme;

  ListItemStateProperty<TextStyle?>? get leadingTextStyle;

  ListItemStateProperty<TextStyle?>? get overlineTextStyle;

  ListItemStateProperty<TextStyle?>? get headlineTextStyle;

  ListItemStateProperty<TextStyle?>? get supportingTextStyle;

  ListItemStateProperty<TextStyle?>? get trailingTextStyle;

  ListItemStateProperty<IconThemeDataPartial?>? get trailingIconTheme;

  ListItemThemeDataPartial copyWith({
    covariant ListItemStateProperty<ShapeBorder?>? containerShape,
    covariant ListItemStateProperty<Color?>? containerColor,
    covariant ListItemStateProperty<Color?>? stateLayerColor,
    covariant ListItemStateProperty<double?>? stateLayerOpacity,
    covariant ListItemStateProperty<IconThemeDataPartial?>? leadingIconTheme,
    covariant ListItemStateProperty<TextStyle?>? leadingTextStyle,
    covariant ListItemStateProperty<TextStyle?>? overlineTextStyle,
    covariant ListItemStateProperty<TextStyle?>? headlineTextStyle,
    covariant ListItemStateProperty<TextStyle?>? supportingTextStyle,
    covariant ListItemStateProperty<TextStyle?>? trailingTextStyle,
    covariant ListItemStateProperty<IconThemeDataPartial?>? trailingIconTheme,
  }) =>
      containerShape != null ||
          containerColor != null ||
          stateLayerColor != null ||
          stateLayerOpacity != null ||
          leadingIconTheme != null ||
          leadingTextStyle != null ||
          overlineTextStyle != null ||
          headlineTextStyle != null ||
          supportingTextStyle != null ||
          trailingTextStyle != null ||
          trailingIconTheme != null
      ? .from(
          containerShape: containerShape ?? this.containerShape,
          stateLayerColor: stateLayerColor ?? this.stateLayerColor,
          stateLayerOpacity: stateLayerOpacity ?? this.stateLayerOpacity,
          containerColor: containerColor ?? this.containerColor,
          leadingIconTheme: leadingIconTheme ?? this.leadingIconTheme,
          leadingTextStyle: leadingTextStyle ?? this.leadingTextStyle,
          overlineTextStyle: overlineTextStyle ?? this.overlineTextStyle,
          headlineTextStyle: headlineTextStyle ?? this.headlineTextStyle,
          supportingTextStyle: supportingTextStyle ?? this.supportingTextStyle,
          trailingTextStyle: trailingTextStyle ?? this.trailingTextStyle,
          trailingIconTheme: trailingIconTheme ?? this.trailingIconTheme,
        )
      : this;

  ListItemThemeDataPartial mergeWith({
    ListItemStateProperty<ShapeBorder?>? containerShape,
    ListItemStateProperty<Color?>? containerColor,
    ListItemStateProperty<Color?>? stateLayerColor,
    ListItemStateProperty<double?>? stateLayerOpacity,
    ListItemStateProperty<IconThemeDataPartial?>? leadingIconTheme,
    ListItemStateProperty<TextStyle?>? leadingTextStyle,
    ListItemStateProperty<TextStyle?>? overlineTextStyle,
    ListItemStateProperty<TextStyle?>? headlineTextStyle,
    ListItemStateProperty<TextStyle?>? supportingTextStyle,
    ListItemStateProperty<TextStyle?>? trailingTextStyle,
    ListItemStateProperty<IconThemeDataPartial?>? trailingIconTheme,
  }) =>
      containerShape != null ||
          containerColor != null ||
          leadingIconTheme != null ||
          overlineTextStyle != null ||
          headlineTextStyle != null ||
          supportingTextStyle != null ||
          trailingTextStyle != null ||
          trailingIconTheme != null
      ? .from(
          containerShape:
              containerShape?.orElseMaybe(this.containerShape?.resolve) ??
              this.containerShape,
          containerColor:
              containerColor?.orElseMaybe(this.containerColor?.resolve) ??
              this.containerColor,
          stateLayerColor:
              stateLayerColor?.orElseMaybe(this.stateLayerColor?.resolve) ??
              this.stateLayerColor,
          stateLayerOpacity:
              stateLayerOpacity?.orElseMaybe(this.stateLayerOpacity?.resolve) ??
              this.stateLayerOpacity,
          leadingIconTheme:
              leadingIconTheme?.orElseMaybe(this.leadingIconTheme?.resolve) ??
              this.leadingIconTheme,
          leadingTextStyle:
              leadingTextStyle
                  ?.orElseMaybe(this.leadingTextStyle?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.leadingTextStyle?.resolve(states)?.merge(value) ??
                        value,
                  ) ??
              this.leadingTextStyle,
          overlineTextStyle:
              overlineTextStyle
                  ?.orElseMaybe(this.overlineTextStyle?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.overlineTextStyle?.resolve(states)?.merge(value) ??
                        value,
                  ) ??
              this.overlineTextStyle,
          headlineTextStyle:
              headlineTextStyle
                  ?.orElseMaybe(this.headlineTextStyle?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.headlineTextStyle?.resolve(states)?.merge(value) ??
                        value,
                  ) ??
              this.headlineTextStyle,
          supportingTextStyle:
              supportingTextStyle
                  ?.orElseMaybe(this.supportingTextStyle?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.supportingTextStyle
                            ?.resolve(states)
                            ?.merge(value) ??
                        value,
                  ) ??
              this.supportingTextStyle,
          trailingTextStyle:
              trailingTextStyle
                  ?.orElseMaybe(this.trailingTextStyle?.resolve)
                  .mapValue(
                    (states, value) =>
                        this.trailingTextStyle?.resolve(states)?.merge(value) ??
                        value,
                  ) ??
              this.trailingTextStyle,
          trailingIconTheme:
              trailingIconTheme?.orElseMaybe(this.trailingIconTheme?.resolve) ??
              this.trailingIconTheme,
        )
      : this;

  ListItemThemeDataPartial merge(ListItemThemeDataPartial? other) =>
      other != null
      ? mergeWith(
          containerShape: other.containerShape,
          containerColor: other.containerColor,
          stateLayerColor: other.stateLayerColor,
          stateLayerOpacity: other.stateLayerOpacity,
          leadingIconTheme: other.leadingIconTheme,
          leadingTextStyle: other.leadingTextStyle,
          overlineTextStyle: other.overlineTextStyle,
          headlineTextStyle: other.headlineTextStyle,
          supportingTextStyle: other.supportingTextStyle,
          trailingTextStyle: other.trailingTextStyle,
          trailingIconTheme: other.trailingIconTheme,
        )
      : this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ListItemThemeDataPartial &&
          containerShape == other.containerShape &&
          containerColor == other.containerColor &&
          stateLayerColor == other.stateLayerColor &&
          stateLayerOpacity == other.stateLayerOpacity &&
          leadingIconTheme == other.leadingIconTheme &&
          leadingTextStyle == other.leadingTextStyle &&
          overlineTextStyle == other.overlineTextStyle &&
          headlineTextStyle == other.headlineTextStyle &&
          supportingTextStyle == other.supportingTextStyle &&
          trailingTextStyle == other.trailingTextStyle &&
          trailingIconTheme == other.trailingIconTheme;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    containerShape,
    containerColor,
    stateLayerColor,
    stateLayerOpacity,
    leadingIconTheme,
    leadingTextStyle,
    overlineTextStyle,
    headlineTextStyle,
    supportingTextStyle,
    trailingTextStyle,
    trailingIconTheme,
  );
}

class _ListItemThemeDataPartial extends ListItemThemeDataPartial {
  const _ListItemThemeDataPartial({
    this.containerShape,
    this.containerColor,
    this.stateLayerColor,
    this.stateLayerOpacity,
    this.leadingIconTheme,
    this.leadingTextStyle,
    this.overlineTextStyle,
    this.headlineTextStyle,
    this.supportingTextStyle,
    this.trailingTextStyle,
    this.trailingIconTheme,
  });

  @override
  final ListItemStateProperty<ShapeBorder?>? containerShape;

  @override
  final ListItemStateProperty<Color?>? containerColor;

  @override
  final ListItemStateProperty<Color?>? stateLayerColor;

  @override
  final ListItemStateProperty<double?>? stateLayerOpacity;

  @override
  final ListItemStateProperty<IconThemeDataPartial?>? leadingIconTheme;

  @override
  final ListItemStateProperty<TextStyle?>? leadingTextStyle;

  @override
  final ListItemStateProperty<TextStyle?>? overlineTextStyle;

  @override
  final ListItemStateProperty<TextStyle?>? headlineTextStyle;

  @override
  final ListItemStateProperty<TextStyle?>? supportingTextStyle;

  @override
  final ListItemStateProperty<TextStyle?>? trailingTextStyle;

  @override
  final ListItemStateProperty<IconThemeDataPartial?>? trailingIconTheme;
}

abstract class ListItemThemeData extends ListItemThemeDataPartial {
  const ListItemThemeData();

  const factory ListItemThemeData.from({
    required ListItemStateProperty<ShapeBorder> containerShape,
    required ListItemStateProperty<Color> containerColor,
    required ListItemStateProperty<Color> stateLayerColor,
    required ListItemStateProperty<double> stateLayerOpacity,
    required ListItemStateProperty<IconThemeDataPartial> leadingIconTheme,
    required ListItemStateProperty<TextStyle> leadingTextStyle,
    required ListItemStateProperty<TextStyle> overlineTextStyle,
    required ListItemStateProperty<TextStyle> headlineTextStyle,
    required ListItemStateProperty<TextStyle> supportingTextStyle,
    required ListItemStateProperty<TextStyle> trailingTextStyle,
    required ListItemStateProperty<IconThemeDataPartial> trailingIconTheme,
  }) = _ListItemThemeData;

  const factory ListItemThemeData.fallback({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
  }) = _ListItemThemeDataDefaults;

  @override
  ListItemThemeData copyWith({
    covariant ListItemStateProperty<ShapeBorder>? containerShape,
    covariant ListItemStateProperty<Color>? containerColor,
    covariant ListItemStateProperty<Color>? stateLayerColor,
    covariant ListItemStateProperty<double>? stateLayerOpacity,
    covariant ListItemStateProperty<IconThemeDataPartial>? leadingIconTheme,
    covariant ListItemStateProperty<TextStyle>? leadingTextStyle,
    covariant ListItemStateProperty<TextStyle>? overlineTextStyle,
    covariant ListItemStateProperty<TextStyle>? headlineTextStyle,
    covariant ListItemStateProperty<TextStyle>? supportingTextStyle,
    covariant ListItemStateProperty<TextStyle>? trailingTextStyle,
    covariant ListItemStateProperty<IconThemeDataPartial>? trailingIconTheme,
  }) =>
      containerShape != null ||
          containerColor != null ||
          stateLayerColor != null ||
          stateLayerOpacity != null ||
          leadingIconTheme != null ||
          leadingTextStyle != null ||
          overlineTextStyle != null ||
          headlineTextStyle != null ||
          supportingTextStyle != null ||
          trailingTextStyle != null ||
          trailingIconTheme != null
      ? .from(
          containerShape: containerShape ?? this.containerShape,
          containerColor: containerColor ?? this.containerColor,
          stateLayerColor: stateLayerColor ?? this.stateLayerColor,
          stateLayerOpacity: stateLayerOpacity ?? this.stateLayerOpacity,
          leadingIconTheme: leadingIconTheme ?? this.leadingIconTheme,
          leadingTextStyle: leadingTextStyle ?? this.leadingTextStyle,
          overlineTextStyle: overlineTextStyle ?? this.overlineTextStyle,
          headlineTextStyle: headlineTextStyle ?? this.headlineTextStyle,
          supportingTextStyle: supportingTextStyle ?? this.supportingTextStyle,
          trailingTextStyle: trailingTextStyle ?? this.trailingTextStyle,
          trailingIconTheme: trailingIconTheme ?? this.trailingIconTheme,
        )
      : this;

  @override
  ListItemThemeData mergeWith({
    ListItemStateProperty<ShapeBorder?>? containerShape,
    ListItemStateProperty<Color?>? containerColor,
    ListItemStateProperty<Color?>? stateLayerColor,
    ListItemStateProperty<double?>? stateLayerOpacity,
    ListItemStateProperty<IconThemeDataPartial?>? leadingIconTheme,
    ListItemStateProperty<TextStyle?>? leadingTextStyle,
    ListItemStateProperty<TextStyle?>? overlineTextStyle,
    ListItemStateProperty<TextStyle?>? headlineTextStyle,
    ListItemStateProperty<TextStyle?>? supportingTextStyle,
    ListItemStateProperty<TextStyle?>? trailingTextStyle,
    ListItemStateProperty<IconThemeDataPartial?>? trailingIconTheme,
  }) =>
      containerShape != null ||
          containerColor != null ||
          stateLayerColor != null ||
          stateLayerOpacity != null ||
          leadingIconTheme != null ||
          leadingTextStyle != null ||
          overlineTextStyle != null ||
          headlineTextStyle != null ||
          supportingTextStyle != null ||
          trailingTextStyle != null ||
          trailingIconTheme != null
      ? .from(
          containerShape:
              containerShape?.orElse(this.containerShape.resolve) ??
              this.containerShape,
          containerColor:
              containerColor?.orElse(this.containerColor.resolve) ??
              this.containerColor,
          stateLayerColor:
              stateLayerColor?.orElse(this.stateLayerColor.resolve) ??
              this.stateLayerColor,
          stateLayerOpacity:
              stateLayerOpacity?.orElse(this.stateLayerOpacity.resolve) ??
              this.stateLayerOpacity,
          leadingIconTheme:
              leadingIconTheme?.orElse(this.leadingIconTheme.resolve) ??
              this.leadingIconTheme,
          leadingTextStyle:
              leadingTextStyle
                  ?.orElse(this.leadingTextStyle.resolve)
                  .mapValue(
                    (states, value) =>
                        this.leadingTextStyle.resolve(states).merge(value),
                  ) ??
              this.leadingTextStyle,
          overlineTextStyle:
              overlineTextStyle
                  ?.orElse(this.overlineTextStyle.resolve)
                  .mapValue(
                    (states, value) =>
                        this.overlineTextStyle.resolve(states).merge(value),
                  ) ??
              this.overlineTextStyle,
          headlineTextStyle:
              headlineTextStyle
                  ?.orElse(this.headlineTextStyle.resolve)
                  .mapValue(
                    (states, value) =>
                        this.headlineTextStyle.resolve(states).merge(value),
                  ) ??
              this.headlineTextStyle,
          supportingTextStyle:
              supportingTextStyle
                  ?.orElse(this.supportingTextStyle.resolve)
                  .mapValue(
                    (states, value) =>
                        this.supportingTextStyle.resolve(states).merge(value),
                  ) ??
              this.supportingTextStyle,
          trailingTextStyle:
              trailingTextStyle
                  ?.orElse(this.trailingTextStyle.resolve)
                  .mapValue(
                    (states, value) =>
                        this.trailingTextStyle.resolve(states).merge(value),
                  ) ??
              this.trailingTextStyle,
          trailingIconTheme:
              trailingIconTheme?.orElse(this.trailingIconTheme.resolve) ??
              this.trailingIconTheme,
        )
      : this;

  @override
  ListItemThemeData merge(ListItemThemeDataPartial? other) => other != null
      ? mergeWith(
          containerShape: other.containerShape,
          containerColor: other.containerColor,
          stateLayerColor: other.stateLayerColor,
          stateLayerOpacity: other.stateLayerOpacity,
          leadingIconTheme: other.leadingIconTheme,
          leadingTextStyle: other.leadingTextStyle,
          overlineTextStyle: other.overlineTextStyle,
          headlineTextStyle: other.headlineTextStyle,
          supportingTextStyle: other.supportingTextStyle,
          trailingTextStyle: other.trailingTextStyle,
          trailingIconTheme: other.trailingIconTheme,
        )
      : this;

  @override
  ListItemStateProperty<ShapeBorder> get containerShape;

  @override
  ListItemStateProperty<Color> get containerColor;

  @override
  ListItemStateProperty<Color> get stateLayerColor;

  @override
  ListItemStateProperty<double> get stateLayerOpacity;

  @override
  ListItemStateProperty<IconThemeDataPartial> get leadingIconTheme;

  @override
  ListItemStateProperty<TextStyle> get leadingTextStyle;

  @override
  ListItemStateProperty<TextStyle> get overlineTextStyle;

  @override
  ListItemStateProperty<TextStyle> get headlineTextStyle;

  @override
  ListItemStateProperty<TextStyle> get supportingTextStyle;

  @override
  ListItemStateProperty<TextStyle> get trailingTextStyle;

  @override
  ListItemStateProperty<IconThemeDataPartial> get trailingIconTheme;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ListItemThemeData &&
          containerShape == other.containerShape &&
          containerColor == other.containerColor &&
          stateLayerColor == other.stateLayerColor &&
          stateLayerOpacity == other.stateLayerOpacity &&
          leadingIconTheme == other.leadingIconTheme &&
          leadingTextStyle == other.leadingTextStyle &&
          overlineTextStyle == other.overlineTextStyle &&
          headlineTextStyle == other.headlineTextStyle &&
          supportingTextStyle == other.supportingTextStyle &&
          trailingTextStyle == other.trailingTextStyle &&
          trailingIconTheme == other.trailingIconTheme;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    containerShape,
    containerColor,
    stateLayerColor,
    stateLayerOpacity,
    leadingIconTheme,
    leadingTextStyle,
    overlineTextStyle,
    headlineTextStyle,
    supportingTextStyle,
    trailingTextStyle,
    trailingIconTheme,
  );
}

class _ListItemThemeData extends ListItemThemeData {
  const _ListItemThemeData({
    required this.containerShape,
    required this.containerColor,
    required this.stateLayerColor,
    required this.stateLayerOpacity,
    required this.leadingIconTheme,
    required this.leadingTextStyle,
    required this.overlineTextStyle,
    required this.headlineTextStyle,
    required this.supportingTextStyle,
    required this.trailingTextStyle,
    required this.trailingIconTheme,
  });

  @override
  final ListItemStateProperty<ShapeBorder> containerShape;

  @override
  final ListItemStateProperty<Color> stateLayerColor;

  @override
  final ListItemStateProperty<double> stateLayerOpacity;

  @override
  final ListItemStateProperty<Color> containerColor;

  @override
  final ListItemStateProperty<IconThemeDataPartial> leadingIconTheme;

  @override
  final ListItemStateProperty<TextStyle> leadingTextStyle;

  @override
  final ListItemStateProperty<TextStyle> overlineTextStyle;

  @override
  final ListItemStateProperty<TextStyle> headlineTextStyle;

  @override
  final ListItemStateProperty<TextStyle> supportingTextStyle;

  @override
  final ListItemStateProperty<TextStyle> trailingTextStyle;

  @override
  final ListItemStateProperty<IconThemeDataPartial> trailingIconTheme;
}

class _ListItemThemeDataDefaults extends ListItemThemeData {
  const _ListItemThemeDataDefaults({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
  }) : _colorTheme = colorTheme,
       _shapeTheme = shapeTheme,
       _stateTheme = stateTheme,
       _typescaleTheme = typescaleTheme;

  final ColorThemeData _colorTheme;
  final ShapeThemeData _shapeTheme;
  final StateThemeData _stateTheme;
  final TypescaleThemeData _typescaleTheme;

  @override
  ListItemStateProperty<ShapeBorder> get containerShape =>
      StateProperty.resolveWith((states) {
        final outerCorner = _shapeTheme.corner.large;
        final innerCorner = _shapeTheme.corner.extraSmall;
        final CornersGeometry corners = switch (states) {
          SegmentedListItemStates(isFirst: true, isLast: true) ||
          SelectableListItemStates(isSelected: true) => .all(outerCorner),
          SegmentedListItemStates(isFirst: true) => .vertical(
            top: outerCorner,
            bottom: innerCorner,
          ),
          SegmentedListItemStates(isLast: true) => .vertical(
            top: innerCorner,
            bottom: outerCorner,
          ),
          _ => Corners.all(innerCorner),
        };
        return CornersBorder.rounded(corners: corners);
      });

  @override
  ListItemStateProperty<Color> get containerColor => .resolveWith(
    (states) => switch (states) {
      InteractiveListItemDisabledStates() => _colorTheme.onSurface.withValues(
        alpha: 0.10,
      ),
      DraggableListItemStates(isDragged: true) => _colorTheme.tertiaryContainer,
      SelectableListItemStates(isSelected: true) =>
        _colorTheme.secondaryContainer,
      _ => _colorTheme.surface,
    },
  );

  @override
  ListItemStateProperty<Color> get stateLayerColor => .resolveWith(
    (states) => switch (states) {
      DraggableListItemStates(isDragged: true) =>
        _colorTheme.onTertiaryContainer,
      SelectableListItemStates(isSelected: true) =>
        _colorTheme.onSecondaryContainer,
      _ => _colorTheme.onSurface,
    },
  );

  @override
  ListItemStateProperty<double> get stateLayerOpacity => .resolveWith(
    (states) => switch (states) {
      InteractiveListItemDisabledStates() => 0.0,
      DraggableListItemStates(isDragged: true) =>
        _stateTheme.draggedStateLayerOpacity,
      InteractiveListItemEnabledStates(isPressed: true) =>
        _stateTheme.pressedStateLayerOpacity,
      InteractiveListItemEnabledStates(isHovered: true) =>
        _stateTheme.hoverStateLayerOpacity,
      InteractiveListItemEnabledStates(isFocused: true) => 0.0,
      _ => 0.0,
    },
  );

  @override
  ListItemStateProperty<IconThemeDataPartial> get leadingIconTheme =>
      .resolveWith((states) {
        final color = switch (states) {
          InteractiveListItemDisabledStates() =>
            _colorTheme.onSurface.withValues(alpha: 0.38),
          DraggableListItemStates(isDragged: true) =>
            _colorTheme.onTertiaryContainer,
          SelectableListItemStates(isSelected: true) =>
            _colorTheme.onSecondaryContainer,
          _ => _colorTheme.onSurfaceVariant,
        };
        return .from(size: 24.0, opticalSize: 24.0, color: color);
      });

  @override
  ListItemStateProperty<TextStyle> get leadingTextStyle =>
      .resolveWith((states) {
        final color = switch (states) {
          InteractiveListItemDisabledStates() =>
            _colorTheme.onSurface.withValues(alpha: 0.38),
          DraggableListItemStates(isDragged: true) =>
            _colorTheme.onTertiaryContainer,
          SelectableListItemStates(isSelected: true) =>
            _colorTheme.onSecondaryContainer,
          _ => _colorTheme.onSurfaceVariant,
        };
        return _typescaleTheme.labelLarge.toTextStyle(color: color);
      });

  @override
  ListItemStateProperty<TextStyle> get overlineTextStyle =>
      .resolveWith((states) {
        final color = switch (states) {
          InteractiveListItemDisabledStates() =>
            _colorTheme.onSurface.withValues(alpha: 0.38),
          DraggableListItemStates(isDragged: true) =>
            _colorTheme.onTertiaryContainer,
          SelectableListItemStates(isSelected: true) =>
            _colorTheme.onSecondaryContainer,
          _ => _colorTheme.onSurfaceVariant,
        };
        return _typescaleTheme.labelMedium.toTextStyle(color: color);
      });

  @override
  ListItemStateProperty<TextStyle> get headlineTextStyle =>
      .resolveWith((states) {
        final color = switch (states) {
          InteractiveListItemDisabledStates() =>
            _colorTheme.onSurface.withValues(alpha: 0.38),
          DraggableListItemStates(isDragged: true) =>
            _colorTheme.onTertiaryContainer,
          SelectableListItemStates(isSelected: true) =>
            _colorTheme.onSecondaryContainer,
          _ => _colorTheme.onSurface,
        };
        return _typescaleTheme.bodyLarge.toTextStyle(color: color);
      });

  @override
  ListItemStateProperty<TextStyle> get supportingTextStyle =>
      .resolveWith((states) {
        final color = switch (states) {
          InteractiveListItemDisabledStates() =>
            _colorTheme.onSurface.withValues(alpha: 0.38),
          DraggableListItemStates(isDragged: true) =>
            _colorTheme.onTertiaryContainer,
          SelectableListItemStates(isSelected: true) =>
            _colorTheme.onSecondaryContainer,
          _ => _colorTheme.onSurfaceVariant,
        };
        return _typescaleTheme.bodyMedium.toTextStyle(color: color);
      });

  @override
  ListItemStateProperty<TextStyle> get trailingTextStyle =>
      .resolveWith((states) {
        final color = switch (states) {
          InteractiveListItemDisabledStates() =>
            _colorTheme.onSurface.withValues(alpha: 0.38),
          DraggableListItemStates(isDragged: true) =>
            _colorTheme.onTertiaryContainer,
          SelectableListItemStates(isSelected: true) =>
            _colorTheme.onSecondaryContainer,
          _ => _colorTheme.onSurfaceVariant,
        };
        return _typescaleTheme.labelLarge.toTextStyle(color: color);
      });

  @override
  ListItemStateProperty<IconThemeDataPartial> get trailingIconTheme =>
      .resolveWith((states) {
        final color = switch (states) {
          InteractiveListItemDisabledStates() =>
            _colorTheme.onSurface.withValues(alpha: 0.38),
          DraggableListItemStates(isDragged: true) =>
            _colorTheme.onTertiaryContainer,
          SelectableListItemStates(isSelected: true) =>
            _colorTheme.onSecondaryContainer,
          _ => _colorTheme.onSurfaceVariant,
        };
        return .from(size: 24.0, opticalSize: 24.0, color: color);
      });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _ListItemThemeDataDefaults &&
          _colorTheme == other._colorTheme &&
          _shapeTheme == other._shapeTheme &&
          _stateTheme == other._stateTheme &&
          _typescaleTheme == other._typescaleTheme;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    _colorTheme,
    _shapeTheme,
    _stateTheme,
    _typescaleTheme,
  );
}

class ListItemTheme extends InheritedTheme {
  const ListItemTheme({super.key, required this.data, required super.child});

  final ListItemThemeData data;

  @override
  bool updateShouldNotify(ListItemTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      ListItemTheme(data: data, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ListItemThemeData>("data", data));
  }

  static Widget merge({
    Key? key,
    required ListItemThemeDataPartial data,
    required Widget child,
  }) => Builder(
    builder: (context) =>
        ListItemTheme(key: key, data: of(context).merge(data), child: child),
  );

  static ListItemThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ListItemTheme>()?.data;

  static ListItemThemeData of(BuildContext context) {
    final result = maybeOf(context);
    if (result != null) return result;
    return .fallback(
      colorTheme: ColorTheme.of(context),
      shapeTheme: ShapeTheme.of(context),
      stateTheme: StateTheme.of(context),
      typescaleTheme: TypescaleTheme.of(context),
    );
  }
}
