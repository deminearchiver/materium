import 'dart:ui';

import 'package:materium/flutter.dart';

const double _kCollapsedHeight = 64.0;
const double _kExpandedBottomPadding = 12.0;

const Curve _kFastOutLinearIn = Cubic(0.4, 0.0, 1.0, 1.0);

enum CustomAppBarType { small, mediumFlexible, largeFlexible }

enum CustomAppBarBehavior { duplicate, stretch }

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    super.key,
    // TODO: reorder CustomAppBar properties
    this.scrollController,
    required this.type,
    this.behavior,
    this.primary = true,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.stretch = false,
    this.systemOverlayStyle,
    this.collapsedPadding,
    this.expandedPadding,
    this.collapsedContainerColor,
    this.expandedContainerColor,
    this.collapsedTitleTextStyle,
    this.expandedTitleTextStyle,
    this.collapsedSubtitleTextStyle,
    this.expandedSubtitleTextStyle,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
  });

  final ScrollController? scrollController;

  final CustomAppBarType type;
  final CustomAppBarBehavior? behavior;
  final bool primary;
  final bool floating;
  final bool pinned;
  final bool snap;
  final bool stretch;
  final SystemUiOverlayStyle? systemOverlayStyle;

  final EdgeInsetsGeometry? collapsedPadding;
  final EdgeInsetsGeometry? expandedPadding;

  final Color? collapsedContainerColor;
  final Color? expandedContainerColor;

  final TextStyle? collapsedTitleTextStyle;
  final TextStyle? expandedTitleTextStyle;

  final TextStyle? collapsedSubtitleTextStyle;
  final TextStyle? expandedSubtitleTextStyle;

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  static _CustomAppBarState? _maybeStateOf(BuildContext context) =>
      _CustomAppBarScope.maybeOf(context)?.state;

  static _CustomAppBarState _stateOf(BuildContext context) =>
      _CustomAppBarScope.of(context).state;

  static Animation<double>? maybeAnimationOf(BuildContext context) =>
      _maybeStateOf(context)?._animation;

  static Animation<double> animationOf(BuildContext context) =>
      _stateOf(context)._animation;

  static final Animatable<double> _expandedOpacityAnimatable = Tween<double>(
    begin: 1.0,
    end: 0.0,
  );

  static final Animatable<double> _collapsedOpacityAnimatable = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: const Cubic(0.8, 0.0, 0.8, 0.15)));

  static Animation<double> containerColorFractionAnimation(
    Animation<double> parent,
  ) => CurveTween(curve: _kFastOutLinearIn).animate(parent);

  static Animation<double> expandedOpacityAnimation(Animation<double> parent) =>
      _expandedOpacityAnimatable.animate(parent);

  static Animation<double> collapsedOpacityAnimation(
    Animation<double> parent,
  ) => _collapsedOpacityAnimatable.animate(parent);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late ColorThemeData _colorTheme;
  late TypescaleThemeData _typescaleTheme;
  ScrollPosition? _position;

  CustomAppBarBehavior get _behavior => widget.behavior ?? .duplicate;

  TypeStyle get _collapsedTitleTypeStyle =>
      _typescaleTheme.titleLargeEmphasized;

  TextStyle get _collapsedTitleTextStyle => _collapsedTitleTypeStyle
      .toTextStyle(color: _colorTheme.onSurface)
      .merge(widget.collapsedTitleTextStyle);

  TypeStyle get _collapsedSubtitleTypeStyle => _typescaleTheme.labelMedium;

  TextStyle get _collapsedSubtitleTextStyle => _collapsedSubtitleTypeStyle
      .toTextStyle(color: _colorTheme.onSurfaceVariant)
      .merge(widget.collapsedSubtitleTextStyle);

  double get _collapsedTitleSubtitleSpace => 0.0;

  EdgeInsetsGeometry get _collapsedPadding =>
      widget.collapsedPadding?.horizontalInsets() ??
      const .symmetric(horizontal: 16.0, vertical: 0.0);

  double get _collapsedContentHeight =>
      _collapsedTitleTypeStyle.lineHeight +
      (widget.subtitle != null
          ? _collapsedTitleSubtitleSpace +
                _collapsedSubtitleTypeStyle.lineHeight
          : 0.0);

  double get _collapsedHeight => _kCollapsedHeight;

  Color get _collapsedColor =>
      widget.collapsedContainerColor ?? _colorTheme.surfaceContainer;

  TypeStyle get _expandedTitleTypeStyle => switch (widget.type) {
    .small => _collapsedTitleTypeStyle,
    .mediumFlexible => _typescaleTheme.headlineMediumEmphasized,
    .largeFlexible => _typescaleTheme.displaySmallEmphasized,
  };

  TextStyle get _expandedTitleTextStyle => _expandedTitleTypeStyle
      .toTextStyle(color: _colorTheme.onSurface)
      .merge(widget.expandedTitleTextStyle);

  TypeStyle get _expandedSubtitleTypeStyle => switch (widget.type) {
    .small => _collapsedSubtitleTypeStyle,
    .mediumFlexible => _typescaleTheme.labelLarge,
    .largeFlexible => _typescaleTheme.titleMedium,
  };

  TextStyle get _expandedSubtitleTextStyle => _expandedSubtitleTypeStyle
      .toTextStyle(color: _colorTheme.onSurfaceVariant)
      .merge(widget.expandedSubtitleTextStyle);

  double get _expandedTitleSubtitleSpace => switch (widget.type) {
    .small => _collapsedTitleSubtitleSpace,
    .mediumFlexible => 4.0,
    .largeFlexible => 8.0,
  };

  EdgeInsetsGeometry get _expandedPadding => widget.type == .small
      ? _collapsedPadding
      : widget.expandedPadding ??
            const .fromLTRB(16.0, 0.0, 16.0, _kExpandedBottomPadding);

  double get _expandedContentHeight => widget.type == .small
      ? _collapsedContentHeight
      : _expandedTitleTypeStyle.lineHeight +
            (widget.subtitle != null
                ? _expandedTitleSubtitleSpace +
                      _expandedSubtitleTypeStyle.lineHeight
                : 0.0);

  double get _expandedHeight => widget.type == .small
      ? _collapsedHeight
      : _collapsedHeight + _expandedContentHeight + _expandedPadding.vertical;

  Color get _expandedColor =>
      widget.expandedContainerColor ?? _colorTheme.surface;

  late _RawAnimation<double> _animation;

  late Animation<double> _containerColorFractionAnimation;

  void _scrollPositionListener() {
    _updateAnimation();
  }

  void _isScrollingListener() {
    _updateAnimation();
  }

  void _updateAnimation() {
    assert(_position != null);
    final position = _position!;

    assert(position.hasPixels);
    final pixels = position.pixels;

    final isScrolling = position.isScrollingNotifier.value;

    final heightDifference = _expandedHeight - _collapsedHeight;

    final oldValue = _animation.value;
    final newValue = clampDouble(
      pixels / (heightDifference > 0.0 ? heightDifference : _collapsedHeight),
      0.0,
      1.0,
    );

    final oldStatus = _animation.status;
    final AnimationStatus newStatus =
        newValue == 0.0 || newValue == 1.0 || !isScrolling
        ? oldStatus == .dismissed
              ? .dismissed
              : .completed
        : newValue > oldValue
        ? .forward
        : .reverse;

    if (oldValue == newValue && oldStatus == newStatus) return;

    _animation.value = newValue;
    _animation.status = newStatus;
  }

  @override
  void initState() {
    super.initState();
    _animation = _RawAnimation(status: .dismissed, value: 0.0);
    _containerColorFractionAnimation =
        CustomAppBar.containerColorFractionAnimation(_animation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorTheme = ColorTheme.of(context);
    _typescaleTheme = TypescaleTheme.of(context);

    final oldPosition = _position;
    final newPosition =
        widget.scrollController?.positions.singleOrNull ??
        Scrollable.of(context, axis: .vertical).position;

    if (oldPosition != newPosition) {
      oldPosition?.isScrollingNotifier.removeListener(_isScrollingListener);
      oldPosition?.removeListener(_scrollPositionListener);

      newPosition.addListener(_scrollPositionListener);
      newPosition.isScrollingNotifier.addListener(_isScrollingListener);
    }
    _position = newPosition;
    _updateAnimation();
  }

  @override
  void dispose() {
    _position?.removeListener(_scrollPositionListener);
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = widget.primary
        ? MediaQuery.maybePaddingOf(context)?.top ?? 0.0
        : 0.0;
    final Widget flexibleSpace = Padding(
      padding: .only(top: topPadding),
      child: Stack(
        fit: .expand,
        children: [
          if (widget.title != null || widget.subtitle != null)
            switch (_behavior) {
              _ when _expandedHeight <= _collapsedHeight =>
                _CustomAppBarAlwaysCollapsedFlexibleSpace(
                  title: widget.title,
                  subtitle: widget.subtitle,
                ),
              .duplicate => _CustomAppBarDuplicatingFlexibleSpace(
                expandedTitle: widget.title,
                expandedSubtitle: widget.subtitle,
                collapsedTitle: widget.title,
                collapsedSubtitle: widget.subtitle,
              ),
              .stretch => _CustomAppBarStretchingFlexibleSpace(
                title: widget.title,
                subtitle: widget.subtitle,
              ),
            },
          Positioned(
            left: 0.0,
            top: 0.0,
            right: 0.0,
            height: _collapsedHeight,
            child: Flex.horizontal(
              children: [
                ?widget.leading,
                const Flexible.space(),
                ?widget.trailing,
              ],
            ),
          ),
        ],
      ),
    );
    return _CustomAppBarScope(
      state: this,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) => SliverAppBar(
          primary: widget.primary,
          floating: widget.floating,
          pinned: widget.pinned,
          snap: widget.snap,
          stretch: widget.stretch,
          systemOverlayStyle: widget.systemOverlayStyle,
          automaticallyImplyLeading: false,
          collapsedHeight: _collapsedHeight,
          expandedHeight: _expandedHeight,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          leadingWidth: 0.0,
          leading: null,
          title: null,
          actions: const [],
          actionsPadding: .zero,
          backgroundColor: _expandedColor == _collapsedColor
              ? _expandedColor
              : .lerp(
                  _expandedColor,
                  _collapsedColor,
                  _containerColorFractionAnimation.value,
                )!,
          flexibleSpace: flexibleSpace,
          bottom: widget.bottom,
        ),
      ),
    );
  }
}

class _CustomAppBarScope extends InheritedWidget {
  const _CustomAppBarScope({
    // ignore: unused_element_parameter
    super.key,
    required this.state,
    required super.child,
  });

  final _CustomAppBarState state;

  @override
  bool updateShouldNotify(_CustomAppBarScope oldWidget) {
    return state != oldWidget.state;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<_CustomAppBarState>("state", state));
  }

  static _CustomAppBarScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_CustomAppBarScope>();
  }

  static _CustomAppBarScope of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null);
    return result!;
  }
}

class _CustomAppBarAlwaysCollapsedFlexibleSpace extends StatelessWidget {
  const _CustomAppBarAlwaysCollapsedFlexibleSpace({
    // ignore: unused_element_parameter
    super.key,
    this.title,
    this.subtitle,
  }) : assert(title != null || subtitle != null);

  final Widget? title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final state = CustomAppBar._stateOf(context);
    return SizedBox(
      height: state._collapsedHeight,
      child: Padding(
        padding: state._collapsedPadding,
        child: Flex.vertical(
          mainAxisSize: .min,
          mainAxisAlignment: .center,
          crossAxisAlignment: .stretch,
          children: [
            if (title case final title?)
              DefaultTextStyle.merge(
                maxLines: 1,
                overflow: .ellipsis,
                textAlign: .start,
                style: state._collapsedTitleTextStyle,
                child: title,
              ),
            if (title != null && subtitle != null)
              SizedBox(height: state._collapsedTitleSubtitleSpace),
            if (subtitle case final subtitle?)
              DefaultTextStyle.merge(
                maxLines: 1,
                overflow: .ellipsis,
                textAlign: .start,
                style: state._collapsedSubtitleTextStyle,
                child: subtitle,
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomAppBarDuplicatingFlexibleSpace extends StatefulWidget {
  const _CustomAppBarDuplicatingFlexibleSpace({
    // ignore: unused_element_parameter
    super.key,
    // TODO: reorder _CustomAppBarDuplicatingHeader properties
    this.collapsedTitle,
    this.collapsedSubtitle,
    this.expandedTitle,
    this.expandedSubtitle,
  }) : assert(
         (expandedTitle != null || expandedSubtitle != null) ||
             (collapsedTitle != null || collapsedSubtitle != null),
       );

  final Widget? collapsedTitle;
  final Widget? collapsedSubtitle;

  final Widget? expandedTitle;
  final Widget? expandedSubtitle;

  @override
  State<_CustomAppBarDuplicatingFlexibleSpace> createState() =>
      _CustomAppBarDuplicatingFlexibleSpaceState();
}

class _CustomAppBarDuplicatingFlexibleSpaceState
    extends State<_CustomAppBarDuplicatingFlexibleSpace> {
  late _CustomAppBarState _state;
  late Animation<double> _expandedOpacityAnimation;
  late Animation<double> _collapsedOpacityAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = CustomAppBar._stateOf(context);
    _expandedOpacityAnimation = CustomAppBar.expandedOpacityAnimation(
      _state._animation,
    );
    _collapsedOpacityAnimation = CustomAppBar.collapsedOpacityAnimation(
      _state._animation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = _state._animation;

    final hangingHeight = _state._expandedHeight - _state._collapsedHeight;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final hideCollapsedSemantics = animation.value < 0.5;
        final hideExpandedSemantics = !hideCollapsedSemantics;
        return Flex.vertical(
          crossAxisAlignment: .stretch,
          children: [
            ExcludeSemantics(
              excluding: hideCollapsedSemantics,
              child: SizedBox(
                height: _state._collapsedHeight,
                child: Padding(
                  padding: _state._collapsedPadding,
                  child: Opacity(
                    opacity: _collapsedOpacityAnimation.value,
                    child: Flex.vertical(
                      mainAxisSize: .min,
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .stretch,
                      children: [
                        if (widget.collapsedTitle case final collapsedTitle?)
                          DefaultTextStyle.merge(
                            maxLines: 1,
                            overflow: .ellipsis,
                            textAlign: .start,
                            style: _state._collapsedTitleTextStyle,
                            child: collapsedTitle,
                          ),
                        if (widget.collapsedTitle != null &&
                            widget.collapsedSubtitle != null)
                          SizedBox(height: _state._collapsedTitleSubtitleSpace),
                        if (widget.collapsedSubtitle
                            case final collapsedSubtitle?)
                          DefaultTextStyle.merge(
                            maxLines: 1,
                            overflow: .ellipsis,
                            textAlign: .start,
                            style: _state._collapsedSubtitleTextStyle,
                            child: collapsedSubtitle,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ExcludeSemantics(
              excluding: hideExpandedSemantics,
              child: ClipRect(
                child: SizedBox(
                  height: lerpDouble(hangingHeight, 0.0, animation.value),
                  child: OverflowBox(
                    minHeight: 0.0,
                    maxHeight: hangingHeight,
                    alignment: .bottomCenter,
                    child: Padding(
                      padding: _state._expandedPadding,
                      child: Opacity(
                        opacity: _expandedOpacityAnimation.value,
                        child: Flex.vertical(
                          mainAxisSize: .min,
                          mainAxisAlignment: .center,
                          crossAxisAlignment: .stretch,
                          children: [
                            if (widget.expandedTitle case final expandedTitle?)
                              DefaultTextStyle.merge(
                                maxLines: 1,
                                overflow: .ellipsis,
                                textAlign: .start,
                                style: _state._expandedTitleTextStyle,
                                child: expandedTitle,
                              ),
                            if (widget.expandedTitle != null &&
                                widget.expandedSubtitle != null)
                              SizedBox(
                                height: _state._expandedTitleSubtitleSpace,
                              ),
                            if (widget.expandedSubtitle
                                case final expandedSubtitle?)
                              DefaultTextStyle.merge(
                                maxLines: 1,
                                overflow: .ellipsis,
                                textAlign: .start,
                                style: _state._expandedSubtitleTextStyle,
                                child: expandedSubtitle,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CustomAppBarStretchingFlexibleSpace extends StatelessWidget {
  const _CustomAppBarStretchingFlexibleSpace({
    // ignore: unused_element_parameter
    super.key,
    this.title,
    this.subtitle,
  }) : assert(title != null || subtitle != null);

  final Widget? title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final state = CustomAppBar._stateOf(context);
    final Animation<double> animation = state._animation;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Align(
        alignment: .lerp(
          state._collapsedHeight == state._expandedHeight
              ? .center
              : .bottomCenter,
          .center,
          animation.value,
        )!,
        child: Padding(
          padding: .lerp(
            state._expandedPadding,
            state._collapsedPadding.horizontalInsets(),
            animation.value,
          )!,
          child: Flex.vertical(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            crossAxisAlignment: .stretch,
            children: [
              if (title case final title?)
                DefaultTextStyle.merge(
                  maxLines: 1,
                  overflow: .ellipsis,
                  textAlign: .start,
                  style: .lerp(
                    state._expandedTitleTextStyle,
                    state._collapsedTitleTextStyle,
                    animation.value,
                  )!,
                  child: title,
                ),
              if (title != null && subtitle != null)
                SizedBox(
                  height: lerpDouble(
                    state._expandedTitleSubtitleSpace,
                    state._collapsedTitleSubtitleSpace,
                    animation.value,
                  ),
                ),
              if (subtitle case final subtitle?)
                DefaultTextStyle.merge(
                  maxLines: 1,
                  overflow: .ellipsis,
                  textAlign: .start,
                  style: .lerp(
                    state._expandedSubtitleTextStyle,
                    state._collapsedSubtitleTextStyle,
                    animation.value,
                  )!,
                  child: subtitle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RawAnimation<T extends Object?> extends Animation<T>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  _RawAnimation({required AnimationStatus status, required T value})
    : _status = status,
      _value = value;

  AnimationStatus _status;

  @override
  AnimationStatus get status => _status;

  set status(AnimationStatus value) {
    if (_status == value) return;
    _status = value;
    notifyStatusListeners(status);
  }

  T _value;

  @override
  T get value => _value;

  set value(T value) {
    if (_value == value) return;
    _value = value;
    notifyListeners();
  }
}
