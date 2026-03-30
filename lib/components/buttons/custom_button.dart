part of 'buttons.dart';

enum _ButtonContentMode { inherited, adaptive, custom }

class ButtonContent extends StatelessWidget {
  const ButtonContent({
    super.key,
    this.padding,
    this.spacing,
    this.icon,
    this.label,
  }) : assert(icon != null || label != null),
       _mode = .inherited;

  const ButtonContent.adaptive({
    super.key,
    this.padding,
    this.spacing,
    this.icon,
    this.label,
  }) : assert(icon != null || label != null),
       _mode = .adaptive;

  const ButtonContent.custom({
    super.key,
    EdgeInsetsGeometry this.padding = .zero,
    double this.spacing = 0.0,
    this.icon,
    this.label,
  }) : assert(icon != null || label != null),
       _mode = .custom;

  final _ButtonContentMode _mode;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final Widget? icon;
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    final scope = _mode != .custom
        ? _ButtonContentScope.maybeOf(context)
        : null;
    return Padding(
      padding: padding ?? scope?.padding ?? .zero,
      child: Flex.horizontal(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        spacing: spacing ?? scope?.iconLabelSpace ?? 0.0,
        children: [?icon, ?label],
      ),
    );
  }
}

class ButtonContainer<S extends Object?> extends StatefulWidget {
  const ButtonContainer({
    super.key,
    required this.style,
    required this.settings,
    this.isSelected,
    required this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    required this.child,
  });

  final ButtonStyle<S> style;
  final S settings;
  final bool? isSelected;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final Widget child;

  bool get _isDisabled =>
      onTap == null &&
      onDoubleTap == null &&
      onLongPress == null &&
      onSecondaryTap == null;

  @override
  State<ButtonContainer<S>> createState() => _ButtonContainerState<S>();
}

class _ButtonContainerState<S extends Object?> extends State<ButtonContainer<S>>
    with TickerProviderStateMixin {
  late WidgetStatesController _statesController;

  late DefaultTextStyle _defaultTextStyle;
  late SpringThemeData _springTheme;
  late IconThemeData _iconTheme;

  late OutlinedBorder _containerShape;
  late Color _containerColor;
  late Outline _containerOutline;
  late double _containerElevation;
  late Color _containerShadowColor;
  late IconThemeData _resolvedIconTheme;
  late TextStyle _resolvedLabelTextStyle;

  late SpringDescription _spatialSpring;
  late AnimationController _spatialController;

  final Tween<OutlinedBorder?> _containerShapeTween = OutlinedBorderTween();
  late Animation<OutlinedBorder?> _containerShapeAnimation;

  late SpringDescription _effectsSpring;
  late AnimationController _effectsController;

  final Tween<Color?> _containerColorTween = ColorTween();
  late Animation<Color?> _containerColorAnimation;

  final Tween<Outline?> _containerOutlineTween = OutlineTween();
  late Animation<Outline?> _containerOutlineAnimation;

  final Tween<double> _containerElevationTween = Tween<double>();
  late Animation<double> _containerElevationAnimation;

  final Tween<Color?> _containerShadowColorTween = ColorTween();
  late Animation<Color?> _containerShadowColorAnimation;

  final Tween<IconThemeData?> _iconThemeTween = IconThemeDataTween();
  late Animation<IconThemeData?> _iconThemeAnimation;

  final Tween<TextStyle?> _labelTextStyleTween = _TextStyleTween();
  late Animation<TextStyle?> _labelTextStyleAnimation;

  late Listenable _spatialEffectsListenable;

  // late Animation<OutlinedBorder> _resolvedContainerShapeAnimation;
  // late Animation<Color> _resolvedContainerColorAnimation;
  // late Animation<Color> _resolvedContainerShadowColorAnimation;
  // late Animation<IconThemeData> _resolvedIconThemeAnimation;
  // late Animation<TextStyle> _resolvedLabelTextStyleAnimation;

  var _focused = false;
  var _pressed = false;

  _ButtonStates<S>? _lastStates;
  late _ButtonStates<S> _states;

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  SpringSimulation _createImplicitSpringSimulation(SpringDescription spring) =>
      SpringSimulation(spring, 0.0, 1.0, 0.0, snapToEnd: true);

  void _updateSpatialAnimations({required OutlinedBorder containerShape}) {
    if (containerShape == _containerShapeTween.end) {
      return;
    }

    _containerShapeTween
      ..begin = _containerShapeAnimation.value
      ..end = containerShape;

    if (_states == _lastStates) {
      _spatialController.value = 1.0;
      return;
    }

    if (_containerShapeTween.begin == _containerShapeTween.end) {
      _spatialController.value = 1.0;
      return;
    }

    final simulation = _createImplicitSpringSimulation(_spatialSpring);
    unawaited(_spatialController.animateWith(simulation));
  }

  void _updateEffectsAnimation({
    required Color containerColor,
    required Outline containerOutline,
    required double containerElevation,
    required Color containerShadowColor,
    required IconThemeData iconTheme,
    required TextStyle labelTextStyle,
  }) {
    if (containerColor == _containerColorTween.end &&
        containerOutline == _containerOutlineTween.end &&
        containerElevation == _containerElevationTween.end &&
        containerShadowColor == _containerShadowColorTween.end &&
        iconTheme == _iconThemeTween.end &&
        labelTextStyle == _labelTextStyleTween.end) {
      return;
    }

    _containerColorTween
      ..begin = _containerColorAnimation.value ?? containerColor
      ..end = containerColor;
    _containerOutlineTween
      ..begin = _containerOutlineAnimation.value ?? containerOutline
      ..end = containerOutline;
    _containerElevationTween
      ..begin = _containerElevationAnimation.value
      ..end = containerElevation;
    _containerShadowColorTween
      ..begin = _containerShadowColorAnimation.value ?? containerShadowColor
      ..end = containerShadowColor;
    _iconThemeTween
      ..begin = _iconThemeAnimation.value ?? iconTheme
      ..end = iconTheme;
    _labelTextStyleTween
      ..begin = _labelTextStyleAnimation.value ?? labelTextStyle
      ..end = labelTextStyle;

    if (_states == _lastStates) {
      _effectsController.value = 1.0;
      return;
    }

    if (_containerColorTween.begin == _containerColorTween.end &&
        _containerOutlineTween.begin == _containerOutlineTween.end &&
        _containerElevationTween.begin == _containerElevationTween.end &&
        _containerShadowColorTween.begin == _containerShadowColorTween.end &&
        _iconThemeTween.begin == _iconThemeTween.end &&
        _labelTextStyleTween.begin == _labelTextStyleTween.end) {
      return;
    }

    final simulation = _createImplicitSpringSimulation(_effectsSpring);
    unawaited(_effectsController.animateWith(simulation));
  }

  void _resolveStates() {
    final states = _statesController.value as StrictSet<WidgetState>;

    final isSelected = widget.isSelected;
    final isDisabled = widget._isDisabled;

    final _ButtonStates<S> result = isSelected != null
        ? isDisabled
              ? _ToggleButtonStates.disabled(
                  settings: widget.settings,
                  isSelected: isSelected,
                )
              : _ToggleButtonStates.enabled(
                  settings: widget.settings,
                  isSelected: isSelected,
                  isHovered: states.contains(.hovered),
                  isFocused: _focused && !_pressed,
                  isPressed: _pressed,
                )
        : isDisabled
        ? _DefaultButtonStates.disabled(settings: widget.settings)
        : _DefaultButtonStates.enabled(
            settings: widget.settings,
            isHovered: states.contains(.hovered),
            isFocused: _focused && !_pressed,
            isPressed: _pressed,
          );

    if (result.isSelected == true) {
      states.add(.selected);
    }

    if (result.isDisabled) {
      states.add(.disabled);
    } else {
      states.remove(.disabled);
    }
    if (result.isHovered) {
      states.add(.pressed);
    } else {
      states.remove(.pressed);
    }
    if (result.isFocused) {
      states.add(.focused);
    } else {
      states.remove(.focused);
    }
    if (result.isPressed) {
      states.add(.pressed);
    } else {
      states.remove(.pressed);
    }

    _states = result;
  }

  void _statesListener() {
    setState(() {});
  }

  void _onPointerDown(PointerDownEvent _) {
    if (!mounted) return;
    setState(() {
      _focused = false;
      _pressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent _) {
    if (!mounted) return;
    setState(() {
      _focused = false;
      _pressed = false;
    });
  }

  void _onPointerCancel(PointerCancelEvent _) {
    if (!mounted) return;
    setState(() {
      _focused = false;
      _pressed = false;
    });
  }

  void _onTapDown(TapDownDetails _) {
    if (!mounted) return;
    setState(() {
      _focused = false;
      _pressed = true;
    });
  }

  void _onTapUp(TapUpDetails _) {
    if (!mounted) return;
    setState(() {
      _focused = false;
      _pressed = false;
    });
  }

  void _onTapCancel() {
    if (!mounted) return;
    setState(() {
      _focused = false;
      _pressed = false;
    });
  }

  void _onFocusChange(bool value) {
    if (!mounted) return;
    setState(() => _focused = value);
  }

  void _onTapOutside(PointerEvent _) {
    if (!mounted) return;
    setState(() {
      _focused = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _statesController = WidgetStatesController()..addListener(_statesListener);

    _containerElevationTween
      ..begin = 0.0
      ..end = 0.0;

    _spatialController = AnimationController.unbounded(vsync: this, value: 1.0);
    _effectsController = AnimationController(vsync: this, value: 1.0);
    _spatialEffectsListenable = Listenable.merge([
      _spatialController,
      _effectsController,
    ]);

    _containerShapeAnimation = _containerShapeTween.animate(_spatialController);
    _containerColorAnimation = _containerColorTween.animate(_effectsController);
    _containerOutlineAnimation = _containerOutlineTween.animate(
      _effectsController,
    );
    _containerElevationAnimation = _containerElevationTween.animate(
      _effectsController,
    );
    _containerShadowColorAnimation = _containerShadowColorTween.animate(
      _effectsController,
    );
    _iconThemeAnimation = _iconThemeTween.animate(_effectsController);
    _labelTextStyleAnimation = _labelTextStyleTween.animate(_effectsController);

    // TODO: listen to both spatial and effects animation controllers.
    // _resolvedContainerShapeAnimation = _containerShapeAnimation
    //     .nonNullOrElse(() => _containerShape)
    //     .mapValue(
    //       (value) => (_containerOutlineAnimation.value ?? _containerOutline)
    //           .apply(value),
    //     );

    // _resolvedContainerColorAnimation = _containerColorAnimation.nonNullOrElse(
    //   () => _containerColor,
    // );

    // _resolvedContainerShadowColorAnimation = _containerShadowColorAnimation
    //     .nonNullOrElse(() => _containerShadowColor);

    // _resolvedIconThemeAnimation = _iconThemeAnimation.nonNullOrElse(
    //   () => _resolvedIconTheme,
    // );

    // _resolvedLabelTextStyleAnimation = _labelTextStyleAnimation.nonNullOrElse(
    //   () => _resolvedLabelTextStyle,
    // );
  }

  @override
  void didUpdateWidget(covariant ButtonContainer<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _defaultTextStyle = DefaultTextStyle.of(context);
    _springTheme = SpringTheme.of(context);
    _iconTheme = IconTheme.of(context);

    _spatialSpring = _springTheme.fastSpatial.toSpringDescription();
    _effectsSpring = _springTheme.defaultEffects.toSpringDescription();
  }

  @override
  void dispose() {
    _effectsController.dispose();
    _spatialController.dispose();
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _resolveStates();

    final minTapTargetSize = widget.style.minTapTargetSize.resolve(_states);
    final constraints = widget.style.constraints.resolve(_states);
    final padding = widget.style.padding.resolve(_states);
    final iconLabelSpace = widget.style.iconLabelSpace.resolve(_states);
    _containerShape = widget.style.containerShape.resolve(_states);
    _containerColor = widget.style.containerColor.resolve(_states);
    _containerOutline = widget.style.containerOutline.resolve(_states);
    _containerElevation = widget.style.containerElevation.resolve(_states);
    _containerShadowColor = widget.style.containerShadowColor.resolve(_states);
    final stateLayerColor = widget.style.stateLayerColor;
    final stateLayerOpacity = widget.style.stateLayerOpacity;
    _resolvedIconTheme = _iconTheme.merge(
      widget.style.iconTheme.resolve(_states),
    );
    _resolvedLabelTextStyle = _defaultTextStyle.style.merge(
      widget.style.labelTextStyle.resolve(_states),
    );

    final overlayColor = MixedWidgetStateLayerColor<ButtonStates<S>>.from(
      (widgetStates) => _DefaultButtonStates.fromWidgetStates(
        widgetStates,
        settings: widget.settings,
      ),
      color: stateLayerColor,
      opacity: stateLayerOpacity,
    );

    _updateSpatialAnimations(containerShape: _containerShape);

    _updateEffectsAnimation(
      containerColor: _containerColor,
      containerOutline: _containerOutline,
      containerElevation: _containerElevation,
      containerShadowColor: _containerShadowColor,
      iconTheme: _resolvedIconTheme,
      labelTextStyle: _resolvedLabelTextStyle,
    );

    _lastStates = _states;

    return RepaintBoundary(
      child: Semantics(
        container: true,
        button: true,
        enabled: !_states.isDisabled,
        child: _InputPadding(
          minTapTargetSize: minTapTargetSize,
          child: ConstrainedBox(
            constraints: constraints,
            child: AnimatedBuilder(
              animation: _spatialController,
              builder: (context, child) => FocusRingTheme.merge(
                data: .from(
                  shape: .all(
                    _containerShapeAnimation.value ?? _containerShape,
                  ),
                ),
                child: child!,
              ),
              child: FocusRing(
                visible: _states.isFocused,
                placement: .outward,
                child: TapRegion(
                  behavior: .deferToChild,
                  consumeOutsideTaps: false,
                  onTapOutside: !_states.isDisabled ? _onTapOutside : null,
                  onTapUpOutside: !_states.isDisabled ? _onTapOutside : null,
                  child: Listener(
                    behavior: .deferToChild,
                    onPointerDown: !_states.isDisabled ? _onPointerDown : null,
                    onPointerUp: !_states.isDisabled ? _onPointerUp : null,
                    onPointerCancel: !_states.isDisabled
                        ? _onPointerCancel
                        : null,
                    child: AnimatedBuilder(
                      animation: _spatialEffectsListenable,
                      builder: (context, child) {
                        final resolvedContainerShape =
                            (_containerOutlineAnimation.value ??
                                    _containerOutline)
                                .apply(
                                  _containerShapeAnimation.value ??
                                      _containerShape,
                                );
                        return Material(
                          clipBehavior: .antiAlias,
                          borderOnForeground: false,
                          shape: resolvedContainerShape,
                          color:
                              _containerColorAnimation.value ?? _containerColor,
                          elevation: _containerElevationAnimation.value,
                          shadowColor:
                              _containerShadowColorAnimation.value ??
                              _containerShadowColor,
                          child: child,
                        );
                      },
                      child: InkWell(
                        statesController: _statesController,
                        overlayColor: overlayColor,
                        enableFeedback: !_states.isDisabled,
                        onTap: !_states.isDisabled ? widget.onTap : null,
                        onDoubleTap: !_states.isDisabled
                            ? widget.onDoubleTap
                            : null,
                        onLongPress: !_states.isDisabled
                            ? widget.onLongPress
                            : null,
                        onSecondaryTap: !_states.isDisabled
                            ? widget.onSecondaryTap
                            : null,
                        onTapDown: !_states.isDisabled ? _onTapDown : null,
                        onTapUp: !_states.isDisabled ? _onTapUp : null,
                        onTapCancel: !_states.isDisabled ? _onTapCancel : null,
                        onFocusChange: !_states.isDisabled
                            ? _onFocusChange
                            : null,
                        child: Align.center(
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: AnimatedBuilder(
                            animation: _effectsController,
                            builder: (context, child) => DefaultTextStyle(
                              style:
                                  _labelTextStyleAnimation.value ??
                                  _resolvedLabelTextStyle,
                              child: IconTheme(
                                data:
                                    _iconThemeAnimation.value ??
                                    _resolvedIconTheme,
                                child: child!,
                              ),
                            ),
                            child: _ButtonContentScope(
                              padding: padding,
                              iconLabelSpace: iconLabelSpace,
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
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

class _ButtonContentScope extends InheritedWidget {
  const _ButtonContentScope({
    super.key,
    required this.padding,
    required this.iconLabelSpace,
    required super.child,
  });

  final EdgeInsetsGeometry padding;
  final double iconLabelSpace;

  @override
  bool updateShouldNotify(_ButtonContentScope oldWidget) =>
      padding != oldWidget.padding ||
      iconLabelSpace != oldWidget.iconLabelSpace;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>("padding", padding))
      ..add(DoubleProperty("iconLabelSpace", iconLabelSpace));
  }

  static _ButtonContentScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ButtonContentScope>();

  static _ButtonContentScope of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null);
    return result!;
  }
}
