import 'dart:math' as math;

import 'package:material/src/material/flutter.dart';

abstract class CornersBorderDelegate {
  const CornersBorderDelegate();

  Path getInnerPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  });

  Path getOuterPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  });

  bool get preferPaintInterior => false;

  void paint({
    required Canvas canvas,
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  });

  void paintInterior({
    required Canvas canvas,
    required Rect rect,
    required Paint paint,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) {
    assert(
      !preferPaintInterior,
      "$runtimeType.preferPaintInterior returns true but $runtimeType.paintInterior is not implemented.",
    );
    assert(
      false,
      "$runtimeType.preferPaintInterior returns false, so it is an error to call its paintInterior method.",
    );
  }

  CornersBorderDelegate? lerpFrom(CornersBorderDelegate? a, double t) =>
      a == null ? scale(t) : null;

  CornersBorderDelegate? lerpTo(CornersBorderDelegate? b, double t) =>
      b == null ? scale(1.0 - t) : null;

  CornersBorderDelegate scale(double t);

  static CornersBorderDelegate? lerp(
    CornersBorderDelegate? a,
    CornersBorderDelegate? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return b?.lerpFrom(a, t) ?? a?.lerpTo(b, t) ?? (t < 0.5 ? a : b);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType && other is CornersBorderDelegate;

  @override
  int get hashCode => runtimeType.hashCode;

  static const CornersBorderDelegate rounded = _RoundedCornersBorderDelegate();

  static const CornersBorderDelegate cut = _CutCornersBorderDelegate();

  static const CornersBorderDelegate superellipse =
      _SuperellipseCornersBorderDelegate();
}

class _RoundedCornersBorderDelegate extends CornersBorderDelegate {
  const _RoundedCornersBorderDelegate();

  @override
  Path getInnerPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) => Path()..addRRect(borderRadius.toRRect(rect).deflate(side.strokeInset));

  @override
  Path getOuterPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) => Path()..addRRect(borderRadius.toRRect(rect));

  @override
  bool get preferPaintInterior => true;

  @override
  void paint({
    required Canvas canvas,
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        if (side.width == 0.0) {
          canvas.drawRRect(borderRadius.toRRect(rect), side.toPaint());
        } else {
          final paint = Paint()..color = side.color;
          final borderRect = borderRadius.toRRect(rect);
          final inner = borderRect.deflate(side.strokeInset);
          final outer = borderRect.inflate(side.strokeOutset);
          canvas.drawDRRect(outer, inner, paint);
        }
    }
  }

  @override
  void paintInterior({
    required Canvas canvas,
    required Rect rect,
    required Paint paint,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) {
    if (borderRadius == BorderRadius.zero) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRRect(borderRadius.toRRect(rect), paint);
    }
  }

  @override
  _RoundedCornersBorderDelegate scale(double t) => this;

  // TODO: implement lerpFrom and lerpTo

  @override
  String toString() => "CornersBorderDelegate.rounded";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _RoundedCornersBorderDelegate;

  @override
  int get hashCode => runtimeType.hashCode;
}

class _CutCornersBorderDelegate extends CornersBorderDelegate {
  const _CutCornersBorderDelegate();

  Path _getPath(RRect rrect) {
    final centerLeft = Offset(rrect.left, rrect.center.dy);
    final centerRight = Offset(rrect.right, rrect.center.dy);
    final centerTop = Offset(rrect.center.dx, rrect.top);
    final centerBottom = Offset(rrect.center.dx, rrect.bottom);

    final tlRadiusX = math.max(0.0, rrect.tlRadiusX);
    final tlRadiusY = math.max(0.0, rrect.tlRadiusY);
    final trRadiusX = math.max(0.0, rrect.trRadiusX);
    final trRadiusY = math.max(0.0, rrect.trRadiusY);
    final blRadiusX = math.max(0.0, rrect.blRadiusX);
    final blRadiusY = math.max(0.0, rrect.blRadiusY);
    final brRadiusX = math.max(0.0, rrect.brRadiusX);
    final brRadiusY = math.max(0.0, rrect.brRadiusY);

    final List<Offset> vertices = <Offset>[
      Offset(rrect.left, math.min(centerLeft.dy, rrect.top + tlRadiusY)),
      Offset(math.min(centerTop.dx, rrect.left + tlRadiusX), rrect.top),
      Offset(math.max(centerTop.dx, rrect.right - trRadiusX), rrect.top),
      Offset(rrect.right, math.min(centerRight.dy, rrect.top + trRadiusY)),
      Offset(rrect.right, math.max(centerRight.dy, rrect.bottom - brRadiusY)),
      Offset(math.max(centerBottom.dx, rrect.right - brRadiusX), rrect.bottom),
      Offset(math.min(centerBottom.dx, rrect.left + blRadiusX), rrect.bottom),
      Offset(rrect.left, math.max(centerLeft.dy, rrect.bottom - blRadiusY)),
    ];

    return Path()..addPolygon(vertices, true);
  }

  @override
  Path getInnerPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) => _getPath(borderRadius.toRRect(rect).deflate(side.strokeInset));

  @override
  Path getOuterPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) => _getPath(borderRadius.toRRect(rect));

  @override
  void paint({
    required Canvas canvas,
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) {
    if (rect.isEmpty) return;
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final borderRect = borderRadius.toRRect(rect);
        final adjustedRect = borderRect.inflate(side.strokeOutset);
        final path = _getPath(adjustedRect)
          ..addPath(
            getInnerPath(rect: rect, side: side, borderRadius: borderRadius),
            Offset.zero,
          );
        canvas.drawPath(path, side.toPaint());
    }
  }

  @override
  _CutCornersBorderDelegate scale(double t) => this;

  // TODO: implement lerpFrom and lerpTo

  @override
  String toString() => "CornersBorderDelegate.cut";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType && other is _CutCornersBorderDelegate;

  @override
  int get hashCode => runtimeType.hashCode;
}

class _SuperellipseCornersBorderDelegate extends CornersBorderDelegate {
  const _SuperellipseCornersBorderDelegate();

  @override
  Path getInnerPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) => Path()
    ..addRSuperellipse(
      borderRadius.toRSuperellipse(rect).deflate(side.strokeInset),
    );

  @override
  Path getOuterPath({
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) => Path()..addRSuperellipse(borderRadius.toRSuperellipse(rect));

  @override
  bool get preferPaintInterior => true;

  @override
  void paint({
    required Canvas canvas,
    required Rect rect,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        if (side.width == 0.0) {
          canvas.drawRSuperellipse(
            borderRadius.toRSuperellipse(rect),
            side.toPaint(),
          );
        } else {
          final strokeOffset = (side.strokeOutset - side.strokeInset) / 2.0;
          final base = borderRadius.toRSuperellipse(rect).inflate(strokeOffset);
          canvas.drawRSuperellipse(base, side.toPaint());
        }
    }
  }

  @override
  void paintInterior({
    required Canvas canvas,
    required Rect rect,
    required Paint paint,
    required BorderSide side,
    required BorderRadius borderRadius,
  }) {
    if (borderRadius == BorderRadius.zero) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRSuperellipse(borderRadius.toRSuperellipse(rect), paint);
    }
  }

  @override
  _SuperellipseCornersBorderDelegate scale(double t) => this;

  // TODO: implement lerpFrom and lerpTo

  @override
  String toString() => "CornersBorderDelegate.superellipse";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _SuperellipseCornersBorderDelegate;

  @override
  int get hashCode => runtimeType.hashCode;
}

class CornersBorder extends OutlinedBorder {
  const CornersBorder({
    super.side,
    required this.delegate,
    this.corners = Corners.none,
  });

  const CornersBorder.rounded({super.side, this.corners = Corners.none})
    : delegate = CornersBorderDelegate.rounded;

  const CornersBorder.cut({super.side, this.corners = Corners.none})
    : delegate = CornersBorderDelegate.cut;

  const CornersBorder.superellipse({super.side, this.corners = Corners.none})
    : delegate = CornersBorderDelegate.superellipse;

  final CornersBorderDelegate delegate;
  final CornersGeometry corners;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      delegate.getInnerPath(
        rect: rect,
        side: side,
        borderRadius: corners.resolve(textDirection).toBorderRadius(rect.size),
      );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      delegate.getOuterPath(
        rect: rect,
        side: side,
        borderRadius: corners.resolve(textDirection).toBorderRadius(rect.size),
      );

  @override
  bool get preferPaintInterior => delegate.preferPaintInterior;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    delegate.paint(
      canvas: canvas,
      rect: rect,
      side: side,
      borderRadius: corners.resolve(textDirection).toBorderRadius(rect.size),
    );
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    delegate.paintInterior(
      canvas: canvas,
      rect: rect,
      paint: paint,
      side: side,
      borderRadius: corners.resolve(textDirection).toBorderRadius(rect.size),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is CornersBorder) {
      return CornersBorder(
        side: BorderSide.lerp(a.side, side, t),
        delegate: CornersBorderDelegate.lerp(a.delegate, delegate, t)!,
        corners: CornersGeometry.lerp(a.corners, corners, t)!,
      );
    }
    if (a is RoundedRectangleBorder) {
      const aDelegate = CornersBorderDelegate.rounded;
      final aCorners = CornersGeometry.fromBorderRadius(a.borderRadius);
      return CornersBorder(
        side: BorderSide.lerp(a.side, side, t),
        delegate: CornersBorderDelegate.lerp(aDelegate, delegate, t)!,
        corners: CornersGeometry.lerp(aCorners, corners, t)!,
      );
    }
    if (a is BeveledRectangleBorder) {
      const aDelegate = CornersBorderDelegate.cut;
      final aCorners = CornersGeometry.fromBorderRadius(a.borderRadius);
      return CornersBorder(
        side: BorderSide.lerp(a.side, side, t),
        delegate: CornersBorderDelegate.lerp(aDelegate, delegate, t)!,
        corners: CornersGeometry.lerp(aCorners, corners, t)!,
      );
    }
    if (a is RoundedSuperellipseBorder) {
      const aDelegate = CornersBorderDelegate.superellipse;
      final aCorners = CornersGeometry.fromBorderRadius(a.borderRadius);
      return CornersBorder(
        side: BorderSide.lerp(a.side, side, t),
        delegate: CornersBorderDelegate.lerp(aDelegate, delegate, t)!,
        corners: CornersGeometry.lerp(aCorners, corners, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is CornersBorder) {
      return CornersBorder(
        side: BorderSide.lerp(side, b.side, t),
        delegate: CornersBorderDelegate.lerp(delegate, b.delegate, t)!,
        corners: CornersGeometry.lerp(corners, b.corners, t)!,
      );
    }
    if (b is RoundedRectangleBorder) {
      const bDelegate = CornersBorderDelegate.rounded;
      final bCorners = CornersGeometry.fromBorderRadius(b.borderRadius);
      return CornersBorder(
        side: BorderSide.lerp(side, b.side, t),
        delegate: CornersBorderDelegate.lerp(delegate, bDelegate, t)!,
        corners: CornersGeometry.lerp(corners, bCorners, t)!,
      );
    }
    if (b is BeveledRectangleBorder) {
      const bDelegate = CornersBorderDelegate.cut;
      final bCorners = CornersGeometry.fromBorderRadius(b.borderRadius);
      return CornersBorder(
        side: BorderSide.lerp(side, b.side, t),
        delegate: CornersBorderDelegate.lerp(delegate, bDelegate, t)!,
        corners: CornersGeometry.lerp(corners, bCorners, t)!,
      );
    }
    if (b is RoundedSuperellipseBorder) {
      const bDelegate = CornersBorderDelegate.superellipse;
      final bCorners = CornersGeometry.fromBorderRadius(b.borderRadius);
      return CornersBorder(
        side: BorderSide.lerp(side, b.side, t),
        delegate: CornersBorderDelegate.lerp(delegate, bDelegate, t)!,
        corners: CornersGeometry.lerp(corners, bCorners, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  CornersBorder scale(double t) => CornersBorder(
    side: side.scale(t),
    delegate: delegate.scale(t),
    corners: corners * t,
  );

  @override
  CornersBorder copyWith({
    BorderSide? side,
    CornersBorderDelegate? delegate,
    CornersGeometry? corners,
  }) => CornersBorder(
    side: side ?? this.side,
    delegate: delegate ?? this.delegate,
    corners: corners ?? this.corners,
  );

  @override
  String toString() =>
      "${objectRuntimeType(this, "CornersBorder")}"
      "(side: $side, delegate: $delegate, corners: $corners)";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is CornersBorder &&
          side == other.side &&
          delegate == other.delegate &&
          corners == other.corners;

  @override
  int get hashCode => Object.hash(runtimeType, side, delegate, corners);
}
