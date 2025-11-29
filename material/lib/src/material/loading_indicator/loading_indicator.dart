import 'dart:math' as math;

import 'package:material/src/material_shapes/material_shapes.dart';
import 'package:material/src/material/flutter.dart';

const double _kContainerWidth = 48.0;
const double _kContainerHeight = 48.0;
const double _kIndicatorSize = 38.0;
final double _kActiveIndicatorScale =
    _kIndicatorSize / math.min(_kContainerWidth, _kContainerHeight);

const double _kFullRotationAngle = math.pi * 2;
const double _kSingleRotationAngle = math.pi * 3 / 4;
const double _kLinearRotationAngle = math.pi / 4;
const double _kMorphRotationAngle =
    _kSingleRotationAngle - _kLinearRotationAngle;

const int _kGlobalRotationDurationMs = 4666;
const int _kMorphIntervalMs = 650;
const double _kFullRotation = 2.0 * math.pi;
const double _kQuarterRotation = _kFullRotation / 4.0;

final List<RoundedPolygon> _indeterminateIndicatorPolygons = <RoundedPolygon>[
  MaterialShapes.softBurst,
  MaterialShapes.cookie9Sided,
  MaterialShapes.pentagon,
  MaterialShapes.pill,
  MaterialShapes.sunny,
  MaterialShapes.cookie4Sided,
  MaterialShapes.oval,
];

final List<RoundedPolygon> _determinateIndicatorPolygons = <RoundedPolygon>[
  // ignore: invalid_use_of_internal_member
  MaterialShapes.circle.transformedWithMatrix(
    Matrix4.rotationZ(2.0 * math.pi / 20.0),
  ),
  MaterialShapes.softBurst,
];

class LoadingIndicatorController {
  // TODO: add vsync here
  // TODO: this class manages LoadingIndicator animations and allows syncing multiple loading indicators together
}

class DeterminateLoadingIndicator extends StatefulWidget {
  const DeterminateLoadingIndicator({
    super.key,
    required this.contained,
    required this.progress,
    this.indicatorPolygons,
    this.containerColor,
    this.indicatorColor,
  }) : assert(progress >= 0.0 && progress <= 1.0),
       assert(
         indicatorPolygons == null || indicatorPolygons.length >= 2,
         "indicatorPolygons should have, at least, two RoundedPolygons",
       );

  final bool contained;

  final double progress;

  final List<RoundedPolygon>? indicatorPolygons;

  final Color? containerColor;

  final Color? indicatorColor;

  List<RoundedPolygon> get _indicatorPolygons =>
      indicatorPolygons ?? _determinateIndicatorPolygons;

  @override
  State<DeterminateLoadingIndicator> createState() =>
      _DeterminateLoadingIndicatorState();
}

class _DeterminateLoadingIndicatorState
    extends State<DeterminateLoadingIndicator> {
  double get _progressValue => widget.progress;

  late List<Morph> _morphSequence;
  late double _morphScaleFactor;

  final Matrix4 _scaleMatrix = Matrix4.zero();

  void _updateMorphScaleFactor(List<RoundedPolygon> indicatorPolygons) {
    _morphScaleFactor =
        _calculateScaleFactor(widget._indicatorPolygons) *
        _kActiveIndicatorScale;
  }

  @override
  void initState() {
    super.initState();
    _morphSequence = _updateMorphSequence(
      polygons: widget._indicatorPolygons,
      circularSequence: false,
    );
    _updateMorphScaleFactor(widget._indicatorPolygons);
  }

  @override
  void didUpdateWidget(covariant DeterminateLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget._indicatorPolygons, oldWidget._indicatorPolygons)) {
      _morphSequence = _updateMorphSequence(
        morphSequence: _morphSequence,
        polygons: widget._indicatorPolygons,
        circularSequence: false,
      );
      _updateMorphScaleFactor(widget._indicatorPolygons);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _morphSequence = _updateMorphSequence(
      morphSequence: _morphSequence,
      polygons: widget._indicatorPolygons,
      circularSequence: false,
    );
    _updateMorphScaleFactor(widget._indicatorPolygons);
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);

    final loadingIndicatorTheme = LoadingIndicatorTheme.of(context);

    final indicatorColor =
        widget.indicatorColor ??
        (widget.contained
            ? loadingIndicatorTheme.containedIndicatorColor
            : loadingIndicatorTheme.indicatorColor);

    final containerColor =
        widget.containerColor ?? loadingIndicatorTheme.containedContainerColor;

    // Adjust the active morph index according to the progress.
    final activeMorphIndex = math.min(
      (_morphSequence.length * _progressValue).toInt(),
      (_morphSequence.length - 1),
    );

    // Prepare the progress value that will be used for the active Morph.
    final adjustedProgressValue =
        _progressValue == 1.0 && activeMorphIndex == _morphSequence.length - 1
        // Prevents a zero when the progress is one and we are at the last
        // shape morph.
        ? 1.0
        : (_progressValue * _morphSequence.length) % 1.0;

    final currentMorph = _morphSequence[activeMorphIndex];

    // Rotate counterclockwise.
    final rotation = -_progressValue * math.pi;

    return RepaintBoundary(
      child: Semantics(
        label: "$_progressValue",
        value: "$_progressValue",
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _kContainerWidth,
            minHeight: _kContainerHeight,
          ),
          child: Material(
            animationDuration: Duration.zero,
            clipBehavior: Clip.antiAlias,
            type: MaterialType.card,
            shape: CornersBorder.rounded(
              corners: Corners.all(shapeTheme.corner.full),
            ),
            color: widget.contained ? containerColor : Colors.transparent,
            elevation: widget.contained ? elevationTheme.level0 : 0.0,
            shadowColor: widget.contained
                ? colorTheme.shadow
                : Colors.transparent,
            child: CustomPaint(
              isComplex: true,
              willChange: false,
              painter: _DeterminateLoadingIndicatorPainter(
                currentMorph: currentMorph,
                morphScaleFactor: _morphScaleFactor,
                adjustedProgressValue: adjustedProgressValue,
                rotation: rotation,
                indicatorColor: indicatorColor,
                scaleMatrix: _scaleMatrix,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeterminateLoadingIndicatorPainter extends CustomPainter {
  _DeterminateLoadingIndicatorPainter({
    required this.currentMorph,
    required this.morphScaleFactor,
    required this.adjustedProgressValue,
    required this.rotation,
    required this.indicatorColor,
    this.scaleMatrix,
  });

  final Morph currentMorph;
  final double morphScaleFactor;
  final double adjustedProgressValue;
  final double rotation;
  final Color indicatorColor;
  final Matrix4? scaleMatrix;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final morphPath = currentMorph.toPath(
      progress: adjustedProgressValue,
      startAngle: 0,
    );

    final processedPath = _processPath(
      path: morphPath,
      size: size,
      scaleFactor: morphScaleFactor,
      scaleMatrix: scaleMatrix,
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = indicatorColor;

    canvas
      // Save the canvas before applying the transform
      ..save()
      // Rotate the canvas around the size's center
      ..translate(center.dx, center.dy)
      ..rotate(rotation)
      ..translate(-center.dx, -center.dy)
      // Draw the processed path onto the canvas
      ..drawPath(processedPath, paint)
      // Restore the canvas after applying the transform
      ..restore();
  }

  @override
  bool shouldRepaint(_DeterminateLoadingIndicatorPainter oldDelegate) {
    // TODO: measure the performance impact of these comparisons
    return currentMorph != oldDelegate.currentMorph ||
        morphScaleFactor != oldDelegate.morphScaleFactor ||
        adjustedProgressValue != oldDelegate.adjustedProgressValue ||
        rotation != oldDelegate.rotation ||
        indicatorColor != oldDelegate.indicatorColor ||
        scaleMatrix != oldDelegate.scaleMatrix;
  }
}

class IndeterminateLoadingIndicator extends StatefulWidget {
  const IndeterminateLoadingIndicator({
    super.key,
    required this.contained,
    this.indicatorPolygons,
    this.indicatorColor,
    this.containerColor,
    this.semanticsLabel,
  }) : assert(
         indicatorPolygons == null || indicatorPolygons.length >= 2,
         "indicatorPolygons should have, at least, two RoundedPolygons",
       );

  final bool contained;

  final List<RoundedPolygon>? indicatorPolygons;

  final Color? indicatorColor;

  final Color? containerColor;

  final String? semanticsLabel;

  List<RoundedPolygon> get _indicatorPolygons =>
      indicatorPolygons ?? _indeterminateIndicatorPolygons;

  @override
  State<IndeterminateLoadingIndicator> createState() =>
      _IndeterminateLoadingIndicatorState();
}

class _IndeterminateLoadingIndicatorState
    extends State<IndeterminateLoadingIndicator>
    with SingleTickerProviderStateMixin {
  final Matrix4 _scaleMatrix = Matrix4.zero();

  final ValueNotifier<double> _globalAngle = ValueNotifier(0.0);

  final ValueNotifier<int> _morphIndex = ValueNotifier(0);

  late List<Morph> _morphSequence;
  late double _morphScaleFactor;

  late AnimationController _controller;

  late Animation<double> _rotation;

  late Animation<double> _scale;

  late Animation<double> _morphProgress;

  void _updateMorphScaleFactor(List<RoundedPolygon> indicatorPolygons) {
    _morphScaleFactor =
        _calculateScaleFactor(widget._indicatorPolygons) *
        _kActiveIndicatorScale;
  }

  void _statusListener(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _globalAngle.value =
        (_globalAngle.value + _kSingleRotationAngle) % _kFullRotationAngle;
    _morphIndex.value = (_morphIndex.value + 1) % _morphSequence.length;
    _controller.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();

    _morphSequence = _updateMorphSequence(
      polygons: widget._indicatorPolygons,
      circularSequence: true,
    );
    _updateMorphScaleFactor(widget._indicatorPolygons);

    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 650),
          )
          ..addStatusListener(_statusListener)
          ..forward();

    _rotation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _scale =
        TweenSequence<double>([
              TweenSequenceItem(
                tween: Tween<double>(begin: 1.0, end: 1.125),
                weight: 200.0 / 350.0,
              ),
              TweenSequenceItem(
                tween: Tween<double>(begin: 1.125, end: 1.0),
                weight: 150.0 / 350.0,
              ),
            ])
            .chain(
              CurveTween(curve: const Interval(300.0 / 650.0, 650.0 / 650.0)),
            )
            .animate(_controller);

    _morphProgress = Tween<double>(begin: 0.0, end: 1.0)
        .chain(
          CurveTween(
            curve: const Interval(
              300.0 / 650.0,
              550.0 / 650.0,
              curve: Curves.easeOut,
            ),
          ),
        )
        .animate(_controller);
  }

  @override
  void didUpdateWidget(IndeterminateLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.indicatorPolygons, oldWidget.indicatorPolygons)) {
      _morphIndex.value = 0;
      _morphSequence = _updateMorphSequence(
        morphSequence: _morphSequence,
        polygons: widget._indicatorPolygons,
        circularSequence: true,
      );
      _updateMorphScaleFactor(widget._indicatorPolygons);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _globalAngle.dispose();
    _morphIndex.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _morphIndex.value = 0;
    _morphSequence = _updateMorphSequence(
      morphSequence: _morphSequence,
      polygons: widget._indicatorPolygons,
      circularSequence: true,
    );
    _updateMorphScaleFactor(widget._indicatorPolygons);
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);

    final loadingIndicatorTheme = LoadingIndicatorTheme.of(context);

    final indicatorColor =
        widget.indicatorColor ??
        (widget.contained
            ? loadingIndicatorTheme.containedIndicatorColor
            : loadingIndicatorTheme.indicatorColor);

    final containerColor =
        widget.containerColor ?? loadingIndicatorTheme.containedContainerColor;

    return RepaintBoundary(
      child: Semantics(
        label: widget.semanticsLabel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _kContainerWidth,
            minHeight: _kContainerHeight,
          ),
          child: Material(
            animationDuration: Duration.zero,
            clipBehavior: Clip.antiAlias,
            type: MaterialType.card,
            shape: CornersBorder.rounded(
              corners: Corners.all(shapeTheme.corner.full),
            ),
            color: widget.contained ? containerColor : Colors.transparent,
            elevation: widget.contained ? elevationTheme.level0 : 0.0,
            shadowColor: widget.contained
                ? colorTheme.shadow
                : Colors.transparent,
            child: CustomPaint(
              willChange: true,
              painter: _IndeterminateLoadingIndicatorPainter(
                repaint: _controller,
                indicatorColor: indicatorColor,
                morphScaleFactor: _morphScaleFactor,
                morphs: _morphSequence,
                morphIndex: _morphIndex,
                globalAngle: _globalAngle,
                rotation: _rotation,
                scale: _scale,
                morphProgress: _morphProgress,
                scaleMatrix: _scaleMatrix,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndeterminateLoadingIndicatorPainter extends CustomPainter {
  _IndeterminateLoadingIndicatorPainter({
    required super.repaint,
    required this.indicatorColor,
    required this.morphScaleFactor,
    required this.morphs,
    required this.morphIndex,
    required this.globalAngle,
    required this.rotation,
    required this.scale,
    required this.morphProgress,
    this.scaleMatrix,
  });

  final Color indicatorColor;

  final double morphScaleFactor;

  final List<Morph> morphs;

  final ValueListenable<int> morphIndex;

  final ValueListenable<double> globalAngle;

  final ValueListenable<double> rotation;

  final ValueListenable<double> scale;

  final ValueListenable<double> morphProgress;

  final Matrix4? scaleMatrix;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final angle =
        globalAngle.value +
        _kLinearRotationAngle * rotation.value +
        _kMorphRotationAngle * morphProgress.value;

    final scaleFactor = morphScaleFactor * scale.value;

    final currentMorph = morphs[morphIndex.value];
    final morphPath = currentMorph.toPath(progress: morphProgress.value);

    final processedPath = _processPath(
      path: morphPath,
      size: size,
      scaleFactor: scaleFactor,
      scaleMatrix: scaleMatrix,
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = indicatorColor;

    canvas
      // Save the canvas before applying the transform
      ..save()
      // Rotate the canvas around the size's center
      ..translate(center.dx, center.dy)
      ..rotate(angle)
      ..translate(-center.dx, -center.dy)
      // Draw the processed path onto the canvas
      ..drawPath(processedPath, paint)
      // Restore the canvas after applying the transform
      ..restore();
  }

  @override
  bool shouldRepaint(_IndeterminateLoadingIndicatorPainter oldDelegate) {
    return indicatorColor != oldDelegate.indicatorColor ||
        morphScaleFactor != oldDelegate.morphScaleFactor ||
        morphs != oldDelegate.morphs ||
        morphIndex != oldDelegate.morphIndex ||
        globalAngle != oldDelegate.globalAngle ||
        rotation != oldDelegate.rotation ||
        scale != oldDelegate.scale ||
        morphProgress != oldDelegate.morphProgress ||
        scaleMatrix != oldDelegate.scaleMatrix;
  }
}

Iterable<Morph> _generateMorphSequence({
  required List<RoundedPolygon> polygons,
  required bool circularSequence,
  RoundedPolygon Function(RoundedPolygon polygon)? forEachPolygon,
}) sync* {
  forEachPolygon ??= (polygon) => polygon.normalized();
  for (var i = 0; i < polygons.length; i++) {
    if (i + 1 < polygons.length) {
      yield Morph(forEachPolygon(polygons[i]), forEachPolygon(polygons[i + 1]));
    } else if (circularSequence) {
      // Create a morph from the last shape to the first shape
      yield Morph(forEachPolygon(polygons[i]), forEachPolygon(polygons[0]));
    }
  }
}

List<Morph> _updateMorphSequence({
  List<Morph>? morphSequence,
  required List<RoundedPolygon> polygons,
  required bool circularSequence,
  RoundedPolygon Function(RoundedPolygon polygon)? forEachPolygon,
}) {
  final iterable = _generateMorphSequence(
    polygons: polygons,
    circularSequence: circularSequence,
    forEachPolygon: forEachPolygon,
  );
  morphSequence
    ?..clear()
    ..addAll(iterable);
  return morphSequence ?? [...iterable];
}

double _calculateScaleFactor(
  List<RoundedPolygon> indicatorPolygons, {
  bool approximate = true,
}) {
  var scaleFactor = 1.0;
  for (var i = 0; i < indicatorPolygons.length; i++) {
    final polygon = indicatorPolygons[i];

    final bounds = polygon.calculateBounds(approximate: approximate);
    final maxBounds = polygon.calculateMaxBounds();

    final scaleX = bounds.width / maxBounds.width;
    final scaleY = bounds.height / maxBounds.height;

    // We use max(scaleX, scaleY) to handle cases like a pill-shape that can throw off the
    // entire calculation.
    scaleFactor = math.min(scaleFactor, math.max(scaleX, scaleY));
  }
  return scaleFactor;
}

Path _processPath({
  required Path path,
  required Size size,
  required double scaleFactor,
  Matrix4? scaleMatrix,
}) {
  scaleMatrix ??= Matrix4.zero();
  scaleMatrix
    ..setIdentity()
    ..scaleByDouble(
      size.width * scaleFactor,
      size.height * scaleFactor,
      1.0,
      1.0,
    );

  // Scale to the desired size.
  path = path.transform(scaleMatrix.storage);

  // Translate the path to align its center with the available size center.
  path = path.shift(size.center(Offset.zero) - path.getBounds().center);

  return path;
}
