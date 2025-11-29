import 'package:material/src/material/flutter.dart';

const double _kCenterOpticallyCoefficient = 0.11;

class CenterOptically extends SingleChildRenderObjectWidget {
  const CenterOptically({
    super.key,
    this.enabled = true,
    this.corners = .none,
    this.maxOffsets = .zero,
    this.textDirection,
    super.child,
  });

  final bool enabled;
  final CornersGeometry corners;
  final EdgeInsetsGeometry maxOffsets;
  final TextDirection? textDirection;

  @override
  RenderCenterOptically createRenderObject(BuildContext context) =>
      RenderCenterOptically(
        enabled: enabled,
        corners: corners,
        maxOffsets: maxOffsets,
        textDirection: textDirection ?? Directionality.maybeOf(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCenterOptically renderObject,
  ) {
    renderObject
      ..enabled = enabled
      ..corners = corners
      ..maxOffsets = maxOffsets
      ..textDirection = textDirection ?? Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>("enabled", enabled))
      ..add(DiagnosticsProperty<CornersGeometry>("corners", corners))
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          "maxOffsets",
          maxOffsets,
          defaultValue: EdgeInsets.zero,
        ),
      )
      ..add(
        EnumProperty<TextDirection>(
          "textDirection",
          textDirection,
          defaultValue: null,
        ),
      );
  }
}

class RenderCenterOptically extends RenderShiftedBox {
  RenderCenterOptically({
    bool enabled = true,
    CornersGeometry corners = .none,
    EdgeInsetsGeometry maxOffsets = .zero,
    TextDirection? textDirection,
    RenderBox? child,
  }) : _enabled = enabled,
       _corners = corners,
       _maxOffsets = maxOffsets,
       _textDirection = textDirection,
       super(child);

  Corners? _resolvedCornersCache;
  Corners get _resolvedCorners =>
      _resolvedCornersCache ??= corners.resolve(textDirection);

  EdgeInsets? _resolvedMaxOffsetsCache;
  EdgeInsets get _resolvedMaxOffsets =>
      _resolvedMaxOffsetsCache ??= maxOffsets.resolve(textDirection);

  void _markNeedResolution() {
    _resolvedCornersCache = null;
    _resolvedMaxOffsetsCache = null;
    markNeedsLayout();
  }

  bool _enabled;
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    markNeedsLayout();
  }

  CornersGeometry _corners;
  CornersGeometry get corners => _corners;
  set corners(CornersGeometry value) {
    if (_corners == value) return;
    _corners = value;
    _markNeedResolution();
  }

  EdgeInsetsGeometry _maxOffsets;
  EdgeInsetsGeometry get maxOffsets => _maxOffsets;
  set maxOffsets(EdgeInsetsGeometry value) {
    if (_maxOffsets == value) return;
    _maxOffsets = value;
    _markNeedResolution();
  }

  TextDirection? _textDirection;
  TextDirection? get textDirection => _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedResolution();
  }

  @protected
  double computeHorizontalPaddingCorrection(BorderRadius borderRadius) =>
      _kCenterOpticallyCoefficient /
      2.0 *
      (borderRadius.topLeft.x +
          borderRadius.bottomLeft.x -
          borderRadius.topRight.x -
          borderRadius.bottomRight.x);

  @protected
  double computeVerticalPaddingCorrection(BorderRadius borderRadius) =>
      _kCenterOpticallyCoefficient /
      2.0 *
      (borderRadius.topLeft.x +
          borderRadius.topRight.x -
          borderRadius.bottomLeft.x -
          borderRadius.bottomRight.x);

  double getHorizontalPaddingCorrection(BorderRadius borderRadius) {
    final maxOffsets = _resolvedMaxOffsets;
    if (maxOffsets.left == 0.0 && maxOffsets.right == 0.0) return 0.0;
    return clampDouble(
      computeHorizontalPaddingCorrection(borderRadius),
      -maxOffsets.left,
      maxOffsets.right,
    );
  }

  double getVerticalPaddingCorrection(BorderRadius borderRadius) {
    final maxOffsets = _resolvedMaxOffsets;
    if (maxOffsets.top == 0.0 && maxOffsets.bottom == 0.0) return 0.0;
    return clampDouble(
      computeVerticalPaddingCorrection(borderRadius),
      -maxOffsets.top,
      maxOffsets.bottom,
    );
  }

  Offset _getPaddingCorrection(BorderRadius borderRadius) => Offset(
    getHorizontalPaddingCorrection(borderRadius),
    getVerticalPaddingCorrection(borderRadius),
  );

  void _dryPositionChild(RenderBox _, Offset _) {}

  void _positionChild(RenderBox child, Offset position) {
    assert(child.parentData != null && child.parentData is BoxParentData);
    (child.parentData! as BoxParentData).offset = position;
  }

  Size _layout({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
    required ChildPositioner positionChild,
  }) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    final size = constraints.constrain(layoutChild(child, constraints));
    if (enabled) {
      final borderRadius = _resolvedCorners.toBorderRadius(size);
      final paddingCorrection = _getPaddingCorrection(borderRadius);
      positionChild(child, paddingCorrection);
    } else {
      positionChild(child, .zero);
    }
    return size;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(
    constraints: constraints,
    layoutChild: ChildLayoutHelper.dryLayoutChild,
    positionChild: _dryPositionChild,
  );

  @override
  void performLayout() {
    size = _layout(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
      positionChild: _positionChild,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>("enabled", enabled, defaultValue: true))
      ..add(
        DiagnosticsProperty<CornersGeometry>(
          "corners",
          corners,
          defaultValue: Corners.none,
        ),
      )
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          "maxOffsets",
          maxOffsets,
          defaultValue: EdgeInsets.zero,
        ),
      )
      ..add(
        EnumProperty<TextDirection>(
          "textDirection",
          textDirection,
          defaultValue: null,
        ),
      );
  }

  static double calculatePaddingCorrection(
    double averageStart,
    double averageEnd,
    double maxStartOffset,
    double maxEndOffset,
  ) => clampDouble(
    _kCenterOpticallyCoefficient * (averageStart - averageEnd),
    -maxStartOffset,
    maxEndOffset,
  );
}
