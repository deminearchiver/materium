import 'dart:async';

import 'package:materium/flutter.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  SettingsService._({required SharedPreferencesAsync sharedPreferencesAsync})
    : _prefs = sharedPreferencesAsync {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  final SharedPreferencesAsync _prefs;

  late final _useShizuku = ExternalSettingNotifier<bool>(
    defaultValue: false,
    onLoad: () async => Option.maybe(await _prefs.getBool(_useShizukuKey)),
    onSave: (value) => switch (value) {
      Some(:final value) => _prefs.setBool(_useShizukuKey, value),
      None() => _prefs.remove(_useShizukuKey),
    },
  )..addListener(_maybeNotify);

  SettingNotifier<bool> get useShizuku => _useShizuku;

  late final _theme = ExternalSettingNotifier<ThemeMode>(
    defaultValue: .system,
    onLoad: () async {
      final value = await _prefs.getString(_themeKey);
      final ThemeMode? result = switch (value?.toLowerCase()) {
        "system" => .system,
        "light" => .light,
        "dark" => .dark,
        _ => null,
      };
      return Option.maybe(result);
    },
    onSave: (value) => switch (value) {
      Some(:final value) => _prefs.setString(_themeKey, value.name),
      None() => _prefs.remove(_themeKey),
    },
  )..addListener(_maybeNotify);

  SettingNotifier<ThemeMode> get theme => _theme;

  late final _themeColor = ExternalSettingNotifier<Color>(
    defaultValue: obtainiumThemeColor,
    onLoad: () async => switch (await _prefs.getInt(_themeColorKey)) {
      final value? => Some(Color(value)),
      _ => const None(),
    },
    onSave: (value) => switch (value) {
      Some(:final value) => _prefs.setInt(_themeColorKey, value.toARGB32()),
      None() => _prefs.remove(_themeColorKey),
    },
  )..addListener(_maybeNotify);

  SettingNotifier<Color> get themeColor => _themeColor;

  bool _isNotifyingAllListeners = false;

  void _maybeNotify() {
    if (!_isNotifyingAllListeners) {
      notifyListeners();
    }
  }

  void _notifyAllListeners() {
    // Stop notifying global listeners
    _isNotifyingAllListeners = true;

    // Notify local listeners
    _useShizuku.notify();
    _theme.notify();
    _themeColor.notify();

    // Resume notifying global listeners
    _isNotifyingAllListeners = false;

    // Notify global listeners
    notifyListeners();
  }

  Future<void> loadOnly({
    bool useShizuku = false,
    bool theme = false,
    bool themeColor = false,
  }) async {
    final futures = <Future<bool>>[
      if (useShizuku) _useShizuku.load(notify: false),
      if (theme) _theme.load(notify: false),
      if (themeColor) _themeColor.load(notify: false),
    ];
    if (futures.isNotEmpty) {
      final result = await Future.wait(futures);
      if (result.contains(true)) {
        _notifyAllListeners();
      }
    }
  }

  Future<void> loadAll() =>
      loadOnly(useShizuku: true, theme: true, themeColor: true);

  Future<void> saveOnly({
    bool useShizuku = false,
    bool theme = false,
    bool themeColor = false,
  }) async {
    final futures = <Future<void>>[
      if (useShizuku) _useShizuku.save(),
      if (theme) _theme.save(),
      if (themeColor) _themeColor.save(),
    ];
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> saveAll() =>
      saveOnly(useShizuku: true, theme: true, themeColor: true);

  static const _useShizukuKey = "useShizuku";
  static const _themeKey = "theme";
  static const _themeColorKey = "themeColor";

  static Future<SettingsService> create() async {
    final instance = SettingsService._(
      sharedPreferencesAsync: SharedPreferencesAsync(
        options: const SharedPreferencesOptions(),
      ),
    );
    return instance;
  }
}

class SettingNotifier<T extends Object?>
    with ChangeNotifier
    implements ValueNotifier<T> {
  SettingNotifier({
    required this.defaultValue,
    Future<Option<T>> Function()? onLoad,
    Future<void> Function(Option<T> value)? onSave,
  }) : _currentValue = Some(defaultValue),
       _onLoad = onLoad,
       _onSave = onSave {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  final T defaultValue;
  final Future<Option<T>> Function()? _onLoad;
  final Future<void> Function(Option<T> value)? _onSave;

  Option<T> _currentValue;

  @override
  T get value => switch (_currentValue) {
    Some(:final value) => value,
    None() => defaultValue,
  };

  @override
  set value(T newValue) {
    setValue(newValue);
  }

  Option<T> get valueOrNone => _currentValue;

  bool get isDefault => _currentValue.isNone;

  bool get isCustom => _currentValue.isSome;

  Future<bool> setValue(
    T newValue, {
    bool notify = true,
    bool save = true,
  }) async {
    if (_currentValue case Some(value: final currentValueInner)) {
      if (currentValueInner == newValue) return false;
    }
    _currentValue = newValue == defaultValue
        ? None<T>()
        : _currentValue = Some(newValue);
    if (notify) notifyListeners();
    if (save) await this.save();
    return true;
  }

  Future<bool> setValueOrNone(
    Option<T> newValue, {
    bool notify = true,
    bool save = true,
  }) async {
    if (_currentValue == newValue) return false;
    _currentValue = switch (newValue) {
      Some(value: final newValueInner) =>
        newValueInner == defaultValue ? None<T>() : newValue,
      final None<T> _ => newValue,
    };
    if (notify) notifyListeners();
    if (save) await this.save();
    return true;
  }

  Future<bool> setDefault({bool notify = true, bool save = true}) =>
      setValueOrNone(None<T>(), notify: notify, save: save);

  Future<bool> load({bool notify = true}) async {
    final newValue = await _onLoad?.call();
    if (newValue != null && _currentValue != newValue) {
      _currentValue = switch (newValue) {
        Some(value: final newValueInner) =>
          newValueInner == defaultValue ? None<T>() : newValue,
        final None<T> _ => newValue,
      };
      if (notify) notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> save() async {
    await _onSave?.call(_currentValue);
  }

  @override
  String toString() {
    final identity = describeIdentity(this);
    final arguments = <String>[
      "value: $value",
      if (isDefault) "is default" else "default: $defaultValue",
    ].join(", ");
    return "$identity<$T>($arguments)";
  }
}

class ExternalSettingNotifier<T extends Object?> = SettingNotifier<T>
    with ExternalChangeNotifier;
