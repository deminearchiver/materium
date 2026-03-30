part of 'buttons.dart';

enum ButtonSize { extraSmall, small, medium, large, extraLarge }

enum ButtonShape { round, square }

enum ButtonColor { elevated, filled, tonal, outlined, text }

typedef ToggleButtonSize = ButtonSize;

typedef ToggleButtonShape = ButtonShape;

enum ToggleButtonColor {
  elevated(.elevated),
  filled(.filled),
  tonal(.tonal),
  outlined(.outlined);

  const ToggleButtonColor(this._color);

  final ButtonColor _color;
}

typedef IconButtonSize = ButtonSize;

typedef IconButtonShape = ButtonShape;

enum IconButtonColor { filled, tonal, outlined, standard }

enum IconButtonWidth { narrow, normal, wide }

typedef IconToggleButtonSize = IconButtonSize;

typedef IconToggleButtonShape = IconButtonShape;

typedef IconToggleButtonColor = IconButtonColor;

typedef IconToggleButtonWidth = IconButtonWidth;

enum FloatingActionButtonSize { small, medium, large }

enum FloatingActionButtonColor {
  primaryContainer,
  secondaryContainer,
  tertiaryContainer,
  primary,
  secondary,
  tertiary,
}

@immutable
class ButtonSettings with Diagnosticable {
  const ButtonSettings({
    this.size = .small,
    this.shape = .round,
    this.color = .filled,
  });

  final ButtonSize size;
  final ButtonShape shape;
  final ButtonColor color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ButtonSettings &&
          size == other.size &&
          shape == other.shape &&
          color == other.color;

  @override
  int get hashCode => Object.hash(runtimeType, size, shape, color);
}

@immutable
class ToggleButtonSettings with Diagnosticable {
  const ToggleButtonSettings({
    this.size = .small,
    this.shape = .round,
    this.color = .filled,
  });

  final ToggleButtonSize size;
  final ToggleButtonShape shape;
  final ToggleButtonColor color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ToggleButtonSettings &&
          size == other.size &&
          shape == other.shape &&
          color == other.color;

  @override
  int get hashCode => Object.hash(runtimeType, size, shape, color);
}

@immutable
class IconButtonSettings with Diagnosticable {
  const IconButtonSettings({
    this.size = .small,
    this.shape = .round,
    this.color = .filled,
    this.width = .normal,
  });

  final IconButtonSize size;
  final IconButtonShape shape;
  final IconButtonColor color;
  final IconButtonWidth width;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is IconButtonSettings &&
          size == other.size &&
          shape == other.shape &&
          color == other.color &&
          width == other.width;

  @override
  int get hashCode => Object.hash(runtimeType, size, shape, color, width);
}

@immutable
class IconToggleButtonSettings with Diagnosticable {
  const IconToggleButtonSettings({
    this.size = .small,
    this.shape = .round,
    this.color = .filled,
    this.width = .normal,
  });

  final IconToggleButtonSize size;
  final IconToggleButtonShape shape;
  final IconToggleButtonColor color;
  final IconToggleButtonWidth width;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is IconToggleButtonSettings &&
          size == other.size &&
          shape == other.shape &&
          color == other.color &&
          width == other.width;

  @override
  int get hashCode => Object.hash(runtimeType, size, shape, color, width);
}

@immutable
class FloatingActionButtonSettings with Diagnosticable {
  const FloatingActionButtonSettings({
    this.size = .small,
    this.color = .primaryContainer,
  });

  final FloatingActionButtonSize size;
  final FloatingActionButtonColor color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is FloatingActionButtonSettings &&
          size == other.size &&
          color == other.color;

  @override
  int get hashCode => Object.hash(runtimeType, size, color);
}
