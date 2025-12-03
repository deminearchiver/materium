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
    this.opticalCenterEnabled = true,
    this.opticalCenterMaxOffsets = const .all(.infinity),
    this.containerShape,
    this.containerColor,
    required this.child,
  });

  final bool isFirst;
  final bool isLast;
  final bool opticalCenterEnabled;
  final EdgeInsetsGeometry opticalCenterMaxOffsets;
  final ShapeBorder? containerShape;
  final Color? containerColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);

    final resolvedShape =
        containerShape ??
        _defaultShape(shapeTheme: shapeTheme, isFirst: isFirst, isLast: isLast);

    final corners = opticalCenterEnabled
        ? _cornersFromShape(resolvedShape)
        : null;

    final resolvedContainerColor = containerColor ?? colorTheme.surfaceBright;

    return Material(
      animationDuration: .zero,
      type: .card,
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
        DiagnosticsProperty<ShapeBorder>(
          "containerShape",
          containerShape,
          defaultValue: null,
        ),
      )
      ..add(
        ColorProperty("containerColor", containerColor, defaultValue: null),
      );
  }

  static ShapeBorder _defaultShape({
    required ShapeThemeData shapeTheme,
    required bool isFirst,
    required bool isLast,
  }) {
    final edgeCorner = shapeTheme.corner.largeIncreased;
    final connectionCorner = shapeTheme.corner.extraSmall;
    return CornersBorder.rounded(
      corners: .vertical(
        top: isFirst ? edgeCorner : connectionCorner,
        bottom: isLast ? edgeCorner : connectionCorner,
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
  final WidgetStateProperty<Color>? stateLayerColor;
  final WidgetStateProperty<double>? stateLayerOpacity;

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
  late ColorThemeData _colorTheme;
  late ShapeThemeData _shapeTheme;
  late StateThemeData _stateTheme;

  WidgetStatesController? _internalStatesController;

  WidgetStatesController get _statesController {
    if (widget.statesController case final statesController?) {
      return statesController;
    }
    assert(_internalStatesController != null);
    return _internalStatesController!;
  }

  WidgetStateProperty<Color> get _stateLayerColor =>
      WidgetStatePropertyAll(_colorTheme.onSurface);

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

  void _statesListener() {
    setState(() {});
  }

  bool _pressed = false;
  bool _focused = false;

  WidgetStates _resolveStates() {
    final states = _statesController.value;

    final isDisabled = widget.onTap == null && widget.onLongPress == null;

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
    return Set.of(states);
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
    _colorTheme = ColorTheme.of(context);
    _shapeTheme = ShapeTheme.of(context);
    _stateTheme = StateTheme.of(context);
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
    final states = _resolveStates();
    final isDisabled = states.contains(WidgetState.disabled);
    final listItemContainerScope = _ListItemContainerScope.maybeOf(context);
    return listItemContainerScope.buildCenterOptically(
      inverse: true,
      child: FocusRingTheme.merge(
        data: FocusRingThemeDataPartial.from(
          shape: Corners.all(_shapeTheme.corner.large),
        ),
        child: FocusRing(
          visible: states.contains(WidgetState.focused),
          placement: FocusRingPlacement.inward,
          layoutBuilder: (context, info, child) => child,
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
            child: InkWell(
              statesController: widget.statesController,
              focusNode: widget.focusNode,
              canRequestFocus: widget.canRequestFocus,
              autofocus: widget.autofocus,
              overlayColor: WidgetStateLayerColor(
                color: widget.stateLayerColor ?? _stateLayerColor,
                opacity: widget.stateLayerOpacity ?? _stateLayerOpacity,
              ),
              onTap: !isDisabled ? widget.onTap : null,
              onLongPress: !isDisabled ? widget.onLongPress : null,
              onTapDown: !isDisabled
                  ? (_) => setState(() {
                      _focused = false;
                      _pressed = true;
                    })
                  : null,
              onTapUp: !isDisabled
                  ? (_) => setState(() {
                      _focused = false;
                      _pressed = false;
                    })
                  : null,
              onTapCancel: !isDisabled
                  ? () => setState(() {
                      _focused = false;
                      _pressed = false;
                    })
                  : null,
              onFocusChange: !isDisabled
                  ? (value) {
                      setState(() => _focused = value);
                      widget.onFocusChange?.call(value);
                    }
                  : null,
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

class ListItemLayout extends StatefulWidget {
  const ListItemLayout({
    super.key,
    this.isMultiline,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.leadingSpace,
    this.trailingSpace,
    this.leading,
    this.overline,
    this.headline,
    this.supportingText,
    this.trailing,
  }) : assert(headline != null || supportingText != null);

  final bool? isMultiline;
  final double? minHeight;
  final double? maxHeight;
  final EdgeInsetsGeometry? padding;
  final double? leadingSpace;
  final double? trailingSpace;

  final Widget? leading;
  final Widget? overline;
  final Widget? headline;
  final Widget? supportingText;
  final Widget? trailing;

  @override
  State<ListItemLayout> createState() => _ListItemLayoutState();
}

class _ListItemLayoutState extends State<ListItemLayout> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final isMultiline =
        widget.isMultiline ??
        // TODO: add logic for determining isMultiline when overline is set
        (widget.headline != null && widget.supportingText != null);

    final minHeight = widget.minHeight ?? (isMultiline ? 72.0 : 56.0);

    final maxHeight = widget.maxHeight ?? .infinity;

    final constraints = BoxConstraints(
      minHeight: minHeight,
      maxHeight: maxHeight,
    );

    final containerPadding =
        widget.padding?.horizontalInsets() ??
        const .symmetric(horizontal: 16.0);

    final verticalContentPadding =
        widget.padding?.verticalInsets() ??
        (isMultiline
            ? const .symmetric(vertical: 12.0)
            : const .symmetric(vertical: 8.0));

    final horizontalContentPadding = EdgeInsetsGeometry.directional(
      start: widget.leading != null ? widget.leadingSpace ?? 12.0 : 0.0,
      end: widget.trailing != null ? widget.trailingSpace ?? 12.0 : 0.0,
    );

    final contentPadding = verticalContentPadding.add(horizontalContentPadding);

    return ConstrainedBox(
      constraints: constraints,
      child: Padding(
        padding: containerPadding,
        child: Flex.horizontal(
          mainAxisSize: .max,
          mainAxisAlignment: .start,
          crossAxisAlignment: .center,
          children: [
            if (widget.leading case final leading?)
              IconTheme.merge(
                data: .from(
                  color: colorTheme.onSurfaceVariant,
                  size: 24.0,
                  opticalSize: 24.0,
                ),
                child: leading,
              ),
            Flexible.tight(
              child: Padding(
                padding: contentPadding,
                child: Flex.vertical(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .stretch,
                  children: [
                    if (widget.overline case final overline?)
                      DefaultTextStyle(
                        style: typescaleTheme.labelMedium.toTextStyle(
                          color: colorTheme.onSurfaceVariant,
                        ),
                        textAlign: .start,
                        maxLines: 1,
                        overflow: .ellipsis,
                        child: overline,
                      ),
                    if (widget.headline case final headline?)
                      DefaultTextStyle(
                        style: typescaleTheme.titleMediumEmphasized.toTextStyle(
                          color: colorTheme.onSurface,
                        ),
                        textAlign: .start,
                        maxLines: 1,
                        overflow: .ellipsis,
                        child: headline,
                      ),
                    if (widget.supportingText case final supportingText?)
                      DefaultTextStyle(
                        style: typescaleTheme.bodyMedium.toTextStyle(
                          color: colorTheme.onSurfaceVariant,
                        ),
                        textAlign: .start,
                        maxLines: 2,
                        overflow: .ellipsis,
                        child: supportingText,
                      ),
                  ],
                ),
              ),
            ),
            if (widget.trailing case final trailing?)
              DefaultTextStyle(
                style: typescaleTheme.labelSmall.toTextStyle(
                  color: colorTheme.onSurfaceVariant,
                ),
                overflow: .ellipsis,
                child: IconTheme.merge(
                  data: .from(
                    color: colorTheme.onSurfaceVariant,
                    size: 24.0,
                    opticalSize: 24.0,
                  ),
                  child: trailing,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
