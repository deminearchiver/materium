part of 'buttons.dart';

// P.S. - Thanks to [ButtonStyleButton] authors.

/// A widget to pad the area around a [ButtonContainer]'s inner [Material].
///
/// Redirect taps that occur in the padded area around the child to the center
/// of the child. This increases the size of the button and the button's
/// "tap target", but not its material or its ink splashes.
class _InputPadding extends SingleChildRenderObjectWidget {
  const _InputPadding({super.child, required this.minTapTargetSize});

  final Size minTapTargetSize;

  @override
  _RenderInputPadding createRenderObject(BuildContext context) =>
      _RenderInputPadding(minTapTargetSize: minTapTargetSize);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderInputPadding renderObject,
  ) {
    renderObject.minTapTargetSize = minTapTargetSize;
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding({required Size minTapTargetSize, RenderBox? child})
    : _minTapTargetSize = minTapTargetSize,
      super(child);

  Size _minTapTargetSize;

  Size get minTapTargetSize => _minTapTargetSize;

  set minTapTargetSize(Size value) {
    if (_minTapTargetSize == value) return;
    _minTapTargetSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child case final child?) {
      return math.max(
        child.getMinIntrinsicWidth(height),
        minTapTargetSize.width,
      );
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child case final child?) {
      return math.max(
        child.getMinIntrinsicHeight(width),
        minTapTargetSize.height,
      );
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child case final child?) {
      return math.max(
        child.getMaxIntrinsicWidth(height),
        minTapTargetSize.width,
      );
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child case final child?) {
      return math.max(
        child.getMaxIntrinsicHeight(width),
        minTapTargetSize.height,
      );
    }
    return 0.0;
  }

  Size _layout({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
    required ChildPositioner positionChild,
  }) {
    if (child case final child?) {
      final childSize = layoutChild(child, constraints);
      final size = constraints.constrain(
        Size(
          math.max(childSize.width, minTapTargetSize.width),
          math.max(childSize.height, minTapTargetSize.height),
        ),
      );

      final offset = Alignment.center.alongOffset(size - childSize as Offset);
      positionChild(child, offset);

      return size;
    }
    return .zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(
    constraints: constraints,
    layoutChild: ChildLayoutHelper.dryLayoutChild,
    positionChild: ChildLayoutHelper.dryPositionChild,
  );

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final child = this.child;
    if (child == null) return null;
    final result = child.getDryBaseline(constraints, baseline);
    if (result == null) return null;
    final childSize = child.getDryLayout(constraints);
    return result +
        Alignment.center
            .alongOffset(getDryLayout(constraints) - childSize as Offset)
            .dy;
  }

  @override
  void performLayout() {
    size = _layout(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
      positionChild: ChildLayoutHelper.positionChild,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    if (child case final child?) {
      final center = child.size.center(Offset.zero);
      return result.addWithRawTransform(
        transform: MatrixUtils.forceToPoint(center),
        position: center,
        hitTest: (result, position) {
          assert(position == center);
          return child.hitTest(result, position: center);
        },
      );
    }
    return false;
  }
}

class _TextStyleTween extends Tween<TextStyle?> {
  _TextStyleTween({super.begin, super.end});

  @override
  TextStyle? lerp(double t) => TextStyle.lerp(begin, end, t);
}
