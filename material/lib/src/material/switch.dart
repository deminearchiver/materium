import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:material/src/material/flutter.dart';
import 'package:flutter/material.dart' as flutter;

typedef SwitchLegacy = flutter.Switch;
typedef SwitchThemeLegacy = flutter.SwitchTheme;
typedef SwitchThemeDataLegacy = flutter.SwitchThemeData;

class Switch extends StatefulWidget {
  const Switch({
    super.key,
    required this.onCheckedChanged,
    required this.checked,
  });

  final ValueChanged<bool>? onCheckedChanged;
  final bool checked;

  @override
  State<Switch> createState() => _SwitchState();
}

class _SwitchState extends State<Switch> with TickerProviderStateMixin {
  bool get _isSelected => widget.checked;

  late final WidgetStatesController _statesController;

  late AnimationController _handlePositionController;
  final Tween<double> _handlePositionTween = Tween<double>();
  late Animation<double> _handlePositionAnimation;

  late AnimationController _handleSizeController;
  final Tween<Size?> _handleSizeTween = SizeTween();
  late Animation<Size?> _handleSizeAnimation;

  late AnimationController _colorController;
  final Tween<Color?> _trackColorTween = ColorTween();
  final Tween<Color?> _outlineColorTween = ColorTween();
  final Tween<Color?> _handleColorTween = ColorTween();
  final Tween<Color?> _iconColorTween = ColorTween();
  late Animation<Color?> _trackColorAnimation;
  late Animation<Color?> _outlineColorAnimation;
  late Animation<Color?> _handleColorAnimation;
  late Animation<Color?> _iconColorAnimation;

  late ColorThemeData _colorTheme;
  late ShapeThemeData _shapeTheme;
  late StateThemeData _stateTheme;
  late SpringThemeData _springTheme;

  bool _pressed = false;
  bool _focused = false;

  WidgetStateProperty<Color> get _trackColor =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return _isSelected
            ? isDisabled
                  ? _colorTheme.onSurface.withValues(alpha: 0.1)
                  : _colorTheme.primary
            : isDisabled
            ? _colorTheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : _colorTheme.surfaceContainerHighest;
      });

  WidgetStateProperty<Color> get _handleColor =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return _isSelected
            ? isDisabled
                  ? _colorTheme.surface
                  : _colorTheme.onPrimary
            : isDisabled
            ? _colorTheme.onSurface.withValues(alpha: 0.38)
            : _colorTheme.outline;
      });

  WidgetStateProperty<double> get _outlineWidth =>
      const WidgetStatePropertyAll(2.0);

  WidgetStateProperty<Color> get _outlineColor =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return _isSelected
            ? isDisabled
                  ? _colorTheme.primary.withValues(alpha: 0.0)
                  : _colorTheme.primary
            : isDisabled
            ? _colorTheme.onSurface.withValues(alpha: 0.1)
            : _colorTheme.outline;
      });

  WidgetStateProperty<CornersGeometry> get _trackShape =>
      WidgetStatePropertyAll(Corners.all(_shapeTheme.corner.full));

  WidgetStateProperty<CornersGeometry> get _stateLayerShape =>
      WidgetStatePropertyAll(Corners.all(_shapeTheme.corner.full));

  WidgetStateProperty<Color> get _stateLayerColor =>
      WidgetStateProperty.resolveWith(
        (states) => _isSelected ? _colorTheme.primary : _colorTheme.onSurface,
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

  WidgetStateProperty<Size> get _handleSize =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return !isDisabled && states.contains(WidgetState.pressed)
            ? const Size.square(28.0)
            : const Size.square(24.0);
      });

  WidgetStateProperty<CornersGeometry> get _handleShape =>
      WidgetStatePropertyAll(Corners.all(_shapeTheme.corner.full));

  WidgetStateProperty<Color> get _iconColor =>
      WidgetStateProperty.resolveWith((states) {
        final isDisabled = states.contains(WidgetState.disabled);
        return _isSelected
            ? isDisabled
                  ? _colorTheme.onSurface.withValues(alpha: 0.38)
                  : _colorTheme.primary
            : isDisabled
            ? _colorTheme.surfaceContainerHighest.withValues(alpha: 0.38)
            : _colorTheme.surfaceContainerHighest;
      });

  void _updateHandlePositionAnimation({required double handlePosition}) {
    if (handlePosition == _handlePositionTween.end) {
      return;
    }

    _handlePositionTween.begin = _handlePositionAnimation.value;
    _handlePositionTween.end = handlePosition;

    if (_handlePositionTween.begin == _handlePositionTween.end) {
      return;
    }

    final simulation = SpringSimulation(
      _springTheme.fastSpatial.toSpringDescription(),
      0.0,
      1.0,
      0.0,
    );
    _handlePositionController.animateWith(simulation);
  }

  void _updateHandleSizeAnimation({required Size handleSize}) {
    if (handleSize == _handleSizeTween.end) {
      return;
    }

    _handleSizeTween.begin = _handleSizeAnimation.value ?? handleSize;
    _handleSizeTween.end = handleSize;

    if (_handleSizeTween.begin == _handleSizeTween.end) {
      return;
    }

    final simulation = SpringSimulation(
      _springTheme.fastEffects.toSpringDescription(),
      0.0,
      1.0,
      0.0,
    );
    _handleSizeController.animateWith(simulation);
  }

  void _updateColorAnimations({
    required Color trackColor,
    required Color outlineColor,
    required Color handleColor,
    required Color iconColor,
  }) {
    // The animation is already in progress.
    // There is no point in triggering it again
    // because it would animate to the same value.
    if (trackColor == _trackColorTween.end &&
        outlineColor == _outlineColorTween.end &&
        handleColor == _handleColorTween.end &&
        iconColor == _iconColorTween.end) {
      return;
    }

    _trackColorTween.begin = _trackColorAnimation.value ?? trackColor;
    _trackColorTween.end = trackColor;
    _outlineColorTween.begin = _outlineColorAnimation.value ?? outlineColor;
    _outlineColorTween.end = outlineColor;
    _handleColorTween.begin = _handleColorAnimation.value ?? handleColor;
    _handleColorTween.end = handleColor;
    _iconColorTween.begin = _iconColorAnimation.value ?? iconColor;
    _iconColorTween.end = iconColor;

    // We don't have to animate between states
    // if the initial state is the same as the target state.
    if (_trackColorTween.begin == _trackColorTween.end &&
        _outlineColorTween.begin == _outlineColorTween.end &&
        _handleColorTween.begin == _handleColorTween.end &&
        _iconColorTween.begin == _iconColorTween.end) {
      _colorController.value = 1.0;
      return;
    }

    _colorController.value = 0.0;
    _colorController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 67),
      curve: const EasingThemeData.fallback().linear,
    );
  }

  /// This method returns a [UnmodifiableSetView] over
  /// [WidgetStatesController.value]. The returned collection must not be used
  /// if changes were made to the [WidgetStatesController.value]. In that case,
  /// this method must be called again to update [WidgetStatesController.value]
  /// according to internal state.
  ///
  /// Returns an [UnmodifiableSetView].
  Set<WidgetState> _resolveStates() {
    final states = _statesController.value;

    final isDisabled = widget.onCheckedChanged == null;

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
    // The set view returned must be used while no mutations are
    // made to the parent.
    return UnmodifiableSetView(states);
  }

  void _statesListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController()..addListener(_statesListener);

    final handlePosition = _isSelected ? 1.0 : 0.0;
    _handlePositionTween.begin = handlePosition;
    _handlePositionTween.end = handlePosition;

    _handlePositionController = AnimationController.unbounded(
      vsync: this,
      value: 1.0,
    );
    _handlePositionAnimation = _handlePositionTween.animate(
      _handlePositionController,
    );

    _handleSizeController = AnimationController.unbounded(
      vsync: this,
      value: 1.0,
    );
    _handleSizeAnimation = _handleSizeTween.animate(_handleSizeController);

    _colorController = AnimationController(vsync: this, value: 1.0);
    _trackColorAnimation = _trackColorTween.animate(_colorController);
    _outlineColorAnimation = _outlineColorTween.animate(_colorController);
    _handleColorAnimation = _handleColorTween.animate(_colorController);
    _iconColorAnimation = _iconColorTween.animate(_colorController);
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
    _handleSizeController.dispose();
    _handlePositionController.dispose();
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final states = _resolveStates();
    final isDisabled = states.contains(WidgetState.disabled);
    final outlineWidth = _outlineWidth.resolve(states);
    final outlineColor = _outlineColor.resolve(states);
    final trackColor = _trackColor.resolve(states);
    final trackCorners = _trackShape.resolve(states);
    final stateLayerCorners = _stateLayerShape.resolve(states);
    final handleSize = _handleSize.resolve(states);
    final handleColor = _handleColor.resolve(states);
    final handleCorners = _handleShape.resolve(states);
    final iconColor = _iconColor.resolve(states);

    const minTapTargetSize = Size(48.0, 48.0);
    const stateLayerSize = 40.0;
    const trackSize = Size(52.0, 32.0);

    final stateLayerShape = CornersBorder.rounded(corners: stateLayerCorners);
    final handleShape = CornersBorder.rounded(corners: handleCorners);

    final handlePosition = _isSelected ? 1.0 : 0.0;

    _updateHandlePositionAnimation(handlePosition: handlePosition);
    _updateHandleSizeAnimation(handleSize: handleSize);
    _updateColorAnimations(
      trackColor: trackColor,
      outlineColor: outlineColor,
      handleColor: handleColor,
      iconColor: iconColor,
    );

    final trackChild = SizedBox.square(
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
            onTap: !isDisabled
                ? () => widget.onCheckedChanged?.call(!_isSelected)
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

    final handleChild = Align.center(
      child: AnimatedBuilder(
        animation: _colorController,
        builder: (context, child) {
          final resolvedIconColor = _iconColorAnimation.value ?? iconColor;
          final resolvedIconOpacity = _colorController.value;
          return IconTheme.merge(
            // We cannot use Opacity here because of an assertion error that
            // occurs due to us keeping track of canvas save count.
            data: IconThemeDataPartial.from(
              color: resolvedIconOpacity < 1.0
                  ? resolvedIconColor.withValues(
                      alpha: resolvedIconColor.a * resolvedIconOpacity,
                    )
                  : resolvedIconColor,
              fill: 0.0,
              grade: 0.0,
              size: 16.0,
              opticalSize: 24.0,
              weight: 400.0,
            ),
            child: child!,
          );
        },

        child: _isSelected
            ? const Icon(Symbols.check_rounded, applyTextScaling: false)
            : const Icon(Symbols.close_rounded, applyTextScaling: false),
      ),
    );

    return RepaintBoundary(
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
            data: FocusRingThemeDataPartial.from(shape: trackCorners),
            child: FocusRing(
              visible: states.contains(WidgetState.focused),
              placement: FocusRingPlacement.outward,
              layoutBuilder: (context, info, child) => Align.center(
                child: SizedBox.fromSize(size: trackSize, child: child),
              ),
              child: _SwitchPaint(
                handlePosition: _handlePositionAnimation,
                trackShape: _outlineColorAnimation
                    .nonNullOr(outlineColor)
                    .mapValue(
                      (value) => CornersBorder.rounded(
                        corners: trackCorners,
                        side: BorderSide(
                          width: outlineWidth,
                          color: _outlineColorAnimation.value!,
                          strokeAlign: BorderSide.strokeAlignInside,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                trackColor: _trackColorAnimation.nonNullOr(trackColor),
                minTapTargetSize: minTapTargetSize,
                trackSize: trackSize,
                handleSize: _handleSizeAnimation.nonNullOr(handleSize),
                handleShape: handleShape,
                handleColor: _handleColorAnimation.nonNullOr(handleColor),
                childrenPaintOrder: .handleChildIsTop,
                trackChildPosition: .middle,
                trackChild: trackChild,
                handleChildPosition: .top,
                handleChild: handleChild,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _SwitchSlot { trackChild, handleChild }

enum SwitchChildPosition { bottom, middle, top }

enum _SwitchChildrenPaintOrder { trackChildIsTop, handleChildIsTop }

class _SwitchPaint
    extends SlottedMultiChildRenderObjectWidget<_SwitchSlot, RenderBox> {
  const _SwitchPaint({
    // ignore: unused_element_parameter
    super.key,
    required this.handlePosition,
    required this.minTapTargetSize,
    required this.trackSize,
    required this.trackShape,
    required this.trackColor,
    required this.handleSize,
    required this.handleShape,
    required this.handleColor,
    required this.childrenPaintOrder,
    required this.trackChildPosition,
    this.trackChild,
    required this.handleChildPosition,
    this.handleChild,
  });

  final ValueListenable<double> handlePosition;
  final Size minTapTargetSize;

  // Track
  final Size trackSize;
  final ValueListenable<ShapeBorder> trackShape;
  final ValueListenable<Color> trackColor;

  // Handle
  final ValueListenable<Size> handleSize;
  final ShapeBorder handleShape;
  final ValueListenable<Color> handleColor;

  final _SwitchChildrenPaintOrder childrenPaintOrder;
  final SwitchChildPosition trackChildPosition;
  final Widget? trackChild;
  final SwitchChildPosition handleChildPosition;
  final Widget? handleChild;

  @override
  Iterable<_SwitchSlot> get slots => _SwitchSlot.values;

  @override
  Widget? childForSlot(_SwitchSlot slot) => switch (slot) {
    .trackChild => trackChild,
    .handleChild => handleChild,
  };

  @override
  _RenderSwitchPaint createRenderObject(BuildContext context) {
    return _RenderSwitchPaint(
      handlePosition: handlePosition,
      minTapTargetSize: minTapTargetSize,
      trackSize: trackSize,
      trackShape: trackShape,
      trackColor: trackColor,
      handleSize: handleSize,
      handleShape: handleShape,
      handleColor: handleColor,
      childrenPaintOrder: childrenPaintOrder,
      trackChildPosition: trackChildPosition,
      handleChildPosition: handleChildPosition,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSwitchPaint renderObject,
  ) {
    renderObject
      ..handlePosition = handlePosition
      ..minTapTargetSize = minTapTargetSize
      ..trackSize = trackSize
      ..trackShape = trackShape
      ..trackColor = trackColor
      ..handleSize = handleSize
      ..handleShape = handleShape
      ..handleColor = handleColor
      ..childrenPaintOrder = childrenPaintOrder
      ..trackChildPosition = trackChildPosition
      ..handleChildPosition = handleChildPosition
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderSwitchPaint extends RenderBox
    with SlottedContainerRenderObjectMixin<_SwitchSlot, RenderBox> {
  _RenderSwitchPaint({
    required ValueListenable<double> handlePosition,
    required Size minTapTargetSize,
    // Track
    required Size trackSize,
    required ValueListenable<ShapeBorder> trackShape,
    required ValueListenable<Color> trackColor,
    // Handle
    required ValueListenable<Size> handleSize,
    required ShapeBorder handleShape,
    required ValueListenable<Color> handleColor,
    // Children
    required _SwitchChildrenPaintOrder childrenPaintOrder,
    required SwitchChildPosition trackChildPosition,
    required SwitchChildPosition handleChildPosition,
    // Context
    TextDirection? textDirection,
  }) : _handlePosition = handlePosition,
       _minTapTargetSize = minTapTargetSize,
       _trackSize = trackSize,
       _trackShape = trackShape,
       _trackColor = trackColor,
       _handleSize = handleSize,
       _handleShape = handleShape,
       _handleColor = handleColor,
       _textDirection = textDirection,
       _childrenPaintOrder = childrenPaintOrder,
       _trackChildPosition = trackChildPosition,
       _handleChildPosition = handleChildPosition;

  ValueListenable<double> _handlePosition;
  ValueListenable<double> get handlePosition => _handlePosition;
  set handlePosition(ValueListenable<double> value) {
    if (_handlePosition == value) return;
    _handlePosition.removeListener(markNeedsLayout);
    _handlePosition = value;
    _handlePosition.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  Size _minTapTargetSize;
  Size get minTapTargetSize => _minTapTargetSize;
  set minTapTargetSize(Size value) {
    if (_minTapTargetSize == value) return;
    _minTapTargetSize = value;
    markNeedsLayout();
  }

  Size _trackSize;
  Size get trackSize => _trackSize;
  set trackSize(Size value) {
    if (_trackSize == value) return;
    _trackSize = value;
    markNeedsLayout();
  }

  ValueListenable<ShapeBorder> _trackShape;
  ValueListenable<ShapeBorder> get trackShape => _trackShape;
  set trackShape(ValueListenable<ShapeBorder> value) {
    if (_trackShape == value) return;
    _trackShape.removeListener(markNeedsPaint);
    _trackShape = value;
    _trackShape.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  ValueListenable<Color> _trackColor;
  ValueListenable<Color> get trackColor => _trackColor;
  set trackColor(ValueListenable<Color> value) {
    if (_trackColor == value) return;
    _trackColor.removeListener(markNeedsPaint);
    _trackColor = value;
    _trackColor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  ValueListenable<Size> _handleSize;
  ValueListenable<Size> get handleSize => _handleSize;
  set handleSize(ValueListenable<Size> value) {
    if (_handleSize == value) return;
    _handleSize.removeListener(markNeedsLayout);
    _handleSize = value;
    _handleSize.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  ShapeBorder _handleShape;
  ShapeBorder get handleShape => _handleShape;
  set handleShape(ShapeBorder value) {
    if (_handleShape == value) return;
    _handleShape = value;
    markNeedsPaint();
  }

  ValueListenable<Color> _handleColor;
  ValueListenable<Color> get handleColor => _handleColor;
  set handleColor(ValueListenable<Color> value) {
    if (_handleColor == value) return;
    _handleColor.removeListener(markNeedsPaint);
    _handleColor = value;
    _handleColor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  _SwitchChildrenPaintOrder _childrenPaintOrder;
  _SwitchChildrenPaintOrder get childrenPaintOrder => _childrenPaintOrder;
  set childrenPaintOrder(_SwitchChildrenPaintOrder value) {
    if (_childrenPaintOrder == value) return;
    _childrenPaintOrder = value;
    markNeedsPaint();
  }

  SwitchChildPosition _trackChildPosition;
  SwitchChildPosition get trackChildPosition => _trackChildPosition;
  set trackChildPosition(SwitchChildPosition value) {
    if (_trackChildPosition == value) return;
    _trackChildPosition = value;
    markNeedsPaint();
  }

  SwitchChildPosition _handleChildPosition;
  SwitchChildPosition get handleChildPosition => _handleChildPosition;
  set handleChildPosition(SwitchChildPosition value) {
    if (_handleChildPosition == value) return;
    _handleChildPosition = value;
    markNeedsPaint();
  }

  TextDirection? _textDirection;
  TextDirection? get textDirection => _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
  }

  RenderBox? get _trackChild => childForSlot(.trackChild);

  RenderBox? get _handleChild => childForSlot(.handleChild);

  Size _computeOuterSize() {
    return Size(
      math.max(
        trackSize.width,
        // This calculation was derived from handle center equations
        trackSize.width - trackSize.shortestSide + minTapTargetSize.width,
      ),
      math.max(trackSize.height, minTapTargetSize.height),
    );
  }

  Rect _computeInnerRect(Size outerSize) {
    assert(
      outerSize.width >= trackSize.width &&
          outerSize.height >= trackSize.height,
    );
    return Rect.fromLTWH(
      (outerSize.width - trackSize.width) / 2.0,
      (outerSize.height - trackSize.height) / 2.0,
      trackSize.width,
      trackSize.height,
    );
  }

  // Offset _computeHandleInnerCenter() {}
  Offset _computeHandleOuterCenter(Rect innerRect) {
    final innerCenterStart = trackSize.shortestSide / 2.0;
    final outerCenterStart = innerRect.left + innerCenterStart;
    final innerCenterEnd = trackSize.width - innerCenterStart;
    final outerCenterEnd = innerRect.left + innerCenterEnd;
    return Offset(
      lerpDouble(outerCenterStart, outerCenterEnd, _handlePosition.value)!,
      innerRect.top + innerRect.height / 2.0,
    );
  }

  Rect _computeHandleRect(Offset center) {
    final handleSize = this.handleSize.value;
    return Rect.fromLTWH(
      center.dx - handleSize.width / 2.0,
      center.dy - handleSize.height / 2.0,
      handleSize.width,
      handleSize.height,
    );
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _handlePosition.addListener(markNeedsLayout);
    _trackShape.addListener(markNeedsPaint);
    _trackColor.addListener(markNeedsPaint);
    _handleSize.addListener(markNeedsLayout);
    _handleColor.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _handleColor.removeListener(markNeedsPaint);
    _handleSize.removeListener(markNeedsLayout);
    _trackColor.removeListener(markNeedsPaint);
    _trackShape.removeListener(markNeedsPaint);
    _handlePosition.removeListener(markNeedsLayout);
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
    final innerRect = _computeInnerRect(outerSize);

    final outerCenter = _computeHandleOuterCenter(innerRect);
    if (_trackChild case final trackChild?) {
      layoutChild(
        trackChild,
        BoxConstraints(
          minWidth: 0.0,
          minHeight: 0.0,
          maxWidth: minTapTargetSize.width,
          maxHeight: minTapTargetSize.height,
        ),
      );
      final trackChildSize = trackChild.size;
      positionChild(
        trackChild,
        Offset(
          outerCenter.dx - trackChildSize.width / 2.0,
          outerCenter.dy - trackChildSize.height / 2.0,
        ),
      );
    }
    if (_handleChild case final handleChild?) {
      final handleSize = this.handleSize.value;
      layoutChild(
        handleChild,
        BoxConstraints(
          minWidth: 0.0,
          minHeight: 0.0,
          maxWidth: handleSize.width,
          maxHeight: handleSize.height,
        ),
      );
      final handleChildSize = handleChild.size;
      positionChild(
        handleChild,
        Offset(
          outerCenter.dx - handleChildSize.width / 2.0,
          outerCenter.dy - handleChildSize.height / 2.0,
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
    covariant BoxConstraints constraints,
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

  void _paintTrack(PaintingContext context, Rect shiftedRect) {
    final trackPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = trackColor.value;
    trackShape.value
      ..paintInterior(context.canvas, shiftedRect, trackPaint)
      ..paint(context.canvas, shiftedRect);
  }

  void _paintTrackChild(PaintingContext context) {
    if (_trackChild case final trackChild?) {
      context.paintChild(
        trackChild,
        (trackChild.parentData! as BoxParentData).offset,
      );
    }
  }

  void _paintHandle(PaintingContext context, Rect shiftedRect) {
    final handlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = handleColor.value;
    handleShape
      ..paintInterior(context.canvas, shiftedRect, handlePaint)
      ..paint(context.canvas, shiftedRect);
  }

  void _paintHandleChild(PaintingContext context) {
    if (_handleChild case final handleChild?) {
      context.paintChild(
        handleChild,
        (handleChild.parentData! as BoxParentData).offset,
      );
    }
  }

  void _paintChildFor(PaintingContext context, SwitchChildPosition position) {
    if (trackChildPosition == position && handleChildPosition == position) {
      switch (childrenPaintOrder) {
        case .trackChildIsTop:
          _paintHandleChild(context);
          _paintTrackChild(context);
        case .handleChildIsTop:
          _paintTrackChild(context);
          _paintHandleChild(context);
      }
    } else if (trackChildPosition == position) {
      _paintTrackChild(context);
    } else if (handleChildPosition == position) {
      _paintHandleChild(context);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final innerRect = _computeInnerRect(size);
    final outerCenter = _computeHandleOuterCenter(innerRect);
    final handleRect = _computeHandleRect(outerCenter);

    context.withCanvasTransform((context) {
      if (offset != Offset.zero) {
        context.canvas.translate(offset.dx, offset.dy);
      }

      // Paint the child below the track, if any
      _paintChildFor(context, .bottom);

      // Paint the track
      _paintTrack(context, innerRect);

      // Paint the child between the track and the handle, if any
      _paintChildFor(context, .middle);

      // Paint the handle
      _paintHandle(context, handleRect);

      // Paint the child above the handle, if any
      _paintChildFor(context, .top);
    });
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }
    final trackChild = _trackChild;
    if (trackChild == null) {
      return false;
    }
    final Offset center = trackChild.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) {
        assert(position == center);
        return trackChild.hitTest(result, position: center);
      },
    );
  }
}
