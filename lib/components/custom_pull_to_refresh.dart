import 'dart:async';

import 'package:materium/flutter.dart';

class CustomPullToRefreshDelegate extends PullToRefreshDefaultDelegate {
  CustomPullToRefreshDelegate({required super.vsync, super.spring})
    : _layoutController = .new(
        vsync: vsync,
        lowerBound: 0.0,
        upperBound: .infinity,
        animationBehavior: .preserve,
      );

  final AnimationController _layoutController;

  var _isActive = false;

  Animation<double> get layoutFraction => _layoutController.view;

  SpringSimulation _createSimulation(double targetValue) => .new(
    spring,
    _layoutController.value,
    targetValue,
    _layoutController.velocity,
    snapToEnd: true,
  );

  @override
  void snapTo(double targetValue) {
    super.snapTo(targetValue);
    if (!_isActive) {
      _layoutController.value = targetValue;
    }
  }

  @override
  TickerFuture animateToThreshold() {
    _isActive = true;
    unawaited(_layoutController.animateWith(_createSimulation(0.0)));
    return super.animateToThreshold();
  }

  @override
  TickerFuture animateToHidden() {
    _isActive = false;
    unawaited(_layoutController.animateWith(_createSimulation(0.0)));
    return super.animateToHidden();
  }

  @override
  void dispose() {
    _layoutController.dispose();
    super.dispose();
  }
}

mixin CustomPullToRefreshStates implements PullToRefreshStates {
  double get layoutFraction;

  double get layoutHeight;
}

class CustomPullToRefreshController
    extends PullToRefreshController<CustomPullToRefreshDelegate>
    implements
        CustomPullToRefreshStates,
        ValueListenable<CustomPullToRefreshStates> {
  CustomPullToRefreshController({
    super.onRefresh,
    super.enabled,
    required super.delegate,
    super.threshold,
    super.isRefreshing,
  }) {
    delegate.layoutFraction.addListener(notifyListeners);
  }

  @override
  double get layoutFraction => delegate.layoutFraction.value;

  @override
  double get layoutHeight => layoutFraction * threshold;

  @override
  CustomPullToRefreshStates get value => this;

  @override
  void dispose() {
    delegate.layoutFraction.removeListener(notifyListeners);
    super.dispose();
  }
}

class CustomPullToRefresh extends StatefulWidget {
  const CustomPullToRefresh({
    super.key,
    required this.onRefresh,
    this.enabled = true,
    this.threshold = defaultThreshold,
    required this.builder,
  });

  final RefreshCallback onRefresh;

  final bool enabled;
  final double threshold;

  final Widget Function(
    BuildContext context,
    CustomPullToRefreshController controller,
  )
  builder;

  @override
  CustomPullToRefreshState createState() => CustomPullToRefreshState();

  static const defaultThreshold = 80.0;
}

class CustomPullToRefreshState extends State<CustomPullToRefresh>
    with TickerProviderStateMixin {
  late CustomPullToRefreshController _controller;

  late CustomPullToRefreshDelegate _delegate;

  Future<void>? _refreshFuture;

  void _onRefresh() {
    if (!mounted) return;

    final completer = Completer<void>();
    _refreshFuture = completer.future;

    _controller.isRefreshing = true;

    unawaited(
      widget.onRefresh().whenComplete(() {
        if (!mounted) return;

        _controller.isRefreshing = false;

        if (!completer.isCompleted) {
          completer.complete();
        }

        _refreshFuture = null;
      }),
    );
  }

  ValueListenable<CustomPullToRefreshStates> get states => _controller;

  Future<void> show() {
    if (!mounted) return Future.value();
    if (_refreshFuture case final refreshFuture?) {
      return refreshFuture;
    }
    _onRefresh();
    return _refreshFuture ?? Future.value();
  }

  // TODO: implement?
  // bool dismiss() {}

  @override
  void initState() {
    super.initState();
    _delegate = .new(vsync: this);
    _controller = .new(
      onRefresh: _onRefresh,
      enabled: widget.enabled,
      delegate: _delegate,
      threshold: widget.threshold,
      isRefreshing: false,
    );
  }

  @override
  void didUpdateWidget(covariant CustomPullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.enabled = widget.enabled;
    _controller.threshold = widget.threshold;
  }

  @override
  void dispose() {
    _controller.dispose();
    _delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
