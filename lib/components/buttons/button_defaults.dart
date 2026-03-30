part of 'buttons.dart';

abstract final class _ButtonDefaults {
  static Corner cornerRound(ShapeThemeData shapeTheme) =>
      shapeTheme.corner.full;

  static Corner cornerSquare(ShapeThemeData shapeTheme, ButtonSize size) =>
      switch (size) {
        .extraSmall => shapeTheme.corner.medium,
        .small => shapeTheme.corner.medium,
        .medium => shapeTheme.corner.large,
        .large => shapeTheme.corner.extraLarge,
        .extraLarge => shapeTheme.corner.extraLarge,
      };

  static Corner cornerPressed(ShapeThemeData shapeTheme, ButtonSize size) =>
      switch (size) {
        .extraSmall => shapeTheme.corner.small,
        .small => shapeTheme.corner.small,
        .medium => shapeTheme.corner.medium,
        .large => shapeTheme.corner.largeIncreased,
        .extraLarge => shapeTheme.corner.largeIncreased,
      };
}

abstract final class ButtonDefaults {}

abstract final class IconButtonDefaults {}

abstract final class FloatingActionButtonDefaults {}
