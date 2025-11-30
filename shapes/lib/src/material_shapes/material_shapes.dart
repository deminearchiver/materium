import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';

import '../shapes.dart';

@internal
extension RoundedPolygonInternalExtension on RoundedPolygon {
  @internal
  RoundedPolygon transformedWithMatrix(Matrix4 matrix) => transformed((x, y) {
    final transformedPoint = matrix.transform3(Vector3(x, y, 0.0));
    return (transformedPoint.x, transformedPoint.y);
  });

  @internal
  Path toPathWith({
    Path? path,
    int startAngle = 270,
    bool repeatPath = false,
    bool closePath = true,
  }) => _pathFromCubics(
    path: path ?? Path(),
    startAngle: startAngle,
    repeatPath: repeatPath,
    closePath: closePath,
    cubics: cubics,
    rotationPivotX: centerX,
    rotationPivotY: centerY,
  );
}

extension RoundedPolygonExtension on RoundedPolygon {
  Path toPath({int startAngle = 0}) => toPathWith(
    path: Path(),
    startAngle: startAngle,
    repeatPath: false,
    closePath: true,
  );
}

extension MorphInternalExtension on Morph {
  @internal
  Path toPathWith({
    required double progress,
    Path? path,
    int startAngle = 270, // 12 O'clock
    bool repeatPath = false,
    bool closePath = true,
    double rotationPivotX = 0.0,
    double rotationPivotY = 0.0,
  }) => _pathFromCubics(
    path: path ?? Path(),
    startAngle: startAngle,
    repeatPath: repeatPath,
    closePath: closePath,
    cubics: asCubics(progress),
    rotationPivotX: rotationPivotX,
    rotationPivotY: rotationPivotY,
  );
}

extension MorphExtension on Morph {
  Path toPath({required double progress, Path? path, int startAngle = 0}) =>
      toPathWith(
        path: path ?? Path(),
        progress: progress,
        startAngle: startAngle,
      );
}

Path _pathFromCubics({
  required Path path,
  required int startAngle,
  required bool repeatPath,
  required bool closePath,
  required List<Cubic> cubics,
  required double rotationPivotX,
  required double rotationPivotY,
}) {
  var first = true;
  Cubic? firstCubic;

  path.reset();

  for (var i = 0; i < cubics.length; i++) {
    final it = cubics[i];

    if (first) {
      path.moveTo(it.anchor0X, it.anchor0Y);
      if (startAngle != 0) {
        firstCubic = it;
      }
      first = false;
    }

    path.cubicTo(
      it.control0X,
      it.control0Y,
      it.control1X,
      it.control1Y,
      it.anchor1X,
      it.anchor1Y,
    );
  }

  if (repeatPath) {
    var firstInRepeat = true;

    for (var i = 0; i < cubics.length; i++) {
      final it = cubics[i];

      if (firstInRepeat) {
        path.lineTo(it.anchor0X, it.anchor0Y);
        firstInRepeat = false;
      }

      path.cubicTo(
        it.control0X,
        it.control0Y,
        it.control1X,
        it.control1Y,
        it.anchor1X,
        it.anchor1Y,
      );
    }
  }

  if (closePath) path.close();

  if (startAngle != 0 && firstCubic != null) {
    final angleToFirstCubicRadians = math.atan2(
      cubics[0].anchor0Y - rotationPivotY,
      cubics[0].anchor0X - rotationPivotX,
    );
    final startAngleRadians = _degreesToRadians(startAngle.toDouble());
    // Rotate the Path to to start from the given angle.
    // path.transform(Matrix().apply { rotateZ(-angleToFirstCubic + startAngle) });
    final matrix = Matrix4.rotationZ(
      -angleToFirstCubicRadians + startAngleRadians,
    );
    return path.transform(matrix.storage);
  }
  return path;
}

double _degreesToRadians(double degrees) {
  return degrees * (math.pi / 180.0);
}

abstract final class MaterialShapes {
  // Cache various roundings for use below
  static const CornerRounding _cornerRound15 = CornerRounding(radius: 0.15);
  static const CornerRounding _cornerRound20 = CornerRounding(radius: 0.2);
  static const CornerRounding _cornerRound30 = CornerRounding(radius: 0.3);
  static const CornerRounding _cornerRound50 = CornerRounding(radius: 0.5);
  static const CornerRounding _cornerRound100 = CornerRounding(radius: 1.0);

  static final Matrix4 _rotateNeg45 = Matrix4.rotationZ(-math.pi * 0.25);
  static final Matrix4 _rotateNeg90 = Matrix4.rotationZ(-math.pi * 0.5);
  static final Matrix4 _rotateNeg135 = Matrix4.rotationZ(-math.pi * 0.75);

  static RoundedPolygon circle = buildCircle().normalized();
  static RoundedPolygon square = buildSquare().normalized();
  static RoundedPolygon slanted = buildSlanted().normalized();
  static RoundedPolygon arch = buildArch().normalized();
  static RoundedPolygon fan = buildFan().normalized();
  static RoundedPolygon arrow = buildArrow().normalized();
  static RoundedPolygon semiCircle = buildSemiCircle().normalized();
  static RoundedPolygon oval = buildOval().normalized();
  static RoundedPolygon pill = buildPill().normalized();
  static RoundedPolygon triangle = buildTriangle().normalized();
  static RoundedPolygon diamond = buildDiamond().normalized();
  static RoundedPolygon clamShell = buildClamShell().normalized();
  static RoundedPolygon pentagon = buildPentagon().normalized();
  static RoundedPolygon gem = buildGem().normalized();
  static RoundedPolygon verySunny = buildVerySunny().normalized();
  static RoundedPolygon sunny = buildSunny().normalized();
  static RoundedPolygon cookie4Sided = buildCookie4Sided().normalized();
  static RoundedPolygon cookie6Sided = buildCookie6Sided().normalized();
  static RoundedPolygon cookie7Sided = buildCookie7Sided().normalized();
  static RoundedPolygon cookie9Sided = buildCookie9Sided().normalized();
  static RoundedPolygon cookie12Sided = buildCookie12Sided().normalized();
  static RoundedPolygon ghostish = buildGhostish().normalized();
  static RoundedPolygon clover4Leaf = buildClover4Leaf().normalized();
  static RoundedPolygon clover8Leaf = buildClover8Leaf().normalized();
  static RoundedPolygon burst = buildBurst().normalized();
  static RoundedPolygon softBurst = buildSoftBurst().normalized();
  static RoundedPolygon boom = buildBoom().normalized();
  static RoundedPolygon softBoom = buildSoftBoom().normalized();
  static RoundedPolygon flower = buildFlower().normalized();
  static RoundedPolygon puffy = buildPuffy().normalized();
  static RoundedPolygon puffyDiamond = buildPuffyDiamond().normalized();
  static RoundedPolygon pixelCircle = buildPixelCircle().normalized();
  static RoundedPolygon pixelTriangle = buildPixelTriangle().normalized();
  static RoundedPolygon bun = buildBun().normalized();
  static RoundedPolygon heart = buildHeart().normalized();

  @internal
  static RoundedPolygon buildCircle({int numVertices = 10}) =>
      RoundedPolygon.circle(numVertices: numVertices);

  @internal
  static RoundedPolygon buildSquare() => RoundedPolygon.rectangle(
    width: 1.0,
    height: 1.0,
    rounding: _cornerRound30,
  );

  @internal
  static RoundedPolygon buildSlanted() => _customPolygon(const <_PointNRound>[
    _PointNRound(
      Offset(0.926, 0.970),
      CornerRounding(radius: 0.189, smoothing: 0.811),
    ),
    _PointNRound(
      Offset(-0.021, 0.967),
      CornerRounding(radius: 0.187, smoothing: 0.057),
    ),
  ], reps: 2);

  @internal
  static RoundedPolygon buildArch() => RoundedPolygon.regular(
    numVertices: 4,
    perVertexRounding: const <CornerRounding>[
      _cornerRound100,
      _cornerRound100,
      _cornerRound20,
      _cornerRound20,
    ],
  ).transformedWithMatrix(_rotateNeg135);

  @internal
  static RoundedPolygon buildFan() => _customPolygon(const <_PointNRound>[
    _PointNRound(
      Offset(1.004, 1.000),
      CornerRounding(radius: 0.148, smoothing: 0.417),
    ),
    _PointNRound(Offset(0.000, 1.000), CornerRounding(radius: 0.151)),
    _PointNRound(Offset(0.000, -0.003), CornerRounding(radius: 0.148)),
    _PointNRound(Offset(0.978, 0.020), CornerRounding(radius: 0.803)),
  ], reps: 1);

  @internal
  static RoundedPolygon buildArrow() => _customPolygon(const <_PointNRound>[
    _PointNRound(Offset(0.500, 0.892), CornerRounding(radius: 0.313)),
    _PointNRound(Offset(-0.216, 1.050), CornerRounding(radius: 0.207)),
    _PointNRound(
      Offset(0.499, -0.160),
      CornerRounding(radius: 0.215, smoothing: 1.000),
    ),
    _PointNRound(Offset(1.225, 1.060), CornerRounding(radius: 0.211)),
  ], reps: 1);

  @internal
  static RoundedPolygon buildSemiCircle() => RoundedPolygon.rectangle(
    width: 1.6,
    height: 1.0,
    perVertexRounding: const <CornerRounding>[
      _cornerRound20,
      _cornerRound20,
      _cornerRound100,
      _cornerRound100,
    ],
  );

  @internal
  static RoundedPolygon buildOval() => RoundedPolygon.circle()
      .transformedWithMatrix(Matrix4.diagonal3Values(1.0, 0.64, 1.0))
      .transformedWithMatrix(_rotateNeg45);

  @internal
  static RoundedPolygon buildPill() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.961, 0.039), CornerRounding(radius: 0.426)),
      _PointNRound(Offset(1.001, 0.428)),
      _PointNRound(Offset(1.000, 0.609), CornerRounding(radius: 1.000)),
    ],
    reps: 2,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildTriangle() => RoundedPolygon.regular(
    numVertices: 3,
    rounding: _cornerRound20,
  ).transformedWithMatrix(_rotateNeg90);

  @internal
  static RoundedPolygon buildDiamond() => _customPolygon(const <_PointNRound>[
    _PointNRound(
      Offset(0.500, 1.096),
      CornerRounding(radius: 0.151, smoothing: 0.524),
    ),
    _PointNRound(Offset(0.040, 0.500), CornerRounding(radius: 0.159)),
  ], reps: 2);

  @internal
  static RoundedPolygon buildClamShell() => _customPolygon(const <_PointNRound>[
    _PointNRound(Offset(0.171, 0.841), CornerRounding(radius: 0.159)),
    _PointNRound(Offset(-0.020, 0.500), CornerRounding(radius: 0.140)),
    _PointNRound(Offset(0.170, 0.159), CornerRounding(radius: 0.159)),
  ], reps: 2);

  @internal
  static RoundedPolygon buildPentagon() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.500, -0.009), CornerRounding(radius: 0.172)),
      _PointNRound(Offset(1.030, 0.365), CornerRounding(radius: 0.164)),
      _PointNRound(Offset(0.828, 0.970), CornerRounding(radius: 0.169)),
    ],
    reps: 1,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildGem() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(
        Offset(0.499, 1.023),
        CornerRounding(radius: 0.241, smoothing: 0.778),
      ),
      _PointNRound(Offset(-0.005, 0.792), CornerRounding(radius: 0.208)),
      _PointNRound(Offset(0.073, 0.258), CornerRounding(radius: 0.228)),
      _PointNRound(Offset(0.433, -0.000), CornerRounding(radius: 0.491)),
    ],
    reps: 1,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildSunny() => RoundedPolygon.star(
    numVerticesPerRadius: 8,
    innerRadius: 0.8,
    rounding: _cornerRound15,
  );

  @internal
  static RoundedPolygon buildVerySunny() => _customPolygon(const <_PointNRound>[
    _PointNRound(Offset(0.500, 1.080), CornerRounding(radius: 0.085)),
    _PointNRound(Offset(0.358, 0.843), CornerRounding(radius: 0.085)),
  ], reps: 8);

  @internal
  static RoundedPolygon buildCookie4Sided() =>
      _customPolygon(const <_PointNRound>[
        _PointNRound(Offset(1.237, 1.236), CornerRounding(radius: 0.258)),
        _PointNRound(Offset(0.500, 0.918), CornerRounding(radius: 0.233)),
      ], reps: 4);

  @internal
  static RoundedPolygon buildCookie6Sided() =>
      _customPolygon(const <_PointNRound>[
        _PointNRound(Offset(0.723, 0.884), CornerRounding(radius: 0.394)),
        _PointNRound(Offset(0.500, 1.099), CornerRounding(radius: 0.398)),
      ], reps: 6);

  @internal
  static RoundedPolygon buildCookie7Sided() => RoundedPolygon.star(
    numVerticesPerRadius: 7,
    innerRadius: 0.75,
    rounding: _cornerRound50,
  ).transformedWithMatrix(_rotateNeg90);

  @internal
  static RoundedPolygon buildCookie9Sided() => RoundedPolygon.star(
    numVerticesPerRadius: 9,
    innerRadius: 0.8,
    rounding: _cornerRound50,
  ).transformedWithMatrix(_rotateNeg90);

  @internal
  static RoundedPolygon buildCookie12Sided() => RoundedPolygon.star(
    numVerticesPerRadius: 12,
    innerRadius: 0.8,
    rounding: _cornerRound50,
  ).transformedWithMatrix(_rotateNeg90);

  @internal
  static RoundedPolygon buildGhostish() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.500, 0.0), CornerRounding(radius: 1.000)),
      _PointNRound(Offset(1.0, 0.0), CornerRounding(radius: 1.000)),
      _PointNRound(
        Offset(1.0, 1.140),
        CornerRounding(radius: 0.254, smoothing: 0.106),
      ),
      _PointNRound(Offset(0.575, 0.906), CornerRounding(radius: 0.253)),
    ],
    reps: 1,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildClover4Leaf() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.500, 0.074)),
      _PointNRound(Offset(0.725, -0.099), CornerRounding(radius: 0.476)),
    ],
    reps: 4,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildClover8Leaf() =>
      _customPolygon(const <_PointNRound>[
        _PointNRound(Offset(0.500, 0.036)),
        _PointNRound(Offset(0.758, -0.101), CornerRounding(radius: 0.209)),
      ], reps: 8);

  @internal
  static RoundedPolygon buildBurst() => _customPolygon(const <_PointNRound>[
    _PointNRound(Offset(0.500, -0.006), CornerRounding(radius: 0.006)),
    _PointNRound(Offset(0.592, 0.158), CornerRounding(radius: 0.006)),
  ], reps: 12);

  @internal
  static RoundedPolygon buildSoftBurst() => _customPolygon(const <_PointNRound>[
    _PointNRound(Offset(0.193, 0.277), CornerRounding(radius: 0.053)),
    _PointNRound(Offset(0.176, 0.055), CornerRounding(radius: 0.053)),
  ], reps: 10);

  @internal
  static RoundedPolygon buildBoom() => _customPolygon(const <_PointNRound>[
    _PointNRound(Offset(0.457, 0.296), CornerRounding(radius: 0.007)),
    _PointNRound(Offset(0.500, -0.051), CornerRounding(radius: 0.007)),
  ], reps: 15);

  @internal
  static RoundedPolygon buildSoftBoom() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.733, 0.454)),
      _PointNRound(Offset(0.839, 0.437), CornerRounding(radius: 0.532)),
      _PointNRound(
        Offset(0.949, 0.449),
        CornerRounding(radius: 0.439, smoothing: 1.000),
      ),
      _PointNRound(Offset(0.998, 0.478), CornerRounding(radius: 0.174)),
    ],
    reps: 16,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildFlower() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.370, 0.187)),
      _PointNRound(Offset(0.416, 0.049), CornerRounding(radius: 0.381)),
      _PointNRound(Offset(0.479, 0.001), CornerRounding(radius: 0.095)),
    ],
    reps: 8,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildPuffy() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.500, 0.053)),
      _PointNRound(Offset(0.545, -0.040), CornerRounding(radius: 0.405)),
      _PointNRound(Offset(0.670, -0.035), CornerRounding(radius: 0.426)),
      _PointNRound(Offset(0.717, 0.066), CornerRounding(radius: 0.574)),
      _PointNRound(Offset(0.722, 0.128)),
      _PointNRound(Offset(0.777, 0.002), CornerRounding(radius: 0.360)),
      _PointNRound(Offset(0.914, 0.149), CornerRounding(radius: 0.660)),
      _PointNRound(Offset(0.926, 0.289), CornerRounding(radius: 0.660)),
      _PointNRound(Offset(0.881, 0.346)),
      _PointNRound(Offset(0.940, 0.344), CornerRounding(radius: 0.126)),
      _PointNRound(Offset(1.003, 0.437), CornerRounding(radius: 0.255)),
    ],
    reps: 2,
    mirroring: true,
  ).transformedWithMatrix(Matrix4.diagonal3Values(1.0, 0.742, 1.0));

  @internal
  static RoundedPolygon buildPuffyDiamond() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.870, 0.130), CornerRounding(radius: 0.146)),
      _PointNRound(Offset(0.818, 0.357)),
      _PointNRound(Offset(1.000, 0.332), CornerRounding(radius: 0.853)),
    ],
    reps: 4,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildPixelCircle() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.500, 0.000)),
      _PointNRound(Offset(0.704, 0.000)),
      _PointNRound(Offset(0.704, 0.065)),
      _PointNRound(Offset(0.843, 0.065)),
      _PointNRound(Offset(0.843, 0.148)),
      _PointNRound(Offset(0.926, 0.148)),
      _PointNRound(Offset(0.926, 0.296)),
      _PointNRound(Offset(1.000, 0.296)),
    ],
    reps: 2,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildPixelTriangle() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.110, 0.500)),
      _PointNRound(Offset(0.113, 0.000)),
      _PointNRound(Offset(0.287, 0.000)),
      _PointNRound(Offset(0.287, 0.087)),
      _PointNRound(Offset(0.421, 0.087)),
      _PointNRound(Offset(0.421, 0.170)),
      _PointNRound(Offset(0.560, 0.170)),
      _PointNRound(Offset(0.560, 0.265)),
      _PointNRound(Offset(0.674, 0.265)),
      _PointNRound(Offset(0.675, 0.344)),
      _PointNRound(Offset(0.789, 0.344)),
      _PointNRound(Offset(0.789, 0.439)),
      _PointNRound(Offset(0.888, 0.439)),
    ],
    reps: 1,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildBun() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.796, 0.500)),
      _PointNRound(Offset(0.853, 0.518), CornerRounding(radius: 1.0)),
      _PointNRound(Offset(0.992, 0.631), CornerRounding(radius: 1.0)),
      _PointNRound(Offset(0.968, 1.000), CornerRounding(radius: 1.0)),
    ],
    reps: 2,
    mirroring: true,
  );

  @internal
  static RoundedPolygon buildHeart() => _customPolygon(
    const <_PointNRound>[
      _PointNRound(Offset(0.500, 0.268), CornerRounding(radius: 0.016)),
      _PointNRound(Offset(0.792, -0.066), CornerRounding(radius: 0.958)),
      _PointNRound(Offset(1.064, 0.276), CornerRounding(radius: 1.000)),
      _PointNRound(Offset(0.501, 0.946), CornerRounding(radius: 0.129)),
    ],
    reps: 1,
    mirroring: true,
  );

  static List<_PointNRound> _doRepeat(
    List<_PointNRound> points,
    int reps,
    Offset center,
    bool mirroring,
  ) {
    if (mirroring) {
      final result = <_PointNRound>[];

      final angles = <double>[
        for (int i = 0; i < points.length; i++)
          (points[i].o - center)._angleRadians(),
      ];

      final distances = <double>[
        for (int i = 0; i < points.length; i++) (points[i].o - center).distance,
      ];

      final actualReps = reps * 2;
      final sectionAngle = math.pi * 2.0 / actualReps;

      for (var it = 0; it < actualReps; it++) {
        for (var index = 0; index < points.length; index++) {
          final i = it.isEven ? index : points.length - 1 - index;
          if (i > 0 || it.isEven) {
            final a =
                (sectionAngle * it +
                (it.isEven
                    ? angles[i]
                    : sectionAngle - angles[i] + 2.0 * angles[0]));
            final finalPoint =
                Offset(math.cos(a), math.sin(a)) * distances[i] + center;
            result.add(_PointNRound(finalPoint, points[i].r));
          }
        }
      }

      return result;
    } else {
      final np = points.length;
      return List.generate(np * reps, (it) {
        final point = points[it % np].o._rotateDegrees(
          (it ~/ np) * 360.0 / reps,
          center,
        );
        return _PointNRound(point, points[it % np].r);
      });
    }
  }

  static RoundedPolygon _customPolygon(
    List<_PointNRound> pnr, {
    required int reps,
    Offset center = const Offset(0.5, 0.5),
    bool mirroring = false,
  }) {
    final actualPoints = _doRepeat(pnr, reps, center, mirroring);
    return RoundedPolygon.fromVertices(
      vertices: List.generate(actualPoints.length * 2, (ix) {
        final it = actualPoints[ix ~/ 2].o;
        return ix.isEven ? it.dx : it.dy;
      }),
      perVertexRounding: <CornerRounding>[
        for (int i = 0; i < actualPoints.length; i++) actualPoints[i].r,
      ],
      centerX: center.dx,
      centerY: center.dy,
    );
  }
}

@immutable
class _PointNRound {
  const _PointNRound(this.o, [this.r = CornerRounding.unrounded]);

  final Offset o;
  final CornerRounding r;

  @override
  String toString() => "PointNRound($o, $r)";

  @override
  int get hashCode => Object.hash(runtimeType, o, r);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is _PointNRound &&
            o == other.o &&
            r == other.r;
  }
}

extension on Offset {
  Offset _rotateDegrees(double angle, [Offset center = Offset.zero]) {
    final a = angle._toRadians();
    final off = this - center;
    return Offset(
          off.dx * math.cos(a) - off.dy * math.sin(a),
          off.dx * math.sin(a) + off.dy * math.cos(a),
        ) +
        center;
  }

  double _angleRadians() => math.atan2(dy, dx);
}

extension on double {
  double _toRadians() => this / 360.0 * 2.0 * math.pi;
}

abstract class _PathBorder extends OutlinedBorder {
  const _PathBorder({super.side, this.squash = 0.0});

  Path get path;

  /// How much of the aspect ratio of the attached widget to take on.
  ///
  /// If [squash] is non-zero, the border will match the aspect ratio of the
  /// bounding box of the widget that it is attached to, which can give a
  /// squashed appearance.
  ///
  /// The [squash] parameter lets you control how much of that aspect ratio this
  /// border takes on.
  ///
  /// A value of zero means that the border will be drawn with a square aspect
  /// ratio at the size of the shortest side of the bounding rectangle, ignoring
  /// the aspect ratio of the widget, and a value of one means it will be drawn
  /// with the aspect ratio of the widget. The value of [squash] has no effect
  /// if the widget is square to begin with.
  ///
  /// Defaults to zero, and must be between zero and one, inclusive.
  final double squash;

  Path _transformPath(Rect rect, {TextDirection? textDirection}) {
    var scale = Offset(rect.width, rect.height);

    scale = rect.shortestSide == rect.width
        ? Offset(scale.dx, squash * scale.dy + (1 - squash) * scale.dx)
        : Offset(squash * scale.dx + (1 - squash) * scale.dy, scale.dy);

    final actualRect =
        Offset(
          rect.left + (rect.width - scale.dx) / 2,
          rect.top + (rect.height - scale.dy) / 2,
        ) &
        Size(scale.dx, scale.dy);

    final matrix = Matrix4.identity()
      ..translateByDouble(actualRect.left, actualRect.top, 0.0, 1.0)
      ..scaleByDouble(scale.dx, scale.dy, 1.0, 1.0);

    return path.transform(matrix.storage);
  }

  @override
  _PathBorder copyWith({BorderSide? side, double? squash});

  @override
  _PathBorder scale(double t);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final adjustedRect = rect.deflate(side.strokeInset);
    return _transformPath(adjustedRect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final adjustedRect = rect.inflate(side.strokeOutset);
    return _transformPath(adjustedRect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        return;
      case BorderStyle.solid:
        final adjustedRect = rect.inflate(side.strokeOffset / 2.0);
        final path = _transformPath(adjustedRect);
        canvas.drawPath(path, side.toPaint());
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is _PathBorder &&
            side == other.side &&
            squash == other.squash;
  }

  @override
  int get hashCode => Object.hash(runtimeType, side, squash);
}

abstract class _CubicsBorder extends _PathBorder {
  const _CubicsBorder({super.side, super.squash, required this.cubics});

  final List<Cubic> cubics;

  @override
  Path get path;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is _CubicsBorder &&
            side == other.side &&
            squash == other.squash &&
            listEquals(cubics, other.cubics);
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, side, squash, Object.hashAll(cubics));
}

class RoundedPolygonBorder extends _PathBorder {
  const RoundedPolygonBorder({
    super.side,
    super.squash,
    required this.polygon,
    this.startAngle = 0,
  });

  final RoundedPolygon polygon;
  final int startAngle;

  @override
  Path get path => polygon.toPath(startAngle: startAngle);

  @override
  RoundedPolygonBorder copyWith({
    BorderSide? side,
    double? squash,
    RoundedPolygon? polygon,
    int? startAngle,
  }) => RoundedPolygonBorder(
    polygon: polygon ?? this.polygon,
    startAngle: startAngle ?? this.startAngle,
  );

  @override
  RoundedPolygonBorder scale(double t) => RoundedPolygonBorder(
    side: side.scale(t),
    squash: squash,
    polygon: polygon,
    startAngle: startAngle,
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is RoundedPolygonBorder &&
            side == other.side &&
            squash == other.squash &&
            polygon == other.polygon &&
            startAngle == other.startAngle;
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, squash, side, polygon, startAngle);
}

class MorphBorder extends _PathBorder {
  const MorphBorder({
    super.side,
    super.squash,
    required this.morph,
    required this.progress,
    this.startAngle = 0,
  });

  final Morph morph;
  final double progress;
  final int startAngle;

  @override
  Path get path => morph.toPath(progress: progress, startAngle: startAngle);

  @override
  MorphBorder copyWith({
    BorderSide? side,
    double? squash,
    Morph? morph,
    double? progress,
    int? startAngle,
  }) => MorphBorder(
    side: side ?? this.side,
    squash: squash ?? this.squash,
    morph: morph ?? this.morph,
    progress: progress ?? this.progress,
    startAngle: startAngle ?? this.startAngle,
  );

  @override
  MorphBorder scale(double t) => MorphBorder(
    side: side.scale(t),
    squash: squash,
    morph: morph,
    progress: progress,
    startAngle: startAngle,
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is MorphBorder &&
            side == other.side &&
            squash == other.squash &&
            morph == other.morph &&
            progress == other.progress &&
            startAngle == other.startAngle;
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, side, squash, morph, progress, startAngle);
}
