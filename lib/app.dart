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
import 'package:materium/theme/legacy.dart';
import 'package:materium/theme/theme.dart';
import 'package:provider/provider.dart';

class Obtainium extends StatefulWidget {
  const Obtainium({super.key});

  @override
  State<Obtainium> createState() => _ObtainiumState();
}

class _ObtainiumState extends State<Obtainium> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestNonOptionalPermissions();
    });
  }

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

  // void onReceiveForegroundServiceData(Object data) {
  //   print("onReceiveTaskData: $data");
  // }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    // FlutterForegroundTask.removeTaskDataCallback(onReceiveForegroundServiceData);
    super.dispose();
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

  ColorThemeData _createColorTheme({
    required BuildContext context,
    required Brightness brightness,
    bool highContrast = false,
  }) {
    final settingsProvider = context.watch<SettingsProvider>();
    const variant = DynamicSchemeVariant.vibrant;
    const platform = DynamicSchemePlatform.phone;
    const specVersion = DynamicSchemeSpecVersion.spec2025;
    final contrastLevel = highContrast ? 1.0 : 0.0;
    if (settingsProvider.useMaterialYou) {
      final provided = DynamicColor.dynamicColorScheme(
        brightness,
      )?.toColorTheme();

      final sourceColor = const Color(0xFF6750A4);
      final fallback = ColorThemeData.fromSeed(
        sourceColor: sourceColor,
        brightness: brightness,
        contrastLevel: contrastLevel,
        variant: variant,
        platform: platform,
        specVersion: specVersion,
      );

      return fallback.merge(provided);

      // final sourceColor = switch (widget.dynamicColorSource) {
      //   AccentColorSource(:final accentColor) => accentColor,
      //   _ => const Color(0xFF6750A4),
      // };
      // final fallback = ColorThemeData.fromSeed(
      //   sourceColor: sourceColor,
      //   brightness: brightness,
      //   contrastLevel: contrastLevel,
      //   variant: variant,
      //   platform: platform,
      //   specVersion: specVersion,
      // );
      // final provided = switch (widget.dynamicColorSource) {
      //   DynamicColorSchemesSource(
      //     :final dynamicLightColorScheme,
      //     :final dynamicDarkColorScheme,
      //   ) =>
      //     switch (brightness) {
      //       .light => dynamicLightColorScheme.toColorTheme(),
      //       .dark => dynamicDarkColorScheme.toColorTheme(),
      //     },
      //   DynamicColorSchemeSource(
      //     brightness: final availableBrightness,
      //     :final dynamicColorScheme,
      //   ) =>
      //     availableBrightness == brightness
      //         ? dynamicColorScheme.toColorTheme()
      //         : null,
      //   _ => null,
      // };
      // return fallback.merge(provided);
    } else {
      return ColorThemeData.fromSeed(
        sourceColor: settingsProvider.themeColor,
        brightness: brightness,
        contrastLevel: contrastLevel,
        variant: variant,
        platform: platform,
        specVersion: specVersion,
      );
    }
  }

  Widget _buildColorTheme(BuildContext context, Widget child) {
    final themeMode = context.select<SettingsService, ThemeMode>(
      (settings) => settings.theme.value,
    );
    final Brightness brightness = switch (themeMode) {
      .system => MediaQuery.platformBrightnessOf(context),
      .light => .light,
      .dark => .dark,
    };
    final highContrast = MediaQuery.highContrastOf(context);
    return ColorTheme(
      data: _createColorTheme(
        context: context,
        brightness: brightness,
        highContrast: highContrast,
      ),
      child: child,
    );
  }

  Widget _buildTypographyTheme(BuildContext context, Widget child) =>
      TypographyDefaults.material3Expressive2026.build(context, child);

  Widget _buildSpringTheme(BuildContext context, Widget child) =>
      SpringTheme(data: const SpringThemeData.expressive(), child: child);

  Widget _buildAppWrapper({
    Widget? child,
    required Widget Function(BuildContext context, Widget? child) builder,
  }) => CombiningBuilder(
    builders: [_buildColorTheme, _buildTypographyTheme, _buildSpringTheme],
    child: Builder(builder: (context) => builder(context, child)),
  );

  Widget _buildHomeWrapper(BuildContext context, Widget? child) =>
      child ?? const SizedBox.shrink();

  Widget _buildMaterialApp(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Localization
      title: "Materium",
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Theming
      themeMode: switch (settingsProvider.theme) {
        .system => .system,
        .light => .light,
        .dark => .dark,
      },
      theme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(
          context: context,
          brightness: .light,
          highContrast: false,
        ),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      darkTheme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(
          context: context,
          brightness: .dark,
          highContrast: false,
        ),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      highContrastTheme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(
          context: context,
          brightness: .light,
          highContrast: true,
        ),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      highContrastDarkTheme: LegacyThemeFactory.createTheme(
        colorTheme: _createColorTheme(
          context: context,
          brightness: .dark,
          highContrast: true,
        ),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),

      // Navigation
      navigatorKey: globalNavigatorKey,
      builder: _buildHomeWrapper,
      home: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: const HomePage(),
      ),
    );
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

    return WithForegroundTask(
      child: _buildAppWrapper(
        builder: (context, child) => _buildMaterialApp(context),
      ),
    );
  }
}
