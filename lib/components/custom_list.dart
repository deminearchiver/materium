import 'package:materium/flutter.dart';

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
        CornersBorder.rounded(
          corners: Corners.vertical(
            top: isFirst
                ? shapeTheme.corner.largeIncreased
                : shapeTheme.corner.extraSmall,
            bottom: isLast
                ? shapeTheme.corner.largeIncreased
                : shapeTheme.corner.extraSmall,
          ),
        );

    final corners = opticalCenterEnabled
        ? _cornersFromShape(resolvedShape)
        : null;

    return Material(
      animationDuration: .zero,
      type: .card,
      clipBehavior: .antiAlias,
      color: containerColor ?? colorTheme.surfaceBright,
      shape: resolvedShape,
      child: CenterOptically(
        enabled: corners != null,
        corners: corners ?? .none,
        maxOffsets: corners != null ? opticalCenterMaxOffsets : .zero,
        child: child,
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
          defaultValue: const EdgeInsets.all(.infinity),
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

  static CornersGeometry? _cornersFromShape(ShapeBorder shape) =>
      switch (shape) {
        CornersBorder(:final corners) => corners,
        RoundedRectangleBorder(:final borderRadius) =>
          CornersGeometry.fromBorderRadius(borderRadius),
        StadiumBorder() => Corners.full,
        _ => null,
      };
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
    return FocusRingTheme.merge(
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
            child: widget.child,
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

    final maxHeight = widget.maxHeight ?? double.infinity;

    final constraints = BoxConstraints(
      minHeight: minHeight,
      maxHeight: maxHeight,
    );

    final EdgeInsetsGeometry containerPadding =
        widget.padding?.horizontalInsets() ??
        const EdgeInsets.symmetric(horizontal: 16.0);

    final EdgeInsetsGeometry verticalContentPadding =
        widget.padding?.verticalInsets() ??
        (isMultiline
            ? const EdgeInsets.symmetric(vertical: 12.0)
            : const EdgeInsets.symmetric(vertical: 8.0));

    final EdgeInsetsGeometry horizontalContentPadding =
        EdgeInsetsDirectional.only(
          start: widget.leading != null ? widget.leadingSpace ?? 12.0 : 0.0,
          end: widget.trailing != null ? widget.trailingSpace ?? 12.0 : 0.0,
        );

    final EdgeInsetsGeometry contentPadding = verticalContentPadding.add(
      horizontalContentPadding,
    );

    return ConstrainedBox(
      constraints: constraints,
      child: Padding(
        padding: containerPadding,
        child: Flex.horizontal(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.leading case final leading?)
              IconTheme.merge(
                data: IconThemeDataPartial.from(
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
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.overline case final overline?)
                      DefaultTextStyle(
                        style: typescaleTheme.labelMedium.toTextStyle(
                          color: colorTheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: overline,
                      ),
                    if (widget.headline case final headline?)
                      DefaultTextStyle(
                        style: typescaleTheme.titleMediumEmphasized.toTextStyle(
                          color: colorTheme.onSurface,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: headline,
                      ),
                    if (widget.supportingText case final supportingText?)
                      DefaultTextStyle(
                        style: typescaleTheme.bodyMedium.toTextStyle(
                          color: colorTheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
                child: IconTheme.merge(
                  data: IconThemeDataPartial.from(
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
