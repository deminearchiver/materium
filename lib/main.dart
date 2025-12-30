import 'dart:io';

import 'package:materium/app.dart';
import 'package:materium/flutter.dart';
import 'package:materium/database/database.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/logs_provider.dart';
import 'package:materium/providers/notifications_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// ignore: implementation_imports
import 'package:easy_localization/src/easy_localization_controller.dart';

// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';

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
    Assets.fonts.firacode.ofl,
    Assets.fonts.googlesanscode.ofl,
    Assets.fonts.googlesansflex.ofl,
    Assets.fonts.robotoflex.ofl,
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

  final settings = await SettingsService.create();
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
        ChangeNotifierProvider(create: (context) => settings),
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
