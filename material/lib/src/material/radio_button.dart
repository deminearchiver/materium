// ignore_for_file: deprecated_member_use_from_same_package, deprecated_member_use

import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' as flutter;

import 'package:material/src/material/flutter.dart';

typedef RadioLegacy<T extends Object?> = flutter.Radio<T>;
typedef RadioThemeLegacy = flutter.RadioTheme;
typedef RadioThemeDataLegacy = flutter.RadioThemeData;
typedef RadioListTileLegacy<T extends Object?> = flutter.RadioListTile<T>;

class RadioButton extends StatefulWidget {
  const RadioButton({super.key, required this.onTap, required this.selected});

  final VoidCallback? onTap;
  final bool selected;

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton>
    with TickerProviderStateMixin {
  bool get _isSelected => widget.selected;

  late final WidgetStatesController _statesController;
  bool _pressed = false;
  bool _focused = false;

  late AnimationController _animationController;
  late AnimationController _colorController;
  final Tween<Color?> _iconColorTween = ColorTween();
  late Animation<Color?> _iconColorAnimation;

  late ColorThemeData _colorTheme;
  late ShapeThemeData _shapeTheme;
  late StateThemeData _stateTheme;
  late SpringThemeData _springTheme;

  WidgetStateProperty<double> get _stateLayerSize =>
      const WidgetStatePropertyAll(40.0);

  WidgetStateProperty<ShapeBorder> get _stateLayerShape =>
      WidgetStatePropertyAll(
        CornersBorder.rounded(corners: Corners.all(_shapeTheme.corner.full)),
      );

  WidgetStateProperty<Color> get _stateLayerColor =>
      WidgetStateProperty.resolveWith(
        (_) => _isSelected ? _colorTheme.primary : _colorTheme.onSurface,
      );

  WidgetStateProperty<double> get _stateLayerOpacity =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return 0.0;
        }
        if (states.contains(WidgetState.pressed)) {
          return _stateTheme.pressedStateLayerOpacity;
        }
        if (states.contains(WidgetState.hovered)) {
          return _stateTheme.hoverStateLayerOpacity;
        }
        if (states.contains(WidgetState.focused)) {
          return 0.0;
        }
        return 0.0;
      });

  WidgetStateProperty<double> get _iconSize =>
      const WidgetStatePropertyAll(20.0);

  WidgetStateProperty<Color> get _iconColor =>
      WidgetStateProperty.resolveWith((states) {
        final isSelected = _isSelected;
        if (states.contains(WidgetState.disabled)) {
          return isSelected
              ? _colorTheme.onSurface.withValues(alpha: 0.38)
              : _colorTheme.onSurface.withValues(alpha: 0.38);
        }
        if (states.contains(WidgetState.pressed)) {
          return isSelected ? _colorTheme.primary : _colorTheme.onSurface;
        }
        if (states.contains(WidgetState.focused)) {
          return isSelected ? _colorTheme.primary : _colorTheme.onSurface;
        }
        if (states.contains(WidgetState.hovered)) {
          return isSelected ? _colorTheme.primary : _colorTheme.onSurface;
        }
        return isSelected ? _colorTheme.primary : _colorTheme.onSurfaceVariant;
      });

  void _updateColorAnimations({required Color iconColor}) {
    // The animation is already in progress.
    // There is no point in triggering it again
    // because it would animate to the same value.
    if (iconColor == _iconColorTween.end) {
      return;
    }

    _iconColorTween.begin = _iconColorAnimation.value ?? iconColor;
    _iconColorTween.end = iconColor;

    // We don't have to animate between states
    // if the initial state is the same as the target state.
    if (_iconColorTween.begin == _iconColorTween.end) {
      return;
    }

    final spring = _springTheme.defaultEffects;
    final simulation = SpringSimulation(
      spring.toSpringDescription(),
      0.0,
      1.0,
      0.0,
    );
    _colorController.animateWith(simulation);
  }

  /// This method returns a [UnmodifiableSetView] over
  /// [WidgetStatesController.value]. The returned collection must not be used
  /// if changes were made to the [WidgetStatesController.value]. In that case,
  /// this method must be called again to update [WidgetStatesController.value]
  /// according to internal state.
  ///
  /// Returns an [UnmodifiableSetView].
  WidgetStates _resolveStates() {
    final states = _statesController.value;

    final isDisabled = widget.onTap == null;

    if (isDisabled) {
      states.add(WidgetState.disabled);
    } else {
      states.remove(WidgetState.disabled);
    }

    if (!isDisabled && _pressed) {
      states.add(WidgetState.pressed);
    } else {
      states.remove(WidgetState.pressed);
    }
    if (!isDisabled && (_focused && !_pressed)) {
      states.add(WidgetState.focused);
    } else {
      states.remove(WidgetState.focused);
    }
    return UnmodifiableSetView(states);
  }

  void _statesListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _statesController = WidgetStatesController()..addListener(_statesListener);

    _animationController = AnimationController.unbounded(
      vsync: this,
      value: _isSelected ? 1.0 : 0.0,
    );
    _colorController = AnimationController(vsync: this, value: 0.0);
    _iconColorAnimation = _iconColorTween.animate(_colorController);
  }

  @override
  void didUpdateWidget(covariant RadioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSelected = oldWidget.selected;
    final newSelected = widget.selected;
    if (newSelected != oldSelected) {
      const springTheme = SpringThemeData.expressive();
      final spring = springTheme.fastSpatial;
      final oldValue = _animationController.value;
      final newValue = newSelected ? 1.0 : 0.0;
      final simulation = SpringSimulation(
        spring.toSpringDescription(),
        oldValue,
        newValue,
        0.0,
      );
      if (newValue >= oldValue) {
        _animationController.animateWith(simulation);
      } else {
        _animationController.animateBackWith(simulation);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorTheme = ColorTheme.of(context);
    _shapeTheme = ShapeTheme.of(context);
    _stateTheme = StateTheme.of(context);
    _springTheme = SpringTheme.of(context);
  }

  @override
  void dispose() {
    _colorController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final states = _resolveStates();
    final isDisabled = states.contains(WidgetState.disabled);
    const minTapTargetSize = Size.square(48.0);
    final stateLayerSize = _stateLayerSize.resolve(states);
    final stateLayerShape = _stateLayerShape.resolve(states);
    final iconSize = _iconSize.resolve(states);
    final iconColor = _iconColor.resolve(states);

    _updateColorAnimations(iconColor: iconColor);

    final child = SizedBox.square(
      dimension: stateLayerSize,
      child: Listener(
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: !isDisabled
            ? (_) {
                setState(() {
                  _focused = false;
                  _pressed = true;
                });
              }
            : null,
        onPointerUp: !isDisabled
            ? (_) {
                setState(() {
                  _focused = false;
                  _pressed = false;
                });
              }
            : null,
        onPointerCancel: !isDisabled
            ? (_) {
                setState(() {
                  _focused = false;
                  _pressed = false;
                });
              }
            : null,
        child: Material(
          animationDuration: Duration.zero,
          type: MaterialType.transparency,
          clipBehavior: Clip.none,
          color: Colors.transparent,
          child: InkWell(
            statesController: _statesController,
            customBorder: stateLayerShape,
            overlayColor: WidgetStateLayerColor(
              color: _stateLayerColor,
              opacity: _stateLayerOpacity,
            ),
            enableFeedback: !isDisabled,
            onTap: !isDisabled
                ? () {
                    widget.onTap?.call();
                  }
                : null,
            onTapDown: !isDisabled
                ? (_) {
                    setState(() {
                      _focused = false;
                      _pressed = true;
                    });
                  }
                : null,
            onTapUp: !isDisabled
                ? (_) {
                    setState(() {
                      _focused = false;
                      _pressed = false;
                    });
                  }
                : null,
            onTapCancel: !isDisabled
                ? () {
                    setState(() {
                      _focused = false;
                      _pressed = false;
                    });
                  }
                : null,
            onFocusChange: !isDisabled
                ? (value) {
                    setState(() => _focused = value);
                  }
                : null,
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: Semantics(
        enabled: !states.contains(WidgetState.disabled),
        label: null,
        checked: _isSelected,
        child: Align.center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: TapRegion(
            behavior: HitTestBehavior.deferToChild,
            consumeOutsideTaps: false,
            onTapOutside: !isDisabled
                ? (_) {
                    setState(() => _focused = false);
                  }
                : null,
            onTapUpOutside: !isDisabled
                ? (_) {
                    setState(() => _focused = false);
                  }
                : null,
            child: FocusRingTheme.merge(
              data: FocusRingThemeDataPartial.from(
                shape: Corners.all(_shapeTheme.corner.full),
              ),
              child: FocusRing(
                visible: states.contains(WidgetState.focused),
                placement: FocusRingPlacement.outward,
                layoutBuilder: (context, info, child) => Align.center(
                  child: SizedBox.square(
                    dimension: stateLayerSize,
                    child: child,
                  ),
                ),
                child: _RadioButtonPaint(
                  minTapTargetSize: const _ValueListenable(minTapTargetSize),
                  iconSize: _ValueListenable(iconSize),
                  iconColor: _iconColorAnimation.nonNullOr(iconColor),
                  animation: _animationController,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioButtonPaint extends SingleChildRenderObjectWidget {
  const _RadioButtonPaint({
    // super.key,
    required this.minTapTargetSize,
    required this.iconSize,
    required this.iconColor,
    required this.animation,
    super.child,
  });

  final ValueListenable<Size> minTapTargetSize;
  final ValueListenable<double> iconSize;
  final ValueListenable<Color> iconColor;
  final ValueListenable<double> animation;

  @override
  _RenderRadioButtonPaint createRenderObject(BuildContext context) {
    return _RenderRadioButtonPaint(
      minTapTargetSize: minTapTargetSize,
      iconSize: iconSize,
      iconColor: iconColor,
      animation: animation,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderRadioButtonPaint renderObject,
  ) {
    renderObject
      ..minTapTargetSize = minTapTargetSize
      ..iconSize = iconSize
      ..iconColor = iconColor
      ..animation = animation;
  }
}

class _RenderRadioButtonPaint extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderRadioButtonPaint({
    required ValueListenable<Size> minTapTargetSize,
    required ValueListenable<double> iconSize,
    required ValueListenable<Color> iconColor,
    required ValueListenable<double> animation,
    RenderBox? child,
  }) : _minTapTargetSize = minTapTargetSize,
       _iconSize = iconSize,
       _iconColor = iconColor,
       _animation = animation {
    this.child = child;
  }

  ValueListenable<Size> _minTapTargetSize;
  ValueListenable<Size> get minTapTargetSize => _minTapTargetSize;
  set minTapTargetSize(ValueListenable<Size> value) {
    if (_minTapTargetSize == value) return;
    _minTapTargetSize.removeListener(markNeedsLayout);
    _minTapTargetSize = value;
    _minTapTargetSize.addListener(markNeedsLayout);
  }

  ValueListenable<double> _iconSize;
  ValueListenable<double> get iconSize => _iconSize;
  set iconSize(ValueListenable<double> value) {
    if (_iconSize == value) return;
    _iconSize.removeListener(markNeedsLayout);
    _iconSize = value;
    _iconSize.addListener(markNeedsLayout);
  }

  ValueListenable<Color> _iconColor;
  ValueListenable<Color> get iconColor => _iconColor;
  set iconColor(ValueListenable<Color> value) {
    if (_iconColor == value) return;
    _iconColor.removeListener(markNeedsLayout);
    _iconColor = value;
    _iconColor.addListener(markNeedsLayout);
  }

  ValueListenable<double> _animation;
  ValueListenable<double> get animation => _animation;
  set animation(ValueListenable<double> value) {
    if (_animation == value) return;
    _animation.removeListener(markNeedsPaint);
    _animation = value;
    _animation.addListener(markNeedsPaint);
  }

  Size _computeOuterSize() {
    final minTapTargetSize = this.minTapTargetSize.value;
    final iconSize = this.iconSize.value;
    return Size(
      math.max(minTapTargetSize.width, iconSize),
      math.max(minTapTargetSize.height, iconSize),
    );
  }

  // Offset _computeOuterCenter(Size outerSize) => outerSize.center(Offset.zero);
  // Rect _computeIconRect(Offset center) {
  //   final iconSize = this.iconSize.value;
  //   return Rect.fromCenter(center: center, width: iconSize, height: iconSize);
  // }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    minTapTargetSize.addListener(markNeedsLayout);
    iconSize.addListener(markNeedsLayout);
    iconColor.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    iconColor.removeListener(markNeedsPaint);
    iconSize.removeListener(markNeedsLayout);
    minTapTargetSize.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _computeOuterSize().width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _computeOuterSize().height;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _computeOuterSize().width;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _computeOuterSize().height;
  }

  void _positionChild(RenderBox child, Offset position) {
    assert(child.parentData != null && child.parentData is BoxParentData);
    (child.parentData! as BoxParentData).offset = position;
  }

  Size _layout({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
    required ChildPositioner positionChild,
  }) {
    final outerSize = _computeOuterSize();
    final center = outerSize.center(Offset.zero);
    if (child case final child?) {
      layoutChild(
        child,
        BoxConstraints(
          minWidth: 0.0,
          minHeight: 0.0,
          maxWidth: outerSize.width,
          maxHeight: outerSize.height,
        ),
      );
      final childSize = child.size;
      positionChild(
        child,
        Offset(
          center.dx - childSize.width / 2.0,
          center.dy - childSize.height / 2.0,
        ),
      );
    }
    return constraints.constrain(outerSize);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(
    constraints: constraints,
    layoutChild: ChildLayoutHelper.dryLayoutChild,
    positionChild: (_, _) {},
  );

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    return null;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return null;
  }

  @override
  void performLayout() {
    size = _layout(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
      positionChild: _positionChild,
    );
  }

  void _paintIcon(PaintingContext context) {
    const relativeIconSize = 20.0;
    const relativeCircleRadius = relativeIconSize / 2.0;
    const relativeStrokeWidth = 2.0;
    const relativeDotSize = 12.0;
    const relativeDotRadius = relativeDotSize / 2.0;

    final center = size.center(Offset.zero);
    final scale = iconSize.value / relativeIconSize;

    // TODO: remove scaling once the magic numbers are extracted into theme.
    context.withCanvasTransform((context) {
      context.canvas.translate(center.dx, center.dy);
      context.canvas.scale(scale);
      context.canvas.translate(-center.dx, -center.dy);
      final paint = Paint()
        ..color = iconColor.value
        ..style = PaintingStyle.stroke
        ..strokeWidth = relativeStrokeWidth;

      context.canvas.drawCircle(
        center,
        relativeCircleRadius - relativeStrokeWidth / 2.0,
        paint,
      );

      paint
        ..style = PaintingStyle.fill
        ..strokeWidth = 0.0;
      final dotRadius = lerpDouble(0.0, relativeDotRadius, animation.value)!;
      if (dotRadius > 0.0) {
        context.canvas.drawCircle(
          center,
          // TODO: dot radius shouldn't depend on stroke width.
          //  It's counter-intuitive.
          dotRadius - relativeStrokeWidth / 2.0,
          paint,
        );
      }
    });
  }

  void _paintChild(PaintingContext context) {
    if (child case final child?) {
      context.paintChild(child, (child.parentData! as BoxParentData).offset);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.withCanvasTransform((context) {
      if (offset != Offset.zero) {
        context.canvas.translate(offset.dx, offset.dy);
      }
      _paintChild(context);
      _paintIcon(context);
    });
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }
    final child = this.child;
    if (child == null) return false;
    final Offset center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) {
        assert(position == center);
        return child.hitTest(result, position: center);
      },
    );
  }
}

class RadioGroupButton<T extends Object?> extends StatefulWidget {
  const RadioGroupButton({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.toggleable = false,
    this.focusNode,
    this.autofocus = false,
    this.enabled,
    this.groupRegistry,
  });

  /// {@macro flutter.widget.RawRadio.value}
  final T value;

  /// {@macro flutter.material.Radio.groupValue}
  @Deprecated("Use a RadioGroup ancestor to manage group value instead.")
  final T? groupValue;

  /// {@macro flutter.material.Radio.onChanged}
  /// Called when the user selects this radio button.
  ///
  /// The radio button passes [value] as a parameter to this callback. The radio
  /// button does not actually change state until the parent widget rebuilds the
  /// radio button with the new [groupValue].
  ///
  /// If null, the radio button will be displayed as disabled.
  ///
  /// The provided callback will not be invoked if this radio button is already
  /// selected and [toggleable] is not set to true.
  ///
  /// If the [toggleable] is set to true, tapping a already selected radio will
  /// invoke this callback with `null` as value.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt.
  ///
  /// For example:
  ///
  /// ```dart
  /// RadioGroupButton<SingingCharacter>(
  ///   value: SingingCharacter.lafayette,
  ///   groupValue: _character,
  ///   onChanged: (SingingCharacter? newValue) {
  ///     setState(() {
  ///       _character = newValue;
  ///     });
  ///   },
  /// )
  /// ```
  ///
  /// This is deprecated, use [RadioGroup] to handle value change instead.
  @Deprecated(
    "Use RadioGroup to handle value change instead. "
    "This feature was deprecated after v3.32.0-0.0.pre.",
  )
  final ValueChanged<T?>? onChanged;

  /// {@macro flutter.widget.RawRadio.toggleable}
  final bool toggleable;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Whether this widget is interactive.
  ///
  /// If not provided, this widget will be interactable if one of the following
  /// is true:
  ///
  /// * Having a [RadioGroup] with the same type T above this widget.
  /// * A [groupRegistry] is provided.
  ///
  /// If this is set to true, one of the above condition must also be true.
  /// Otherwise, an assertion error is thrown.
  final bool? enabled;

  /// {@macro flutter.widget.RawRadio.groupRegistry}
  ///
  /// Unless provided, the [BuildContext] will be used to look up the ancestor
  /// [RadioGroupRegistry].
  final RadioGroupRegistry<T>? groupRegistry;

  @override
  State<RadioGroupButton<T>> createState() => _RadioGroupButtonState<T>();
}

class _RadioGroupButtonState<T extends Object?>
    extends State<RadioGroupButton<T>> {
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get _enabled =>
      widget.enabled ??
      (widget.onChanged != null ||
          widget.groupRegistry != null ||
          RadioGroup.maybeOf<T>(context) != null);

  _LegacyRadioGroupRegistry<T>? _internalRadioRegistry;
  RadioGroupRegistry<T> get _effectiveRegistry {
    if (widget.groupRegistry != null) return widget.groupRegistry!;

    final inheritedRegistry = RadioGroup.maybeOf<T>(context);
    if (inheritedRegistry != null) return inheritedRegistry;

    // Handles deprecated API.
    return _internalRadioRegistry ??= _LegacyRadioGroupRegistry<T>(this);
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !(widget.enabled ?? false) ||
          widget.onChanged != null ||
          widget.groupRegistry != null ||
          RadioGroup.maybeOf<T>(context) != null,
      "Radio is enabled but has no Radio.onChange or registry above",
    );

    // TODO: remove this if not needed due to an internal transparent Material
    assert(debugCheckHasMaterial(context));

    return _RawRadio(
      value: widget.value,
      // mouseCursor: WidgetStateMouseCursor.clickable,
      toggleable: widget.toggleable,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      groupRegistry: _effectiveRegistry,
      enabled: _enabled,
      builder: (context, state) => RadioButton(
        onTap: () => state.onChanged?.call(!state.value),
        selected: state.value,
      ),
    );
  }
}

class _RawRadio<T extends Object?> extends StatefulWidget {
  /// Creates a radio button.
  ///
  /// If [enabled] is true, the [groupRegistry] must not be null.
  const _RawRadio({
    super.key,
    required this.value,
    // required this.mouseCursor,
    required this.toggleable,
    required this.focusNode,
    required this.autofocus,
    required this.groupRegistry,
    required this.enabled,
    required this.builder,
  }) : assert(
         !enabled || groupRegistry != null,
         "an enabled raw radio must have a registry",
       );

  /// {@macro flutter.widget.RawRadio.value}
  final T value;

  // /// {@macro flutter.widget.RawRadio.mouseCursor}
  // final WidgetStateProperty<MouseCursor> mouseCursor;

  /// {@macro flutter.widget.RawRadio.toggleable}
  final bool toggleable;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The builder for the radio button visual.
  ///
  /// Use the input `state` to determine the current state of the radio.
  ///
  /// {@macro flutter.widgets.ToggleableStateMixin.buildToggleableWithChild}
  final Widget Function(BuildContext context, _RawRadioState<T> state) builder;

  /// Whether this widget is enabled.
  final bool enabled;

  /// {@macro flutter.widget.RawRadio.groupRegistry}
  ///
  /// {@macro flutter.widget.RawRadio.groupValue}
  final RadioGroupRegistry<T>? groupRegistry;

  @override
  State<_RawRadio<T>> createState() => _RawRadioState<T>();
}

class _RawRadioState<T extends Object?> extends State<_RawRadio<T>>
    with RadioClient<T> {
  /// Handle selection status changed.
  ///
  /// if `selected` is false, nothing happens.
  ///
  /// if `selected` is true, select this radio. i.e. [Radio.onChanged] is called
  /// with [Radio.value]. This also updates the group value in [RadioGroup] if it
  /// is in use.
  ///
  /// if `selected` is null, unselect this radio. Same as `selected` is true
  /// except group value is set to null.
  void _handleChanged(bool? selected) {
    assert(registry != null);
    if (!(selected ?? true)) {
      return;
    }
    if (selected ?? false) {
      registry!.onChanged(widget.value);
    } else {
      registry!.onChanged(null);
    }
  }

  @override
  FocusNode get focusNode => widget.focusNode;

  @override
  // ignore: override_on_non_overriding_member
  bool get enabled => isInteractive;

  @override
  T get radioValue => widget.value;

  ValueChanged<bool?>? get onChanged =>
      registry != null ? _handleChanged : null;

  @override
  bool get tristate => widget.toggleable;

  bool get value => widget.value == registry?.groupValue;

  bool get isInteractive => widget.enabled;

  @override
  void initState() {
    super.initState();
    // [ToggleableStateMixin] is not used so this could be below
    // the init state
    registry = widget.groupRegistry;
  }

  @override
  void didUpdateWidget(covariant _RawRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    registry = widget.groupRegistry;
  }

  @override
  void dispose() {
    super.dispose();
    // TODO: investigate why this is below dispose in the original implementation
    registry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool? accessibilitySelected;
    String? semanticsHint;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        accessibilitySelected = null;

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        accessibilitySelected = value;

        // Only provide hint for unselected radio buttons to avoid duplication
        // of the selected state announcement.
        // Selected state is already announced by iOS via the 'selected' property.
        if (!value) {
          final localizations = WidgetsLocalizations.of(context);
          semanticsHint = localizations._radioButtonUnselectedLabel;
        }
    }
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: value,
      selected: accessibilitySelected,
      hint: semanticsHint,
      child: widget.builder(context, this),
    );
  }
}

// TODO: Remove this once deprecated API is removed.
/// A registry for deprecated API.
class _LegacyRadioGroupRegistry<T> extends RadioGroupRegistry<T> {
  _LegacyRadioGroupRegistry(this.state);

  final _RadioGroupButtonState<T> state;

  @override
  T? get groupValue => state.widget.groupValue;

  @override
  ValueChanged<T?> get onChanged => state.widget.onChanged!;

  @override
  void registerClient(RadioClient<T> radio) {}

  @override
  void unregisterClient(RadioClient<T> radio) {}
}

class _ValueListenable<T extends Object?> extends ValueListenable<T> {
  const _ValueListenable(this.value);

  @override
  final T value;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

extension on WidgetsLocalizations {
  // TODO: remove when radioButtonUnselectedLabel lands on stable
  String? get _radioButtonUnselectedLabel {
    try {
      final Object? result = (this as dynamic).radioButtonUnselectedLabel;
      return result != null && result is String ? result : null;
    } on NoSuchMethodError {
      return null;
    }
  }
}
