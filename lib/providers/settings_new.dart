import 'dart:async';

import 'package:materium/flutter.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeVariant {
  system(null),
  calm(.neutral),
  pastel(.tonalSpot),
  juicy(.vibrant),
  creative(.expressive);

  const ThemeVariant(this.dynamicSchemeVariantOrNull);

  final DynamicSchemeVariant? dynamicSchemeVariantOrNull;

  // TODO(deminearchiver): remove hardcoded value when dynamic color is finished
  DynamicSchemeVariant get dynamicSchemeVariant =>
      dynamicSchemeVariantOrNull ?? .tonalSpot;

  static ThemeVariant? fromDynamicSchemeVariant(DynamicSchemeVariant value) =>
      switch (value) {
        .neutral => .calm,
        .tonalSpot => .pastel,
        .vibrant => .juicy,
        .expressive => .creative,
        _ => null,
      };
}

enum ThemeContrast {
  system(null),
  low(-1.0),
  normal(0.0),
  medium(0.5),
  high(1.0);

  const ThemeContrast(this.contrastLevel);

  final double? contrastLevel;

  static ThemeContrast fromContrastLevel(double value) => switch (value) {
    < -0.5 => .low,
    < 0.25 => .normal,
    < 0.75 => .medium,
    _ => .high,
  };
}

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

  late final _themeMode = ExternalSettingNotifier<ThemeMode>(
    defaultValue: .system,
    onLoad: () async {
      Object? value;
      try {
        value = (await _prefs.getString(_themeModeKey))?.toLowerCase();
      } on TypeError {
        value = await _prefs.getInt(_themeModeKey);
      }
      final ThemeMode? result = switch (value) {
        "system" || 0 => .system,
        "light" || 1 => .light,
        "dark" || 2 => .dark,
        _ => null,
      };
      return Option.maybe(result);
    },
    onSave: (value) => switch (value) {
      Some(:final value) => _prefs.setString(_themeModeKey, value.name),
      None() => _prefs.remove(_themeModeKey),
    },
  )..addListener(_maybeNotify);

  SettingNotifier<ThemeMode> get themeMode => _themeMode;

  late final _themeVariant = ExternalSettingNotifier<ThemeVariant>(
    defaultValue: .pastel,
    onLoad: () async {
      final value = await _prefs.getString(_themeVariantKey);
      final ThemeVariant? result = switch (value?.toLowerCase()) {
        "system" => .system,
        "calm" => .calm,
        "pastel" => .pastel,
        "juicy" => .juicy,
        "creative" => .creative,
        _ => null,
      };
      return Option.maybe(result);
    },
    onSave: (value) => switch (value) {
      Some(:final value) => _prefs.setString(_themeVariantKey, value.name),
      _ => _prefs.remove(_themeVariantKey),
    },
  )..addListener(_maybeNotify);

  SettingNotifier<ThemeVariant> get themeVariant => _themeVariant;

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

  late final _useMaterialYou = ExternalSettingNotifier<bool>(
    defaultValue: true,
    onLoad: () async => Option.maybe(await _prefs.getBool(_useMaterialYouKey)),
    onSave: (value) => switch (value) {
      Some(:final value) => _prefs.setBool(_useMaterialYouKey, value),
      None() => _prefs.remove(_useMaterialYouKey),
    },
  )..addListener(_maybeNotify);

  SettingNotifier<bool> get useMaterialYou => _useMaterialYou;

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
    _themeMode.notify();
    _themeVariant.notify();
    _themeColor.notify();
    _useMaterialYou.notify();

    // Resume notifying global listeners
    _isNotifyingAllListeners = false;

    // Notify global listeners
    notifyListeners();
  }

  Future<void> loadOnly({
    bool useShizuku = false,
    bool themeMode = false,
    bool themeVariant = false,
    bool themeColor = false,
    bool useMaterialYou = false,
  }) async {
    final futures = <Future<bool>>[
      if (useShizuku) _useShizuku.load(notify: false),
      if (themeMode) _themeMode.load(notify: false),
      if (themeVariant) _themeVariant.load(notify: false),
      if (themeColor) _themeColor.load(notify: false),
      if (useMaterialYou) _useMaterialYou.load(notify: false),
    ];
    if (futures.isNotEmpty) {
      final result = await Future.wait(futures);
      if (result.contains(true)) {
        _notifyAllListeners();
      }
    }
  }

  Future<void> loadAll() => loadOnly(
    useShizuku: true,
    themeMode: true,
    themeVariant: true,
    themeColor: true,
    useMaterialYou: true,
  );

  Future<void> saveOnly({
    bool useShizuku = false,
    bool themeMode = false,
    bool themeVariant = false,
    bool themeColor = false,
    bool useMaterialYou = false,
  }) async {
    final futures = <Future<void>>[
      if (useShizuku) _useShizuku.save(),
      if (themeMode) _themeMode.save(),
      if (themeVariant) _themeVariant.save(),
      if (themeColor) _themeColor.save(),
      if (useMaterialYou) _useMaterialYou.save(),
    ];
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> saveAll() => saveOnly(
    useShizuku: true,
    themeMode: true,
    themeVariant: true,
    themeColor: true,
    useMaterialYou: true,
  );

  static const _useShizukuKey = "useShizuku";
  static const _themeModeKey = "theme";
  static const _themeVariantKey = "themeVariant";
  static const _themeColorKey = "themeColor";
  static const _useMaterialYouKey = "useMaterialYou";

  static Future<SettingsService> create() async {
    final instance = SettingsService._(
      sharedPreferencesAsync: SharedPreferencesAsync(
        options: const SharedPreferencesOptions(),
      ),
    );
    await instance.loadAll();
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
