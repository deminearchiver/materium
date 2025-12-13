import 'package:material/src/material/flutter.dart';
import 'package:flutter/scheduler.dart';

enum FocusRingPlacement { inward, outward }

typedef FocusRingLayoutBuilder =
    Widget Function(
      BuildContext context,
      OverlayChildLayoutInfo info,
      Widget child,
    );

class FocusRing extends StatefulWidget {
  const FocusRing({
    super.key,
    required this.visible,
    required this.placement,
    this.layoutBuilder = defaultLayoutBuilder,
    required this.child,
  });

  final bool visible;

  final FocusRingPlacement placement;

  final FocusRingLayoutBuilder layoutBuilder;

  final Widget child;

  @override
  State<FocusRing> createState() => _FocusRingState();

  static Widget defaultLayoutBuilder(
    BuildContext _,
    OverlayChildLayoutInfo _,
    Widget child,
  ) => child;
}

class _FocusRingState extends State<FocusRing>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _overlayPortalController =
      OverlayPortalController();

  late AnimationController _widthController;

  final _growValueTween = Tween<double>(begin: 0.0);
  final _shrinkValueTween = Tween<double>();
  final _growCurveTween = CurveTween(
    curve: const EasingThemeData.fallback().linear,
  );
  final _shrinkCurveTween = CurveTween(
    curve: const EasingThemeData.fallback().linear,
  );

  late Animation<double> _widthAnimation;

  late EasingThemeData _easingTheme;
  late FocusRingThemeData _focusRingTheme;

  bool _showOverlay() {
    if (_overlayPortalController.isShowing) return false;
    _overlayPortalController.show();
    return true;
  }

  bool _hideOverlay() {
    if (!_overlayPortalController.isShowing) return false;
    _overlayPortalController.hide();
    return true;
  }

  void _toggleOverlay([bool? show]) {
    final VoidCallback callback = show != null
        ? show
              ? _showOverlay
              : _hideOverlay
        : _overlayPortalController.toggle;
    _callDeferred(callback);
  }

  void _animationStatusListener(AnimationStatus status) {
    _toggleOverlay(status != .dismissed);
  }

  void _callDeferred(VoidCallback callback) {
    if (SchedulerBinding.instance.schedulerPhase == .persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        callback();
      });
    } else {
      callback();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      _toggleOverlay(true);
    }
    _widthController = AnimationController(
      vsync: this,
      value: widget.visible ? 1.0 : 0.0,
    )..addStatusListener(_animationStatusListener);
    _widthAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: _growValueTween.chain(_growCurveTween),
        weight: 0.25,
      ),
      TweenSequenceItem(
        tween: _shrinkValueTween.chain(_shrinkCurveTween),
        weight: 0.75,
      ),
    ]).animate(_widthController);
  }

  @override
  void didUpdateWidget(covariant FocusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _widthController.animateTo(1.0, duration: _focusRingTheme.duration);
      } else {
        _widthController.animateBack(0.0, duration: .zero);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _easingTheme = EasingTheme.of(context);
    _focusRingTheme = FocusRingTheme.of(context);

    _growValueTween.end = _focusRingTheme.activeWidth;
    _shrinkValueTween.begin = _focusRingTheme.activeWidth;
    _shrinkValueTween.end = _focusRingTheme.width;

    _growCurveTween.curve = _easingTheme.standard;
    _shrinkCurveTween.curve = _easingTheme.standard;
  }

  @override
  void dispose() {
    _widthController.dispose();
    super.dispose();
  }

  // Widget _buildGlobalOverlay(
  //   BuildContext context,
  //   OverlayChildLayoutInfo info,
  //   Widget child,
  // ) {
  //   final transform = info.childPaintTransform;
  //   final translateX = transform.storage[12];
  //   final translateY = transform.storage[13];
  //   final translationOffset = Offset(translateX, translateY);
  //   final scaleX = transform.storage[0];
  //   final scaleY = transform.storage[5];
  //   final childSize = info.childSize;
  //   final scaledChildSize = Size(
  //     childSize.width * scaleX,
  //     childSize.height * scaleY,
  //   );
  //   final focusIndicatorOffset = 2.0;
  //   final scaledFocusIndicatorSize = Size(
  //     childSize.width + focusIndicatorOffset * 2.0,
  //     childSize.height + focusIndicatorOffset * 2.0,
  //   );
  //   return IgnorePointer(
  //     child: Align.topLeft(
  //       child: Transform.translate(
  //         offset: translationOffset,
  //         child: SizedBox.fromSize(
  //           size: scaledChildSize,
  //           child: Align.center(
  //             child: SizedBox.fromSize(
  //               size: scaledFocusIndicatorSize,
  //               child: child,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLocalOverlay(
    BuildContext context,
    OverlayChildLayoutInfo info,
    Widget child,
  ) => IgnorePointer(
    child: Align.topLeft(
      child: Transform(
        transform: info.childPaintTransform,
        child: SizedBox.fromSize(
          size: info.childSize,
          child: widget.layoutBuilder(context, info, child),
        ),
      ),
    ),
  );

  Widget _buildIndicator(BuildContext context) {
    final padding = switch (widget.placement) {
      .inward => _focusRingTheme.inwardOffset,
      .outward => -_focusRingTheme.outwardOffset,
    };
    final strokeAlign = switch (widget.placement) {
      .inward => BorderSide.strokeAlignInside,
      .outward => BorderSide.strokeAlignOutside,
    };
    return AnimatedBuilder(
      animation: _widthController,
      builder: (context, _) => Padding(
        padding: EdgeInsetsGeometry.all(padding),
        child: DecoratedBox(
          position: .foreground,
          decoration: ShapeDecoration(
            shape: CornersBorder.rounded(
              corners: _focusRingTheme.shape,
              side: _widthAnimation.value > 0.0
                  ? BorderSide(
                      style: .solid,
                      color: _focusRingTheme.color,
                      width: _widthAnimation.value,
                      strokeAlign: strokeAlign,
                    )
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final indicator = _buildIndicator(context);
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlayPortalController,
      overlayChildBuilder: (context, info) =>
          _buildLocalOverlay(context, info, indicator),
      child: widget.child,
    );
  }
}
