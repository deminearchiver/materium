import 'dart:math' as math;

import 'package:material/material_shapes.dart';
import 'package:materium/flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Rotate by 36 degrees.
const _kRotationDelta = math.pi / 5.0;

/// Design size of the expressive list bullet.
const _kDesignSize = 8.0;

/// Center of the expressive list bullet design viewbox.
const _kDesignSizeCenter = _kDesignSize / 2.0;

/// Static path in a 8x8 viewbox.
final _kDesignPath = Path()
  ..moveTo(4.95843, 0.279933)
  ..cubicTo(5.5378, -0.353974, 6.58452, 0.173492, 6.41974, 1.01632)
  ..lineTo(6.05454, 2.88412)
  ..cubicTo(5.99767, 3.17501, 6.09646, 3.47451, 6.31525, 3.67447)
  ..lineTo(7.72007, 4.95843)
  ..cubicTo(8.35397, 5.5378, 7.82651, 6.58452, 6.98368, 6.41974)
  ..lineTo(5.11588, 6.05454)
  ..cubicTo(4.82499, 5.99767, 4.52549, 6.09646, 4.32553, 6.31525)
  ..lineTo(3.04157, 7.72007)
  ..cubicTo(2.4622, 8.35397, 1.41548, 7.82651, 1.58026, 6.98368)
  ..lineTo(1.94545, 5.11588)
  ..cubicTo(2.00233, 4.82499, 1.90354, 4.52549, 1.68475, 4.32553)
  ..lineTo(0.279933, 3.04157)
  ..cubicTo(-0.353974, 2.4622, 0.173492, 1.41548, 1.01632, 1.58026)
  ..lineTo(2.88412, 1.94545)
  ..cubicTo(3.17501, 2.00233, 3.47451, 1.90354, 3.67447, 1.68475)
  ..lineTo(4.95843, 0.279933)
  ..close();

class ExpressiveListBullet extends StatelessWidget {
  const ExpressiveListBullet({
    super.key,
    this.rotation = 0.0,
    this.size,
    this.color,
    this.outline = const .from(),
    this.opacity,
    this.semanticLabel,
  });

  const ExpressiveListBullet.indexed({
    super.key,
    required int index,
    this.size,
    this.color,
    this.outline = const .from(),
    this.opacity,
    this.semanticLabel,
  }) : rotation = index * _kRotationDelta;

  final double rotation;

  final double? size;

  final Color? color;

  final Outline outline;

  final double? opacity;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final shapeTheme = ShapeTheme.of(context);
    final iconTheme = IconTheme.of(context);

    final size = this.size ?? iconTheme.size;

    final opacity = this.opacity ?? iconTheme.opacity;
    var color = this.color ?? iconTheme.color;
    if (opacity != 1.0) {
      color = color.withValues(alpha: color.a * opacity);
    }

    return ExcludeSemantics(
      child: Align.center(
        child: Skeleton.leaf(
          child: Skeleton.replace(
            width: size,
            height: size,
            replacement: Surface(
              shape: shapeTheme.applyCorner(corner: shapeTheme.cornerFull),
              color: color,
            ),
            child: Surface(
              clipBehavior: .none,
              shape: _ExpressiveListBulletBorder(
                side: outline.toBorderSide(),
                rotation: rotation,
              ),
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

final class _ExpressiveListBulletBorder extends StaticPathBorder {
  const _ExpressiveListBulletBorder({
    super.side,
    super.strokeCap = .round,
    super.strokeJoin = .round,
    super.strokeMiterLimit = 0.0,
    super.squash = 0.0,
    this.rotation = 0.0,
  });

  final double rotation;

  @override
  Path get path {
    final matrix = Matrix4.identity()
      ..scaleByDouble(1 / _kDesignSize, 1 / _kDesignSize, 1.0, 1.0)
      ..translateByDouble(_kDesignSizeCenter, _kDesignSizeCenter, 0.0, 1.0)
      ..rotateZ(rotation)
      ..translateByDouble(-_kDesignSizeCenter, -_kDesignSizeCenter, 0.0, 1.0);
    return _kDesignPath.transform(matrix.storage);
  }

  @override
  _ExpressiveListBulletBorder copyWith({
    BorderSide? side,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    double? strokeMiterLimit,
    double? squash,
    double? rotation,
  }) => _ExpressiveListBulletBorder(
    side: side ?? this.side,
    strokeCap: strokeCap ?? this.strokeCap,
    strokeJoin: strokeJoin ?? this.strokeJoin,
    strokeMiterLimit: strokeMiterLimit ?? this.strokeMiterLimit,
    squash: squash ?? this.squash,
    rotation: rotation ?? this.rotation,
  );

  @override
  _ExpressiveListBulletBorder scale(double t) => _ExpressiveListBulletBorder(
    side: side.scale(t),
    strokeCap: strokeCap,
    strokeJoin: strokeJoin,
    strokeMiterLimit: strokeMiterLimit,
    squash: squash,
    rotation: rotation,
  );

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write(objectRuntimeType(this, "_ExpressiveListBulletBorder"))
      ..write("($side");
    if (strokeCap != .butt) {
      buffer.write(", strokeCap: $strokeCap");
    }
    if (strokeJoin != .miter) {
      buffer.write(", strokeJoin: $strokeJoin");
    } else if (strokeMiterLimit != 4.0) {
      buffer.write(", strokeMiterLimit: $strokeMiterLimit");
    }
    if (squash != 0.0) {
      buffer.write(", squash: $squash");
    }
    if (rotation != 0.0) {
      buffer.write(", rotation: $rotation");
    }
    buffer.write(")");
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ExpressiveListBulletBorder &&
          side == other.side &&
          strokeCap == other.strokeCap &&
          strokeJoin == other.strokeJoin &&
          strokeMiterLimit == other.strokeMiterLimit &&
          squash == other.squash &&
          rotation == other.rotation;

  @override
  int get hashCode => Object.hash(
    side,
    strokeCap,
    strokeJoin,
    strokeMiterLimit,
    squash,
    rotation,
  );
}
