import 'dart:math' as math;

import 'package:materium/flutter.dart';

const _kRotationMultiplier = math.pi / 5.0;

class ExpressiveListBullet extends StatelessWidget {
  const ExpressiveListBullet({
    super.key,
    this.rotation = 0.0,
    this.color,
    this.semanticLabel,
  });

  const ExpressiveListBullet.indexed({
    super.key,
    required int index,
    this.color,
    this.semanticLabel,
  }) : rotation = index * _kRotationMultiplier;

  final double rotation;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);

    final opacity = iconTheme.opacity;
    var color = this.color ?? iconTheme.color;
    if (opacity != 1.0) {
      color = color.withValues(alpha: color.a * opacity);
    }

    return ExcludeSemantics(
      child: Align.center(
        child: CustomPaint(
          size: const .square(8.0),
          painter: _ExpressiveListBulletPainter(
            rotation: rotation,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _ExpressiveListBulletPainter extends CustomPainter {
  _ExpressiveListBulletPainter({required this.rotation, required this.color});

  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(.zero);
    final paint = Paint()..color = color;

    canvas
      // Save the canvas before applying the transform
      ..save()
      // Rotate the canvas around the size's center
      ..translate(center.dx, center.dy)
      ..rotate(rotation)
      ..translate(-center.dx, -center.dy)
      // Draw the processed path onto the canvas
      ..drawPath(_path, paint)
      // Restore the canvas after applying the transform
      ..restore();
  }

  @override
  bool shouldRepaint(_ExpressiveListBulletPainter oldDelegate) =>
      rotation != oldDelegate.rotation || color != oldDelegate.color;

  static final _path = Path()
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
}
