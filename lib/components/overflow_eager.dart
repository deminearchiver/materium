import 'dart:math' as math;

import 'package:materium/flutter.dart';

class Overflow extends StatefulWidget {
  const Overflow({
    super.key,
    required this.direction,
    this.crossAxisAlignment = .center,
    required this.overflowIndicator,
    required this.children,
  });

  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;
  final Widget overflowIndicator;
  final List<Widget> children;

  @override
  State<Overflow> createState() => _OverflowState();

  static _OverflowState? _maybeStateOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_OverflowScope>()?.state;
}

class _OverflowState extends State<Overflow> {
  @override
  Widget build(BuildContext context) {
    return _OverflowScope(
      state: this,
      child: _Overflow(
        direction: widget.direction,
        overflowIndicator: widget.overflowIndicator,
        children: widget.children,
      ),
    );
  }
}

class _OverflowScope extends InheritedWidget {
  const _OverflowScope({super.key, required this.state, required super.child});

  final _OverflowState state;

  @override
  bool updateShouldNotify(_OverflowScope oldWidget) => state != oldWidget.state;
}

class OverflowItemBuilder extends StatefulWidget {
  const OverflowItemBuilder({super.key, required this.builder, this.child})
    : cacheLayoutInfo = false;

  final bool cacheLayoutInfo;
  final Widget Function(
    BuildContext context,
    OverflowLayoutInfo layoutInfo,
    Widget? child,
  )
  builder;
  final Widget? child;

  @override
  State<OverflowItemBuilder> createState() => _OverflowItemBuilderState();
}

class _OverflowItemBuilderState extends State<OverflowItemBuilder> {
  OverflowLayoutInfo? _cachedLayoutInfo;
  Widget? _cachedBuildResult;

  Widget _buildLayout(
    BuildContext context,
    ValueBoxConstraints<OverflowLayoutInfo> constraints,
  ) {
    final layoutInfo = constraints.value;
    final cachedBuildResult = _cachedBuildResult;
    if ((layoutInfo._doingDryLayout ||
            (widget.cacheLayoutInfo && layoutInfo == _cachedLayoutInfo)) &&
        cachedBuildResult != null) {
      // print("Cached $constraints");
      return cachedBuildResult;
    } else {
      // print("Eager $constraints");
      final buildResult = widget.builder(context, layoutInfo, widget.child);
      if (!layoutInfo._doingDryLayout) {
        _cachedLayoutInfo = layoutInfo;
        _cachedBuildResult = buildResult;
      }
      return buildResult;
    }
  }

  @override
  void didUpdateWidget(covariant OverflowItemBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cacheLayoutInfo != oldWidget.cacheLayoutInfo &&
        !widget.cacheLayoutInfo) {
      _cachedLayoutInfo = null;
      _cachedBuildResult = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedLayoutInfo = null;
    _cachedBuildResult = null;
  }

  @override
  void dispose() {
    _cachedLayoutInfo = null;
    _cachedBuildResult = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasOverflowAncestor = Overflow._maybeStateOf(context) != null;
    assert(
      hasOverflowAncestor,
      "OverflowLayoutInfoProvider widget must have an Overflow ancestor widget.",
    );
    return _OverflowParentDataWidget(
      child: ValueLayoutBuilder<OverflowLayoutInfo>(builder: _buildLayout),
    );
  }
}

enum _OverflowSlot { overflowIndicator }

class _Overflow extends CompoundRenderObjectWidget<_OverflowSlot, RenderBox> {
  const _Overflow({
    super.key,
    required this.direction,
    this.crossAxisAlignment = .center,
    required this.overflowIndicator,
    this.textDirection,
    required super.children,
  });

  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final Widget overflowIndicator;

  @override
  Iterable<_OverflowSlot> get slots => _OverflowSlot.values;

  @override
  Widget? childForSlot(_OverflowSlot slot) => switch (slot) {
    .overflowIndicator => overflowIndicator,
  };

  @override
  _RenderOverflow createRenderObject(BuildContext context) => _RenderOverflow(
    direction: direction,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection ?? Directionality.maybeOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, _RenderOverflow renderObject) {
    renderObject
      ..direction = direction
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context);
  }
}

class _OverflowParentDataWidget extends ParentDataWidget<_OverflowParentData> {
  const _OverflowParentDataWidget({super.key, required super.child});

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is _OverflowParentData);
    final parentData = renderObject.parentData! as _OverflowParentData;
    var needsLayout = false;

    if (needsLayout) {
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Overflow;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _OverflowParentData extends ContainerBoxParentData<RenderBox> {
  OverflowLayoutInfo _layoutInfo = OverflowLayoutInfo._doingDryLayout(
    isVisible: false,
    visibleChildCount: 1,
    totalChildCount: 1,
  );

  @override
  String toString() =>
      "${super.toString()}; "
      "layoutInfo=$_layoutInfo";
}

extension on CrossAxisAlignment {
  double _getChildCrossAxisOffset(double freeSpace, bool flipped) {
    // This method should not be used to position baseline-aligned children.
    return switch (this) {
      .stretch || .baseline => 0.0,
      .start => flipped ? freeSpace : 0.0,
      .center => freeSpace / 2.0,
      .end => CrossAxisAlignment.start._getChildCrossAxisOffset(
        freeSpace,
        !flipped,
      ),
    };
  }
}

class _RenderOverflow extends RenderBox
    with
        CompoundRenderObjectMixin<
          _OverflowSlot,
          RenderBox,
          _OverflowParentData
        > {
  _RenderOverflow({
    required Axis direction,
    CrossAxisAlignment crossAxisAlignment = .center,
    TextDirection? textDirection,
    List<RenderBox>? children,
  }) : _direction = direction,
       _crossAxisAlignment = crossAxisAlignment {
    addAllIndexedChildren(children);
  }

  Axis _direction;
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  CrossAxisAlignment _crossAxisAlignment;
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  TextDirection? _textDirection;
  TextDirection? get textDirection => _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  RenderBox? get _overflowIndicator => childForSlot(.overflowIndicator);

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  _OverflowParentData _childParentData(RenderBox child) {
    assert(child.parentData != null);
    assert(child.parentData is _OverflowParentData);
    return child.parentData! as _OverflowParentData;
  }

  @pragma("wasm:prefer-inline")
  @pragma("vm:prefer-inline")
  @pragma("dart2js:prefer-inline")
  ValueBoxConstraints<OverflowLayoutInfo> _overflowConstraints(
    BoxConstraints constraints,
    OverflowLayoutInfo info,
  ) => ValueBoxConstraints<OverflowLayoutInfo>(constraints, info);

  double _childMainAxisExtent(Size childSize) => switch (direction) {
    .horizontal => childSize.width,
    .vertical => childSize.height,
  };

  double _childCrossAxisExtent(Size childSize) => switch (direction) {
    .horizontal => childSize.height,
    .vertical => childSize.width,
  };

  BoxConstraints _constraintsForChild(BoxConstraints constraints) {
    final fillCrossAxis = switch (crossAxisAlignment) {
      .stretch => true,
      .start || .center || .end || .baseline => false,
    };
    return switch (direction) {
      .horizontal =>
        fillCrossAxis
            ? BoxConstraints.tightFor(height: constraints.maxHeight)
            : BoxConstraints(maxHeight: constraints.maxHeight),
      .vertical =>
        fillCrossAxis
            ? BoxConstraints.tightFor(width: constraints.maxWidth)
            : BoxConstraints(maxWidth: constraints.maxWidth),
    };
  }

  Size _axisSize(double mainAxisExtent, double crossAxisExtent) =>
      switch (direction) {
        .horizontal => Size(mainAxisExtent, crossAxisExtent),
        .vertical => Size(crossAxisExtent, mainAxisExtent),
      };

  Offset _axisOffset(double mainAxisOffset, double crossAxisOffset) =>
      switch (direction) {
        .horizontal => Offset(mainAxisOffset, crossAxisOffset),
        .vertical => Offset(crossAxisOffset, mainAxisOffset),
      };

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverflowParentData) {
      child.parentData = _OverflowParentData();
    }
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final fillCrossAxis = switch (crossAxisAlignment) {
      .stretch => true,
      .start || .center || .end || .baseline => false,
    };

    Size overflowIndicatorSize = .zero;
    if (_overflowIndicator case final child?) {
      final childLayoutInfo = OverflowLayoutInfo._doingDryLayout(
        isVisible: true,
        visibleChildCount: indexedChildCount,
        totalChildCount: indexedChildCount,
      );
      final childConstraints = _overflowConstraints(
        _constraintsForChild(constraints),
        childLayoutInfo,
      );
      child.layout(childConstraints, parentUsesSize: true);
      overflowIndicatorSize = child.size;
    }

    final overflowIndicatorMainAxisExtent = _childMainAxisExtent(
      overflowIndicatorSize,
    );

    final overflowIndicatorCrossAxisExtent = _childCrossAxisExtent(
      overflowIndicatorSize,
    );

    final maxMainAxisExtent = switch (direction) {
      .horizontal => constraints.maxWidth,
      .vertical => constraints.maxHeight,
    };

    var remainingMainAxisExtent = math.max(
      maxMainAxisExtent - overflowIndicatorMainAxisExtent,
      0.0,
    );

    var mainAxisExtent = 0.0;

    var crossAxisExtent = switch (direction) {
      .horizontal => fillCrossAxis ? constraints.maxHeight : 0.0,
      .vertical => fillCrossAxis ? constraints.maxWidth : 0.0,
    };

    final lastChildIndex = indexedChildCount - 1;

    var lastVisibleChildIndex = -1;

    for (
      var child = firstIndexedChild, childIndex = 0;
      child != null;
      child = indexedChildAfter(child), childIndex++
    ) {
      final isLast = childIndex == lastChildIndex;

      final childParentData = _childParentData(child);
      childParentData._layoutInfo = childParentData._layoutInfo.copyWith(
        isVisible: true,
        visibleChildCount: indexedChildCount,
        totalChildCount: indexedChildCount,
      );

      final childConstraints = _overflowConstraints(
        _constraintsForChild(constraints),
        childParentData._layoutInfo,
      );
      child.layout(childConstraints, parentUsesSize: true);
      final childSize = child.size;
      final childMainAxisExtent = _childMainAxisExtent(childSize);

      final isVisible =
          (childIndex == 0 || lastVisibleChildIndex == childIndex - 1) &&
          (childMainAxisExtent <= remainingMainAxisExtent ||
              (isLast && lastVisibleChildIndex == lastChildIndex - 1));

      childParentData._layoutInfo = childParentData._layoutInfo.copyWith(
        isVisible: isVisible,
      );

      if (isVisible) {
        final childCrossAxisExtent = _childCrossAxisExtent(childSize);
        crossAxisExtent = math.max(crossAxisExtent, childCrossAxisExtent);

        childParentData.offset = _axisOffset(
          mainAxisExtent,
          crossAxisAlignment._getChildCrossAxisOffset(
            crossAxisExtent - childCrossAxisExtent,
            false,
          ),
        );
        mainAxisExtent += childMainAxisExtent;
        remainingMainAxisExtent = math.max(
          remainingMainAxisExtent - childMainAxisExtent,
          0.0,
        );

        lastVisibleChildIndex = childIndex;
      } else {
        childParentData.offset = .zero;
      }
    }
    final hasOverflow = lastVisibleChildIndex < lastChildIndex;

    for (
      var child = firstIndexedChild, childIndex = 0;
      child != null;
      child = indexedChildAfter(child), childIndex++
    ) {
      final childParentData = _childParentData(child);
      childParentData._layoutInfo = childParentData._layoutInfo.copyWith(
        visibleChildCount: lastVisibleChildIndex + 1,
        totalChildCount: indexedChildCount,
      );
      final childConstraints = _overflowConstraints(
        _constraintsForChild(constraints),
        childParentData._layoutInfo,
      );
      child.layout(childConstraints, parentUsesSize: true);
    }

    if (_overflowIndicator case final child?) {
      final childParentData = _childParentData(child);
      final isVisible = hasOverflow;
      childParentData._layoutInfo = childParentData._layoutInfo.copyWith(
        isVisible: isVisible,
        visibleChildCount: lastVisibleChildIndex + 1,
        totalChildCount: indexedChildCount,
      );

      final childConstraints = _overflowConstraints(
        _constraintsForChild(constraints),
        childParentData._layoutInfo,
      );
      child.layout(childConstraints, parentUsesSize: true);

      if (isVisible) {
        crossAxisExtent = math.max(
          crossAxisExtent,
          overflowIndicatorCrossAxisExtent,
        );
        childParentData.offset = _axisOffset(
          mainAxisExtent,
          crossAxisAlignment._getChildCrossAxisOffset(
            crossAxisExtent - overflowIndicatorCrossAxisExtent,
            false,
          ),
        );
        mainAxisExtent += overflowIndicatorMainAxisExtent;
      } else {
        childParentData.offset = .zero;
      }
    }
    size = constraints.constrain(_axisSize(mainAxisExtent, crossAxisExtent));
  }

  void _paintChild(PaintingContext context, RenderBox child) {
    final childParentData = _childParentData(child);
    if (childParentData._layoutInfo.isVisible) {
      context.paintChild(child, childParentData.offset);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.withCanvasTransform((context) {
      if (offset != .zero) {
        context.canvas.translate(offset.dx, offset.dy);
      }

      if (_overflowIndicator case final child?) {
        _paintChild(context, child);
      }

      for (
        var child = firstIndexedChild;
        child != null;
        child = indexedChildAfter(child)
      ) {
        _paintChild(context, child);
      }
    });
  }

  bool _hitTestChild(RenderBox child, BoxHitTestResult result, Offset offset) {
    final childParentData = _childParentData(child);
    return childParentData._layoutInfo.isVisible &&
        result.addWithPaintOffset(
          offset: childParentData.offset,
          position: offset,
          hitTest: (result, position) {
            assert(position == offset - childParentData.offset);
            return child.hitTest(result, position: position);
          },
        );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_overflowIndicator case final child?) {
      final isHit = _hitTestChild(child, result, position);
      if (isHit) return true;
    }
    for (
      var child = firstIndexedChild;
      child != null;
      child = indexedChildAfter(child)
    ) {
      final isHit = _hitTestChild(child, result, position);
      if (isHit) return true;
    }
    return false;
  }
}

@immutable
class OverflowLayoutInfo with Diagnosticable {
  const OverflowLayoutInfo._({
    required bool doingDryLayout,
    required this.isVisible,
    required this.visibleChildCount,
    required this.totalChildCount,
  }) : _doingDryLayout = doingDryLayout;

  const OverflowLayoutInfo._doingDryLayout({
    required this.isVisible,
    required this.visibleChildCount,
    required this.totalChildCount,
  }) : _doingDryLayout = true;

  const OverflowLayoutInfo._doingLayout({
    required this.isVisible,
    required this.visibleChildCount,
    required this.totalChildCount,
  }) : _doingDryLayout = false;

  final bool _doingDryLayout;
  final bool isVisible;

  final int visibleChildCount;
  final int totalChildCount;

  int get overflowChildCount => totalChildCount - visibleChildCount;

  OverflowLayoutInfo copyWith({
    bool? isVisible,
    int? visibleChildCount,
    int? totalChildCount,
  }) =>
      isVisible != null || visibleChildCount != null || totalChildCount != null
      ? ._(
          doingDryLayout: _doingDryLayout,
          isVisible: isVisible ?? this.isVisible,
          visibleChildCount: visibleChildCount ?? this.visibleChildCount,
          totalChildCount: totalChildCount ?? this.totalChildCount,
        )
      : this;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        FlagProperty(
          "doingDryLayout",
          value: _doingDryLayout,
          ifTrue: "doing dry layout",
        ),
      )
      ..add(
        FlagProperty(
          "visibility",
          value: isVisible,
          ifFalse: "hidden",
          ifTrue: "visible",
        ),
      )
      ..add(IntProperty("visibleChildCount", visibleChildCount))
      ..add(IntProperty("totalChildCount", totalChildCount));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is OverflowLayoutInfo &&
          _doingDryLayout == other._doingDryLayout &&
          isVisible == other.isVisible &&
          visibleChildCount == other.visibleChildCount &&
          totalChildCount == other.totalChildCount;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    _doingDryLayout,
    isVisible,
    visibleChildCount,
    totalChildCount,
  );
}
