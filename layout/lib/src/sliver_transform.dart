import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'sliver.dart';

class SliverTransform extends SingleChildRenderObjectWidget {
  /// Creates a widget that transforms its child.
  const SliverTransform({
    super.key,
    required this.transform,
    this.origin,
    this.alignment,
    this.transformHitTests = true,
    this.filterQuality,
    Widget? sliver,
  }) : super(child: sliver);

  /// Creates a widget that transforms its child using a rotation around the
  /// center.
  ///
  /// The `angle` argument gives the rotation in clockwise radians.
  ///
  /// {@tool snippet}
  ///
  /// This example rotates an orange box containing text around its center by
  /// fifteen degrees.
  ///
  /// ```dart
  /// Transform.rotate(
  ///   angle: -math.pi / 12.0,
  ///   child: Container(
  ///     padding: const EdgeInsets.all(8.0),
  ///     color: const Color(0xFFE8581C),
  ///     child: const Text('Apartment for rent!'),
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [RotationTransition], which animates changes in rotation smoothly
  ///    over a given duration.
  SliverTransform.rotate({
    super.key,
    required double angle,
    this.origin,
    this.alignment = .center,
    this.transformHitTests = true,
    this.filterQuality,
    Widget? sliver,
  }) : transform = _computeRotation(angle),
       super(child: sliver);

  /// Creates a widget that transforms its child using a translation.
  ///
  /// The `offset` argument specifies the translation.
  ///
  /// {@tool snippet}
  ///
  /// This example shifts the silver-colored child down by fifteen pixels.
  ///
  /// ```dart
  /// Transform.translate(
  ///   offset: const Offset(0.0, 15.0),
  ///   child: Container(
  ///     padding: const EdgeInsets.all(8.0),
  ///     color: const Color(0xFF7F7F7F),
  ///     child: const Text('Quarter'),
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  SliverTransform.translate({
    super.key,
    required Offset offset,
    this.transformHitTests = true,
    this.filterQuality,
    Widget? sliver,
  }) : transform = .translationValues(offset.dx, offset.dy, 0.0),
       origin = null,
       alignment = null,
       super(child: sliver);

  /// Creates a widget that scales its child along the 2D plane.
  ///
  /// The `scaleX` argument provides the scalar by which to multiply the `x`
  /// axis, and the `scaleY` argument provides the scalar by which to multiply
  /// the `y` axis. Either may be omitted, in which case the scaling factor for
  /// that axis defaults to 1.0.
  ///
  /// For convenience, to scale the child uniformly, instead of providing
  /// `scaleX` and `scaleY`, the `scale` parameter may be used.
  ///
  /// At least one of `scale`, `scaleX`, and `scaleY` must be non-null. If
  /// `scale` is provided, the other two must be null; similarly, if it is not
  /// provided, one of the other two must be provided.
  ///
  /// The [alignment] controls the origin of the scale; by default, this is the
  /// center of the box.
  ///
  /// {@tool snippet}
  ///
  /// This example shrinks an orange box containing text such that each
  /// dimension is half the size it would otherwise be.
  ///
  /// ```dart
  /// Transform.scale(
  ///   scale: 0.5,
  ///   child: Container(
  ///     padding: const EdgeInsets.all(8.0),
  ///     color: const Color(0xFFE8581C),
  ///     child: const Text('Bad Idea Bears'),
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  /// * [ScaleTransition], which animates changes in scale smoothly over a given
  ///   duration.
  SliverTransform.scale({
    super.key,
    double? scale,
    double? scaleX,
    double? scaleY,
    this.origin,
    this.alignment = .center,
    this.transformHitTests = true,
    this.filterQuality,
    Widget? sliver,
  }) : assert(
         !(scale == null && scaleX == null && scaleY == null),
         "At least one of 'scale', 'scaleX' and 'scaleY' is required to be non-null",
       ),
       assert(
         scale == null || (scaleX == null && scaleY == null),
         "If 'scale' is non-null then 'scaleX' and 'scaleY' must be left null",
       ),
       transform = .diagonal3Values(
         scale ?? scaleX ?? 1.0,
         scale ?? scaleY ?? 1.0,
         1.0,
       ),
       super(child: sliver);

  /// Creates a widget that mirrors its child about the widget's center point.
  ///
  /// If `flipX` is true, the child widget will be flipped horizontally. Defaults to false.
  ///
  /// If `flipY` is true, the child widget will be flipped vertically. Defaults to false.
  ///
  /// If both are true, the child widget will be flipped both vertically and horizontally, equivalent to a 180 degree rotation.
  ///
  /// {@tool snippet}
  ///
  /// This example flips the text horizontally.
  ///
  /// ```dart
  /// Transform.flip(
  ///   flipX: true,
  ///   child: const Text('Horizontal Flip'),
  /// )
  /// ```
  /// {@end-tool}
  SliverTransform.flip({
    super.key,
    bool flipX = false,
    bool flipY = false,
    this.origin,
    this.transformHitTests = true,
    this.filterQuality,
    Widget? sliver,
  }) : alignment = .center,
       transform = .diagonal3Values(
         flipX ? -1.0 : 1.0,
         flipY ? -1.0 : 1.0,
         1.0,
       ),
       super(child: sliver);

  // Computes a rotation matrix for an angle in radians, attempting to keep rotations
  // at integral values for angles of 0, π/2, π, 3π/2.
  static Matrix4 _computeRotation(double radians) {
    assert(
      radians.isFinite,
      'Cannot compute the rotation matrix for a non-finite angle: $radians',
    );
    if (radians == 0.0) {
      return .identity();
    }
    final sin = math.sin(radians);
    if (sin == 1.0) {
      return _createZRotation(1.0, 0.0);
    }
    if (sin == -1.0) {
      return _createZRotation(-1.0, 0.0);
    }
    final double cos = math.cos(radians);
    if (cos == -1.0) {
      return _createZRotation(0.0, -1.0);
    }
    return _createZRotation(sin, cos);
  }

  static Matrix4 _createZRotation(double sin, double cos) {
    final result = Matrix4.zero();
    result.storage[0] = cos;
    result.storage[1] = sin;
    result.storage[4] = -sin;
    result.storage[5] = cos;
    result.storage[10] = 1.0;
    result.storage[15] = 1.0;
    return result;
  }

  /// The matrix to transform the child by during painting.
  final Matrix4 transform;

  /// The origin of the coordinate system in which to apply the matrix,
  /// described relative to the point given by [alignment].
  ///
  /// Setting an origin is equivalent to conjugating the transform matrix by a
  /// translation. This property is provided just for convenience.
  ///
  /// This offset is applied in addition to any [alignment] transformation, so in this
  /// example, the child is rotated about its center, since [alignment]
  /// in [Transform.rotate] defaults to [Alignment.center]:
  ///
  /// ```dart
  /// Transform.rotate(
  ///   angle: math.pi,
  ///   child: Container(
  ///    width: 150.0,
  ///    height: 150.0,
  ///    color: Colors.blue,
  ///  ),
  /// )
  /// ```
  ///
  /// However, in this example the [origin] offset is applied after the
  /// `alignment`, so the child rotates about its bottom-right corner:
  ///
  /// ```dart
  /// Transform.rotate(
  ///   angle: math.pi,
  ///   origin: const Offset(75.0, 75.0),
  ///   child: Container(
  ///    width: 150.0,
  ///    height: 150.0,
  ///    color: Colors.blue,
  ///  ),
  /// )
  /// ```
  final Offset? origin;

  /// The alignment of the origin, relative to the size of the box.
  ///
  /// When this and [origin] are both null, the origin is the upper-left corner
  /// of this render object.
  /// The default for this field is null for some constructors,
  /// and [Alignment.center] for others.
  ///
  /// This is equivalent to setting an origin based on the size of the box.
  /// If it is specified at the same time as the [origin], both are applied.
  ///
  /// An [AlignmentDirectional.centerStart] value is the same as an [Alignment]
  /// whose [Alignment.x] value is `-1.0` if [Directionality.of] returns
  /// [TextDirection.ltr], and `1.0` if [Directionality.of] returns
  /// [TextDirection.rtl].	 Similarly [AlignmentDirectional.centerEnd] is the
  /// same as an [Alignment] whose [Alignment.x] value is `1.0` if
  /// [Directionality.of] returns	 [TextDirection.ltr], and `-1.0` if
  /// [Directionality.of] returns [TextDirection.rtl].
  final AlignmentGeometry? alignment;

  /// Whether to apply the transformation when performing hit tests.
  final bool transformHitTests;

  /// The filter quality with which to apply the transform as a bitmap operation.
  ///
  /// {@template flutter.widgets.Transform.optional.FilterQuality}
  /// The transform will be applied by re-rendering the child if [filterQuality] is null,
  /// otherwise it controls the quality of an [ImageFilter.matrix] applied to a bitmap
  /// rendering of the child.
  /// {@endtemplate}
  final FilterQuality? filterQuality;

  @override
  RenderSliverTransform createRenderObject(BuildContext context) {
    return RenderSliverTransform(
      transform: transform,
      origin: origin,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverTransform renderObject,
  ) {
    renderObject
      ..transform = transform
      ..origin = origin
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..transformHitTests = transformHitTests
      ..filterQuality = filterQuality;
  }
}

/// Applies a transformation before painting its child.
class RenderSliverTransform extends RenderProxySliver {
  /// Creates a render object that transforms its child.
  RenderSliverTransform({
    required Matrix4 transform,
    Offset? origin,
    AlignmentGeometry? alignment,
    TextDirection? textDirection,
    this.transformHitTests = true,
    FilterQuality? filterQuality,
    RenderSliver? child,
  }) : super(child) {
    this.transform = transform;
    this.alignment = alignment;
    this.textDirection = textDirection;
    this.filterQuality = filterQuality;
    this.origin = origin;
  }

  /// The origin of the coordinate system (relative to the upper left corner of
  /// this render object) in which to apply the matrix.
  ///
  /// Setting an origin is equivalent to conjugating the transform matrix by a
  /// translation. This property is provided just for convenience.
  Offset? get origin => _origin;
  Offset? _origin;
  set origin(Offset? value) {
    if (_origin == value) {
      return;
    }
    _origin = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// The alignment of the origin, relative to the size of the box.
  ///
  /// This is equivalent to setting an origin based on the size of the box.
  /// If it is specified at the same time as an offset, both are applied.
  ///
  /// An [AlignmentDirectional.centerStart] value is the same as an [Alignment]
  /// whose [Alignment.x] value is `-1.0` if [textDirection] is
  /// [TextDirection.ltr], and `1.0` if [textDirection] is [TextDirection.rtl].
  /// Similarly [AlignmentDirectional.centerEnd] is the same as an [Alignment]
  /// whose [Alignment.x] value is `1.0` if [textDirection] is
  /// [TextDirection.ltr], and `-1.0` if [textDirection] is [TextDirection.rtl].
  AlignmentGeometry? get alignment => _alignment;
  AlignmentGeometry? _alignment;
  set alignment(AlignmentGeometry? value) {
    if (_alignment == value) {
      return;
    }
    _alignment = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to null, but only after [alignment] has been changed
  /// to a value that does not depend on the direction.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  bool get alwaysNeedsCompositing => child != null && _filterQuality != null;

  /// When set to true, hit tests are performed based on the position of the
  /// child as it is painted. When set to false, hit tests are performed
  /// ignoring the transformation.
  ///
  /// [applyPaintTransform], and therefore [localToGlobal] and [globalToLocal],
  /// always honor the transformation, regardless of the value of this property.
  bool transformHitTests;

  Matrix4? _transform;

  /// The matrix to transform the child by during painting. The provided value
  /// is copied on assignment.
  ///
  /// There is no getter for [transform], because [Matrix4] is mutable, and
  /// mutations outside of the control of the render object could not reliably
  /// be reflected in the rendering.
  // ignore: avoid_setters_without_getters
  set transform(Matrix4 value) {
    if (_transform == value) {
      return;
    }
    _transform = .copy(value);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// The filter quality with which to apply the transform as a bitmap operation.
  ///
  /// {@macro flutter.widgets.Transform.optional.FilterQuality}
  FilterQuality? get filterQuality => _filterQuality;
  FilterQuality? _filterQuality;
  set filterQuality(FilterQuality? value) {
    if (_filterQuality == value) {
      return;
    }
    final bool didNeedCompositing = alwaysNeedsCompositing;
    _filterQuality = value;
    if (didNeedCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
  }

  /// Sets the transform to the identity matrix.
  void setIdentity() {
    _transform!.setIdentity();
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// Concatenates a rotation about the x axis into the transform.
  void rotateX(double radians) {
    _transform!.rotateX(radians);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// Concatenates a rotation about the y axis into the transform.
  void rotateY(double radians) {
    _transform!.rotateY(radians);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// Concatenates a rotation about the z axis into the transform.
  void rotateZ(double radians) {
    _transform!.rotateZ(radians);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// Concatenates a translation by (x, y, z) into the transform.
  void translate(double x, [double y = 0.0, double z = 0.0]) {
    _transform!.translateByDouble(x, y, z, 1.0);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// Concatenates a scale into the transform.
  void scale(double x, [double? y, double? z]) {
    _transform!.scaleByDouble(x, y ?? x, z ?? x, 1.0);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  Matrix4? get _effectiveTransform {
    final resolvedAlignment = alignment?.resolve(textDirection);
    if (_origin == null && resolvedAlignment == null) {
      return _transform;
    }
    final result = Matrix4.identity();
    if (_origin != null) {
      result.translateByDouble(_origin!.dx, _origin!.dy, 0.0, 1.0);
    }
    Offset? translation;
    if (resolvedAlignment != null) {
      // translation = resolvedAlignment.alongSize(size);
      translation = resolvedAlignment.alongSize(getAbsoluteSize());
      result.translateByDouble(translation.dx, translation.dy, 0.0, 1.0);
    }
    result.multiply(_transform!);
    if (resolvedAlignment != null) {
      result.translateByDouble(-translation!.dx, -translation.dy, 0.0, 1.0);
    }
    if (_origin != null) {
      result.translateByDouble(-_origin!.dx, -_origin!.dy, 0.0, 1.0);
    }
    return result;
  }

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

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    // assert(!transformHitTests || _effectiveTransform != null);
    // return result.addWithPaintTransform(
    //   transform: transformHitTests ? _effectiveTransform : null,
    //   position: position,
    //   hitTest: (BoxHitTestResult result, Offset position) {
    //     return super.hitTestChildren(result, position: position);
    //   },
    // );
    assert(geometry != null);
    assert(!debugNeedsLayout);
    return result.addWithPaintTransform(
      transform: transformHitTests ? _effectiveTransform : null,
      axisDirection: constraints.axisDirection,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
      hitTest: super.hitTestChildren,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final transform = _effectiveTransform!;
      if (filterQuality == null) {
        final childOffset = MatrixUtils.getAsTranslation(transform);
        if (childOffset == null) {
          // if the matrix is singular the children would be compressed to a line or
          // single point, instead short-circuit and paint nothing.
          final det = transform.determinant();
          if (det == 0 || !det.isFinite) {
            layer = null;
            return;
          }
          layer = context.pushTransform(
            needsCompositing,
            offset,
            transform,
            super.paint,
            oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
          );
        } else {
          super.paint(context, offset + childOffset);
          layer = null;
        }
      } else {
        final effectiveTransform =
            Matrix4.translationValues(offset.dx, offset.dy, 0.0)
              ..multiply(transform)
              ..translateByDouble(-offset.dx, -offset.dy, 0.0, 1.0);
        final filter = ui.ImageFilter.matrix(
          effectiveTransform.storage,
          filterQuality: filterQuality!,
        );
        if (layer case final ImageFilterLayer filterLayer) {
          filterLayer.imageFilter = filter;
        } else {
          layer = ImageFilterLayer(imageFilter: filter);
        }
        context.pushLayer(layer!, super.paint, offset);
        assert(() {
          layer!.debugCreator = debugCreator;
          return true;
        }());
      }
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    transform.multiply(_effectiveTransform!);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(TransformProperty("transform matrix", _transform))
      ..add(DiagnosticsProperty<Offset>("origin", origin))
      ..add(DiagnosticsProperty<AlignmentGeometry>("alignment", alignment))
      ..add(
        EnumProperty<TextDirection>(
          "textDirection",
          textDirection,
          defaultValue: null,
        ),
      )
      ..add(DiagnosticsProperty<bool>("transformHitTests", transformHitTests));
  }
}
