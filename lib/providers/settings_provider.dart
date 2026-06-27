// Exposes functions used to save/load app settings

import 'dart:convert';

import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:materium/main.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:shared_storage/shared_storage.dart' as saf;

const obtainiumTempId = "deminearchiver_materium_github.com";
const obtainiumId = "dev.deminearchiver.materium";
const obtainiumUrl = "https://github.com/deminearchiver/materium";
const obtainiumThemeColor = Color(0xFF6438B5);

const _migration1CompletedKey = "migration1Completed";

Locale? tryParseLocale(String? localeString) {
  if (localeString == null) return null;
  final split = localeString.split("-");
  if (split.length == 3) {
    return Locale.fromSubtags(languageCode: split[0], countryCode: split[2]);
  }
  if (split.length == 2) {
    return Locale(split[0], split[1]);
  }
  if (split.isNotEmpty) {
    return Locale(split[0]);
  }
  return null;
}

enum ThemeSettings { system, light, dark }

enum SortColumnSettings { added, nameAuthor, authorName, releaseDate }

enum SortOrderSettings { ascending, descending }

class SettingsProvider with ChangeNotifier {
  SettingsProvider._({required this._prefsWithCache});

  Future<void> _reload({required bool reloadCache}) async {
    if (reloadCache) {
      await _prefsWithCache.reloadCache();
    }

    _defaultAppDir = (await getAppStorageDir()).path;

    final info = DeviceInfo.androidInfo!;
    _isTv =
        info.systemFeatures.contains("android.hardware.type.television") ||
        info.systemFeatures.contains("android.software.leanback");

    notifyListeners();
  }

  Future<void> reload() async {
    await _reload(reloadCache: true);
  }

  final SharedPreferencesWithCache _prefsWithCache;
  SharedPreferencesWithCache get prefsWithCache => _prefsWithCache;

  String _defaultAppDir = "";
  String get defaultAppDir => _defaultAppDir;

  bool _justStarted = true;

  bool _isTv = false;
  bool get isTv => _isTv;

  static const String sourceUrl = 'https://github.com/deminearchiver/materium';

  bool get useShizuku {
    return prefsWithCache.getBool('useShizuku') ?? false;
  }

  set useShizuku(bool useShizuku) {
    prefsWithCache.setBool('useShizuku', useShizuku);
    notifyListeners();
  }

  int get updateInterval {
    return prefsWithCache.getInt('updateInterval') ?? 360;
  }

  set updateInterval(int min) {
    prefsWithCache.setInt('updateInterval', min);
    notifyListeners();
  }

  double get updateIntervalSliderVal {
    return prefsWithCache.getDouble('updateIntervalSliderVal') ?? 6.0;
  }

  set updateIntervalSliderVal(double val) {
    prefsWithCache.setDouble('updateIntervalSliderVal', val);
    notifyListeners();
  }

  bool get checkOnStart {
    return prefsWithCache.getBool('checkOnStart') ?? false;
  }

  set checkOnStart(bool checkOnStart) {
    prefsWithCache.setBool('checkOnStart', checkOnStart);
    notifyListeners();
  }

  SortColumnSettings get sortColumn {
    return SortColumnSettings.values[prefsWithCache.getInt('sortColumn') ??
        SortColumnSettings.nameAuthor.index];
  }

  set sortColumn(SortColumnSettings s) {
    prefsWithCache.setInt('sortColumn', s.index);
    notifyListeners();
  }

  SortOrderSettings get sortOrder {
    return SortOrderSettings.values[prefsWithCache.getInt('sortOrder') ??
        SortOrderSettings.ascending.index];
  }

  set sortOrder(SortOrderSettings s) {
    prefsWithCache.setInt('sortOrder', s.index);
    notifyListeners();
  }

  bool checkAndFlipFirstRun() {
    bool result = prefsWithCache.getBool('firstRun') ?? true;
    if (result) {
      prefsWithCache.setBool('firstRun', false);
    }
    return result;
  }

  bool get welcomeShown {
    return prefsWithCache.getBool('welcomeShown') ?? false;
  }

  set welcomeShown(bool welcomeShown) {
    prefsWithCache.setBool('welcomeShown', welcomeShown);
    notifyListeners();
  }

  bool get googleVerificationWarningShown {
    return _prefsWithCache.getBool('googleVerificationWarningShown') ?? false;
  }

  set googleVerificationWarningShown(bool googleVerificationWarningShown) {
    _prefsWithCache.setBool(
      'googleVerificationWarningShown',
      googleVerificationWarningShown,
    );
    notifyListeners();
  }

  bool checkJustStarted() {
    if (_justStarted) {
      _justStarted = false;
      return true;
    }
    return false;
  }

  Future<bool> getInstallPermission({bool enforce = false}) async {
    while (!(await Permission.requestInstallPackages.isGranted)) {
      // Explicit request as InstallPlugin request sometimes bugged
      Fluttertoast.showToast(
        msg: tr('pleaseAllowInstallPerm'),
        toastLength: Toast.LENGTH_LONG,
      );
      if ((await Permission.requestInstallPackages.request()) ==
          PermissionStatus.granted) {
        return true;
      }
      if (!enforce) {
        return false;
      }
    }
    return true;
  }

  bool get showAppWebpage {
    return prefsWithCache.getBool('showAppWebpage') ?? false;
  }

  set showAppWebpage(bool show) {
    prefsWithCache.setBool('showAppWebpage', show);
    notifyListeners();
  }

  bool get pinUpdates {
    return prefsWithCache.getBool('pinUpdates') ?? true;
  }

  set pinUpdates(bool show) {
    prefsWithCache.setBool('pinUpdates', show);
    notifyListeners();
  }

  bool get buryNonInstalled {
    return prefsWithCache.getBool('buryNonInstalled') ?? false;
  }

  set buryNonInstalled(bool show) {
    prefsWithCache.setBool('buryNonInstalled', show);
    notifyListeners();
  }

  bool get groupByCategory {
    return prefsWithCache.getBool('groupByCategory') ?? false;
  }

  set groupByCategory(bool show) {
    prefsWithCache.setBool('groupByCategory', show);
    notifyListeners();
  }

  bool get hideTrackOnlyWarning {
    return prefsWithCache.getBool('hideTrackOnlyWarning') ?? false;
  }

  set hideTrackOnlyWarning(bool show) {
    prefsWithCache.setBool('hideTrackOnlyWarning', show);
    notifyListeners();
  }

  bool get hideAPKOriginWarning {
    return prefsWithCache.getBool('hideAPKOriginWarning') ?? false;
  }

  set hideAPKOriginWarning(bool show) {
    prefsWithCache.setBool('hideAPKOriginWarning', show);
    notifyListeners();
  }

  String? getSettingString(String settingId) {
    String? str = prefsWithCache.getString(settingId);
    return str?.isNotEmpty == true ? str : null;
  }

  void setSettingString(String settingId, String value) {
    prefsWithCache.setString(settingId, value);
    notifyListeners();
  }

  bool? getSettingBool(String settingId) {
    return prefsWithCache.getBool(settingId) ?? false;
  }

  void setSettingBool(String settingId, bool value) {
    prefsWithCache.setBool(settingId, value);
    notifyListeners();
  }

  Map<String, int> get categories => Map<String, int>.from(
    jsonDecode(prefsWithCache.getString('categories') ?? '{}'),
  );

  void setCategories(Map<String, int> cats, {AppsProvider? appsProvider}) {
    if (appsProvider != null) {
      final changedApps = appsProvider
          .getAppValues()
          .map((a) {
            if (!a.app.categories.any((c) => !cats.keys.contains(c))) {
              return null;
            }
            final app = a.app.deepCopy();
            app.categories.removeWhere((c) => !cats.keys.contains(c));
            return app;
          })
          .where((element) => element != null)
          .map((e) => e as App)
          .toList();
      if (changedApps.isNotEmpty) {
        appsProvider.saveApps(changedApps);
      }
    }
    prefsWithCache.setString('categories', jsonEncode(cats));
    notifyListeners();
  }

  Locale? get forcedLocale {
    final fl = tryParseLocale(prefsWithCache.getString('forcedLocale'));
    return supportedLocales.where((element) => element.key == fl).isNotEmpty
        ? fl
        : null;
  }

  set forcedLocale(Locale? fl) {
    if (fl == null) {
      prefsWithCache.remove('forcedLocale');
    } else if (supportedLocales
        .where((element) => element.key == fl)
        .isNotEmpty) {
      prefsWithCache.setString('forcedLocale', fl.toLanguageTag());
    }
    notifyListeners();
  }

  bool setEqual(Set<String> a, Set<String> b) =>
      a.length == b.length && a.union(b).length == a.length;

  void resetLocaleSafe(BuildContext context) {
    if (context.supportedLocales.contains(context.deviceLocale)) {
      context.resetLocale();
    } else {
      context
        ..setLocale(context.fallbackLocale!)
        ..deleteSaveLocale();
    }
  }

  bool get showAppDowngradeError {
    return prefsWithCache.getBool('showAppDowngradeError') ?? true;
  }

  set showAppDowngradeError(bool show) {
    prefsWithCache.setBool('showAppDowngradeError', show);
    notifyListeners();
  }

  bool get showBatteryOptimizationPrompt {
    return prefsWithCache.getBool('showBatteryOptimizationPrompt') ?? true;
  }

  set showBatteryOptimizationPrompt(bool show) {
    prefsWithCache.setBool('showBatteryOptimizationPrompt', show);
    notifyListeners();
  }

  bool get tactileFeedbackEnabled {
    return prefsWithCache.getBool('tactileFeedbackEnabled') ?? true;
  }

  set tactileFeedbackEnabled(bool val) {
    prefsWithCache.setBool('tactileFeedbackEnabled', val);
    notifyListeners();
  }

  void lightImpact() {
    if (tactileFeedbackEnabled) HapticFeedback.lightImpact();
  }

  void heavyImpact() {
    if (tactileFeedbackEnabled) HapticFeedback.heavyImpact();
  }

  void selectionClick() {
    if (tactileFeedbackEnabled) HapticFeedback.selectionClick();
  }

  bool get includePrereleasesByDefault {
    return prefsWithCache.getBool('includePrereleasesByDefault') ?? false;
  }

  set includePrereleasesByDefault(bool val) {
    prefsWithCache.setBool('includePrereleasesByDefault', val);
    notifyListeners();
  }

  bool get removeOnExternalUninstall {
    return prefsWithCache.getBool('removeOnExternalUninstall') ?? false;
  }

  set removeOnExternalUninstall(bool show) {
    prefsWithCache.setBool('removeOnExternalUninstall', show);
    notifyListeners();
  }

  bool get checkUpdateOnDetailPage {
    return prefsWithCache.getBool('checkUpdateOnDetailPage') ?? false;
  }

  set checkUpdateOnDetailPage(bool show) {
    prefsWithCache.setBool('checkUpdateOnDetailPage', show);
    notifyListeners();
  }

  // TODO: uncomment when transitions are reintroduced
  // bool get disablePageTransitions {
  //   return prefsWithCache.getBool('disablePageTransitions') ?? false;
  // }
  // set disablePageTransitions(bool show) {
  //   prefsWithCache.setBool('disablePageTransitions', show);
  //   notifyListeners();
  // }
  // bool get reversePageTransitions {
  //   return prefsWithCache.getBool('reversePageTransitions') ?? false;
  // }
  // set reversePageTransitions(bool show) {
  //   prefsWithCache.setBool('reversePageTransitions', show);
  //   notifyListeners();
  // }

  bool get enableBackgroundUpdates {
    return prefsWithCache.getBool('enableBackgroundUpdates') ?? true;
  }

  set enableBackgroundUpdates(bool val) {
    prefsWithCache.setBool('enableBackgroundUpdates', val);
    notifyListeners();
  }

  bool get bgUpdatesOnWiFiOnly {
    return prefsWithCache.getBool('bgUpdatesOnWiFiOnly') ?? false;
  }

  set bgUpdatesOnWiFiOnly(bool val) {
    prefsWithCache.setBool('bgUpdatesOnWiFiOnly', val);
    notifyListeners();
  }

  bool get bgUpdatesWhileChargingOnly {
    return prefsWithCache.getBool('bgUpdatesWhileChargingOnly') ?? false;
  }

  set bgUpdatesWhileChargingOnly(bool val) {
    prefsWithCache.setBool('bgUpdatesWhileChargingOnly', val);
    notifyListeners();
  }

  DateTime get lastCompletedBGCheckTime {
    int? temp = prefsWithCache.getInt('lastCompletedBGCheckTime');
    return temp != null
        ? DateTime.fromMillisecondsSinceEpoch(temp)
        : DateTime.fromMillisecondsSinceEpoch(0);
  }

  set lastCompletedBGCheckTime(DateTime val) {
    prefsWithCache.setInt(
      'lastCompletedBGCheckTime',
      val.millisecondsSinceEpoch,
    );
    notifyListeners();
  }

  Future<Uri?> getExportDir() async {
    var uriString = prefsWithCache.getString('exportDir');
    if (uriString != null) {
      Uri? uri = Uri.parse(uriString);
      if (!(await saf.canRead(uri) ?? false) ||
          !(await saf.canWrite(uri) ?? false)) {
        uri = null;
        prefsWithCache.remove('exportDir');
        notifyListeners();
      }
      return uri;
    } else {
      return null;
    }
  }

  Future<void> pickExportDir({bool remove = false}) async {
    var existingSAFPerms = (await saf.persistedUriPermissions()) ?? [];
    var currentOneWayDataSyncDir = await getExportDir();
    Uri? newOneWayDataSyncDir;
    if (!remove) {
      try {
        newOneWayDataSyncDir = await saf.openDocumentTree();
      } catch (_) {
        throw ObtainiumError(tr('noFilePickerAvailable'));
      }
    }
    if (currentOneWayDataSyncDir?.path != newOneWayDataSyncDir?.path) {
      if (newOneWayDataSyncDir == null) {
        prefsWithCache.remove('exportDir');
      } else {
        prefsWithCache.setString('exportDir', newOneWayDataSyncDir.toString());
      }
      notifyListeners();
    }
    for (var e in existingSAFPerms) {
      await saf.releasePersistableUriPermission(e.uri);
    }
  }

  bool get autoExportOnChanges {
    return prefsWithCache.getBool('autoExportOnChanges') ?? false;
  }

  set autoExportOnChanges(bool val) {
    prefsWithCache.setBool('autoExportOnChanges', val);
    notifyListeners();
  }

  bool get onlyCheckInstalledOrTrackOnlyApps {
    return prefsWithCache.getBool('onlyCheckInstalledOrTrackOnlyApps') ?? false;
  }

  set onlyCheckInstalledOrTrackOnlyApps(bool val) {
    prefsWithCache.setBool('onlyCheckInstalledOrTrackOnlyApps', val);
    notifyListeners();
  }

  int get exportSettings {
    try {
      return prefsWithCache.getInt('exportSettings') ??
          1; // 0 for no, 1 for yes but no secrets, 2 for everything
    } catch (e) {
      var val = prefsWithCache.getBool('exportSettings') == true ? 1 : 0;
      prefsWithCache.setInt('exportSettings', val);
      return val;
    }
  }

  set exportSettings(int val) {
    prefsWithCache.setInt('exportSettings', val > 2 || val < 0 ? 1 : val);
    notifyListeners();
  }

  bool get parallelDownloads {
    return prefsWithCache.getBool('parallelDownloads') ?? false;
  }

  set parallelDownloads(bool val) {
    prefsWithCache.setBool('parallelDownloads', val);
    notifyListeners();
  }

  List<String> get searchDeselected {
    return prefsWithCache.getStringList('searchDeselected') ??
        SourceProvider().sources.map((s) => s.name).toList();
  }

  set searchDeselected(List<String> list) {
    prefsWithCache.setStringList('searchDeselected', list);
    notifyListeners();
  }

  bool get beforeNewInstallsShareToAppVerifier {
    return prefsWithCache.getBool('beforeNewInstallsShareToAppVerifier') ??
        true;
  }

  set beforeNewInstallsShareToAppVerifier(bool val) {
    prefsWithCache.setBool('beforeNewInstallsShareToAppVerifier', val);
    notifyListeners();
  }

  bool get shizukuPretendToBeGooglePlay {
    return prefsWithCache.getBool('shizukuPretendToBeGooglePlay') ?? false;
  }

  set shizukuPretendToBeGooglePlay(bool val) {
    prefsWithCache.setBool('shizukuPretendToBeGooglePlay', val);
    notifyListeners();
  }

  bool get useFGService {
    return prefsWithCache.getBool('useFGService') ?? false;
  }

  set useFGService(bool val) {
    prefsWithCache.setBool('useFGService', val);
    notifyListeners();
  }

  static SettingsProvider? _instance;

  static Future<SettingsProvider> ensureInitialized() async {
    var instance = _instance;
    if (instance != null) return instance;

    // Options should be shared across all instances
    const sharedPreferencesOptions = SharedPreferencesOptions();

    // First we migrate from legacy SharedPreferences
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: await SharedPreferences.getInstance(),
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: _migration1CompletedKey,
    );

    // By setting a local variable way we utilitize Dart's null safety
    instance = SettingsProvider._(
      // create() includes a call to reloadCache already, no need to call it
      prefsWithCache: await SharedPreferencesWithCache.create(
        sharedPreferencesOptions: sharedPreferencesOptions,
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      ),
    );

    await instance._reload(reloadCache: false);

    return _instance = instance;
  }
}
