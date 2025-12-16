import 'package:materium/flutter.dart';

class _InverseCenterOptically extends CenterOptically {
  const _InverseCenterOptically({
    super.key,
    super.enabled,
    super.corners,
    super.maxOffsets,
    super.textDirection,
    super.child,
  });

  @override
  _RenderInverseCenterOptically createRenderObject(BuildContext context) =>
      _RenderInverseCenterOptically(
        enabled: enabled,
        corners: corners,
        maxOffsets: maxOffsets,
        textDirection: textDirection ?? Directionality.maybeOf(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderInverseCenterOptically renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..corners = corners
      ..maxOffsets = maxOffsets
      ..textDirection = textDirection ?? Directionality.maybeOf(context);
  }
}

class _RenderInverseCenterOptically extends RenderCenterOptically {
  _RenderInverseCenterOptically({
    super.enabled,
    super.corners,
    super.maxOffsets,
    super.textDirection,
    super.child,
  });

  @override
  double getHorizontalPaddingCorrection(BorderRadius borderRadius) =>
      -super.getHorizontalPaddingCorrection(borderRadius);

  @override
  double getVerticalPaddingCorrection(BorderRadius borderRadius) =>
      -super.getVerticalPaddingCorrection(borderRadius);
}

enum ListItemControlAffinity { leading, trailing }

class ListItemContainer extends StatelessWidget {
  const ListItemContainer({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    this.opticalCenterEnabled = false,
    this.opticalCenterMaxOffsets = const .all(.infinity),
    this.containerShape,
    this.containerColor,
    required this.child,
  });

  final bool isFirst;
  final bool isLast;
  final bool opticalCenterEnabled;
  final EdgeInsetsGeometry opticalCenterMaxOffsets;
  final ListItemStateProperty<ShapeBorder?>? containerShape;
  final ListItemStateProperty<Color?>? containerColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final listItemTheme = ListItemTheme.of(context);

    final states = _ListItemStates(isFirst: isFirst, isLast: isLast);

    final resolvedShape =
        containerShape?.resolve(states) ??
        listItemTheme.containerShape.resolve(states);

    final corners = opticalCenterEnabled
        ? _cornersFromShape(resolvedShape)
        : null;

    final resolvedContainerColor =
        containerColor?.resolve(states) ??
        listItemTheme.containerColor.resolve(states);

    return Material.empty(
      clipBehavior: .antiAlias,
      color: resolvedContainerColor,
      shape: resolvedShape,
      elevation: 0.0,
      shadowColor: Colors.transparent,
      child: CenterOptically(
        enabled: corners != null,
        corners: corners ?? .none,
        maxOffsets: corners != null ? opticalCenterMaxOffsets : .zero,
        child: _ListItemContainerScope(
          opticalCenterEnabled: corners != null,
          opticalCenterCorners: corners ?? .none,
          opticalCenterMaxOffsets: corners != null
              ? opticalCenterMaxOffsets
              : .zero,
          child: child,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>("isFirst", isFirst, defaultValue: false))
      ..add(DiagnosticsProperty<bool>("isLast", isLast, defaultValue: false))
      ..add(
        DiagnosticsProperty<bool>(
          "opticalCenterEnabled",
          opticalCenterEnabled,
          defaultValue: true,
        ),
      )
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          "opticalCenterMaxOffsets",
          opticalCenterMaxOffsets,
          defaultValue: const EdgeInsetsGeometry.all(.infinity),
        ),
      )
      ..add(
        DiagnosticsProperty<ListItemStateProperty<ShapeBorder?>>(
          "containerShape",
          containerShape,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ListItemStateProperty<Color?>>(
          "containerColor",
          containerColor,
          defaultValue: null,
        ),
      );
  }

  static CornersGeometry? _cornersFromShape(ShapeBorder shape) =>
      switch (shape) {
        CornersBorder(:final corners) => corners,
        RoundedRectangleBorder(:final borderRadius) ||
        RoundedSuperellipseBorder(:final borderRadius) ||
        BeveledRectangleBorder(:final borderRadius) ||
        ContinuousRectangleBorder(
          :final borderRadius,
        ) => CornersGeometry.fromBorderRadius(borderRadius),
        StadiumBorder() || CircleBorder() || StarBorder() => .full,
        LinearBorder() => .none,
        _ => null,
      };
}

class _ListItemContainerScope extends InheritedWidget {
  const _ListItemContainerScope({
    super.key,
    this.opticalCenterEnabled = false,
    this.opticalCenterCorners = .none,
    this.opticalCenterMaxOffsets = .zero,
    required super.child,
  });

  final bool opticalCenterEnabled;
  final CornersGeometry opticalCenterCorners;
  final EdgeInsetsGeometry opticalCenterMaxOffsets;

  @override
  bool updateShouldNotify(_ListItemContainerScope oldWidget) =>
      opticalCenterEnabled != oldWidget.opticalCenterEnabled ||
      opticalCenterCorners != oldWidget.opticalCenterCorners ||
      opticalCenterMaxOffsets != oldWidget.opticalCenterMaxOffsets;

  static _ListItemContainerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ListItemContainerScope>();
}

typedef _CenterOpticallyConstructor =
    CenterOptically Function({
      Key? key,
      bool enabled,
      CornersGeometry corners,
      EdgeInsetsGeometry maxOffsets,
      TextDirection? textDirection,
      Widget? child,
    });

extension on _ListItemContainerScope? {
  Widget buildCenterOptically({
    Key? key,
    required bool inverse,
    TextDirection? textDirection,
    Widget? child,
  }) {
    final _CenterOpticallyConstructor constructor = inverse
        ? _InverseCenterOptically.new
        : CenterOptically.new;
    return constructor(
      key: key,
      enabled: this?.opticalCenterEnabled ?? false,
      corners: this?.opticalCenterCorners ?? .none,
      maxOffsets: this?.opticalCenterMaxOffsets ?? .zero,
      textDirection: textDirection,
      child: child,
    );
  }
}

class ListItemInteraction extends StatefulWidget {
  const ListItemInteraction({
    super.key,
    // State
    this.statesController,
    this.stateLayerShape,
    this.stateLayerColor,
    this.stateLayerOpacity,
    // Focus
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    // Gesture handlers
    this.onTap,
    this.onLongPress,
    // Child
    required this.child,
  });

  final WidgetStatesController? statesController;
  final ListItemStateProperty<ShapeBorder?>? stateLayerShape;
  final ListItemStateProperty<Color?>? stateLayerColor;
  final ListItemStateProperty<double?>? stateLayerOpacity;

  final FocusNode? focusNode;
  final bool canRequestFocus;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final Widget child;

  @override
  State<ListItemInteraction> createState() => _ListItemInteractionState();
}

class _ListItemInteractionState extends State<ListItemInteraction> {
  late ShapeThemeData _shapeTheme;

  WidgetStatesController? _internalStatesController;

  WidgetStatesController get _statesController {
    if (widget.statesController case final statesController?) {
      return statesController;
    }
    assert(_internalStatesController != null);
    return _internalStatesController!;
  }

  bool _pressed = false;
  bool _focused = false;

  _InteractiveListItemStates _resolveStates() {
    final states = _statesController.value;

    final _InteractiveListItemStates result =
        widget.onTap == null && widget.onLongPress == null
        ? const .disabled(isFirst: false, isLast: false)
        : .enabled(
            isFirst: false,
            isLast: false,
            isHovered: states.contains(WidgetState.hovered),
            isPressed: _pressed,
            isFocused: _focused && !_pressed,
          );

    if (result.isDisabled) {
      states.add(WidgetState.disabled);
    } else {
      states.remove(WidgetState.disabled);
    }
    if (result.isHovered) {
      states.add(WidgetState.pressed);
    } else {
      states.remove(WidgetState.pressed);
    }
    if (result.isFocused) {
      states.add(WidgetState.focused);
    } else {
      states.remove(WidgetState.focused);
    }
    return result;
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
    widget.onFocusChange?.call(value);
  }

  @override
  void initState() {
    super.initState();
    if (widget.statesController == null) {
      _internalStatesController = WidgetStatesController();
    }
    _statesController.addListener(_statesListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shapeTheme = ShapeTheme.of(context);
  }

  @override
  void didUpdateWidget(covariant ListItemInteraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldStatesController = oldWidget.statesController;
    final newStatesController = widget.statesController;
    if (newStatesController != oldStatesController) {
      oldStatesController?.removeListener(_statesListener);
      _internalStatesController?.dispose();
      _internalStatesController = newStatesController == null
          ? WidgetStatesController()
          : null;
      _statesController.addListener(_statesListener);
    }
  }

  @override
  void dispose() {
    _internalStatesController?.dispose();
    _internalStatesController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listItemTheme = ListItemTheme.of(context);
    final listItemContainerScope = _ListItemContainerScope.maybeOf(context);

    final states = _resolveStates();

    final stateLayerShape =
        widget.stateLayerShape?.resolve(states) ??
        const RoundedRectangleBorder();

    final stateLayerColor =
        widget.stateLayerColor?.orElse(
          (states) => listItemTheme.stateLayerColor.resolve(states),
        ) ??
        listItemTheme.stateLayerColor;

    final stateLayerOpacity =
        widget.stateLayerOpacity?.orElse(
          (states) => listItemTheme.stateLayerOpacity.resolve(states),
        ) ??
        listItemTheme.stateLayerOpacity;

    final overlayColor = WidgetStateProperty.resolveWith((widgetStates) {
      final resolvedStates = _InteractiveListItemStates.fromWidgetStates(
        widgetStates,
        isFirst: states.isFirst,
        isLast: states.isLast,
      );
      final resolvedColor = stateLayerColor.resolve(resolvedStates);
      final resolvedOpacity = stateLayerOpacity.resolve(resolvedStates);
      return resolvedColor.withValues(alpha: resolvedColor.a * resolvedOpacity);
    });

    return listItemContainerScope.buildCenterOptically(
      inverse: true,
      child: FocusRingTheme.merge(
        data: FocusRingThemeDataPartial.from(
          shape: Corners.all(_shapeTheme.corner.large),
        ),
        child: FocusRing(
          visible: states.isFocused,
          placement: .inward,
          layoutBuilder: (context, info, child) => child,
          child: Listener(
            behavior: .deferToChild,
            onPointerDown: !states.isDisabled ? _onPointerDown : null,
            onPointerUp: !states.isDisabled ? _onPointerUp : null,
            onPointerCancel: !states.isDisabled ? _onPointerCancel : null,
            child: InkWell(
              customBorder: stateLayerShape,
              overlayColor: overlayColor,
              statesController: widget.statesController,
              focusNode: widget.focusNode,
              canRequestFocus: widget.canRequestFocus,
              autofocus: widget.autofocus,
              onTap: !states.isDisabled ? widget.onTap : null,
              onLongPress: !states.isDisabled ? widget.onLongPress : null,
              onTapDown: !states.isDisabled ? _onTapDown : null,
              onTapUp: !states.isDisabled ? _onTapUp : null,
              onTapCancel: !states.isDisabled ? _onTapCancel : null,
              onFocusChange: !states.isDisabled ? _onFocusChange : null,
              child: listItemContainerScope.buildCenterOptically(
                inverse: false,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ListItemAlignment {
  top(.start),
  middle(.center);

  const ListItemAlignment(this.crossAxisAlignment);

  final CrossAxisAlignment crossAxisAlignment;
}

class ListItemLayout extends StatelessWidget {
  const ListItemLayout({
    super.key,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.leadingPadding,
    this.contentPadding,
    this.trailingPadding,
    this.leadingSpace,
    this.trailingSpace,
    this.alignment = .middle,
    this.leading,
    this.overline,
    this.headline,
    this.supportingText,
    this.trailing,
  }) : assert(overline != null || headline != null || supportingText != null);

  final double? minHeight;
  final double? maxHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final double? leadingSpace;
  final double? trailingSpace;
  final ListItemAlignment alignment;
  final Widget? leading;
  final Widget? overline;
  final Widget? headline;
  final Widget? supportingText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final listItemTheme = ListItemTheme.of(context);

    final states = const _ListItemStates(isFirst: false, isLast: false);

    final resolvedConstraints = BoxConstraints(
      minWidth: 0.0,
      maxWidth: .infinity,
      minHeight: minHeight ?? 48.0,
      maxHeight: maxHeight ?? .infinity,
    );

    final resolvedPadding = padding ?? const .symmetric(horizontal: 16.0);

    final resolvedLeadingSpace = leadingSpace ?? 12.0;

    final resolvedLeadingPadding =
        leadingPadding?.add(.directional(end: resolvedLeadingSpace)) ??
        // Avoid getting _MixedEdgeInsets
        .fromSTEB(0.0, 10.0, resolvedLeadingSpace, 10.0);

    final resolvedContentPadding =
        contentPadding ?? const .symmetric(vertical: 10.0);

    final resolvedTrailingSpace = trailingSpace ?? 12.0;

    final resolvedTrailingPadding =
        trailingPadding?.add(.directional(start: resolvedTrailingSpace)) ??
        // Avoid getting _MixedEdgeInsets
        .fromSTEB(resolvedTrailingSpace, 10.0, 0.0, 10.0);

    return ConstrainedBox(
      constraints: resolvedConstraints,
      child: Padding(
        padding: resolvedPadding,
        child: Flex.horizontal(
          mainAxisSize: .max,
          mainAxisAlignment: .start,
          crossAxisAlignment: alignment.crossAxisAlignment,
          children: [
            if (leading case final leading?)
              Padding(
                padding: resolvedLeadingPadding,
                child: DefaultTextStyle.merge(
                  textAlign: .start,
                  style: listItemTheme.leadingTextStyle.resolve(states),
                  child: IconTheme.merge(
                    data: listItemTheme.leadingIconTheme.resolve(states),
                    child: leading,
                  ),
                ),
              ),
            Flexible.tight(
              child: Padding(
                padding: resolvedContentPadding,
                child: Flex.vertical(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .stretch,
                  children: [
                    if (overline case final overline?)
                      DefaultTextStyle.merge(
                        textAlign: .start,
                        style: listItemTheme.overlineTextStyle.resolve(states),
                        child: overline,
                      ),
                    if (headline case final headline?)
                      DefaultTextStyle.merge(
                        textAlign: .start,
                        style: listItemTheme.headlineTextStyle.resolve(states),
                        child: headline,
                      ),
                    if (supportingText case final supportingText?)
                      DefaultTextStyle.merge(
                        textAlign: .start,
                        style: listItemTheme.supportingTextStyle.resolve(
                          states,
                        ),
                        child: supportingText,
                      ),
                  ],
                ),
              ),
            ),
            if (trailing case final trailing?)
              Padding(
                padding: resolvedTrailingPadding,
                child: DefaultTextStyle.merge(
                  textAlign: .end,
                  style: listItemTheme.trailingTextStyle.resolve(states),
                  child: IconTheme.merge(
                    data: listItemTheme.trailingIconTheme.resolve(states),
                    child: trailing,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ListItemStates implements SegmentedListItemStates {
  const _ListItemStates({required this.isFirst, required this.isLast});

  @override
  final bool isFirst;

  @override
  final bool isLast;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _ListItemStates &&
          isFirst == other.isFirst &&
          isLast == other.isLast;

  @override
  int get hashCode => Object.hash(runtimeType, isFirst, isLast);
}

sealed class _InteractiveListItemStates extends _ListItemStates
    implements InteractiveListItemStates {
  const _InteractiveListItemStates({
    required super.isFirst,
    required super.isLast,
  });

  const factory _InteractiveListItemStates.enabled({
    required bool isFirst,
    required bool isLast,
    bool isHovered,
    bool isFocused,
    bool isPressed,
  }) = _InteractiveListItemEnabledStates;

  const factory _InteractiveListItemStates.disabled({
    required bool isFirst,
    required bool isLast,
  }) = _InteractiveListItemDisabledStates;

  factory _InteractiveListItemStates.fromWidgetStates(
    WidgetStates states, {
    required bool isFirst,
    required bool isLast,
  }) => states.contains(WidgetState.disabled)
      ? .disabled(isFirst: isFirst, isLast: isLast)
      : .enabled(
          isFirst: isFirst,
          isLast: isLast,
          isHovered: states.contains(WidgetState.hovered),
          isFocused: states.contains(WidgetState.focused),
          isPressed: states.contains(WidgetState.pressed),
        );

  bool get isDisabled;

  bool get isHovered;

  bool get isFocused;

  bool get isPressed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _InteractiveListItemStates &&
          isFirst == other.isFirst &&
          isLast == other.isLast &&
          isHovered == other.isHovered &&
          isFocused == other.isFocused &&
          isPressed == other.isPressed &&
          isDisabled == other.isDisabled;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isFirst,
    isLast,
    isHovered,
    isFocused,
    isPressed,
    isDisabled,
  );
}

class _InteractiveListItemDisabledStates extends _InteractiveListItemStates
    implements InteractiveListItemDisabledStates {
  const _InteractiveListItemDisabledStates({
    required super.isFirst,
    required super.isLast,
  });

  @override
  bool get isDisabled => true;

  @override
  bool get isHovered => false;

  @override
  bool get isFocused => false;

  @override
  bool get isPressed => false;
}

class _InteractiveListItemEnabledStates extends _InteractiveListItemStates
    implements InteractiveListItemEnabledStates {
  const _InteractiveListItemEnabledStates({
    required super.isFirst,
    required super.isLast,
    this.isHovered = false,
    this.isFocused = false,
    this.isPressed = false,
  });

  @override
  bool get isDisabled => false;

  @override
  final bool isHovered;

  @override
  final bool isFocused;

  @override
  final bool isPressed;
}
