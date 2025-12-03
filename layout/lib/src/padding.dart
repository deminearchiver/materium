import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:layout/layout.dart';

/// A widget that insets its child by the given padding.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=oD5RtLhhubg}
///
/// When passing layout constraints to its child, padding shrinks the
/// constraints by the given padding, causing the child to layout at a smaller
/// size. Padding then sizes itself to its child's size, inflated by the
/// padding, effectively creating empty space around the child.
///
/// {@tool snippet}
///
/// This snippet creates "Hello World!" [Text] inside a [Card] that is indented
/// by sixteen pixels in each direction.
///
/// ![](https://flutter.github.io/assets-for-api-docs/assets/widgets/padding.png)
///
/// ```dart
/// const Card(
///   child: Padding(
///     padding: EdgeInsets.all(16.0),
///     child: Text('Hello World!'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// ## Design discussion
///
/// ### Why use a [Padding] widget rather than a [Container] with a [Container.padding] property?
///
/// There isn't really any difference between the two. If you supply a
/// [Container.padding] argument, [Container] builds a [Padding] widget
/// for you.
///
/// [Container] doesn't implement its properties directly. Instead, [Container]
/// combines a number of simpler widgets together into a convenient package. For
/// example, the [Container.padding] property causes the container to build a
/// [Padding] widget and the [Container.decoration] property causes the
/// container to build a [DecoratedBox] widget. If you find [Container]
/// convenient, feel free to use it. If not, feel free to build these simpler
/// widgets in whatever combination meets your needs.
///
/// In fact, the majority of widgets in Flutter are combinations of other
/// simpler widgets. Composition, rather than inheritance, is the primary
/// mechanism for building up widgets.
///
/// See also:
///
///  * [EdgeInsets], the class that is used to describe the padding dimensions.
///  * [AnimatedPadding], which animates changes in [padding] over a given
///    duration.
///  * [SliverPadding], the sliver equivalent of this widget.
///  * The [catalog of layout widgets](https://flutter.dev/widgets/layout/).
class Padding extends SingleChildRenderObjectWidget {
  /// Creates a widget that insets its child.
  const Padding({super.key, required this.padding, super.child});

  /// The amount of space by which to inset the child.
  final EdgeInsetsGeometry padding;

  @override
  RenderPadding createRenderObject(BuildContext context) => RenderPadding(
    padding: padding,
    textDirection: Directionality.maybeOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderPadding renderObject) {
    renderObject
      ..padding = padding
      ..textDirection = Directionality.maybeOf(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>("padding", padding));
  }
}

/// Insets its child by the given padding.
///
/// When passing layout constraints to its child, padding shrinks the
/// constraints by the given padding, causing the child to layout at a smaller
/// size. Padding then sizes itself to its child's size, inflated by the
/// padding, effectively creating empty space around the child.
class RenderPadding extends RenderShiftedBox {
  /// Creates a render object that insets its child.
  RenderPadding({
    required EdgeInsetsGeometry padding,
    TextDirection? textDirection,
    RenderBox? child,
  }) : _textDirection = textDirection,
       _padding = padding,
       super(child);

  EdgeInsets? _resolvedPaddingCache;
  EdgeInsets get _resolvedPadding =>
      _resolvedPaddingCache ??= padding.resolve(textDirection);

  void _markNeedResolution() {
    _resolvedPaddingCache = null;
    markNeedsLayout();
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;
  set padding(EdgeInsetsGeometry value) {
    if (_padding == value) return;
    _padding = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [padding].
  ///
  /// This may be changed to null, but only after the [padding] has been changed
  /// to a value that does not depend on the direction.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedResolution();
  }

  Size _layout({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
    required ChildPositioner positionChild,
  }) {
    final padding = _resolvedPadding;
    if (child case final child?) {
      final childSize = layoutChild(child, constraints.deflate(padding));
      positionChild(child, Offset(padding.left, padding.top));
      return constraints.constrainDimensions(
        math.max(0.0, padding.horizontal + childSize.width),
        math.max(0.0, padding.vertical + childSize.height),
      );
    } else {
      return constraints.constrainDimensions(
        math.max(0.0, padding.horizontal),
        math.max(0.0, padding.vertical),
      );
    }
  }

  void _dryPositionChild(RenderBox _, Offset _) {}

  void _positionChild(RenderBox child, Offset position) {
    assert(child.parentData != null && child.parentData is BoxParentData);
    (child.parentData! as BoxParentData).offset = position;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final padding = _resolvedPadding;
    return switch (child) {
      // Relies on double.infinity absorption.
      final child? => math.max(
        0.0,
        child.getMinIntrinsicWidth(math.max(0.0, height - padding.vertical)) +
            padding.horizontal,
      ),
      _ => math.max(0.0, padding.horizontal),
    };
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final padding = _resolvedPadding;
    return switch (child) {
      // Relies on double.infinity absorption.
      final child? => math.max(
        0.0,
        child.getMaxIntrinsicWidth(math.max(0.0, height - padding.vertical)) +
            padding.horizontal,
      ),
      _ => math.max(0.0, padding.horizontal),
    };
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final padding = _resolvedPadding;
    return switch (child) {
      // Relies on double.infinity absorption.
      final child? => math.max(
        0.0,
        child.getMinIntrinsicHeight(math.max(0.0, width - padding.horizontal)) +
            padding.vertical,
      ),
      _ => math.max(0.0, padding.vertical),
    };
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final padding = _resolvedPadding;
    return switch (child) {
      // Relies on double.infinity absorption.
      final child? => math.max(
        0.0,
        child.getMaxIntrinsicHeight(math.max(0.0, width - padding.horizontal)) +
            padding.vertical,
      ),
      _ => math.max(0.0, padding.vertical),
    };
  }

  @override
  @protected
  Size computeDryLayout(covariant BoxConstraints constraints) => _layout(
    constraints: constraints,
    layoutChild: ChildLayoutHelper.dryLayoutChild,
    positionChild: _dryPositionChild,
  );

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    if (child case final child?) {
      final padding = _resolvedPadding;
      final result =
          BaselineOffset(
            child.getDryBaseline(constraints.deflate(padding), baseline),
          ) +
          padding.top;
      return result.offset;
    }
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

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      final outerRect = offset & size;
      debugPaintPadding(
        context.canvas,
        outerRect,
        child != null ? _resolvedPaddingCache!.deflateRect(outerRect) : null,
      );
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>("padding", padding))
      ..add(
        EnumProperty<TextDirection>(
          "textDirection",
          textDirection,
          defaultValue: null,
        ),
      );
  }
}
