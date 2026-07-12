import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:materium/flutter.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/home.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/logs_provider.dart';
import 'package:materium/providers/notifications_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:provider/provider.dart';

class Obtainium extends StatefulWidget {
  const Obtainium({super.key});

  @override
  State<Obtainium> createState() => _ObtainiumState();
}

class _ObtainiumState extends State<Obtainium> {
  SettingsService? _settingsOrNull;
  SettingsService get _settings {
    assert(_settingsOrNull != null);
    return _settingsOrNull!;
  }

  late Listenable _themeListenable;

  var _lastUpdateInterval = -1;
  var _lastUseFGService = false;
  var _firstRunHandled = false;

  Future<void> requestNonOptionalPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      if (!mounted) return;
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.showBatteryOptimizationPrompt) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  void initForegroundService() {
    // ignore: invalid_use_of_visible_for_testing_member
    if (!FlutterForegroundTask.isInitialized) {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: "bg_update",
          channelName: tr("foregroundService"),
          channelDescription: tr("foregroundService"),
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(900000),
          autoRunOnBoot: true,
          autoRunOnMyPackageReplaced: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
    }
  }

  Future<ServiceRequestResult?> startForegroundService(bool restart) async {
    initForegroundService();
    if (await FlutterForegroundTask.isRunningService) {
      if (restart) {
        return FlutterForegroundTask.restartService();
      }
    } else {
      return FlutterForegroundTask.startService(
        serviceTypes: [ForegroundServiceTypes.specialUse],
        serviceId: 666,
        notificationTitle: tr("foregroundService"),
        notificationText: tr("fgServiceNotice"),
        notificationIcon: const NotificationIcon(
          metaDataName: "dev.deminearchiver.materium.service.NOTIFICATION_ICON",
        ),
        callback: startCallback,
      );
    }
    return null;
  }

  Future<ServiceRequestResult?> stopForegroundService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.stopService();
    }
    return null;
  }

  Future<void> initPlatformState() async {
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        await bgUpdateCheck(taskId, null);
        BackgroundFetch.finish(taskId);
      },
      (String taskId) async {
        LogsProvider.instance.add("BG update task timed out.");
        BackgroundFetch.finish(taskId);
      },
    );
    if (!mounted) return;
  }

  SingleChildWidget _buildTypefaceTheme(BuildContext context) =>
      TypefaceTheme.mergeWithData(data: _typography.typeface);

  List<SingleChildWidget> _buildReferenceThemes(BuildContext context) => [
    _buildTypefaceTheme(context),
  ];

  SingleChildWidget _buildColorThemes(BuildContext context) =>
      SingleChildBuilder(
        builder: (context, child) => ListenableBuilder(
          listenable: _themeListenable,
          builder: (context, child) {
            final Brightness brightness = _settings.useBlackTheme.value
                ? .dark
                : switch (_settings.themeMode.value) {
                    .system => MediaQuery.platformBrightnessOf(context),
                    .light => .light,
                    .dark => .dark,
                  };

            final highContrast = MediaQuery.highContrastOf(context);

            final sourceColor = _settings.themeColor.value;

            final contrastLevel = highContrast ? 1.0 : 0.0;

            final DynamicSchemeVariant variant = _settings.useMaterialYou.value
                // ? .tonalSpot
                ? _settings.themeVariant.value.dynamicSchemeVariant
                : _settings.themeVariant.value.dynamicSchemeVariant;

            final DynamicSchemePlatform platform = _settings.useBlackTheme.value
                ? .watch
                : .phone;

            var colorTheme = ColorThemeData.fromSeed(
              sourceColor: ColorThemeSourceColor.fromColor(sourceColor),
              brightness: brightness,
              contrastLevel: contrastLevel,
              variant: variant,
              platform: platform,
              specVersion: _specVersion,
            );

            if (_settings.useMaterialYou.value) {
              final dynamicColorScheme = DynamicColor.dynamicColorScheme(
                brightness,
              );
              colorTheme = colorTheme.maybeMerge(
                dynamicColorScheme?.toColorTheme(),
              );
            }

            final staticColors = StaticColorsData.fallback(
              brightness: brightness,
              contrastLevel: contrastLevel,
              variant: variant,
              specVersion: _specVersion,
              platform: platform,
            );

            return ColorTheme.replaceWithData(
              data: colorTheme,
              child: StaticColors(
                data: staticColors,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          child: child,
        ),
      );

  SingleChildWidget _buildSpringTheme(BuildContext context) =>
      const SpringTheme.replaceWithData(data: .defaultsExpressive());

  SingleChildWidget _buildTypescaleTheme(BuildContext context) =>
      TypescaleTheme.mergeWithData(data: _typography.typescale);

  List<SingleChildWidget> _buildSystemThemes(BuildContext context) => [
    _buildColorThemes(context),
    _buildSpringTheme(context),
    _buildTypescaleTheme(context),
  ];

  List<SingleChildWidget> _buildComponentThemes(BuildContext context) {
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );
    final colorTheme = ColorTheme.of(context);
    return [
      LoadingIndicatorTheme.mergeWithData(
        data: .from(
          containerColor: .resolveWith(
            (states) => useBlackTheme
                ? states.isContained
                      ? colorTheme.primaryDim
                      : Colors.transparent
                : null,
          ),
          activeIndicatorColor: .resolveWith(
            (states) => useBlackTheme
                ? states.isContained
                      ? colorTheme.onPrimary
                      : colorTheme.primary
                : null,
          ),
        ),
      ),
    ];
  }

  List<SingleChildWidget> _buildLegacyThemes(BuildContext context) => [
    SingleChildBuilder(
      builder: (context, child) => ListenableBuilder(
        listenable: _themeListenable,
        builder: (context, child) {
          {
            final colorTheme = ColorTheme.of(context);
            final elevationTheme = ElevationTheme.of(context);
            final shapeTheme = ShapeTheme.of(context);
            final stateTheme = StateTheme.of(context);
            final typescaleTheme = TypescaleTheme.of(context);
            final legacyTheme = LegacyThemeFactory.createTheme(
              colorTheme: colorTheme,
              elevationTheme: elevationTheme,
              shapeTheme: shapeTheme,
              stateTheme: stateTheme,
              typescaleTheme: typescaleTheme,
              scaffoldBackgroundColor: _settings.useBlackTheme.value
                  ? colorTheme.surface
                  : colorTheme.surfaceContainer,
            );
            return Theme(
              data: legacyTheme,
              child: child ?? const SizedBox.shrink(),
            );
          }
        },
        child: child,
      ),
    ),
  ];

  Widget _buildThemes(BuildContext context, Widget child) {
    final builders = <List<SingleChildWidget> Function(BuildContext context)>[
      _buildReferenceThemes,
      _buildSystemThemes,
      _buildComponentThemes,
      _buildLegacyThemes,
    ];
    return Nested(
      children: [
        for (final builder in builders)
          SingleChildBuilder(
            builder: (context, child) =>
                Nested(children: builder(context), child: child),
          ),
      ],
      child: child,
    );
  }

  Widget _buildNavigatorWrapper(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    final colorTheme = ColorTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return DefaultLocalizedTextStyle(
      style: typescaleTheme.bodyLarge.toTextStyle(color: colorTheme.onSurface),
      child: TouchGroup(child: child),
    );
  }

  Widget _buildApp(BuildContext context) => RawMaterialApp(
    debugShowCheckedModeBanner: false,

    // Localization
    title: "Materium",
    localizationsDelegates: context.localizationDelegates,
    supportedLocales: context.supportedLocales,
    locale: context.locale,

    // Navigation
    navigatorKey: globalNavigatorKey,
    builder: _buildNavigatorWrapper,
    home: Shortcuts(
      shortcuts: {LogicalKeySet(.select): const ActivateIntent()},
      child: const HomePage(),
    ),
  );

  // void onReceiveForegroundServiceData(Object data) {
  //   print("onReceiveTaskData: $data");
  // }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestNonOptionalPermissions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final legacyLocale = context.locale;
    final parsedLocale = AppLocaleUtils.parseLocaleParts(
      languageCode: legacyLocale.languageCode,
      countryCode: legacyLocale.countryCode,
      scriptCode: legacyLocale.scriptCode,
    );

    if (LocaleSettings.currentLocale != parsedLocale) {
      LocaleSettings.setLocaleSync(parsedLocale);
    }

    final oldSettings = _settingsOrNull;
    final newSettings = context.read<SettingsService>();
    if (oldSettings != newSettings) {
      _themeListenable = Listenable.merge([
        newSettings.themeMode,
        newSettings.themeVariant,
        newSettings.themeColor,
        newSettings.useMaterialYou,
        newSettings.useBlackTheme,
      ]);
    }
    _settingsOrNull = newSettings;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appsProvider = context.read<AppsProvider>();
    final logs = LogsProvider.instance;
    final notifs = context.read<NotificationsProvider>();

    final updateInterval = context.select<SettingsProvider, int>(
      (settingsProvider) => settingsProvider.updateInterval,
    );

    final useFGService = context.select<SettingsProvider, bool>(
      (settingsProvider) => settingsProvider.useFGService,
    );

    final forcedLocale = context.select<SettingsProvider, Locale?>(
      (settingsProvider) => settingsProvider.forcedLocale,
    );

    if (updateInterval != _lastUpdateInterval ||
        useFGService != _lastUseFGService) {
      _lastUpdateInterval = updateInterval;
      _lastUseFGService = useFGService;
      if (updateInterval == 0) {
        stopForegroundService();
        BackgroundFetch.stop();
      } else if (useFGService) {
        BackgroundFetch.stop();
        startForegroundService(false);
      } else {
        stopForegroundService();
        BackgroundFetch.start();
      }
    }

    if (!_firstRunHandled) {
      _firstRunHandled = true;
      final isFirstRun = context.select<SettingsProvider, bool>(
        (settingsProvider) => settingsProvider.checkAndFlipFirstRun(),
      );
      if (isFirstRun) {
        logs.add('This is the first ever run of Obtainium.');
        getInstalledInfo(obtainiumId)
            .then((value) {
              if (value?.versionName != null) {
                appsProvider.saveApps([
                  App(
                    obtainiumId,
                    obtainiumUrl,
                    'deminearchiver',
                    'Materium',
                    value!.versionName,
                    value.versionName!,
                    [],
                    0,
                    {
                      'versionDetection': true,
                      'apkFilterRegEx': 'fdroid',
                      'invertAPKFilter': true,
                    },
                    null,
                    false,
                  ),
                ], onlyIfExists: false);
              }
            })
            .catchError((err) {
              logs.add('Failed to add Obtainium on first run: $err');
            });
      }
      if (!supportedLocales.map((e) => e.key).contains(context.locale) ||
          (forcedLocale == null && context.deviceLocale != context.locale)) {
        context.read<SettingsProvider>().resetLocaleSafe(context);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifs.checkLaunchByNotif();
    });

    final appBuilder = Builder(key: GlobalObjectKey(this), builder: _buildApp);
    return WithForegroundTask(child: _buildThemes(context, appBuilder));
  }

  static const _specVersion = DynamicSchemeSpecVersion.spec2026;
  static const _typography = TypographyDefaults.material3Expressive2026;
}
