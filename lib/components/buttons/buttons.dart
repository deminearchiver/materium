import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' as flutter;
import 'package:materium/flutter.dart';

// Utilities
part 'input_padding.dart';

// Button theming
part 'button_defaults.dart';
part 'button_settings.dart';
part 'button_states.dart';
part 'button_styles.dart';

// Buttons building blocks
part 'custom_button.dart';

// Localized button components
part 'button.dart';
part 'icon_button.dart';
part 'floating_action_button.dart';

typedef ButtonStyleLegacy = flutter.ButtonStyle;

typedef IconButtonLegacy = flutter.IconButton;
typedef IconButtonThemeLegacy = flutter.IconButtonTheme;
typedef IconButtonThemeDataLegacy = flutter.IconButtonThemeData;

typedef FloatingActionButtonLegacy = flutter.FloatingActionButton;
typedef FloatingActionButtonThemeLegacy = flutter.FloatingActionButtonTheme;
typedef FloatingActionButtonThemeDataLegacy =
    flutter.FloatingActionButtonThemeData;
