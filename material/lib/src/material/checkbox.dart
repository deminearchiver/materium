import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart' as flutter;

import 'package:material/src/material/flutter.dart';

typedef CheckboxLegacy = flutter.Checkbox;
typedef CheckboxThemeLegacy = flutter.CheckboxTheme;
typedef CheckboxThemeDataLegacy = flutter.CheckboxThemeData;

enum _CheckedState { off, intermediate, checked }

sealed class Checkbox extends StatefulWidget {
  const Checkbox._({super.key});

  const factory Checkbox.biState({
    Key? key,
    required ValueChanged<bool>? onCheckedChanged,
    required bool checked,
  }) = _BiStateCheckbox;

  const factory Checkbox.triState({
    Key? key,
    required VoidCallback? onTap,
    required bool? state,
  }) = _TriStateCheckbox;

  _CheckedState get _state;
  VoidCallback? get _onTap;

  @override
  State<Checkbox> createState() => _CheckboxState();
}

class _BiStateCheckbox extends Checkbox {
  const _BiStateCheckbox({
    super.key,
    required this.onCheckedChanged,
    required this.checked,
  }) : super._();

  final ValueChanged<bool>? onCheckedChanged;
  final bool checked;

  @override
  _CheckedState get _state => checked ? .checked : .off;

  @override
  VoidCallback? get _onTap => onCheckedChanged != null ? _onTapCallback : null;

  void _onTapCallback() {
    assert(onCheckedChanged != null);
    onCheckedChanged!(!checked);
  }
}

class _TriStateCheckbox extends Checkbox {
  const _TriStateCheckbox({super.key, required this.onTap, required this.state})
    : super._();

  final VoidCallback? onTap;
  final bool? state;

  @override
  _CheckedState get _state => switch (state) {
    false => .off,
    null => .intermediate,
    true => .checked,
  };

  @override
  VoidCallback? get _onTap => onTap;
}

class _CheckboxState extends State<Checkbox> with TickerProviderStateMixin {
  bool get _isIntermediate => widget._state == .intermediate;
  bool get _isChecked => widget._state == .checked;
  bool get _isCheckedOrIntermediate => widget._state != .off;

  double get _checkedFraction => _isCheckedOrIntermediate ? 1.0 : 0.0;
  double get _crossCenterGravitation => _isIntermediate ? 1.0 : 0.0;

  late ColorThemeData _colorTheme;
  late ShapeThemeData _shapeTheme;
  late StateThemeData _stateTheme;
  late SpringThemeData _springTheme;

  late final WidgetStatesController _statesController;
  bool _pressed = false;
  bool _focused = false;

  late final AnimationController _checkFractionController;
  late final AnimationController _crossCenterGravitationController;
  late final AnimationController _colorController;

  final Tween<Color?> _containerColorTween = ColorTween();
  final Tween<Color?> _outlineColorTween = ColorTween();
  final Tween<Color?> _iconColorTween = ColorTween();

  late Animation<Color?> _containerColorAnimation;
  late Animation<Color?> _outlineColorAnimation;
  late Animation<Color?> _iconColorAnimation;

  WidgetStateProperty<Color> get _containerColor =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return _isCheckedOrIntermediate
            ? isDisabled
                  ? _colorTheme.onSurface.withValues(alpha: 0.38)
                  : _colorTheme.primary
            : isDisabled
            ? _colorTheme.onSurface.withValues(alpha: 0.0)
            : _colorTheme.primary.withValues(alpha: 0.0);
      });

  WidgetStateProperty<Color> get _outlineColor =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        if (isDisabled) {
          return _colorTheme.onSurface.withValues(alpha: 0.38);
        }
        if (_isCheckedOrIntermediate) {
          return _colorTheme.primary;
        }
        if (states.contains(WidgetState.pressed)) {
          return _colorTheme.onSurface;
        }
        if (states.contains(WidgetState.focused)) {
          return _colorTheme.onSurface;
        }
        if (states.contains(WidgetState.hovered)) {
          return _colorTheme.onSurface;
        }
        return _colorTheme.onSurfaceVariant;
      });

  WidgetStateProperty<Color> get _iconColor =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return _isCheckedOrIntermediate
            ? isDisabled
                  ? _colorTheme.surface.withValues(alpha: 0.38)
                  : _colorTheme.onPrimary
            : Colors.transparent;
      });

  WidgetStateProperty<Color> get _stateLayerColor =>
      WidgetStateProperty.resolveWith(
        (_) => _isCheckedOrIntermediate
            ? _colorTheme.primary
            : _colorTheme.onSurface,
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

  void _updateColorAnimations({
    required Color containerColor,
    required Color outlineColor,
    required Color iconColor,
  }) {
    // The animation is already in progress.
    // There is no point in triggering it again
    // because it would animate to the same value.
    if (containerColor == _containerColorTween.end &&
        outlineColor == _outlineColorTween.end &&
        iconColor == _iconColorTween.end) {
      return;
    }

    _containerColorTween.begin =
        _containerColorAnimation.value ?? containerColor;
    _containerColorTween.end = containerColor;
    _outlineColorTween.begin = _outlineColorAnimation.value ?? outlineColor;
    _outlineColorTween.end = outlineColor;
    _iconColorTween.begin = _iconColorAnimation.value ?? iconColor;
    _iconColorTween.end = iconColor;

    // We don't have to animate between states
    // if the initial state is the same as the target state.
    if (_containerColorTween.begin == _containerColorTween.end &&
        _outlineColorTween.begin == _outlineColorTween.end &&
        _iconColorTween.begin == _iconColorTween.end) {
      return;
    }

    final spring = _isCheckedOrIntermediate
        ? _springTheme.defaultEffects
        : _springTheme.fastEffects;
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

    final isDisabled = widget._onTap == null;

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
    _checkFractionController = AnimationController.unbounded(
      vsync: this,
      value: _checkedFraction,
    );
    _crossCenterGravitationController = AnimationController.unbounded(
      vsync: this,
      value: _crossCenterGravitation,
    );
    _colorController = AnimationController(vsync: this, value: 0.0);
    _containerColorAnimation = _containerColorTween.animate(_colorController);
    _outlineColorAnimation = _outlineColorTween.animate(_colorController);
    _iconColorAnimation = _iconColorTween.animate(_colorController);
  }

  @override
  void didUpdateWidget(covariant Checkbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldState = oldWidget._state;
    final newState = widget._state;
    if (oldState != newState) {
      final oldCheckFraction = oldState == .off
          ? 0.0
          : _checkFractionController.value;
      final newCheckFraction = _checkedFraction;
      const springTheme = SpringThemeData.expressive();
      final spring = springTheme.defaultSpatial.toSpringDescription();
      final checkFractionSimulation = SpringSimulation(
        spring,
        oldCheckFraction,
        newCheckFraction,
        0.0,
      );
      if (oldState != .off && newState == .off) {
        const duration = Duration(milliseconds: 100);
        const curve = Threshold(1.0);
        if (newCheckFraction >= oldCheckFraction) {
          _checkFractionController.animateTo(
            newCheckFraction,
            duration: duration,
            curve: curve,
          );
        } else {
          _checkFractionController.animateBack(
            newCheckFraction,
            duration: duration,
            curve: curve,
          );
        }
      } else {
        if (newCheckFraction >= oldCheckFraction) {
          _checkFractionController.animateWith(checkFractionSimulation);
        } else {
          _checkFractionController.animateBackWith(checkFractionSimulation);
        }
      }

      final oldCrossCenterGravitation = _crossCenterGravitationController.value;
      final newCrossCenterGravitation = _crossCenterGravitation;
      final crossCenterGravitationSimulation = SpringSimulation(
        spring,
        oldCrossCenterGravitation,
        newCrossCenterGravitation,
        0.0,
      );
      if (oldState == .off) {
        _crossCenterGravitationController.value = newCrossCenterGravitation;
      } else if (newState == .off) {
        const duration = Duration(milliseconds: 100);
        const curve = Threshold(1.0);
        if (newCrossCenterGravitation >= oldCrossCenterGravitation) {
          _crossCenterGravitationController.animateTo(
            newCrossCenterGravitation,
            duration: duration,
            curve: curve,
          );
        } else {
          _crossCenterGravitationController.animateBack(
            newCrossCenterGravitation,
            duration: duration,
            curve: curve,
          );
        }
      } else {
        if (newCrossCenterGravitation >= oldCrossCenterGravitation) {
          _crossCenterGravitationController.animateWith(
            crossCenterGravitationSimulation,
          );
        } else {
          _crossCenterGravitationController.animateBackWith(
            crossCenterGravitationSimulation,
          );
        }
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
    _crossCenterGravitationController.dispose();
    _checkFractionController.dispose();
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final states = _resolveStates();
    final isDisabled = states.contains(WidgetState.disabled);

    const minTapTargetSize = Size.square(48.0);
    const stateLayerSize = 40.0;
    final stateLayerShape = CornersBorder.rounded(
      corners: Corners.all(_shapeTheme.corner.full),
    );

    final containerColor = _containerColor.resolve(states);
    final outlineColor = _outlineColor.resolve(states);
    final iconColor = _iconColor.resolve(states);

    _updateColorAnimations(
      containerColor: containerColor,
      outlineColor: outlineColor,
      iconColor: iconColor,
    );

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
          type: MaterialType.card,
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
            onTap: !isDisabled ? () => widget._onTap?.call() : null,
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
        checked: _isChecked,
        mixed: _isIntermediate,
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
                child: _CheckboxPaint(
                  minTapTargetSize: minTapTargetSize,
                  containerSize: const Size.square(18.0),
                  containerShape: const Corners.all(Corner.circular(2.0)),
                  containerColor: _containerColorAnimation.nonNullOr(
                    containerColor,
                  ),
                  outlineColor: _outlineColorAnimation.nonNullOr(outlineColor),
                  outlineWidth: 2.0,
                  iconSize: 18.0,
                  iconColor: _iconColorAnimation.nonNullOr(iconColor),
                  iconStrokeWidth: 2.0,
                  iconStrokeCap: StrokeCap.round,
                  iconStrokeJoin: StrokeJoin.round,
                  checkFraction: _checkFractionController,
                  crossCenterGravitation: _crossCenterGravitationController,
                  childPosition: .bottom,
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

enum _CheckboxChildPosition { bottom, middle, top }

class _CheckboxPaint extends SingleChildRenderObjectWidget {
  const _CheckboxPaint({
    // super.key,
    required this.minTapTargetSize,
    required this.containerSize,
    required this.containerShape,
    required this.containerColor,
    required this.outlineColor,
    required this.outlineWidth,
    required this.iconSize,
    required this.iconColor,
    required this.iconStrokeWidth,
    required this.iconStrokeCap,
    required this.iconStrokeJoin,
    required this.checkFraction,
    required this.crossCenterGravitation,
    required this.childPosition,
    super.child,
  });

  final Size minTapTargetSize;

  final Size containerSize;
  final CornersGeometry containerShape;
  final ValueListenable<Color> containerColor;
  final ValueListenable<Color> outlineColor;
  final double outlineWidth;

  final double iconSize;
  final ValueListenable<Color> iconColor;
  final double iconStrokeWidth;
  final StrokeCap iconStrokeCap;
  final StrokeJoin iconStrokeJoin;
  final ValueListenable<double> checkFraction;
  final ValueListenable<double> crossCenterGravitation;

  final _CheckboxChildPosition childPosition;

  @override
  _RenderCheckboxPaint createRenderObject(BuildContext context) =>
      _RenderCheckboxPaint(
        minTapTargetSize: minTapTargetSize,
        containerSize: containerSize,
        containerShape: containerShape,
        containerColor: containerColor,
        outlineColor: outlineColor,
        outlineWidth: outlineWidth,
        iconSize: iconSize,
        iconColor: iconColor,
        iconStrokeWidth: iconStrokeWidth,
        iconStrokeCap: iconStrokeCap,
        iconStrokeJoin: iconStrokeJoin,
        checkFraction: checkFraction,
        crossCenterGravitation: crossCenterGravitation,
        childPosition: childPosition,
        textDirection: Directionality.maybeOf(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCheckboxPaint renderObject,
  ) {
    renderObject
      ..minTapTargetSize = minTapTargetSize
      ..containerSize = containerSize
      ..containerShape = containerShape
      ..containerColor = containerColor
      ..outlineColor = outlineColor
      ..outlineWidth = outlineWidth
      ..iconSize = iconSize
      ..iconColor = iconColor
      ..iconStrokeWidth = iconStrokeWidth
      ..iconStrokeCap = iconStrokeCap
      ..iconStrokeJoin = iconStrokeJoin
      ..checkFraction = checkFraction
      ..crossCenterGravitation = crossCenterGravitation
      ..childPosition = childPosition
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderCheckboxPaint extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderCheckboxPaint({
    // Tap target
    required Size minTapTargetSize,

    // Container
    required Size containerSize,
    required CornersGeometry containerShape,
    required ValueListenable<Color> containerColor,
    required ValueListenable<Color> outlineColor,
    required double outlineWidth,

    // Icon
    required double iconSize,
    required ValueListenable<Color> iconColor,
    required double iconStrokeWidth,
    required StrokeCap iconStrokeCap,
    required StrokeJoin iconStrokeJoin,
    required ValueListenable<double> checkFraction,
    required ValueListenable<double> crossCenterGravitation,

    // Child-related properties
    required _CheckboxChildPosition childPosition,

    // Context
    TextDirection? textDirection,

    // Child
    RenderBox? child,
  }) : _minTapTargetSize = minTapTargetSize,
       _containerSize = containerSize,
       _containerShape = containerShape,
       _containerColor = containerColor,
       _outlineColor = outlineColor,
       _outlineWidth = outlineWidth,
       _iconSize = iconSize,
       _iconColor = iconColor,
       _iconStrokeWidth = iconStrokeWidth,
       _iconStrokeCap = iconStrokeCap,
       _iconStrokeJoin = iconStrokeJoin,
       _checkFraction = checkFraction,
       _crossCenterGravitation = crossCenterGravitation,
       _childPosition = childPosition,
       _textDirection = textDirection {
    this.child = child;
  }

  // Tap target

  Size _minTapTargetSize;
  Size get minTapTargetSize => _minTapTargetSize;
  set minTapTargetSize(Size value) {
    if (_minTapTargetSize == value) return;
    _minTapTargetSize = value;
    markNeedsLayout();
  }

  // Container

  Size _containerSize;
  Size get containerSize => _containerSize;
  set containerSize(Size value) {
    if (_containerSize == value) return;
    _containerSize = value;
    markNeedsLayout();
  }

  CornersGeometry _containerShape;
  CornersGeometry get containerShape => _containerShape;
  set containerShape(CornersGeometry value) {
    if (_containerShape == value) return;
    _containerShape = value;
    _resolvedContainerShapeCache = null;
    markNeedsPaint();
  }

  Corners? _resolvedContainerShapeCache;
  Corners get _resolvedContainerShape =>
      _resolvedContainerShapeCache ??= containerShape.resolve(textDirection);

  ValueListenable<Color> _containerColor;
  ValueListenable<Color> get containerColor => _containerColor;
  set containerColor(ValueListenable<Color> value) {
    if (_containerColor == value) return;
    _containerColor.removeListener(markNeedsPaint);
    _containerColor = value;
    _containerColor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  ValueListenable<Color> _outlineColor;
  ValueListenable<Color> get outlineColor => _outlineColor;
  set outlineColor(ValueListenable<Color> value) {
    if (_outlineColor == value) return;
    _outlineColor.removeListener(markNeedsPaint);
    _outlineColor = value;
    _outlineColor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  double _outlineWidth;
  double get outlineWidth => _outlineWidth;
  set outlineWidth(double value) {
    if (_outlineWidth == value) return;
    _outlineWidth = value;
    markNeedsPaint();
  }

  // Icon

  double _iconSize;
  double get iconSize => _iconSize;
  set iconSize(double value) {
    if (_iconSize == value) return;
    _iconSize = value;
    markNeedsPaint();
  }

  ValueListenable<Color> _iconColor;
  ValueListenable<Color> get iconColor => _iconColor;
  set iconColor(ValueListenable<Color> value) {
    if (_iconColor == value) return;
    _iconColor.removeListener(markNeedsPaint);
    _iconColor = value;
    _iconColor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  double _iconStrokeWidth;
  double get iconStrokeWidth => _iconStrokeWidth;
  set iconStrokeWidth(double value) {
    if (_iconStrokeWidth == value) return;
    _iconStrokeWidth = value;
    markNeedsPaint();
  }

  StrokeCap _iconStrokeCap;
  StrokeCap get iconStrokeCap => _iconStrokeCap;
  set iconStrokeCap(StrokeCap value) {
    if (_iconStrokeCap == value) return;
    _iconStrokeCap = value;
    markNeedsPaint();
  }

  StrokeJoin _iconStrokeJoin;
  StrokeJoin get iconStrokeJoin => _iconStrokeJoin;
  set iconStrokeJoin(StrokeJoin value) {
    if (_iconStrokeJoin == value) return;
    _iconStrokeJoin = value;
    markNeedsPaint();
  }

  ValueListenable<double> _checkFraction;
  ValueListenable<double> get checkFraction => _checkFraction;
  set checkFraction(ValueListenable<double> value) {
    if (_checkFraction == value) return;
    _checkFraction.removeListener(markNeedsPaint);
    _checkFraction = value;
    _checkFraction.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  ValueListenable<double> _crossCenterGravitation;
  ValueListenable<double> get crossCenterGravitation => _crossCenterGravitation;
  set crossCenterGravitation(ValueListenable<double> value) {
    if (_crossCenterGravitation == value) return;
    _crossCenterGravitation.removeListener(markNeedsPaint);
    _crossCenterGravitation = value;
    _crossCenterGravitation.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  // Child

  _CheckboxChildPosition _childPosition;
  _CheckboxChildPosition get childPosition => _childPosition;
  set childPosition(_CheckboxChildPosition value) {
    if (_childPosition == value) return;
    _childPosition = value;
    markNeedsPaint();
  }

  TextDirection? _textDirection;
  TextDirection? get textDirection => _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedsResolution();
  }

  void _markNeedsResolution() {
    markNeedsLayout();
  }

  Size _computeOuterSize() => Size(
    math.max(containerSize.width, minTapTargetSize.width),
    math.max(containerSize.height, minTapTargetSize.height),
  );

  Rect _computeInnerRect(Size outerSize) {
    assert(
      outerSize.width >= containerSize.width &&
          outerSize.height >= containerSize.height,
    );
    return Rect.fromLTWH(
      (outerSize.width - containerSize.width) / 2.0,
      (outerSize.height - containerSize.height) / 2.0,
      containerSize.width,
      containerSize.height,
    );
  }

  Offset _computeOuterCenter(Size outerSize) => outerSize.center(Offset.zero);

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _containerColor.addListener(markNeedsPaint);
    _outlineColor.addListener(markNeedsPaint);
    _iconColor.addListener(markNeedsPaint);
    _checkFraction.addListener(markNeedsPaint);
    _crossCenterGravitation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _crossCenterGravitation.removeListener(markNeedsPaint);
    _checkFraction.removeListener(markNeedsPaint);
    _iconColor.removeListener(markNeedsPaint);
    _outlineColor.removeListener(markNeedsPaint);
    _containerColor.removeListener(markNeedsPaint);
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
    final outerCenter = _computeOuterCenter(outerSize);
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
          outerCenter.dx - childSize.width / 2.0,
          outerCenter.dy - childSize.height / 2.0,
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

  void _paintBox(PaintingContext context, Rect shiftedRect) {
    final borderRadius = _resolvedContainerShape.toBorderRadius(
      shiftedRect.size,
    );

    final containerColor = this.containerColor.value;
    final outlineColor = this.outlineColor.value;

    final containerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = containerColor;

    // TODO: remove because RepaintBoundary seems to have fixed pixel alignment
    if (containerColor == outlineColor || outlineColor.a >= 1.0) {
      final rrect = borderRadius.toRRect(shiftedRect);
      context.canvas.drawRRect(rrect, containerPaint);
    } else {
      final innerBorderRadius =
          borderRadius - BorderRadius.circular(outlineWidth);
      final innerRRect = RRect.fromLTRBAndCorners(
        shiftedRect.left + outlineWidth,
        shiftedRect.top + outlineWidth,
        shiftedRect.right - outlineWidth,
        shiftedRect.bottom - outlineWidth,
        topLeft: innerBorderRadius.topLeft.clamp(minimum: Radius.zero),
        topRight: innerBorderRadius.topRight.clamp(minimum: Radius.zero),
        bottomRight: innerBorderRadius.bottomRight.clamp(minimum: Radius.zero),
        bottomLeft: innerBorderRadius.bottomLeft.clamp(minimum: Radius.zero),
      );
      context.canvas.drawRRect(innerRRect, containerPaint);
    }
    if (outlineWidth > 0.0 && containerColor != outlineColor) {
      final halfOutlineWidth = math.max(0.0, outlineWidth / 2.0);

      final outerBorderRadius =
          borderRadius - BorderRadius.circular(halfOutlineWidth);
      final outerRRect = RRect.fromLTRBAndCorners(
        shiftedRect.left + halfOutlineWidth,
        shiftedRect.top + halfOutlineWidth,
        shiftedRect.right - halfOutlineWidth,
        shiftedRect.bottom - halfOutlineWidth,
        topLeft: outerBorderRadius.topLeft.clamp(minimum: Radius.zero),
        topRight: outerBorderRadius.topRight.clamp(minimum: Radius.zero),
        bottomRight: outerBorderRadius.bottomRight.clamp(minimum: Radius.zero),
        bottomLeft: outerBorderRadius.bottomLeft.clamp(minimum: Radius.zero),
      );

      final outlinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = outlineColor
        ..strokeWidth = outlineWidth;

      context.canvas.drawRRect(outerRRect, outlinePaint);
    }

    // if (outlineWidth > 0.0 && containerColor != outlineColor) {
    //   final innerBorderRadius =
    //       borderRadius - BorderRadius.circular(outlineWidth);
    //   final innerRRect = RRect.fromLTRBAndCorners(
    //     shiftedRect.left + outlineWidth,
    //     shiftedRect.top + outlineWidth,
    //     shiftedRect.right - outlineWidth,
    //     shiftedRect.bottom - outlineWidth,
    //     topLeft: innerBorderRadius.topLeft.clamp(minimum: Radius.zero),
    //     topRight: innerBorderRadius.topRight.clamp(minimum: Radius.zero),
    //     bottomRight: innerBorderRadius.bottomRight.clamp(minimum: Radius.zero),
    //     bottomLeft: innerBorderRadius.bottomLeft.clamp(minimum: Radius.zero),
    //   );
    //   context.canvas.drawRRect(innerRRect, containerPaint);

    //   final halfOutlineWidth = math.max(0.0, outlineWidth / 2.0);
    //   final outerBorderRadius =
    //       borderRadius - BorderRadius.circular(halfOutlineWidth);
    //   final outerRRect = RRect.fromLTRBAndCorners(
    //     shiftedRect.left + halfOutlineWidth,
    //     shiftedRect.top + halfOutlineWidth,
    //     shiftedRect.right - halfOutlineWidth,
    //     shiftedRect.bottom - halfOutlineWidth,
    //     topLeft: outerBorderRadius.topLeft.clamp(minimum: Radius.zero),
    //     topRight: outerBorderRadius.topRight.clamp(minimum: Radius.zero),
    //     bottomRight: outerBorderRadius.bottomRight.clamp(minimum: Radius.zero),
    //     bottomLeft: outerBorderRadius.bottomLeft.clamp(minimum: Radius.zero),
    //   );

    //   final outlinePaint = Paint()
    //     ..style = PaintingStyle.stroke
    //     ..color = outlineColor
    //     ..strokeWidth = outlineWidth;

    //   context.canvas.drawRRect(outerRRect, outlinePaint);
    // } else {
    //   final rrect = borderRadius.toRRect(shiftedRect);
    //   context.canvas.drawRRect(rrect, containerPaint);
    // }
  }

  void _paintCheck(PaintingContext context, Rect shiftedRect) {
    final iconColor = this.iconColor.value;
    final iconPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = iconColor
      ..strokeWidth = iconStrokeWidth
      ..strokeCap = iconStrokeCap
      ..strokeJoin = iconStrokeJoin;

    final double checkFraction = this.checkFraction.value;
    final double crossCenterGravitation = this.crossCenterGravitation.value;

    if (checkFraction > 0.0) {
      const double leftX = 0.25;
      const double leftY = 0.5;

      const double middleX = 0.4;
      const double middleY = 0.65;
      const double rightX = 0.75;
      const double rightY = 0.3;

      final hasOvershoot = checkFraction > 1.0;

      final gravitatedMiddleX = lerpDouble(
        middleX,
        0.5,
        crossCenterGravitation,
      )!;
      final gravitatedMiddleY = lerpDouble(
        middleY,
        0.5,
        crossCenterGravitation,
      )!;
      // gravitate only Y for end to achieve center line
      final gravitatedLeftY = lerpDouble(leftY, 0.5, crossCenterGravitation)!;
      final gravitatedRightY = lerpDouble(rightY, 0.5, crossCenterGravitation)!;

      final scaledLeftX = iconSize * leftX;
      final scaledLeftY = iconSize * gravitatedLeftY;
      final scaledMiddleX = iconSize * gravitatedMiddleX;
      final scaledMiddleY = iconSize * gravitatedMiddleY;
      final scaledRightX = iconSize * rightX;
      final scaledRightY = iconSize * gravitatedRightY;

      final relativeLeftX = scaledMiddleX - scaledLeftX;
      final relativeLeftY = scaledMiddleY - scaledLeftY;
      final relativeRightX = scaledRightX - scaledMiddleX;
      final relativeRightY = scaledRightY - scaledMiddleY;
      final leftLength = math.sqrt(
        relativeLeftX * relativeLeftX + relativeLeftY * relativeLeftY,
      );
      final rightLength = math.sqrt(
        relativeRightX * relativeRightX + relativeRightY * relativeRightY,
      );
      final totalLength = leftLength + rightLength;
      assert(rightLength > 0.0);
      var extendedTotalLength = totalLength;
      var extendedRightLength = rightLength;
      var extendedRightX = scaledRightX;
      var extendedRightY = scaledRightY;
      if (hasOvershoot) {
        extendedTotalLength = totalLength * 2.0;
        extendedRightLength = extendedTotalLength - leftLength;
        extendedRightX =
            scaledMiddleX + relativeRightX / rightLength * extendedRightLength;
        extendedRightY =
            scaledMiddleY + relativeRightY / rightLength * extendedRightLength;
      }

      final fullPath = Path()
        ..moveTo(scaledLeftX, scaledLeftY)
        ..lineTo(scaledMiddleX, scaledMiddleY)
        ..lineTo(extendedRightX, extendedRightY);
      final checkPathMetric = fullPath.computeMetrics(forceClosed: false).first;
      // final totalLength2 = checkPathMetric.length;
      // final checkLength2 = hasOvershoot
      //     ? (totalLength - (extendedTotalLength - leftLength) + rightLength)
      //     : totalLength;

      final checkLength = totalLength;
      final segmentPath = checkPathMetric
          .extractPath(0.0, checkLength * checkFraction, startWithMoveTo: true)
          .shift(shiftedRect.topLeft);
      context.canvas.drawPath(segmentPath, iconPaint);
    }
  }

  void _paintChild(PaintingContext context) {
    if (child case final child?) {
      context.paintChild(child, (child.parentData! as BoxParentData).offset);
    }
  }

  void _paintChildFor(
    PaintingContext context,
    _CheckboxChildPosition position,
  ) {
    if (childPosition == position) {
      _paintChild(context);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final outerSize = _computeOuterSize();
    final innerRect = _computeInnerRect(outerSize);

    context.withCanvasTransform((context) {
      if (offset != Offset.zero) {
        context.canvas.translate(offset.dx, offset.dy);
      }

      // Paint the child below the container, if any
      _paintChildFor(context, .bottom);

      // Paint the container
      _paintBox(context, innerRect);

      // Paint the child between the container and the icon, if any
      _paintChildFor(context, .middle);

      // Paint the icon
      _paintCheck(context, innerRect);

      // Paint the child above the icon, if any
      _paintChildFor(context, .top);
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
