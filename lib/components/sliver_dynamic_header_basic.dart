import 'dart:math' as math;

import 'package:materium/flutter.dart';

@immutable
class SliverDynamicHeaderLayoutInfo with Diagnosticable {
  const SliverDynamicHeaderLayoutInfo({
    required this.minExtent,
    required this.maxExtent,
    required this.currentExtent,
    required this.shrinkOffset,
  }) : assert(minExtent >= 0.0 && maxExtent >= 0.0 && maxExtent >= minExtent),
       assert(currentExtent >= minExtent && currentExtent <= maxExtent),
       assert(shrinkOffset >= 0.0 && shrinkOffset <= maxExtent - minExtent);

  /// The smallest size which the header is allowed to reach
  /// when it shrinks at the start of the viewport.
  final double minExtent;

  /// The size of the header when it is not shrinking at the top of the
  /// viewport.
  ///
  /// This value is equal to or greater than [minExtent].
  final double maxExtent;

  /// The current size of the header.
  ///
  /// This value is between [minExtent] and [maxExtent].
  final double currentExtent;

  /// The distance from [maxExtent] towards [minExtent]
  /// representing the current amount by which the sliver has been shrunk.
  ///
  /// When it is zero, the contents will be rendered with a dimension
  /// of [maxExtent] in the main axis. When it equals the difference
  /// between [maxExtent] and [minExtent] (a positive number), the contents will
  /// be rendered with a dimension of [minExtent] in the main axis.
  ///
  /// The value will always be a positive number in that range.
  final double shrinkOffset;

  SliverDynamicHeaderLayoutInfo copyWith({
    double? minExtent,
    double? maxExtent,
    double? currentExtent,
    double? shrinkOffset,
  }) =>
      minExtent != null ||
          maxExtent != null ||
          currentExtent != null ||
          shrinkOffset != null
      ? SliverDynamicHeaderLayoutInfo(
          minExtent: minExtent ?? this.minExtent,
          maxExtent: maxExtent ?? this.maxExtent,
          currentExtent: currentExtent ?? this.currentExtent,
          shrinkOffset: shrinkOffset ?? this.shrinkOffset,
        )
      : this;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty("minExtent", minExtent))
      ..add(DoubleProperty("maxExtent", maxExtent))
      ..add(DoubleProperty("currentExtent", currentExtent))
      ..add(DoubleProperty("shrinkOffset", shrinkOffset));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is SliverDynamicHeaderLayoutInfo &&
          minExtent == other.minExtent &&
          maxExtent == other.maxExtent &&
          currentExtent == other.currentExtent &&
          shrinkOffset == other.shrinkOffset;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    minExtent,
    maxExtent,
    currentExtent,
    shrinkOffset,
  );
}

typedef SliverDynamicHeaderBuilder =
    Widget Function(
      BuildContext context,
      SliverDynamicHeaderLayoutInfo layoutInfo,
    );

class SliverDynamicHeader extends StatelessWidget {
  /// Create a pinned header sliver that reacts to scrolling by resizing between
  /// the intrinsic sizes of the min and max extent prototypes.
  const SliverDynamicHeader({
    super.key,
    required this.minExtentPrototype,
    required this.maxExtentPrototype,
    required this.builder,
  });

  /// Laid out once to define the minimum size of this sliver along the
  /// [CustomScrollView.scrollDirection] axis.
  ///
  /// If null, the minimum size of the sliver is 0.
  ///
  /// This widget is never made visible.
  final Widget minExtentPrototype;

  /// Laid out once to define the maximum size of this sliver along the
  /// [CustomScrollView.scrollDirection] axis.
  ///
  /// If null, the maximum extent of the sliver is based on the child's
  /// intrinsic size.
  ///
  /// This widget is never made visible.
  final Widget maxExtentPrototype;

  final SliverDynamicHeaderBuilder builder;

  Widget _buildLayout(
    BuildContext context,
    ValueBoxConstraints<SliverDynamicHeaderLayoutInfo> constraints,
  ) => builder(context, constraints.value);

  @override
  Widget build(BuildContext context) => _SliverDynamicHeader(
    minExtentPrototype: ExcludeFocus(child: minExtentPrototype),
    maxExtentPrototype: ExcludeFocus(child: maxExtentPrototype),
    child: ValueLayoutBuilder<SliverDynamicHeaderLayoutInfo>(
      builder: _buildLayout,
    ),
  );
}

enum _SliverDynamicHeaderSlot { minExtent, maxExtent, child }

class _SliverDynamicHeader
    extends
        SlottedMultiChildRenderObjectWidget<
          _SliverDynamicHeaderSlot,
          RenderBox
        > {
  const _SliverDynamicHeader({
    super.key,
    required this.minExtentPrototype,
    required this.maxExtentPrototype,
    required this.child,
  });

  final Widget minExtentPrototype;
  final Widget maxExtentPrototype;
  final Widget child;

  @override
  Iterable<_SliverDynamicHeaderSlot> get slots =>
      _SliverDynamicHeaderSlot.values;

  @override
  Widget childForSlot(_SliverDynamicHeaderSlot slot) => switch (slot) {
    .minExtent => minExtentPrototype,
    .maxExtent => maxExtentPrototype,
    .child => child,
  };

  @override
  _RenderSliverDynamicHeader createRenderObject(BuildContext context) =>
      _RenderSliverDynamicHeader();
}

class _RenderSliverDynamicHeader extends RenderSliver
    with
        SlottedContainerRenderObjectMixin<_SliverDynamicHeaderSlot, RenderBox>,
        RenderSliverHelpers {
  RenderBox? get _minExtentPrototype => childForSlot(.minExtent);

  RenderBox? get _maxExtentPrototype => childForSlot(.maxExtent);

  RenderBox? get _child => childForSlot(.child);

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  double _boxChildExtent(RenderBox child) {
    assert(child.hasSize);
    return switch (constraints.axis) {
      .vertical => child.size.height,
      .horizontal => child.size.width,
    };
  }

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  SliverPhysicalParentData _boxChildParentData(RenderBox child) {
    assert(child.parentData != null);
    assert(child.parentData is SliverPhysicalParentData);
    return child.parentData! as SliverPhysicalParentData;
  }

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  ValueBoxConstraints<SliverDynamicHeaderLayoutInfo> _customConstraints(
    BoxConstraints constraints,
    SliverDynamicHeaderLayoutInfo info,
  ) => ValueBoxConstraints<SliverDynamicHeaderLayoutInfo>(constraints, info);

  @override
  Iterable<RenderBox> get children => <RenderBox>[
    ?_minExtentPrototype,
    ?_maxExtentPrototype,
    ?_child,
  ];

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final prototypeBoxConstraints = constraints.asBoxConstraints();

    var minExtent = 0.0;
    if (_minExtentPrototype case final minExtentPrototype?) {
      minExtentPrototype.layout(prototypeBoxConstraints, parentUsesSize: true);
      minExtent = _boxChildExtent(minExtentPrototype);
    }

    var maxExtent = double.infinity;
    if (_maxExtentPrototype case final maxExtentPrototype?) {
      maxExtentPrototype.layout(prototypeBoxConstraints, parentUsesSize: true);
      maxExtent = _boxChildExtent(maxExtentPrototype);
    }

    final scrollOffset = constraints.scrollOffset;

    var childExtent = 0.0;
    if (_child case final child?) {
      final shrinkOffset = math.min(scrollOffset, maxExtent);
      final resolvedExtent = math.max(minExtent, maxExtent - shrinkOffset);
      final resolvedShrinkOffset = maxExtent - resolvedExtent;
      final boxConstraints = constraints.asBoxConstraints(
        minExtent: resolvedExtent,
        maxExtent: resolvedExtent,
      );
      final layoutInfo = SliverDynamicHeaderLayoutInfo(
        minExtent: minExtent,
        maxExtent: maxExtent,
        currentExtent: resolvedExtent,
        shrinkOffset: resolvedShrinkOffset,
      );
      child.layout(
        _customConstraints(boxConstraints, layoutInfo),
        parentUsesSize: true,
      );
      childExtent = _boxChildExtent(child);
    }

    final remainingPaintExtent = constraints.remainingPaintExtent;
    final layoutExtent = math.min(childExtent, maxExtent - scrollOffset);
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, remainingPaintExtent),
      layoutExtent: clampDouble(layoutExtent, 0.0, remainingPaintExtent),
      maxPaintExtent: childExtent,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: calculateCacheOffset(
        constraints,
        from: 0.0,
        to: childExtent,
      ),
      // Conservatively say we do have overflow to avoid complexity.
      hasVisualOverflow: true,
    );
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    _boxChildParentData(child).applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_child case final child? when geometry!.visible) {
      context.paintChild(
        child,
        offset + _boxChildParentData(child).paintOffset,
      );
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0.0);
    if (_child case final child?) {
      return hitTestBoxChild(
        .wrap(result),
        child,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }
}
