import 'package:materium/flutter.dart';

class CustomDecoratedSliver extends SingleChildRenderObjectWidget {
  const CustomDecoratedSliver({
    super.key,
    this.position = DecorationPosition.background,
    required this.decoration,
    required Widget sliver,
  }) : super(child: sliver);

  final DecorationPosition position;

  final Decoration decoration;

  @override
  RenderCustomDecoratedSliver createRenderObject(BuildContext context) {
    return RenderCustomDecoratedSliver(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomDecoratedSliver renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..position = position
      ..configuration = createLocalImageConfiguration(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final String label = switch (position) {
      DecorationPosition.background => "bg",
      DecorationPosition.foreground => "fg",
    };
    properties
      ..add(
        EnumProperty<DecorationPosition>(
          "position",
          position,
          level: DiagnosticLevel.hidden,
        ),
      )
      ..add(DiagnosticsProperty<Decoration>(label, decoration));
  }
}

class RenderCustomDecoratedSliver extends RenderProxySliver {
  RenderCustomDecoratedSliver({
    required Decoration decoration,
    DecorationPosition position = DecorationPosition.background,
    ImageConfiguration configuration = ImageConfiguration.empty,
  }) : _decoration = decoration,
       _position = position,
       _configuration = configuration;

  Decoration get decoration => _decoration;
  Decoration _decoration;
  set decoration(Decoration value) {
    if (value == decoration) {
      return;
    }
    _decoration = value;
    _painter?.dispose();
    _painter = decoration.createBoxPainter(markNeedsPaint);
    markNeedsPaint();
  }

  DecorationPosition get position => _position;
  DecorationPosition _position;
  set position(DecorationPosition value) {
    if (value == position) {
      return;
    }
    _position = value;
    markNeedsPaint();
  }

  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    if (value == configuration) {
      return;
    }
    _configuration = value;
    markNeedsPaint();
  }

  BoxPainter? _painter;

  @override
  void attach(covariant PipelineOwner owner) {
    // TODO: figure out the correct order for the super call
    _painter = decoration.createBoxPainter(markNeedsPaint);
    super.attach(owner);
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
  }

  @override
  void dispose() {
    _painter?.dispose();
    _painter = null;
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || !child!.geometry!.visible) {
      return;
    }

    // The remaining space in the viewportMainAxisExtent. Can be <= 0 if we have
    // scrolled beyond the extent of the screen.
    // double extent =
    //     constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;

    // The maxExtent includes any overscrolled area. Can be < 0 if we have
    // overscroll in the opposite direction, away from the end of the list.
    // double maxExtent =
    //     constraints.remainingPaintExtent - math.min(constraints.overlap, 0.0);

    final nextSliverExtent =
        constraints.remainingPaintExtent - child!.geometry!.paintExtent;
    final double cappedMainAxisExtent =
        geometry!.paintExtent - constraints.overlap + nextSliverExtent;
    final (Size childSize, Offset scrollOffset) = switch (constraints.axis) {
      Axis.horizontal => (
        Size(cappedMainAxisExtent, constraints.crossAxisExtent),
        Offset(constraints.overlap, 0.0),
      ),
      Axis.vertical => (
        Size(constraints.crossAxisExtent, cappedMainAxisExtent),
        Offset(0.0, constraints.overlap),
      ),
    };

    // Original implementation of the above code:

    // In the case where the child sliver has infinite scroll extent, the decoration
    // should only extend down to the bottom cache extent.
    // final double cappedMainAxisExtent = child!.geometry!.scrollExtent.isInfinite
    //     ? constraints.scrollOffset +
    //           child!.geometry!.cacheExtent +
    //           constraints.cacheOrigin
    //     : child!.geometry!.scrollExtent;
    // final (Size childSize, Offset scrollOffset) = switch (constraints.axis) {
    //   Axis.horizontal => (
    //     Size(cappedMainAxisExtent, constraints.crossAxisExtent),
    //     Offset(-constraints.scrollOffset, 0.0),
    //   ),
    //   Axis.vertical => (
    //     Size(constraints.crossAxisExtent, cappedMainAxisExtent),
    //     Offset(0.0, -constraints.scrollOffset),
    //   ),
    // };

    offset += (child!.parentData! as SliverPhysicalParentData).paintOffset;
    void paintDecoration() => _painter!.paint(
      context.canvas,
      offset + scrollOffset,
      configuration.copyWith(size: childSize),
    );
    switch (position) {
      case DecorationPosition.background:
        paintDecoration();
        context.paintChild(child!, offset);
      case DecorationPosition.foreground:
        context.paintChild(child!, offset);
        paintDecoration();
    }
  }
}
