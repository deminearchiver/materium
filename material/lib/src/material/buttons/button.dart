import 'package:material/src/material/flutter.dart';

enum ButtonSize { extraSmall, small, medium, large, extraLarge }

enum ButtonShape { round, square }

enum ButtonColor { elevated, filled, tonal, outlined, text }

typedef ToggleButtonSize = ButtonSize;

typedef ToggleButtonShape = ButtonShape;

enum ToggleButtonColor { elevated, filled, tonal, outlined }

typedef IconButtonSize = ButtonSize;

typedef IconButtonShape = ButtonShape;

enum IconButtonWidth { narrow, normal, wide }

enum IconButtonColor { filled, tonal, outlined, standard }

typedef IconToggleButtonSize = ButtonSize;

typedef IconToggleButtonShape = ButtonShape;

typedef IconToggleButtonWidth = IconButtonWidth;

typedef IconToggleButtonColor = IconButtonColor;

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.onTap,
    this.icon,
    required this.label,
  });

  final VoidCallback? onTap;
  final Widget? icon;
  final Widget label;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  bool _focused = false;
  bool _pressed = false;

  late WidgetStatesController _statesController;

  final Tween<double> _elevationTween = Tween<double>();

  final Tween<ShapeBorder?> _shapeTween = ShapeBorderTween();
  late AnimationController _shapeController;
  late Animation<ShapeBorder?> _shapeAnimation;

  // late Animation<double> _elevationAnimation;
  // late Animation<Color?> _containerColorAnimation;
  // late Animation<Color?> _contentColorAnimation;

  void _updateShapeAnimation({required ShapeBorder shape}) {
    if (shape == _shapeTween.end) {
      return;
    }

    _shapeTween.begin = _shapeAnimation.value ?? shape;
    _shapeTween.end = shape;

    if (_shapeTween.begin == _shapeTween.end) {
      return;
    }

    final spring = const SpringThemeData.expressive().fastSpatial
        .toSpringDescription();
    final simulation = SpringSimulation(spring, 0.0, 1.0, 0.0, snapToEnd: true);
    _shapeController.animateWith(simulation);
  }

  ButtonStates _resolveStates() {
    final mutableStates = _statesController.value;

    final disabled = widget.onTap == null;

    if (disabled) {
      mutableStates.remove(WidgetState.hovered);
    }

    if (!disabled && (_focused && !_pressed)) {
      mutableStates.add(WidgetState.focused);
    } else {
      mutableStates.remove(WidgetState.focused);
    }

    if (!disabled && _pressed) {
      mutableStates.add(WidgetState.pressed);
    } else {
      mutableStates.remove(WidgetState.pressed);
    }

    return ButtonStates.fromWidgetStates(mutableStates);
  }

  void _statesListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController()..addListener(_statesListener);

    _shapeController = AnimationController.unbounded(vsync: this, value: 1.0);
    _shapeAnimation = _shapeTween.animate(_shapeController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Button oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final states = _resolveStates();
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      child: RepaintBoundary(
        child: Material(
          animationDuration: Duration.zero,
          child: Listener(
            behavior: HitTestBehavior.deferToChild,
            onPointerDown: states.enabled
                ? (_) {
                    setState(() {
                      _focused = false;
                      _pressed = true;
                    });
                  }
                : null,
            onPointerUp: states.enabled
                ? (_) {
                    setState(() {
                      _focused = false;
                      _pressed = false;
                    });
                  }
                : null,
            onPointerCancel: states.enabled
                ? (_) {
                    setState(() {
                      _focused = false;
                      _pressed = false;
                    });
                  }
                : null,
            child: InkWell(
              statesController: _statesController,
              enableFeedback: states.enabled,
              onTap: states.enabled
                  ? () {
                      widget.onTap?.call();
                    }
                  : null,
              onTapDown: states.enabled
                  ? (_) {
                      setState(() {
                        _focused = false;
                        _pressed = true;
                      });
                    }
                  : null,
              onTapUp: states.enabled
                  ? (_) {
                      setState(() {
                        _focused = false;
                        _pressed = false;
                      });
                    }
                  : null,
              onTapCancel: states.enabled
                  ? () {
                      setState(() {
                        _focused = false;
                        _pressed = false;
                      });
                    }
                  : null,
              onFocusChange: states.enabled
                  ? (value) {
                      setState(() {
                        _focused = value;
                      });
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: DefaultTextStyle.merge(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  child: IconTheme.merge(
                    data: const IconThemeDataPartial.from(),
                    child: Flex.horizontal(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.0,
                      children: [
                        if (widget.icon case final icon?) icon,
                        if (widget.label case final label)
                          Flexible.loose(child: label),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

sealed class ButtonStates with Diagnosticable {
  const ButtonStates();

  factory ButtonStates.fromWidgetStates(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled)
      ? const ButtonStatesDisabled()
      : ButtonStatesEnabled(
          hovered: states.contains(WidgetState.hovered),
          focused: states.contains(WidgetState.focused),
          pressed: states.contains(WidgetState.pressed),
        );

  bool get enabled;

  bool get disabled => !enabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ButtonStates &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(runtimeType, enabled);
}

class ButtonStatesDisabled extends ButtonStates {
  const ButtonStatesDisabled();

  @override
  bool get enabled => false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType && other is ButtonStatesDisabled;

  @override
  int get hashCode => runtimeType.hashCode;
}

class ButtonStatesEnabled extends ButtonStates {
  const ButtonStatesEnabled({
    required this.hovered,
    required this.focused,
    required this.pressed,
  });

  @override
  bool get enabled => true;

  final bool hovered;

  final bool focused;

  final bool pressed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ButtonStatesEnabled &&
          hovered == other.hovered &&
          focused == other.focused &&
          pressed == other.pressed;

  @override
  int get hashCode => Object.hash(runtimeType, hovered, focused, pressed);
}

abstract class BaseButtonStyle<S extends Object?> {
  const BaseButtonStyle();

  StateProperty<Size?, S>? get tapTargetSize;
  StateProperty<BoxConstraints?, S>? get constraints;
  StateProperty<EdgeInsetsGeometry?, S>? get padding;
  StateProperty<ShapeBorder?, S>? get shape;
  StateProperty<ShapeBorder?, S>? get containerColor;
  StateProperty<ShapeBorder?, S>? get shadowColor;
  StateProperty<double?, S>? get elevation;
  StateProperty<Color?, S>? get stateLayerColor;
  StateProperty<double?, S>? get stateLayerOpacity;
  StateProperty<IconThemeDataPartial?, S>? get iconTheme;
  StateProperty<TextStyle?, S>? get labelTextStyle;
}
