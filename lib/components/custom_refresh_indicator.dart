import 'dart:async';
import 'dart:math' as math;

import 'package:materium/flutter.dart';

// TODO: implement PullToRefresh with Compose specs

// The over-scroll distance that moves the indicator to its maximum
// displacement, as a percentage of the scrollable's container extent.
const double _kDragContainerExtentPercentage = 0.25;

// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

// When the scroll ends, the duration of the refresh indicator's animation
// to the RefreshIndicator's displacement.
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);

// The duration of the ScaleTransition that starts when the refresh action
// has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// A widget that supports the Material "swipe to refresh" idiom.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=ORApMlzwMdM}
///
/// When the child's [Scrollable] descendant overscrolls, an animated circular
/// progress indicator is faded into view. When the scroll ends, if the
/// indicator has been dragged far enough for it to become completely opaque,
/// the [onRefresh] callback is called. The callback is expected to update the
/// scrollable's contents and then complete the [Future] it returns. The refresh
/// indicator disappears after the callback's [Future] has completed.
///
/// The trigger mode is configured by [CustomRefreshIndicator.triggerMode].
///
/// {@tool dartpad}
/// This example shows how [CustomRefreshIndicator] can be triggered in different ways.
///
/// ** See code in examples/api/lib/material/refresh_indicator/refresh_indicator.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to trigger [CustomRefreshIndicator] in a nested scroll view using
/// the [notificationPredicate] property.
///
/// ** See code in examples/api/lib/material/refresh_indicator/refresh_indicator.1.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to use [CustomRefreshIndicator] without the spinner.
///
/// ** See code in examples/api/lib/material/refresh_indicator/refresh_indicator.2.dart **
/// {@end-tool}
///
/// ## Troubleshooting
///
/// ### Refresh indicator does not show up
///
/// The [CustomRefreshIndicator] will appear if its scrollable descendant can be
/// overscrolled, i.e. if the scrollable's content is bigger than its viewport.
/// To ensure that the [CustomRefreshIndicator] will always appear, even if the
/// scrollable's content fits within its viewport, set the scrollable's
/// [Scrollable.physics] property to [AlwaysScrollableScrollPhysics]:
///
/// ```dart
/// ListView(
///   physics: const AlwaysScrollableScrollPhysics(),
///   // ...
/// )
/// ```
///
/// A [CustomRefreshIndicator] can only be used with a vertical scroll view.
///
/// See also:
///
///  * <https://material.io/design/platform-guidance/android-swipe-to-refresh.html>
///  * [CustomRefreshIndicatorState], can be used to programmatically show the refresh indicator.
///  * [RefreshProgressIndicator], widget used by [CustomRefreshIndicator] to show
///    the inner circular progress spinner during refreshes.
///  * [CupertinoSliverRefreshControl], an iOS equivalent of the pull-to-refresh pattern.
///    Must be used as a sliver inside a [CustomScrollView] instead of wrapping
///    around a [ScrollView] because it's a part of the scrollable instead of
///    being overlaid on top of it.
class CustomRefreshIndicator extends StatefulWidget {
  /// Creates a refresh indicator.
  ///
  /// The [onRefresh], [child], and [notificationPredicate] arguments must be
  /// non-null. The default
  /// [displacement] is 40.0 logical pixels.
  ///
  /// The [semanticsLabel] is used to specify an accessibility label for this widget.
  /// If it is null, it will be defaulted to [MaterialLocalizations.refreshIndicatorSemanticLabel].
  /// An empty string may be passed to avoid having anything read by screen reading software.
  /// The [semanticsValue] may be used to specify progress on the widget.
  const CustomRefreshIndicator({
    super.key,
    required this.child,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    required this.onRefresh,
    this.indicatorColor,
    this.containerColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = .onEdge,
    this.elevation,
    this.onStatusChange,
  }) : assert(elevation == null || elevation >= 0.0);

  /// The widget below this widget in the tree.
  ///
  /// The refresh indicator will be stacked on top of this child. The indicator
  /// will appear when child's Scrollable descendant is over-scrolled.
  ///
  /// Typically a [ListView] or [CustomScrollView].
  final Widget child;

  /// The distance from the child's top or bottom [edgeOffset] where
  /// the refresh indicator will settle. During the drag that exposes the refresh
  /// indicator, its actual displacement may significantly exceed this value.
  ///
  /// In most cases, [displacement] distance starts counting from the parent's
  /// edges. However, if [edgeOffset] is larger than zero then the [displacement]
  /// value is calculated from that offset instead of the parent's edge.
  final double displacement;

  /// The offset where [RefreshProgressIndicator] starts to appear on drag start.
  ///
  /// Depending whether the indicator is showing on the top or bottom, the value
  /// of this variable controls how far from the parent's edge the progress
  /// indicator starts to appear. This may come in handy when, for example, the
  /// UI contains a top [Widget] which covers the parent's edge where the progress
  /// indicator would otherwise appear.
  ///
  /// By default, the edge offset is set to 0.
  ///
  /// See also:
  ///
  ///  * [displacement], can be used to change the distance from the edge that
  ///    the indicator settles.
  final double edgeOffset;

  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh. The returned
  /// [Future] must complete when the refresh operation is finished.
  final RefreshCallback onRefresh;

  /// Called to get the current status of the [CustomRefreshIndicator] to update the UI as needed.
  /// This is an optional parameter, used to fine tune app cases.
  final ValueChanged<RefreshIndicatorStatus?>? onStatusChange;

  /// The progress indicator's background color. The current theme's
  /// [ThemeData.canvasColor] by default.
  final Color? containerColor;

  /// The progress indicator's foreground color. The current theme's
  /// [ColorScheme.primary] by default.
  final Color? indicatorColor;

  /// A check that specifies whether a [ScrollNotification] should be
  /// handled by this widget.
  ///
  /// By default, checks whether `notification.depth == 0`. Set it to something
  /// else for more complicated layouts.
  final ScrollNotificationPredicate notificationPredicate;

  /// {@macro flutter.progress_indicator.ProgressIndicator.semanticsLabel}
  ///
  /// This will be defaulted to [MaterialLocalizations.refreshIndicatorSemanticLabel]
  /// if it is null.
  final String? semanticsLabel;

  /// {@macro flutter.progress_indicator.ProgressIndicator.semanticsValue}
  final String? semanticsValue;

  /// Defines how this [CustomRefreshIndicator] can be triggered when users overscroll.
  ///
  /// The [CustomRefreshIndicator] can be pulled out in two cases,
  /// 1, Keep dragging if the scrollable widget at the edge with zero scroll position
  ///    when the drag starts.
  /// 2, Keep dragging after overscroll occurs if the scrollable widget has
  ///    a non-zero scroll position when the drag starts.
  ///
  /// If this is [RefreshIndicatorTriggerMode.anywhere], both of the cases above can be triggered.
  ///
  /// If this is [RefreshIndicatorTriggerMode.onEdge], only case 1 can be triggered.
  ///
  /// Defaults to [RefreshIndicatorTriggerMode.onEdge].
  final RefreshIndicatorTriggerMode triggerMode;

  /// Defines the elevation of the underlying [CustomRefreshIndicator].
  ///
  /// Defaults to 0.0.
  final double? elevation;

  @override
  CustomRefreshIndicatorState createState() => CustomRefreshIndicatorState();
}

/// Contains the state for a [CustomRefreshIndicator]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
class CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin<CustomRefreshIndicator> {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late Animation<double> _positionFactor;
  late Animation<double> _scaleFactor;
  late AnimationController _switchController;

  late Listenable _positionScaleListenable;

  RefreshIndicatorStatus? _status;
  late Future<void> _pendingRefreshFuture;
  bool? _isIndicatorAtTop;
  double? _dragOffset;

  final Tween<double> _kDragSizeFactorLimitTween = Tween<double>(
    begin: 0.0,
    end: _kDragSizeFactorLimit,
  );

  final Tween<double> _oneToZeroTween = Tween<double>(begin: 1.0, end: 0.0);

  @protected
  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);

    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);

    _switchController = AnimationController(vsync: this);

    _positionScaleListenable = Listenable.merge([
      _positionController,
      _scaleController,
    ]);
  }

  @protected
  @override
  void dispose() {
    _switchController.dispose();
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // If the notification.dragDetails is null, this scroll is not triggered by
  // user dragging. It may be a result of ScrollController.jumpTo or ballistic
  // scroll. In this case, we don't want to trigger the refresh indicator.
  bool _shouldStart(ScrollNotification notification) =>
      ((notification is ScrollStartNotification &&
              notification.dragDetails != null) ||
          (notification is ScrollUpdateNotification &&
              notification.dragDetails != null &&
              widget.triggerMode == .anywhere)) &&
      ((notification.metrics.axisDirection == .up &&
              notification.metrics.extentAfter == 0.0) ||
          (notification.metrics.axisDirection == .down &&
              notification.metrics.extentBefore == 0.0)) &&
      _status == null &&
      _start(notification.metrics.axisDirection);

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }
    if (_shouldStart(notification)) {
      setState(() {
        _status = .drag;
        widget.onStatusChange?.call(_status);
      });
      return false;
    }
    final indicatorAtTopNow = switch (notification.metrics.axisDirection) {
      .down || .up => true,
      .left || .right => null,
    };
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_status == .drag || _status == .armed) {
        _dismiss(.canceled);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_status == .drag || _status == .armed) {
        if (notification.metrics.axisDirection == .down) {
          _dragOffset = _dragOffset! - notification.scrollDelta!;
        } else if (notification.metrics.axisDirection == .up) {
          _dragOffset = _dragOffset! + notification.scrollDelta!;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
      if (_status == .armed && notification.dragDetails == null) {
        // On iOS start the refresh when the Scrollable bounces back from the
        // overscroll (ScrollNotification indicating this don't have dragDetails
        // because the scroll activity is not directly triggered by a drag).
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_status == .drag || _status == .armed) {
        if (notification.metrics.axisDirection == .down) {
          _dragOffset = _dragOffset! - notification.overscroll;
        } else if (notification.metrics.axisDirection == .up) {
          _dragOffset = _dragOffset! + notification.overscroll;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_status) {
        case .armed:
          if (_positionController.value < 1.0) {
            _dismiss(.canceled);
          } else {
            _show();
          }
        case .drag:
          _dismiss(.canceled);
        case .canceled:
        case .done:
        case .refresh:
        case .snap:
        case null:
          // do nothing
          break;
      }
    }
    return false;
  }

  bool _handleIndicatorNotification(
    OverscrollIndicatorNotification notification,
  ) {
    if (notification.depth != 0 || !notification.leading) {
      return false;
    }
    if (_status == .drag) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_status == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case .down:
      case .up:
        _isIndicatorAtTop = true;
      case .left:
      case .right:
        _isIndicatorAtTop = null;
        // we do not support horizontal scroll views.
        return false;
    }
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    assert(_status == .drag || _status == .armed);
    var newValue =
        _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);
    if (_status == .armed) {
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    }
    _positionController.value = clampDouble(
      newValue,
      0.0,
      1.0,
    ); // This triggers various rebuilds.
    if (_status == .drag &&
        _positionController.value >= 1.0 / _kDragSizeFactorLimit) {
      _status = .armed;
      widget.onStatusChange?.call(_status);
    }
  }

  // Stop showing the refresh indicator.
  Future<void> _dismiss(RefreshIndicatorStatus newMode) async {
    await Future<void>.value();
    // This can only be called from _show() when refreshing and
    // _handleScrollNotification in response to a ScrollEndNotification or
    // direction change.
    assert(newMode == .canceled || newMode == .done);
    setState(() {
      _status = newMode;
      widget.onStatusChange?.call(_status);
    });
    switch (_status!) {
      case .done:
        await _scaleController.animateTo(
          1.0,
          duration: _kIndicatorScaleDuration,
        );
      case .canceled:
        await _positionController.animateTo(
          0.0,
          duration: _kIndicatorScaleDuration,
        );
      case .armed:
      case .drag:
      case .refresh:
      case .snap:
        assert(false);
    }
    if (mounted && _status == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _status = null;
      });
    }
  }

  void _show() {
    assert(_status != .refresh);
    assert(_status != .snap);
    final completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _status = .snap;
    widget.onStatusChange?.call(_status);
    _positionController
        .animateTo(
          1.0 / _kDragSizeFactorLimit,
          duration: _kIndicatorSnapDuration,
        )
        .then((value) {
          if (mounted && _status == .snap) {
            // Show the indeterminate progress indicator.
            setState(() => _status = .refresh);

            widget.onRefresh().whenComplete(() {
              if (mounted && _status == .refresh) {
                completer.complete();
                _dismiss(.done);
              }
            });
          }
        });
  }

  /// Show the refresh indicator and run the refresh callback as if it had
  /// been started interactively. If this method is called while the refresh
  /// callback is running, it quietly does nothing.
  ///
  /// Creating the [CustomRefreshIndicator] with a [GlobalKey<RefreshIndicatorState>]
  /// makes it possible to refer to the [CustomRefreshIndicatorState].
  ///
  /// The future returned from this method completes when the
  /// [CustomRefreshIndicator.onRefresh] callback's future completes.
  ///
  /// If you await the future returned by this function from a [State], you
  /// should check that the state is still [mounted] before calling [setState].
  ///
  /// When initiated in this manner, the refresh indicator is independent of any
  /// actual scroll view. It defaults to showing the indicator at the top. To
  /// show it at the bottom, set `atTop` to false.
  Future<void> show({bool atTop = true}) {
    if (_status != .refresh && _status != .snap) {
      if (_status == null) {
        _start(atTop ? .down : .up);
      }
      _show();
    }
    return _pendingRefreshFuture;
  }

  bool? _showIndeterminateIndicator;

  @protected
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleIndicatorNotification,
        child: widget.child,
      ),
    );
    assert(() {
      if (_status == null) {
        assert(_dragOffset == null);
        assert(_isIndicatorAtTop == null);
      } else {
        assert(_dragOffset != null);
        assert(_isIndicatorAtTop != null);
      }
      return true;
    }());

    final showIndeterminateIndicator =
        _status == .snap || _status == .refresh || _status == .done;

    if (_showIndeterminateIndicator != showIndeterminateIndicator) {
      final spring = const SpringThemeData.expressive().defaultEffects
          .toSpringDescription();
      final oldValue = _switchController.value;
      final newValue = showIndeterminateIndicator ? 1.0 : 0.0;
      final simulation = SpringSimulation(
        spring,
        oldValue,
        newValue,
        0.0,
        snapToEnd: true,
      );
      if (newValue >= oldValue) {
        _switchController.animateWith(simulation);
      } else {
        _switchController.animateBackWith(simulation);
      }
    }

    _showIndeterminateIndicator = showIndeterminateIndicator;

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);

    final loadingIndicatorTheme = LoadingIndicatorTheme.of(context);

    final containerColor =
        widget.containerColor ?? loadingIndicatorTheme.containedContainerColor;

    final indicatorColor =
        widget.indicatorColor ?? loadingIndicatorTheme.containedIndicatorColor;

    final elevation = widget.elevation ?? elevationTheme.level0;

    Widget? layer;
    if (_status != null) {
      final Widget indeterminateLoadingIndicator = AnimatedBuilder(
        animation: _switchController,
        builder: (context, child) {
          final opacity = const Interval(
            0.0,
            0.5,
            curve: Curves.easeIn,
          ).transform(clampDouble(_switchController.value, 0.0, 1.0));
          return Visibility(
            visible: opacity > 0.0,
            child: Opacity(opacity: opacity, child: child!),
          );
        },
        child: IndeterminateLoadingIndicator(
          contained: false,
          indicatorColor: indicatorColor,
        ),
      );
      final Widget determinateLoadingIndicator = AnimatedBuilder(
        animation: _switchController,
        builder: (context, child) {
          final opacity = const Interval(
            0.0,
            0.5,
            curve: Curves.easeIn,
          ).transform(clampDouble(1.0 - _switchController.value, 0.0, 1.0));
          return Visibility(
            visible: opacity > 0.0,
            child: Opacity(opacity: opacity, child: child!),
          );
        },
        child: AnimatedBuilder(
          animation: _positionController,
          builder: (context, child) {
            final progress = _positionFactor.value;
            return Transform.rotate(
              angle: progress > 1.0 ? -(progress - 1.0) * math.pi : 0.0,
              child: DeterminateLoadingIndicator(
                contained: true,
                progress: clampDouble(progress, 0.0, 1.0),
              ),
            );
          },
        ),
      );
      final Widget containedLoadingIndicator = Material(
        animationDuration: Duration.zero,
        clipBehavior: .antiAlias,
        shape: CornersBorder.rounded(corners: .all(shapeTheme.corner.full)),
        color: containerColor,
        shadowColor: colorTheme.shadow,
        elevation: elevation,
        child: Stack(
          alignment: .center,
          children: [
            indeterminateLoadingIndicator,
            determinateLoadingIndicator,
          ],
        ),
      );
      final Widget scaleTransition = AnimatedBuilder(
        animation: _positionScaleListenable,
        child: containedLoadingIndicator,
        builder: (context, child) {
          final dragScale = const EasingThemeData.fallback().standard.transform(
            clampDouble(_positionFactor.value, 0.0, 1.0),
          );
          final visibilityScale = clampDouble(_scaleFactor.value, 0.0, 1.0);
          return Transform.scale(
            scale: dragScale * visibilityScale,
            child: child!,
          );
        },
      );
      final Widget fadeTransition = AnimatedBuilder(
        animation: _scaleController,
        child: scaleTransition,
        builder: (context, child) => Opacity(
          opacity: clampDouble(_scaleFactor.value, 0.0, 1.0),
          child: child!,
        ),
      );
      final Widget layout = Padding(
        padding: _isIndicatorAtTop!
            ? .only(top: widget.displacement)
            : .only(bottom: widget.displacement),
        child: Align(
          alignment: _isIndicatorAtTop! ? .topCenter : .bottomCenter,
          child: fadeTransition,
        ),
      );
      final Widget positionTransition = ClipRect(
        child: AnimatedBuilder(
          animation: _positionController,
          builder: (context, child) => Align(
            alignment: _isIndicatorAtTop! ? .bottomCenter : .topCenter,
            widthFactor: null,
            heightFactor: math.max(_positionFactor.value, 0.0),
            child: child!,
          ),
          child: layout,
        ),
      );
      layer = Positioned(
        top: _isIndicatorAtTop! ? widget.edgeOffset : null,
        bottom: !_isIndicatorAtTop! ? widget.edgeOffset : null,
        left: 0.0,
        right: 0.0,
        child: positionTransition,
      );
    }

    return Stack(children: [child, ?layer]);
  }
}
