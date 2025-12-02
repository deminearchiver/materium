import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dynamic_color_platform_interface.dart';

import 'src/json.dart';

export 'src/json.dart';

@immutable
class DynamicColor {
  const DynamicColor();

  static DynamicColorPlatform get _platform => DynamicColorPlatform.instance;

  Future<bool> isDynamicColorAvailable() async {
    final result = await _platform.isDynamicColorAvailable();
    return result ?? false;
  }

  Future<Color?> accentColor() {
    return _platform.accentColor();
  }

  Future<DynamicTonalPalette?> dynamicTonalPalette() {
    return _platform.dynamicTonalPalette();
  }

  Future<DynamicColorScheme?> dynamicLightColorScheme() {
    return _platform.dynamicLightColorScheme();
  }

  Future<DynamicColorScheme?> dynamicDarkColorScheme() {
    return _platform.dynamicDarkColorScheme();
  }

  Future<DynamicColorSchemes?> dynamicColorSchemes() {
    return _platform.dynamicColorSchemes();
  }
}

@immutable
sealed class DynamicColorSource with Diagnosticable {
  const DynamicColorSource();

  static Future<DynamicColorSource> fromPlatform(
    DynamicColorPlatform platform,
  ) async {
    if (await platform.dynamicColorSchemes() case final dynamicColorSchemes?) {
      return DynamicColorSchemesSource(
        dynamicLightColorScheme: dynamicColorSchemes.light,
        dynamicDarkColorScheme: dynamicColorSchemes.dark,
      );
    }
    final (dynamicLightColorScheme, dynamicDarkColorScheme) = await (
      platform.dynamicLightColorScheme(),
      platform.dynamicDarkColorScheme(),
    ).wait;
    if (dynamicLightColorScheme != null && dynamicDarkColorScheme != null) {
      return DynamicColorSchemesSource(
        dynamicLightColorScheme: dynamicLightColorScheme,
        dynamicDarkColorScheme: dynamicDarkColorScheme,
      );
    }
    if (dynamicLightColorScheme != null) {
      return DynamicColorSchemeSource(
        brightness: Brightness.light,
        dynamicColorScheme: dynamicLightColorScheme,
      );
    }
    if (dynamicDarkColorScheme != null) {
      return DynamicColorSchemeSource(
        brightness: Brightness.dark,
        dynamicColorScheme: dynamicDarkColorScheme,
      );
    }
    // TODO: find a use for DynamicTonalPaletteSource
    if (await platform.accentColor() case final accentColor?) {
      return AccentColorSource(accentColor: accentColor);
    }
    return const EmptySource();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType && other is DynamicColorSource;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

@immutable
class EmptySource extends DynamicColorSource {
  const EmptySource();
}

@immutable
class AccentColorSource extends DynamicColorSource {
  const AccentColorSource({required this.accentColor});

  final Color accentColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty("accentColor", accentColor));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is AccentColorSource &&
            accentColor == other.accentColor;
  }

  @override
  int get hashCode => Object.hash(runtimeType, accentColor);
}

@immutable
class DynamicTonalPaletteSource extends DynamicColorSource {
  const DynamicTonalPaletteSource({required this.dynamicTonalPalette});

  final DynamicTonalPalette dynamicTonalPalette;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<DynamicTonalPalette>(
        "dynamicTonalPalette",
        dynamicTonalPalette,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is DynamicTonalPaletteSource &&
            dynamicTonalPalette == other.dynamicTonalPalette;
  }

  @override
  int get hashCode => Object.hash(runtimeType, dynamicTonalPalette);
}

@immutable
class DynamicColorSchemeSource extends DynamicColorSource {
  const DynamicColorSchemeSource({
    required this.brightness,
    required this.dynamicColorScheme,
  });

  final Brightness brightness;
  final DynamicColorScheme dynamicColorScheme;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Brightness>("brightness", brightness))
      ..add(
        DiagnosticsProperty<DynamicColorScheme>(
          "dynamicColorScheme",
          dynamicColorScheme,
        ),
      );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is DynamicColorSchemeSource &&
            brightness == other.brightness &&
            dynamicColorScheme == other.dynamicColorScheme;
  }

  @override
  int get hashCode => Object.hash(runtimeType, brightness, dynamicColorScheme);
}

@immutable
class DynamicColorSchemesSource extends DynamicColorSource {
  const DynamicColorSchemesSource({
    required this.dynamicLightColorScheme,
    required this.dynamicDarkColorScheme,
  });

  final DynamicColorScheme dynamicLightColorScheme;
  final DynamicColorScheme dynamicDarkColorScheme;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<DynamicColorScheme>(
          "dynamicLightColorScheme",
          dynamicLightColorScheme,
        ),
      )
      ..add(
        DiagnosticsProperty<DynamicColorScheme>(
          "dynamicDarkColorScheme",
          dynamicDarkColorScheme,
        ),
      );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is DynamicColorSchemesSource &&
            dynamicLightColorScheme == other.dynamicLightColorScheme &&
            dynamicDarkColorScheme == other.dynamicDarkColorScheme;
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, dynamicLightColorScheme, dynamicDarkColorScheme);
}

typedef DynamicColorWidgetBuilder =
    Widget Function(BuildContext context, DynamicColorSource? source);

class DynamicColorBuilder extends StatefulWidget {
  const DynamicColorBuilder({super.key, required this.builder});

  final DynamicColorWidgetBuilder builder;

  @override
  State<DynamicColorBuilder> createState() => _DynamicColorBuilderState();

  static DynamicColorSource? _initialData;

  static Future<DynamicColorSource> preload() async {
    final data = await DynamicColorSource.fromPlatform(
      DynamicColorPlatform.instance,
    );
    _initialData = data;
    return data;
  }
}

class _DynamicColorBuilderState extends State<DynamicColorBuilder>
    with WidgetsBindingObserver {
  Future<DynamicColorSource>? _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _refresh(true);
      default:
        break;
    }
  }

  @override
  void dispose() {
    _future = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refresh(bool rebuild) async {
    final future = DynamicColorSource.fromPlatform(
      DynamicColorPlatform.instance,
    );
    if (rebuild) {
      setState(() {
        _future = future;
      });
    } else {
      _future = future;
    }
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DynamicColorSource?>(
      initialData: DynamicColorBuilder._initialData,
      future: _future,
      builder: (context, snapshot) {
        return widget.builder(context, snapshot.data);
      },
    );
  }
}
