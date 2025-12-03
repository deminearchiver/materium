import 'dart:io';

import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:materium/flutter.dart';
import 'package:materium/assets/assets.gen.dart';
import 'package:materium/database/database.dart';
import 'package:materium/pages/home.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/logs_provider.dart';
import 'package:materium/providers/notifications_provider.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:materium/theme/legacy.dart';
import 'package:materium/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// ignore: implementation_imports
import 'package:easy_localization/src/easy_localization_controller.dart';

// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';

// ignore: implementation_imports
import 'package:materium_fonts/src/assets/assets.gen.dart' as materium_fonts;

List<MapEntry<Locale, String>> supportedLocales = const [
  MapEntry(Locale("en"), "English"),
  MapEntry(Locale("zh"), "简体中文"),
  MapEntry(Locale("zh", "Hant_TW"), "臺灣話"),
  MapEntry(Locale("it"), "Italiano"),
  MapEntry(Locale("ja"), "日本語"),
  MapEntry(Locale("hu"), "Magyar"),
  MapEntry(Locale("de"), "Deutsch"),
  MapEntry(Locale("fa"), "فارسی"),
  MapEntry(Locale("fr"), "Français"),
  MapEntry(Locale("es"), "Español"),
  MapEntry(Locale("pl"), "Polski"),
  MapEntry(Locale("ru"), "Русский"),
  MapEntry(Locale("bs"), "Bosanski"),
  MapEntry(Locale("pt"), "Português"),
  MapEntry(Locale("pt", "BR"), "Brasileiro"),
  MapEntry(Locale("cs"), "Česky"),
  MapEntry(Locale("sv"), "Svenska"),
  MapEntry(Locale("nl"), "Nederlands"),
  MapEntry(Locale("vi"), "Tiếng Việt"),
  MapEntry(Locale("tr"), "Türkçe"),
  MapEntry(Locale("uk"), "Українська"),
  MapEntry(Locale("da"), "Dansk"),
  MapEntry(
    Locale("en", "EO"),
    "Esperanto",
  ), // https://github.com/aissat/easy_localization/issues/220#issuecomment-846035493
  MapEntry(Locale("in"), "Bahasa Indonesia"),
  MapEntry(Locale("ko"), "한국어"),
  MapEntry(Locale("ca"), "Català"),
  MapEntry(Locale("ar"), "العربية"),
  MapEntry(Locale("ml"), "മലയാളം"),
];
const fallbackLocale = Locale("en");
final localeDir = Assets.translations.path;

final globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> loadTranslations() async {
  // See easy_localization/issues/210
  await EasyLocalizationController.initEasyLocation();
  final s = await SettingsProvider.ensureInitialized();
  final forceLocale = s.forcedLocale;
  final controller = EasyLocalizationController(
    saveLocale: true,
    forceLocale: forceLocale,
    fallbackLocale: fallbackLocale,
    supportedLocales: supportedLocales.map((e) => e.key).toList(),
    assetLoader: const RootBundleAssetLoader(),
    useOnlyLangCode: false,
    useFallbackTranslations: true,
    path: localeDir,
    onLoadError: (e) {
      throw e;
    },
  );
  await controller.loadTranslations();
  Localization.load(
    controller.locale,
    translations: controller.translations,
    fallbackTranslations: controller.fallbackTranslations,
  );
}

@pragma("vm:entry-point")
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final taskId = task.taskId;
  final isTimeout = task.timeout;
  if (isTimeout) {
    print("BG update task timed out.");
    BackgroundFetch.finish(taskId);
    return;
  }
  await bgUpdateCheck(taskId, null);
  BackgroundFetch.finish(taskId);
}

@pragma("vm:entry-point")
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  static const String incrementCountCommand = "incrementCount";

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("onStart(starter: ${starter.name})");
    bgUpdateCheck("bg_check", null);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    bgUpdateCheck("bg_check", null);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print("Foreground service onDestroy(isTimeout: $isTimeout)");
  }

  @override
  void onReceiveData(Object data) {}
}

Stream<LicenseEntry> _licenses() async* {
  final assets = <String>[
    materium_fonts.Assets.fonts.firacode.ofl,
    materium_fonts.Assets.fonts.googlesanscode.ofl,
    materium_fonts.Assets.fonts.googlesansflex.ofl,
    materium_fonts.Assets.fonts.robotoflex.ofl,
  ];
  for (final asset in assets) {
    final license = await rootBundle.loadString(asset);
    yield LicenseEntryWithLineBreaks(const <String>["google_fonts"], license);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LicenseRegistry.addLicense(_licenses);

  try {
    final data = await rootBundle.load(Assets.ca.letsEncryptR3);
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      data.buffer.asUint8List(),
    );
  } catch (e) {
    // Already added, do nothing (see #375)
  }

  await AppDatabase.ensureInitialized();

  final settingsProvider = await SettingsProvider.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await loadTranslations();

  // Make sure to always initialize LogsProvider after EasyLocalization
  // TODO: refactor after migrating to slang
  await LogsProvider.ensureInitialized();

  final np = NotificationsProvider();
  await np.initialize();

  FlutterForegroundTask.initCommunicationPort();

  if (DeviceInfo.androidInfo!.version.sdkInt >= 29) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppsProvider()),
        ChangeNotifierProvider(create: (context) => settingsProvider),
        Provider(create: (context) => np),
      ],
      child: EasyLocalization(
        supportedLocales: supportedLocales.map((e) => e.key).toList(),
        path: localeDir,
        fallbackLocale: fallbackLocale,
        useOnlyLangCode: false,
        child: const Obtainium(),
      ),
    ),
  );

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

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
    required SettingsProvider settingsProvider,
    required Brightness brightness,
    bool highContrast = false,
  }) {
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
    final settingsProvider = context.watch<SettingsProvider>();
    final Brightness brightness = switch (settingsProvider.theme) {
      .system => MediaQuery.platformBrightnessOf(context),
      .light => .light,
      .dark => .dark,
    };
    final highContrast = MediaQuery.highContrastOf(context);
    return ColorTheme(
      data: _createColorTheme(
        settingsProvider: settingsProvider,
        brightness: brightness,
        highContrast: highContrast,
      ),
      child: child,
    );
  }

  Widget _buildTypographyTheme(BuildContext context, Widget child) =>
      TypographyDefaults.googleMaterial3Expressive.build(context, child);

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
      theme: LegacyThemeFactory.create(
        colorTheme: _createColorTheme(
          settingsProvider: settingsProvider,
          brightness: .light,
          highContrast: false,
        ),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      darkTheme: LegacyThemeFactory.create(
        colorTheme: _createColorTheme(
          settingsProvider: settingsProvider,
          brightness: .dark,
          highContrast: false,
        ),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      highContrastTheme: LegacyThemeFactory.create(
        colorTheme: _createColorTheme(
          settingsProvider: settingsProvider,
          brightness: .light,
          highContrast: true,
        ),
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        typescaleTheme: typescaleTheme,
      ),
      highContrastDarkTheme: LegacyThemeFactory.create(
        colorTheme: _createColorTheme(
          settingsProvider: settingsProvider,
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
