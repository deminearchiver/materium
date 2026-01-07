import 'package:flutter/cupertino.dart';
import 'package:materium/flutter.dart';

// Examples can assume:
// typedef GlobalWidgetsLocalizations = DefaultWidgetsLocalizations;
// typedef GlobalMaterialLocalizations = DefaultMaterialLocalizations;

/// [RawMaterialApp] uses this [TextStyle] as its [DefaultTextStyle] to encourage
/// developers to be intentional about their [DefaultTextStyle].
///
/// In Material Design, most [Text] widgets are contained in [Material] widgets,
/// which sets a specific [DefaultTextStyle]. If you're seeing text that uses
/// this text style, consider putting your text in a [Material] widget (or
/// another widget that sets a [DefaultTextStyle]).
const _errorTextStyle = TextStyle(
  color: Color(0xD0FF0000),
  fontFamily: "monospace",
  fontSize: 48.0,
  fontWeight: .w900,
  decoration: .underline,
  decorationColor: Color(0xFFFFFF00),
  decorationStyle: .double,
  debugLabel: "fallback style",
);

class RawMaterialApp extends StatefulWidget {
  /// Creates a MaterialApp.
  ///
  /// At least one of [home], [routes], [onGenerateRoute], or [builder] must be
  /// non-null. If only [routes] is given, it must include an entry for the
  /// [Navigator.defaultRouteName] (`/`), since that is the route used when the
  /// application is launched with an intent that specifies an otherwise
  /// unsupported route.
  ///
  /// This class creates an instance of [WidgetsApp].
  const RawMaterialApp({
    super.key,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    Map<String, WidgetBuilder> this.routes = const {},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.onNavigationNotification,
    List<NavigatorObserver> this.navigatorObservers = const [],
    this.builder,
    this.title = "",
    this.onGenerateTitle,
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale("en", "US")],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
  }) : routeInformationProvider = null,
       routeInformationParser = null,
       routerDelegate = null,
       backButtonDispatcher = null,
       routerConfig = null;

  /// Creates a [RawMaterialApp] that uses the [Router] instead of a [Navigator].
  ///
  /// {@macro flutter.widgets.WidgetsApp.router}
  const RawMaterialApp.router({
    super.key,
    this.scaffoldMessengerKey,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.routerConfig,
    this.backButtonDispatcher,
    this.builder,
    this.title,
    this.onGenerateTitle,
    this.onNavigationNotification,
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale("en", "US")],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
  }) : assert(routerDelegate != null || routerConfig != null),
       navigatorObservers = null,
       navigatorKey = null,
       onGenerateRoute = null,
       home = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       routes = null,
       initialRoute = null;

  /// {@macro flutter.widgets.widgetsApp.navigatorKey}
  final GlobalKey<NavigatorState>? navigatorKey;

  /// A key to use when building the [ScaffoldMessenger].
  ///
  /// If a [scaffoldMessengerKey] is specified, the [ScaffoldMessenger] can be
  /// directly manipulated without first obtaining it from a [BuildContext] via
  /// [ScaffoldMessenger.of]: from the [scaffoldMessengerKey], use the
  /// [GlobalKey.currentState] getter.
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  /// {@macro flutter.widgets.widgetsApp.home}
  final Widget? home;

  /// The application's top-level routing table.
  ///
  /// When a named route is pushed with [Navigator.pushNamed], the route name is
  /// looked up in this map. If the name is present, the associated
  /// [WidgetBuilder] is used to construct a [MaterialPageRoute] that
  /// performs an appropriate transition, including [Hero] animations, to the
  /// new route.
  ///
  /// {@macro flutter.widgets.widgetsApp.routes}
  final Map<String, WidgetBuilder>? routes;

  /// {@macro flutter.widgets.widgetsApp.initialRoute}
  final String? initialRoute;

  /// {@macro flutter.widgets.widgetsApp.onGenerateRoute}
  final RouteFactory? onGenerateRoute;

  /// {@macro flutter.widgets.widgetsApp.onGenerateInitialRoutes}
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// {@macro flutter.widgets.widgetsApp.onUnknownRoute}
  final RouteFactory? onUnknownRoute;

  /// {@macro flutter.widgets.widgetsApp.onNavigationNotification}
  final NotificationListenerCallback<NavigationNotification>?
  onNavigationNotification;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver>? navigatorObservers;

  /// {@macro flutter.widgets.widgetsApp.routeInformationProvider}
  final RouteInformationProvider? routeInformationProvider;

  /// {@macro flutter.widgets.widgetsApp.routeInformationParser}
  final RouteInformationParser<Object>? routeInformationParser;

  /// {@macro flutter.widgets.widgetsApp.routerDelegate}
  final RouterDelegate<Object>? routerDelegate;

  /// {@macro flutter.widgets.widgetsApp.backButtonDispatcher}
  final BackButtonDispatcher? backButtonDispatcher;

  /// {@macro flutter.widgets.widgetsApp.routerConfig}
  final RouterConfig<Object>? routerConfig;

  /// {@macro flutter.widgets.widgetsApp.builder}
  ///
  /// Material specific features such as [showDialog] and [showMenu], and widgets
  /// such as [Tooltip], [PopupMenuButton], also require a [Navigator] to properly
  /// function.
  final TransitionBuilder? builder;

  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String? title;

  /// {@macro flutter.widgets.widgetsApp.onGenerateTitle}
  ///
  /// This value is passed unmodified to [WidgetsApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// {@macro flutter.widgets.widgetsApp.color}
  final Color? color;

  /// {@macro flutter.widgets.widgetsApp.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// Internationalized apps that require translations for one of the locales
  /// listed in [GlobalMaterialLocalizations] should specify this parameter
  /// and list the [supportedLocales] that the application can handle.
  ///
  /// ```dart
  /// // The GlobalMaterialLocalizations and GlobalWidgetsLocalizations
  /// // classes require the following import:
  /// // import 'package:flutter_localizations/flutter_localizations.dart';
  ///
  /// const MaterialApp(
  ///   localizationsDelegates: <LocalizationsDelegate<Object>>[
  ///     // ... app-specific localization delegate(s) here
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///   ],
  ///   supportedLocales: <Locale>[
  ///     Locale('en', 'US'), // English
  ///     Locale('he', 'IL'), // Hebrew
  ///     // ... other locales the app supports
  ///   ],
  ///   // ...
  /// )
  /// ```
  ///
  /// ## Adding localizations for a new locale
  ///
  /// The information that follows applies to the unusual case of an app
  /// adding translations for a language not already supported by
  /// [GlobalMaterialLocalizations].
  ///
  /// Delegates that produce [WidgetsLocalizations] and [MaterialLocalizations]
  /// are included automatically. Apps can provide their own versions of these
  /// localizations by creating implementations of
  /// [LocalizationsDelegate<WidgetsLocalizations>] or
  /// [LocalizationsDelegate<MaterialLocalizations>] whose load methods return
  /// custom versions of [WidgetsLocalizations] or [MaterialLocalizations].
  ///
  /// For example: to add support to [MaterialLocalizations] for a locale it
  /// doesn't already support, say `const Locale('foo', 'BR')`, one first
  /// creates a subclass of [MaterialLocalizations] that provides the
  /// translations:
  ///
  /// ```dart
  /// class FooLocalizations extends MaterialLocalizations {
  ///   FooLocalizations();
  ///   @override
  ///   String get okButtonLabel => 'foo';
  ///   // ...
  ///   // lots of other getters and methods to override!
  /// }
  /// ```
  ///
  /// One must then create a [LocalizationsDelegate] subclass that can provide
  /// an instance of the [MaterialLocalizations] subclass. In this case, this is
  /// essentially just a method that constructs a `FooLocalizations` object. A
  /// [SynchronousFuture] is used here because no asynchronous work takes place
  /// upon "loading" the localizations object.
  ///
  /// ```dart
  /// // continuing from previous example...
  /// class FooLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  ///   const FooLocalizationsDelegate();
  ///   @override
  ///   bool isSupported(Locale locale) {
  ///     return locale == const Locale('foo', 'BR');
  ///   }
  ///   @override
  ///   Future<FooLocalizations> load(Locale locale) {
  ///     assert(locale == const Locale('foo', 'BR'));
  ///     return SynchronousFuture<FooLocalizations>(FooLocalizations());
  ///   }
  ///   @override
  ///   bool shouldReload(FooLocalizationsDelegate old) => false;
  /// }
  /// ```
  ///
  /// Constructing a [RawMaterialApp] with a `FooLocalizationsDelegate` overrides
  /// the automatically included delegate for [MaterialLocalizations] because
  /// only the first delegate of each [LocalizationsDelegate.type] is used and
  /// the automatically included delegates are added to the end of the app's
  /// [localizationsDelegates] list.
  ///
  /// ```dart
  /// // continuing from previous example...
  /// const MaterialApp(
  ///   localizationsDelegates: <LocalizationsDelegate<Object>>[
  ///     FooLocalizationsDelegate(),
  ///   ],
  ///   // ...
  /// )
  /// ```
  /// See also:
  ///
  ///  * [supportedLocales], which must be specified along with
  ///    [localizationsDelegates].
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/to/internationalization/>.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// {@macro flutter.widgets.widgetsApp.localeListResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// {@macro flutter.widgets.LocaleResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  ///
  /// See also:
  ///
  ///  * [localizationsDelegates], which must be specified for localized
  ///    applications.
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/to/internationalization/>.
  final Iterable<Locale> supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/to/performance-overlay>
  final bool showPerformanceOverlay;

  /// Turns on checkerboarding of raster cache images.
  final bool checkerboardRasterCacheImages;

  /// Turns on checkerboarding of layers rendered to offscreen bitmaps.
  final bool checkerboardOffscreenLayers;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool debugShowCheckedModeBanner;

  /// {@macro flutter.widgets.widgetsApp.shortcuts}
  /// {@tool snippet}
  /// This example shows how to add a single shortcut for
  /// [LogicalKeyboardKey.select] to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     shortcuts: <ShortcutActivator, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.shortcuts.seeAlso}
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// {@macro flutter.widgets.widgetsApp.actions}
  /// {@tool snippet}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     actions: <Type, Action<Intent>>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction: CallbackAction<Intent>(
  ///         onInvoke: (Intent intent) {
  ///           // Do something here...
  ///           return null;
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.actions.seeAlso}
  final Map<Type, Action<Intent>>? actions;

  /// {@macro flutter.widgets.widgetsApp.restorationScopeId}
  final String? restorationScopeId;

  /// {@template flutter.material.materialApp.scrollBehavior}
  /// The default [ScrollBehavior] for the application.
  ///
  /// [ScrollBehavior]s describe how [Scrollable] widgets behave. Providing
  /// a [ScrollBehavior] can set the default [ScrollPhysics] across
  /// an application, and manage [Scrollable] decorations like [Scrollbar]s and
  /// [GlowingOverscrollIndicator]s.
  /// {@endtemplate}
  ///
  /// When null, defaults to [MaterialScrollBehavior].
  ///
  /// See also:
  ///
  ///  * [ScrollConfiguration], which controls how [Scrollable] widgets behave
  ///    in a subtree.
  final ScrollBehavior? scrollBehavior;

  /// Turns on a [GridPaper] overlay that paints a baseline grid
  /// Material apps.
  ///
  /// Only available in debug mode.
  ///
  /// See also:
  ///
  ///  * <https://material.io/design/layout/spacing-methods.html>
  final bool debugShowMaterialGrid;

  @override
  State<RawMaterialApp> createState() => _RawMaterialAppState();

  /// The [HeroController] used for Material page transitions.
  ///
  /// Used by the [RawMaterialApp].
  static HeroController createMaterialHeroController() => HeroController(
    createRectTween: (begin, end) =>
        MaterialRectArcTween(begin: begin, end: end),
  );
}

class _RawMaterialAppState extends State<RawMaterialApp> {
  late ColorThemeData _colorTheme;

  late HeroController _heroController;

  bool get _usesRouter =>
      widget.routerDelegate != null || widget.routerConfig != null;

  // Combine the Localizations for Material with the ones contributed
  // by the localizationsDelegates parameter, if any. Only the first delegate
  // of a particular LocalizationsDelegate.type is loaded so the
  // localizationsDelegate parameter can be used to override
  // _MaterialLocalizationsDelegate.
  List<LocalizationsDelegate<Object?>> get _localizationsDelegates => [
    ...?widget.localizationsDelegates,
    DefaultMaterialLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
  ];

  bool get _isDarkTheme => _colorTheme.brightness == .dark;

  /// The color property is pulled from the current theme. This color is only
  /// used on old Android OSes to color the app bar in Android's switcher UI.
  Color get _materialColor => widget.color ?? _colorTheme.primary;

  @override
  void initState() {
    super.initState();
    _heroController = RawMaterialApp.createMaterialHeroController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _colorTheme = ColorTheme.of(context);
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) =>
      (event is! KeyDownEvent && event is! KeyRepeatEvent) ||
          event.logicalKey != .escape
      ? .ignored
      : Tooltip.dismissAllToolTips()
      ? .handled
      : .ignored;

  Widget _buildExitWidgetSelectionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String semanticsLabel,
    required GlobalKey key,
  }) => _MaterialInspectorButton.filled(
    onPressed: onPressed,
    semanticsLabel: semanticsLabel,
    icon: Symbols.close_rounded,
    buttonKey: key,
  );

  Widget _buildMoveExitWidgetSelectionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String semanticsLabel,
    bool usesDefaultAlignment = true,
  }) => _MaterialInspectorButton.iconOnly(
    onPressed: onPressed,
    semanticsLabel: semanticsLabel,
    icon: usesDefaultAlignment
        ? Symbols.arrow_right_rounded
        : Symbols.arrow_left_rounded,
  );

  Widget _buildTapBehaviorButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String semanticsLabel,
    required bool selectionOnTapEnabled,
  }) => _MaterialInspectorButton.toggle(
    onPressed: onPressed,
    semanticsLabel: semanticsLabel,
    // This unicode icon is also used for the Cupertino-styled button and for
    // DevTools. It should be updated in all 3 places if changed.
    icon: const IconData(0x1F74A),
    toggledOn: selectionOnTapEnabled,
  );

  PageRoute<T> _buildMaterialPageRoute<T extends Object?>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) => MaterialPageRoute<T>(settings: settings, builder: builder);

  Widget _buildDefaults(BuildContext context, Widget? child) {
    SystemChrome.setSystemUIOverlayStyle(_isDarkTheme ? .light : .dark);

    var result = switch (widget.builder) {
      // Why are we surrounding a builder with a builder?
      //
      // The widget.builder may contain code that invokes
      // ScaffoldMessenger.of() or DefaultSelectionStyle.of().
      // If we invoke widget.builder() directly, then there is no BuildContext
      // separating them, then no inherited widgets will be found.
      // Therefore, we surround widget.builder with yet another builder so that
      // a context separates them and inherited widget methods correctly
      // resolve to the defaults we surrounded the child with.
      final builder? => Builder(builder: (context) => builder(context, child)),
      _ => child ?? const SizedBox.shrink(),
    };

    result = DefaultSelectionStyle(
      selectionColor: _colorTheme.primary.withValues(alpha: 0.4),
      cursorColor: _colorTheme.primary,
      child: result,
    );

    result = ScaffoldMessenger(key: widget.scaffoldMessengerKey, child: result);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget result = _usesRouter
        ? WidgetsApp.router(
            key: GlobalObjectKey(this),
            routeInformationProvider: widget.routeInformationProvider,
            routeInformationParser: widget.routeInformationParser,
            routerDelegate: widget.routerDelegate,
            routerConfig: widget.routerConfig,
            backButtonDispatcher: widget.backButtonDispatcher,
            onNavigationNotification: widget.onNavigationNotification,
            builder: _buildDefaults,
            title: widget.title,
            onGenerateTitle: widget.onGenerateTitle,
            textStyle: _errorTextStyle,
            color: _materialColor,
            locale: widget.locale,
            localizationsDelegates: _localizationsDelegates,
            localeResolutionCallback: widget.localeResolutionCallback,
            localeListResolutionCallback: widget.localeListResolutionCallback,
            supportedLocales: widget.supportedLocales,
            showPerformanceOverlay: widget.showPerformanceOverlay,
            showSemanticsDebugger: widget.showSemanticsDebugger,
            debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
            exitWidgetSelectionButtonBuilder: _buildExitWidgetSelectionButton,
            moveExitWidgetSelectionButtonBuilder:
                _buildMoveExitWidgetSelectionButton,
            tapBehaviorButtonBuilder: _buildTapBehaviorButton,
            shortcuts: widget.shortcuts,
            actions: widget.actions,
            restorationScopeId: widget.restorationScopeId,
          )
        : WidgetsApp(
            key: GlobalObjectKey(this),
            navigatorKey: widget.navigatorKey,
            navigatorObservers: widget.navigatorObservers!,
            pageRouteBuilder: _buildMaterialPageRoute,
            home: widget.home,
            routes: widget.routes!,
            initialRoute: widget.initialRoute,
            onGenerateRoute: widget.onGenerateRoute,
            onGenerateInitialRoutes: widget.onGenerateInitialRoutes,
            onUnknownRoute: widget.onUnknownRoute,
            onNavigationNotification: widget.onNavigationNotification,
            builder: _buildDefaults,
            title: widget.title,
            onGenerateTitle: widget.onGenerateTitle,
            textStyle: _errorTextStyle,
            color: _materialColor,
            locale: widget.locale,
            localizationsDelegates: _localizationsDelegates,
            localeResolutionCallback: widget.localeResolutionCallback,
            localeListResolutionCallback: widget.localeListResolutionCallback,
            supportedLocales: widget.supportedLocales,
            showPerformanceOverlay: widget.showPerformanceOverlay,
            showSemanticsDebugger: widget.showSemanticsDebugger,
            debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
            exitWidgetSelectionButtonBuilder: _buildExitWidgetSelectionButton,
            moveExitWidgetSelectionButtonBuilder:
                _buildMoveExitWidgetSelectionButton,
            tapBehaviorButtonBuilder: _buildTapBehaviorButton,
            shortcuts: widget.shortcuts,
            actions: widget.actions,
            restorationScopeId: widget.restorationScopeId,
          );

    result = Focus(
      canRequestFocus: false,
      onKeyEvent: _onKeyEvent,
      child: result,
    );

    assert(() {
      if (widget.debugShowMaterialGrid) {
        result = GridPaper(
          color: const Color(0xE0F9BBE0),
          interval: 8.0,
          subdivisions: 1,
          child: result,
        );
      }
      return true;
    }());

    result = HeroControllerScope(controller: _heroController, child: result);

    result = ScrollConfiguration(
      behavior: widget.scrollBehavior ?? const MaterialScrollBehavior(),
      child: result,
    );

    return result;
  }
}

class _MaterialInspectorButton extends InspectorButton {
  const _MaterialInspectorButton.filled({
    super.buttonKey,
    required super.onPressed,
    required super.icon,
    required super.semanticsLabel,
  }) : super.filled();

  const _MaterialInspectorButton.toggle({
    required super.toggledOn,
    required super.onPressed,
    required super.icon,
    required super.semanticsLabel,
  }) : super.toggle();

  const _MaterialInspectorButton.iconOnly({
    required super.onPressed,
    required super.icon,
    required super.semanticsLabel,
  }) : super.iconOnly();

  ButtonStyle _selectionButtonsIconStyle(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);

    final iconOnly = variant == .iconOnly;
    final backgroundColor = this.backgroundColor(context);
    final foregroundColor = this.foregroundColor(context);

    return LegacyThemeFactory.createIconButtonStyle(
      colorTheme: colorTheme,
      elevationTheme: elevationTheme,
      shapeTheme: shapeTheme,
      stateTheme: stateTheme,
      size: iconOnly ? .extraSmall : .small,
      shape: iconOnly ? .square : .round,
      width: .normal,
      isSelected: toggledOn,
      tapTargetSize: .padded,
      containerColor: backgroundColor,
      iconColor: foregroundColor,
      unselectedContainerColor: backgroundColor,
      unselectedIconColor: foregroundColor,
      selectedContainerColor: backgroundColor,
      selectedIconColor: foregroundColor,
    );
  }

  @override
  Color backgroundColor(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    return switch (variant) {
      .filled => colorTheme.errorContainer,
      .iconOnly => colorTheme.surfaceContainerLowest,
      .toggle => toggledOn! ? colorTheme.error : colorTheme.errorContainer,
    };
  }

  @override
  Color foregroundColor(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    return switch (variant) {
      .filled => colorTheme.onErrorContainer,
      .iconOnly => colorTheme.error,
      .toggle => toggledOn! ? colorTheme.onError : colorTheme.onErrorContainer,
    };
  }

  @override
  Widget build(BuildContext context) => IconButton(
    key: buttonKey,
    style: _selectionButtonsIconStyle(context),
    onPressed: onPressed,
    icon: IconLegacy(icon, semanticLabel: semanticsLabel),
  );
}
