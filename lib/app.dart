import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:materium/components/custom_app.dart';
import 'package:materium/flutter.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/home.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/logs_provider.dart';
import 'package:materium/providers/notifications_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:materium/theme/legacy.dart';
import 'package:materium/theme/theme.dart';
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

  Future<void> requestNonOptionalPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
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

  Widget _buildTypefaceTheme(BuildContext context, Widget child) =>
      TypefaceTheme.merge(data: _typography.typeface, child: child);

  Widget _buildReferenceThemes(BuildContext context, Widget child) =>
      CombiningBuilder(
        useOuterContext: true,
        builders: [_buildTypefaceTheme],
        child: child,
      );

  Widget _buildColorThemes(BuildContext context, Widget child) =>
      ListenableBuilder(
        listenable: _themeListenable,
        builder: (context, child) {
          final Brightness brightness = switch (_settings.themeMode.value) {
            .system => MediaQuery.platformBrightnessOf(context),
            .light => .light,
            .dark => .dark,
          };
          final highContrast = MediaQuery.highContrastOf(context);

          final sourceColor = _settings.themeColor.value;

          final contrastLevel = highContrast ? 1.0 : 0.0;

          final DynamicSchemeVariant variant = _settings.useMaterialYou.value
              ? .tonalSpot
              : .vibrant;

          var colorTheme = ColorThemeData.fromSeed(
            sourceColor: sourceColor,
            brightness: brightness,
            contrastLevel: contrastLevel,
            variant: variant,
            platform: _platform,
            specVersion: _specVersion,
          );

          if (_settings.useMaterialYou.value) {
            final dynamicColorScheme = DynamicColor.dynamicColorScheme(
              brightness,
            );
            colorTheme = colorTheme.merge(dynamicColorScheme?.toColorTheme());
          }

          final staticColors = StaticColorsData.fallback(
            brightness: brightness,
            contrastLevel: contrastLevel,
            variant: variant,
            specVersion: _specVersion,
            platform: _platform,
          );

          return ColorTheme(
            data: colorTheme,
            child: StaticColors(data: staticColors, child: child!),
          );
        },
        child: child,
      );

  Widget _buildSpringTheme(BuildContext context, Widget child) =>
      SpringTheme(data: const .expressive(), child: child);

  Widget _buildTypescaleTheme(BuildContext context, Widget child) =>
      TypescaleTheme.merge(data: _typography.typescale, child: child);

  Widget _buildSystemThemes(BuildContext context, Widget child) =>
      CombiningBuilder(
        useOuterContext: true,
        builders: [_buildColorThemes, _buildSpringTheme, _buildTypescaleTheme],
        child: child,
      );

  Widget _buildLegacyThemes(BuildContext context, Widget child) {
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
      scaffoldBackgroundColor: colorTheme.surfaceContainer,
    );

    return Theme(data: legacyTheme, child: child);
  }

  Widget _buildThemes(BuildContext context, Widget child) => CombiningBuilder(
    builders: [_buildReferenceThemes, _buildSystemThemes, _buildLegacyThemes],
    child: child,
  );

  Widget _buildNavigatorWrapper(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();

    final materialLocalization = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    final colorTheme = ColorTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final category = materialLocalization?.scriptCategory ?? .englishLike;
    final localizedTextStyle = _DefaultTextStyles.geometryStyleFor(category);
    final defaultTextStyle = typescaleTheme.bodyLarge
        .toTextStyle(color: colorTheme.onSurface)
        .merge(localizedTextStyle);
    return DefaultTextStyle.merge(style: defaultTextStyle, child: child);
  }

  Widget _buildApp(BuildContext context) {
    return RawMaterialApp(
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
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: const HomePage(),
      ),
    );
  }

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
    final oldSettings = _settingsOrNull;
    final newSettings = context.read<SettingsService>();
    if (oldSettings != newSettings) {
      _themeListenable = Listenable.merge([
        newSettings.themeMode,
        newSettings.themeVariant,
        newSettings.themeColor,
        newSettings.useMaterialYou,
      ]);
    }
    _settingsOrNull = newSettings;
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    // FlutterForegroundTask.removeTaskDataCallback(onReceiveForegroundServiceData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final appsProvider = context.read<AppsProvider>();
    final logs = LogsProvider.instance;
    final notifs = context.read<NotificationsProvider>();
    if (settingsProvider.updateInterval == 0) {
      stopForegroundService();
      BackgroundFetch.stop();
    } else {
      if (settingsProvider.useFGService) {
        BackgroundFetch.stop();
        startForegroundService(false);
      } else {
        stopForegroundService();
        BackgroundFetch.start();
      }
    }
    final isFirstRun = settingsProvider.checkAndFlipFirstRun();
    if (isFirstRun) {
      logs.add("This is the first ever run of Materium.");

      // If this is the first run, add Materium to the Apps list
      getInstalledInfo(obtainiumId).then((value) {
        if (value?.versionName != null) {
          appsProvider.saveApps([
            App(
              obtainiumId,
              obtainiumUrl,
              "deminearchiver",
              "materium",
              value!.versionName,
              value.versionName!,
              [],
              0,
              {
                "versionDetection": true,
                "apkFilterRegEx": "fdroid",
                "invertAPKFilter": true,
              },
              null,
              false,
            ),
          ], onlyIfExists: false);
        }
      });

      if (!supportedLocales.map((e) => e.key).contains(context.locale) ||
          (settingsProvider.forcedLocale == null &&
              context.deviceLocale != context.locale)) {
        settingsProvider.resetLocaleSafe(context);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifs.checkLaunchByNotif();
    });

    final appBuilder = Builder(builder: _buildApp);

    return WithForegroundTask(child: _buildThemes(context, appBuilder));
  }

  static const _platform = DynamicSchemePlatform.phone;
  static const _specVersion = DynamicSchemeSpecVersion.spec2025;
  static const _typography = TypographyDefaults.material3Expressive2026;
}

abstract final class _DefaultTextStyles {
  static const englishLike = TextStyle(
    debugLabel: "englishLike default 2021",
    inherit: true,
    decoration: .none,
    textBaseline: .alphabetic,
    leadingDistribution: .even,
  );

  static const dense = TextStyle(
    debugLabel: "dense default 2021",
    inherit: true,
    decoration: .none,
    textBaseline: .ideographic,
    leadingDistribution: .even,
  );

  static const tall = TextStyle(
    debugLabel: "tall default 2021",
    inherit: true,
    decoration: .none,
    textBaseline: .alphabetic,
    leadingDistribution: .even,
  );

  static TextStyle geometryStyleFor(ScriptCategory category) =>
      switch (category) {
        .englishLike => englishLike,
        .dense => dense,
        .tall => tall,
      };
}
