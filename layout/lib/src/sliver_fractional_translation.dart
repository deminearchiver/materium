import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:layout/src/sliver.dart';

/// Applies a translation transformation before painting its child.
///
/// The translation is expressed as a [Offset] scaled to the child's size. For
/// example, an [Offset] with a `dx` of 0.25 will result in a horizontal
/// translation of one quarter the width of the child.
///
/// Hit tests will only be detected inside the bounds of the
/// [SliverFractionalTranslation], even if the contents are offset such that
/// they overflow.
///
/// See also:
///
///  * [Transform], which applies an arbitrary transform to its child widget at
///    paint time.
///  * [Transform.translate], which applies an absolute offset translation
///    transformation instead of an offset scaled to the child.
///  * The [catalog of layout widgets](https://flutter.dev/widgets/layout/).
class SliverFractionalTranslation extends SingleChildRenderObjectWidget {
  /// Creates a widget that translates its child's painting.
  const SliverFractionalTranslation({
    super.key,
    required this.translation,
    this.transformHitTests = true,
    Widget? sliver,
  }) : super(child: sliver);

  /// The translation to apply to the child, scaled to the child's size.
  ///
  /// For example, an [Offset] with a `dx` of 0.25 will result in a horizontal
  /// translation of one quarter the width of the child.
  final Offset translation;

  /// Whether to apply the translation when performing hit tests.
  final bool transformHitTests;

  @override
  RenderSliverFractionalTranslation createRenderObject(BuildContext context) =>
      RenderSliverFractionalTranslation(
        translation: translation,
        transformHitTests: transformHitTests,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverFractionalTranslation renderObject,
  ) {
    renderObject
      ..translation = translation
      ..transformHitTests = transformHitTests;
  }
}

/// Applies a translation transformation before painting its child.
///
/// The translation is expressed as an [Offset] scaled to the child's size. For
/// example, an [Offset] with a `dx` of 0.25 will result in a horizontal
/// translation of one quarter the width of the child.
///
/// Hit tests will only be detected inside the bounds of the
/// [RenderSliverFractionalTranslation], even if the contents are offset such that
/// they overflow.
class RenderSliverFractionalTranslation extends RenderProxySliver {
  /// Creates a render object that translates its child's painting.
  RenderSliverFractionalTranslation({
    required Offset translation,
    this.transformHitTests = true,
    RenderSliver? child,
  }) : _translation = translation,
       super(child);

  /// The translation to apply to the child, scaled to the child's size.
  ///
  /// For example, an [Offset] with a `dx` of 0.25 will result in a horizontal
  /// translation of one quarter the width of the child.
  Offset get translation => _translation;
  Offset _translation;
  set translation(Offset value) {
    if (_translation == value) {
      return;
    }
    _translation = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  // RenderFractionalTranslation objects don't check if they are
  // themselves hit, because it's confusing to think about
  // how the untransformed size and the child's transformed
  // position interact.
  @override
  bool hitTest(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) => hitTestChildren(
    result,
    mainAxisPosition: mainAxisPosition,
    crossAxisPosition: crossAxisPosition,
  );

  /// When set to true, hit tests are performed based on the position of the
  /// child as it is painted. When set to false, hit tests are performed
  /// ignoring the transformation.
  ///
  /// applyPaintTransform(), and therefore localToGlobal() and globalToLocal(),
  /// always honor the transformation, regardless of the value of this property.
  bool transformHitTests;

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    assert(!debugNeedsLayout);
    final size = getAbsoluteSize();
    final offset = transformHitTests
        ? Offset(translation.dx * size.width, translation.dy * size.height)
        : null;
    return result.addWithPaintOffset(
      offset: offset,
      axisDirection: constraints.axisDirection,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
      hitTest: super.hitTestChildren,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(!debugNeedsLayout);
    final size = getAbsoluteSize();
    if (child != null) {
      super.paint(
        context,
        Offset(
          offset.dx + translation.dx * size.width,
          offset.dy + translation.dy * size.height,
        ),
      );
    }
  }

  @override
  void applyPaintTransform(RenderSliver child, Matrix4 transform) {
    final size = getAbsoluteSize();
    transform.translateByDouble(
      translation.dx * size.width,
      translation.dy * size.height,
      0.0,
      1.0,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Offset>("translation", translation))
      ..add(DiagnosticsProperty<bool>("transformHitTests", transformHitTests));
  }
}
