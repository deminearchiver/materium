import 'dart:math' as math;

import 'package:materium/flutter.dart';

class SliverDynamicHeaderLayoutInfo with Diagnosticable {
  const SliverDynamicHeaderLayoutInfo({
    required this.minExtent,
    required this.maxExtent,
    required this.currentExtent,
    required this.shrinkOffset,
  });

  final double minExtent;
  final double maxExtent;
  final double currentExtent;
  final double shrinkOffset;

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
      Widget? child,
    );

class SliverDynamicHeader extends StatelessWidget {
  /// Create a pinned header sliver that reacts to scrolling by resizing between
  /// the intrinsic sizes of the min and max extent prototypes.
  const SliverDynamicHeader({
    super.key,
    required this.minExtentPrototype,
    required this.maxExtentPrototype,
    required this.builder,
    this.child,
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

  final Widget? child;

  Widget _buildLayout(
    BuildContext context,
    ValueBoxConstraints<SliverDynamicHeaderLayoutInfo> constraints,
  ) => builder(context, constraints.value, child);

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
  RenderBox? get minExtentPrototype => childForSlot(.minExtent);

  RenderBox? get maxExtentPrototype => childForSlot(.maxExtent);

  RenderBox? get child => childForSlot(.child);

  @override
  Iterable<RenderBox> get children => <RenderBox>[
    ?minExtentPrototype,
    ?maxExtentPrototype,
    ?child,
  ];

  double boxExtent(RenderBox box) {
    assert(box.hasSize);
    return switch (constraints.axis) {
      .vertical => box.size.height,
      .horizontal => box.size.width,
    };
  }

  double get childExtent => child == null ? 0 : boxExtent(child!);

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  SliverPhysicalParentData _childParentData(RenderObject child) {
    assert(child.parentData != null);
    assert(child.parentData is SliverPhysicalParentData);
    return child.parentData! as SliverPhysicalParentData;
  }

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  ValueBoxConstraints<SliverDynamicHeaderLayoutInfo> _boxConstraints(
    BoxConstraints constraints,
    SliverDynamicHeaderLayoutInfo info,
  ) => ValueBoxConstraints<SliverDynamicHeaderLayoutInfo>(constraints, info);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @protected
  void setChildParentData(
    RenderObject child,
    SliverConstraints constraints,
    SliverGeometry geometry,
  ) {
    final childParentData = _childParentData(child);
    final direction = applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    );
    childParentData.paintOffset = switch (direction) {
      .up => Offset(
        0.0,
        -(geometry.scrollExtent -
            (geometry.paintExtent + constraints.scrollOffset)),
      ),
      .right => Offset(-constraints.scrollOffset, 0.0),
      .down => Offset(0.0, -constraints.scrollOffset),
      .left => Offset(
        -(geometry.scrollExtent -
            (geometry.paintExtent + constraints.scrollOffset)),
        0.0,
      ),
    };
  }

  @override
  double childMainAxisPosition(covariant RenderObject child) => 0.0;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final BoxConstraints prototypeBoxConstraints = constraints
        .asBoxConstraints();

    var minExtent = 0.0;
    if (minExtentPrototype case final minExtentPrototype?) {
      minExtentPrototype.layout(prototypeBoxConstraints, parentUsesSize: true);
      minExtent = boxExtent(minExtentPrototype);
    }

    var maxExtent = double.infinity;
    if (maxExtentPrototype case final maxExtentPrototype?) {
      maxExtentPrototype.layout(prototypeBoxConstraints, parentUsesSize: true);
      maxExtent = boxExtent(maxExtentPrototype);
    }

    final scrollOffset = constraints.scrollOffset;
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
    child?.layout(
      _boxConstraints(boxConstraints, layoutInfo),
      parentUsesSize: true,
    );

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
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    _childParentData(child).applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child case final child? when geometry!.visible) {
      context.paintChild(child, offset + _childParentData(child).paintOffset);
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child case final child?) {
      return hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        child,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }
}
