import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:materium/flutter.dart';

// Open fonts (bundled as assets or available as system fonts)
const _roboto = "Roboto";
const _firaCode = FontFamily.firaCode;
const _googleSans = FontFamily.googleSans;
const _googleSansCode = FontFamily.googleSansCode;
const _googleSansFlex = FontFamily.googleSansFlex;
const _robotoFlex = FontFamily.robotoFlex;

class TypographyDefaults with Diagnosticable {
  const TypographyDefaults.from({
    this.typeface = const .from(),
    this.typescale = const .from(),
  });

  // TODO: implement TypographyDefaults.fromPlatform
  factory TypographyDefaults.fromPlatform(TargetPlatform platform) =>
      switch (platform) {
        _ => const .from(),
      };

  final TypefaceThemeDataPartial typeface;
  final TypescaleThemeDataPartial typescale;

  TypographyDefaults copyWith({
    covariant TypefaceThemeDataPartial? typeface,
    covariant TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? TypographyDefaults.from(
          typeface: typeface ?? this.typeface,
          typescale: typescale ?? this.typescale,
        )
      : this;

  TypographyDefaults mergeWith({
    TypefaceThemeDataPartial? typeface,
    TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? TypographyDefaults.from(
          typeface: this.typeface.merge(typeface),
          typescale: this.typescale.merge(typescale),
        )
      : this;

  TypographyDefaults merge(TypographyDefaults? other) => other != null
      ? mergeWith(typeface: other.typeface, typescale: other.typescale)
      : this;

  Widget build(BuildContext context, Widget child) => TypefaceTheme.merge(
    data: typeface,
    child: TypescaleTheme.merge(data: typescale, child: child),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<TypefaceThemeDataPartial>(
          "typeface",
          typeface,
          defaultValue: const TypefaceThemeDataPartial.from(),
        ),
      )
      ..add(
        DiagnosticsProperty<TypescaleThemeDataPartial>(
          "typescale",
          typescale,
          defaultValue: const TypescaleThemeDataPartial.from(),
        ),
      );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is TypographyDefaults &&
          typeface == other.typeface &&
          typescale == other.typescale;

  @override
  int get hashCode => Object.hash(runtimeType, typeface, typescale);

  /// A Material 3 Expressive type scale which uses Roboto Flex.
  static const material3Expressive2025 = TypographyDefaults.from(
    typeface: .from(
      // Material 3 Expressive introduced variable font support
      brand: [_robotoFlex, _roboto],
      plain: [_robotoFlex, _roboto],
    ),
  );

  /// A Material 3 Expressive type scale which uses Google Sans Flex,
  /// a previously restricted but freshly opened Google brand font.
  ///
  /// It falls back to using Roboto Flex, then Roboto.
  static const material3Expressive2026 = TypographyDefaults.from(
    typeface: .from(
      // The ROND axis is currently only available for Google Sans Flex,
      // making it a no-op for most of the other possibly installed fonts.
      // This particular information was ripped from a file
      // located at the path "/product/etc/fonts_customization.xml"
      // on a Google Pixel with Android 16 QPR1 (Material 3 Expressive).
      brand: [_googleSansFlex, _googleSans, _robotoFlex, _roboto],
      plain: [_googleSansFlex, _googleSans, _robotoFlex, _roboto],
    ),
    typescale: .from(
      displayLarge: .from(rond: 0.0),
      displayMedium: .from(rond: 0.0),
      displaySmall: .from(rond: 0.0),
      headlineLarge: .from(rond: 0.0),
      headlineMedium: .from(rond: 0.0),
      headlineSmall: .from(rond: 0.0),
      titleLarge: .from(rond: 0.0),
      titleMedium: .from(rond: 0.0),
      titleSmall: .from(rond: 0.0),
      bodyLarge: .from(rond: 0.0),
      bodyMedium: .from(rond: 0.0),
      bodySmall: .from(rond: 0.0),
      labelLarge: .from(rond: 0.0),
      labelMedium: .from(rond: 0.0),
      labelSmall: .from(rond: 0.0),
      displayLargeEmphasized: .from(rond: 100.0),
      displayMediumEmphasized: .from(rond: 100.0),
      displaySmallEmphasized: .from(rond: 100.0),
      headlineLargeEmphasized: .from(rond: 100.0),
      headlineMediumEmphasized: .from(rond: 100.0),
      headlineSmallEmphasized: .from(rond: 100.0),
      titleLargeEmphasized: .from(rond: 100.0),
      titleMediumEmphasized: .from(rond: 100.0),
      titleSmallEmphasized: .from(rond: 100.0),
      bodyLargeEmphasized: .from(rond: 100.0),
      bodyMediumEmphasized: .from(rond: 100.0),
      bodySmallEmphasized: .from(rond: 100.0),
      labelLargeEmphasized: .from(rond: 100.0),
      labelMediumEmphasized: .from(rond: 100.0),
      labelSmallEmphasized: .from(rond: 100.0),
    ),
  );
}

enum CustomCheckboxColor { standard, listItemPhone, listItemWatch, black }

enum CustomRadioButtonColor { standard, listItemPhone, listItemWatch }

enum CustomSwitchSize { standard, nowInAndroid, black }

enum CustomSwitchColor {
  standard,
  listItemPhone,
  listItemWatch,
  nowInAndroid,
  black,
}

enum CustomListItemVariant { settings, licenses, logs }

abstract final class CustomThemeFactory {
  static CheckboxThemeDataPartial createCheckboxTheme({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    CustomCheckboxColor color = .standard,
  }) => switch (color) {
    .standard => const .from(),
    .listItemPhone => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      containerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      containerOutline: .resolveWith(
        (states) => .from(
          color: switch (states) {
            CheckboxEnabledStates(isSelected: true) =>
              colorTheme.secondary.withValues(alpha: 0.0),
            _ => null,
          },
        ),
      ),
      iconColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) => colorTheme.onSecondary,
          _ => null,
        },
      ),
    ),
    .listItemWatch => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      containerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxDisabledStates(isSelected: false) =>
            colorTheme.surfaceContainer.withValues(alpha: 0.0),
          CheckboxEnabledStates(isSelected: false) =>
            colorTheme.surfaceContainer,
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      containerOutline: .resolveWith(
        (states) => .from(
          color: switch (states) {
            CheckboxEnabledStates(isSelected: false) => colorTheme.outline,
            CheckboxEnabledStates(isSelected: true) =>
              colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
            _ => null,
          },
        ),
      ),
      iconColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.primaryContainer,
          _ => null,
        },
      ),
    ),
    .black => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      containerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxDisabledStates(isSelected: false) =>
            colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      containerOutline: .resolveWith(
        (states) => .from(
          color: switch (states) {
            CheckboxDisabledStates() => null,
            CheckboxStates(isSelected: false) => colorTheme.onSurface,
            CheckboxStates(isSelected: true) =>
              colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
          },
        ),
      ),
      iconColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.primaryContainer,
          _ => null,
        },
      ),
    ),
  };

  static RadioButtonThemeDataPartial createRadioButtonTheme({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    CustomRadioButtonColor color = .standard,
  }) => switch (color) {
    .listItemPhone => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      // iconBackgroundColor: .resolveWith(
      //   (states) => switch (states) {
      //     RadioButtonEnabledStates(isSelected: true) =>
      //       colorTheme.secondary,
      //     _ => null,
      //   },
      // ),
      iconOutlineColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      iconDotColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
    ),
    .listItemWatch => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      iconBackgroundColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonDisabledStates(isSelected: false) =>
            colorTheme.surfaceContainer.withValues(alpha: 0.0),
          RadioButtonDisabledStates(isSelected: true) =>
            colorTheme.primaryContainer.withValues(alpha: 0.0),
          RadioButtonEnabledStates(isSelected: false) =>
            colorTheme.surfaceContainer,
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.primaryContainer,
          _ => null,
        },
      ),
      iconOutlineColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: false) => colorTheme.outline,
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      iconDotColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: false) => colorTheme.outline,
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
    ),
    _ => const .from(),
  };

  static SwitchThemeDataPartial createSwitchTheme({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    CustomSwitchSize size = .standard,
    CustomSwitchColor color = .standard,
    bool? showUnselectedIcon,
    bool? showSelectedIcon,
  }) {
    final resolvedShowUnselectedIcon = switch ((
      size,
      color,
      showUnselectedIcon,
    )) {
      (.nowInAndroid, _, _) => false,
      (_, .black, _) => false,
      _ => showUnselectedIcon ?? true,
    };
    final resolvedShowSelectedIcon = switch ((size, color, showSelectedIcon)) {
      (.nowInAndroid, _, _) => false,
      (_, .black, _) => false,
      _ => showSelectedIcon ?? true,
    };

    // final morph = Morph(
    //   MaterialShapes.puffyDiamond.normalized(approximate: false),
    //   MaterialShapes.softBurst.normalized(approximate: false),
    // );
    // final morph = Morph(
    //   MaterialShapes.circle,
    //   MaterialShapes.arrow
    //   // ignore: invalid_use_of_internal_member
    //       .transformedWithMatrix(Matrix4.rotationZ(math.pi / 2.0))
    //       .normalized(approximate: true),
    // );

    final unselectedHandleSize = switch ((
      size,
      color,
      resolvedShowUnselectedIcon,
    )) {
      (.nowInAndroid, _, _) => 17.0,
      (_, .black, _) => 16.0,
      (_, _, true) => 24.0,
      (_, _, false) => 16.0,
    };
    final selectedHandleSize = switch ((
      size,
      color,
      resolvedShowSelectedIcon,
    )) {
      (.nowInAndroid, _, _) => 17.6,
      (_, .black, _) => 16.0,
      _ => 24.0,
    };
    final unselectedPressedHandleSize = switch ((size, color)) {
      (.nowInAndroid, _) => unselectedHandleSize,
      (_, .black) => 24.0,
      _ => 28.0,
    };
    final selectedPressedHandleSize = switch ((size, color)) {
      (.nowInAndroid, _) => selectedHandleSize,
      (_, .black) => 24.0,
      _ => 28.0,
    };

    final SwitchThemeDataPartial switchThemeSize = .from(
      trackSize: .all(switch (size) {
        .nowInAndroid => const Size(48.0, 24.0),
        _ => null,
      }),
      stateLayerSize: .all(switch (size) {
        .nowInAndroid => const .square(30.0),
        _ => null,
      }),
      handleSize: .resolveWith(
        (states) => .square(switch (states) {
          SwitchEnabledStates(isSelected: false, isPressed: true) =>
            unselectedPressedHandleSize,
          SwitchEnabledStates(isSelected: true, isPressed: true) =>
            selectedPressedHandleSize,
          SwitchStates(isSelected: false) => unselectedHandleSize,
          SwitchStates(isSelected: true) => selectedHandleSize,
        }),
      ),
    );
    final SwitchThemeDataPartial switchThemeColor = switch (color) {
      .standard => const .from(),
      .listItemPhone => .from(
        trackColor: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => colorTheme.secondary,
            _ => null,
          },
        ),
        trackOutline: .resolveWith(
          (states) => .from(
            color: switch (states) {
              SwitchDisabledStates(isSelected: true) =>
                colorTheme.secondary.withValues(alpha: 0.0),
              SwitchStates(isSelected: true) => colorTheme.secondary.withValues(
                alpha: 0.0,
              ),
              _ => null,
            },
          ),
        ),
        stateLayerColor: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => colorTheme.secondary,
            _ => null,
          },
        ),
        handleColor: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => colorTheme.onSecondary,
            _ => null,
          },
        ),
        iconTheme: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => .from(
              color: colorTheme.secondary,
            ),
            _ => null,
          },
        ),
      ),
      .listItemWatch => .from(
        trackColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates(isSelected: false) => null,
            SwitchDisabledStates(isSelected: true) => null,
            SwitchStates(isSelected: false) => colorTheme.surfaceContainer,
            SwitchStates(isSelected: true) => colorTheme.onPrimaryContainer,
          },
        ),
        trackOutline: .resolveWith(
          (states) => .from(
            color: switch (states) {
              SwitchDisabledStates(isSelected: false) => null,
              SwitchDisabledStates(isSelected: true) =>
                colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
              SwitchStates(isSelected: false) => colorTheme.outline,
              SwitchStates(isSelected: true) =>
                colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
            },
          ),
        ),
        stateLayerColor: .resolveWith(
          (states) => states.isSelected
              ? colorTheme.onPrimaryContainer
              : colorTheme.onSurface,
        ),
        // handleShape: .resolveWith(
        //   (states) => switch (states) {
        //     SwitchStates(isSelected: false) => _MorphBorder(
        //       morph: morph,
        //       progress: 0.0,
        //     ),
        //     SwitchStates(isSelected: true) => _MorphBorder(
        //       morph: morph,
        //       progress: 1.0,
        //     ),
        //   },
        // ),
        handleColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates(isSelected: false) => null,
            SwitchDisabledStates(isSelected: true) => null,
            SwitchStates(isSelected: false) => colorTheme.outline,
            SwitchStates(isSelected: true) => colorTheme.primaryContainer,
          },
        ),
        iconTheme: .resolveWith(
          (states) => .from(
            color: switch (states) {
              SwitchDisabledStates() => null,
              SwitchStates(isSelected: false) => colorTheme.surfaceContainer,
              SwitchStates(isSelected: true) => colorTheme.onPrimaryContainer,
            },
          ),
        ),
      ),
      .nowInAndroid => .from(
        trackColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates(isSelected: false) =>
              colorTheme.onSurfaceVariant.withValues(alpha: 0.38),
            SwitchDisabledStates(isSelected: true) =>
              colorTheme.onSurface.withValues(alpha: 0.38),
            SwitchStates(isSelected: false) => colorTheme.onSurfaceVariant,
            SwitchStates(isSelected: true) => colorTheme.onPrimaryContainer,
          },
        ),
        trackOutline: const .all(.from(width: 0.0, color: Colors.transparent)),
        stateLayerColor: .resolveWith(
          (states) => states.isSelected
              ? colorTheme.onPrimaryContainer
              : colorTheme.onSurface,
        ),
        handleColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates() => colorTheme.surface.withValues(
              alpha: 0.38,
            ),
            SwitchStates(isSelected: false) =>
              colorTheme.surfaceContainerHighest,
            SwitchStates(isSelected: true) => colorTheme.primaryContainer,
          },
        ),
        iconTheme: .resolveWith(
          (states) => .from(
            color: switch (states) {
              SwitchDisabledStates(isSelected: false) =>
                colorTheme.onSurface.withValues(
                  alpha: resolvedShowUnselectedIcon ? 0.38 : 0.0,
                ),
              SwitchDisabledStates(isSelected: true) =>
                colorTheme.onSurface.withValues(
                  alpha: resolvedShowSelectedIcon ? 0.38 : 0.0,
                ),
              SwitchStates(isSelected: false) =>
                colorTheme.onSurfaceVariant.withValues(
                  alpha: resolvedShowUnselectedIcon ? 1.0 : 0.0,
                ),
              SwitchStates(isSelected: true) =>
                colorTheme.onPrimaryContainer.withValues(
                  alpha: resolvedShowSelectedIcon ? 1.0 : 0.0,
                ),
            },
          ),
        ),
      ),
      .black => .from(
        trackColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates(isSelected: false) =>
              colorTheme.primaryContainer.withValues(alpha: 0.0),
            SwitchDisabledStates(isSelected: true) =>
              colorTheme.primaryContainer.withValues(alpha: 0.0),
            SwitchStates(isSelected: false) =>
              colorTheme.primaryContainer.withValues(alpha: 0.0),
            SwitchStates(isSelected: true) =>
              colorTheme.primaryContainer.withValues(alpha: 0.0),
          },
        ),
        trackOutline: .resolveWith(
          (states) => .from(
            width: switch (states) {
              SwitchStates(isSelected: false) => 2.0,
              SwitchStates(isSelected: true) => 4.0,
            },
            color: switch (states) {
              SwitchDisabledStates(isSelected: false) =>
                colorTheme.onSurface.withValues(alpha: 0.12),
              SwitchDisabledStates(isSelected: true) =>
                colorTheme.onSurface.withValues(alpha: 0.12),
              SwitchStates(isSelected: false) => colorTheme.onSurface,
              SwitchStates(isSelected: true) => colorTheme.onPrimaryContainer,
            },
          ),
        ),
        stateLayerColor: .resolveWith(
          (states) => states.isSelected
              ? colorTheme.onPrimaryContainer
              : colorTheme.onSurface,
        ),
        handleColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates(isSelected: false) =>
              colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
            SwitchDisabledStates(isSelected: true) =>
              colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
            SwitchStates(isSelected: false) =>
              colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
            SwitchStates(isSelected: true) =>
              colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
          },
        ),
        handleOutline: .resolveWith(
          (states) => .from(
            width: switch (states) {
              SwitchEnabledStates(isSelected: true, isPressed: true) =>
                selectedPressedHandleSize / 2.0,
              SwitchEnabledStates(isSelected: false, isPressed: true) =>
                (unselectedPressedHandleSize - unselectedHandleSize).abs() /
                        2.0 +
                    2.0,
              SwitchStates(isSelected: true) => selectedHandleSize / 2.0,
              SwitchStates(isSelected: false) => 2.0,
            },
            color: switch (states) {
              SwitchDisabledStates() => colorTheme.onSurface.withValues(
                alpha: 0.38,
              ),
              SwitchStates(isSelected: false) => colorTheme.onSurface,
              SwitchStates(isSelected: true) => colorTheme.onPrimaryContainer,
            },
          ),
        ),
        iconTheme: .resolveWith(
          (states) => .from(
            color: switch (states) {
              SwitchDisabledStates(isSelected: false) =>
                resolvedShowUnselectedIcon
                    ? null
                    : colorTheme.onSurface.withValues(alpha: 0.0),
              SwitchDisabledStates(isSelected: true) =>
                resolvedShowSelectedIcon
                    ? null
                    : colorTheme.onSurface.withValues(alpha: 0.0),
              SwitchStates(isSelected: false) =>
                colorTheme.surfaceContainerLow.withValues(
                  alpha: resolvedShowUnselectedIcon ? 1.0 : 0.0,
                ),
              SwitchStates(isSelected: true) =>
                colorTheme.onPrimaryContainer.withValues(
                  alpha: resolvedShowSelectedIcon ? 1.0 : 0.0,
                ),
            },
          ),
        ),
      ),
    };
    return switchThemeSize.merge(switchThemeColor);
  }

  static ListItemThemeDataPartial createListItemTheme({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
    required CustomListItemVariant variant,
  }) => switch (variant) {
    .settings => .from(
      containerColor: .all(colorTheme.surfaceBright),
      // stateLayerColor: .all(colorTheme.primary),
      // leadingIconTheme: .all(.from(color: colorTheme.primary)),
      // leadingTextStyle: .all(TextStyle(color: colorTheme.primary)),
      overlineTextStyle: .all(
        typescaleTheme.labelMedium.toTextStyle(
          color: colorTheme.onSurfaceVariant,
        ),
      ),
      headlineTextStyle: .all(
        typescaleTheme.bodyLargeEmphasized.toTextStyle(
          color: colorTheme.onSurface,
        ),
      ),
      supportingTextStyle: .all(
        typescaleTheme.bodyMedium.toTextStyle(
          color: colorTheme.onSurfaceVariant,
        ),
      ),
    ),
    .licenses => .from(
      // containerColor: .all(colorTheme.surfaceBright),
      // headlineTextStyle: .all(
      //   typescaleTheme.titleSmallEmphasized.toTextStyle().copyWith(
      //     fontFamily: FontFamily.googleSansCode,
      //     color: colorTheme.onSurface,
      //   ),
      // ),
      // supportingTextStyle: .all(
      //   typescaleTheme.bodySmall.toTextStyle(
      //     color: colorTheme.onSurfaceVariant,
      //   ),
      // ),
    ),
    .logs => .from(
      containerColor: .all(colorTheme.surface),
      overlineTextStyle: .all(
        typescaleTheme.labelSmall
            .mergeWith(font: const [FontFamily.googleSansCode])
            .toTextStyle(color: colorTheme.onSurfaceVariant),
      ),
      headlineTextStyle: .all(
        typescaleTheme.bodyMedium
            .mergeWith(font: const [FontFamily.googleSansCode])
            .toTextStyle(color: colorTheme.onSurface),
      ),
    ),
  };
}

abstract final class MarkdownThemeFactory {
  static MarkdownStyleSheet defaultStylesheetOf({
    required ColorThemeData colorTheme,
    required TypescaleThemeData typescaleTheme,
  }) {
    return MarkdownStyleSheet(
      p: typescaleTheme.bodyMedium.toTextStyle(color: colorTheme.onSurface),
      a: TextStyle(color: colorTheme.tertiary),
      h3: typescaleTheme.headlineSmall.toTextStyle(color: colorTheme.onSurface),
      em: const TextStyle(fontStyle: FontStyle.italic),
      strong: const TextStyle(fontWeight: FontWeight.bold),
      del: const TextStyle(decoration: TextDecoration.lineThrough),
    );
  }
}

// abstract class _PathBorder extends OutlinedBorder {
//   const _PathBorder({super.side, this.squash = 0.0});

//   Path get path;

//   /// How much of the aspect ratio of the attached widget to take on.
//   ///
//   /// If [squash] is non-zero, the border will match the aspect ratio of the
//   /// bounding box of the widget that it is attached to, which can give a
//   /// squashed appearance.
//   ///
//   /// The [squash] parameter lets you control how much of that aspect ratio this
//   /// border takes on.
//   ///
//   /// A value of zero means that the border will be drawn with a square aspect
//   /// ratio at the size of the shortest side of the bounding rectangle, ignoring
//   /// the aspect ratio of the widget, and a value of one means it will be drawn
//   /// with the aspect ratio of the widget. The value of [squash] has no effect
//   /// if the widget is square to begin with.
//   ///
//   /// Defaults to zero, and must be between zero and one, inclusive.
//   final double squash;

//   Path _transformPath(Rect rect, {TextDirection? textDirection}) {
//     var scale = Offset(rect.width, rect.height);

//     scale = rect.shortestSide == rect.width
//         ? Offset(scale.dx, squash * scale.dy + (1 - squash) * scale.dx)
//         : Offset(squash * scale.dx + (1 - squash) * scale.dy, scale.dy);

//     final actualRect =
//         Offset(
//           rect.left + (rect.width - scale.dx) / 2,
//           rect.top + (rect.height - scale.dy) / 2,
//         ) &
//         Size(scale.dx, scale.dy);

//     final matrix = Matrix4.identity()
//       ..translateByDouble(actualRect.left, actualRect.top, 0.0, 1.0)
//       ..scaleByDouble(scale.dx, scale.dy, 1.0, 1.0);

//     return path.transform(matrix.storage);
//   }

//   @override
//   _PathBorder copyWith({BorderSide? side, double? squash});

//   @override
//   _PathBorder scale(double t);

//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
//     final adjustedRect = rect.deflate(side.strokeInset);
//     return _transformPath(adjustedRect, textDirection: textDirection);
//   }

//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//     final adjustedRect = rect.inflate(side.strokeOutset);
//     return _transformPath(adjustedRect, textDirection: textDirection);
//   }

//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
//     switch (side.style) {
//       case BorderStyle.none:
//         return;
//       case BorderStyle.solid:
//         final adjustedRect = rect.inflate(side.strokeOffset / 2.0);
//         final path = _transformPath(adjustedRect);
//         canvas.drawPath(path, side.toPaint());
//     }
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       runtimeType == other.runtimeType &&
//           other is _PathBorder &&
//           side == other.side &&
//           squash == other.squash;

//   @override
//   int get hashCode => Object.hash(runtimeType, side, squash);
// }

// class _MorphBorder extends _PathBorder {
//   const _MorphBorder({
//     super.side,
//     super.squash,
//     required this.morph,
//     required this.progress,
//     this.startAngle = 0.0,
//   });

//   final Morph morph;
//   final double progress;
//   final double startAngle;

//   @override
//   Path get path => morph.toPath(progress: progress, startAngle: startAngle);

//   @override
//   _MorphBorder copyWith({
//     BorderSide? side,
//     double? squash,
//     Morph? morph,
//     double? progress,
//     double? startAngle,
//   }) => _MorphBorder(
//     side: side ?? this.side,
//     squash: squash ?? this.squash,
//     morph: morph ?? this.morph,
//     progress: progress ?? this.progress,
//     startAngle: startAngle ?? this.startAngle,
//   );

//   @override
//   _MorphBorder scale(double t) => _MorphBorder(
//     side: side.scale(t),
//     squash: squash,
//     morph: morph,
//     progress: progress,
//     startAngle: startAngle,
//   );

//   @override
//   ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
//     if (a is _MorphBorder) {
//       return _MorphBorder(
//         side: BorderSide.lerp(a.side, side, t),
//         squash: lerpDouble(a.squash, squash, t),
//         morph: t < 0.5 ? a.morph : morph,
//         progress: lerpDouble(a.progress, progress, t),
//         startAngle: lerpDouble(a.startAngle, startAngle, t),
//       );
//     }
//     return super.lerpFrom(a, t);
//   }

//   @override
//   ShapeBorder? lerpTo(ShapeBorder? b, double t) {
//     if (b is _MorphBorder) {
//       return _MorphBorder(
//         side: BorderSide.lerp(side, b.side, t),
//         squash: lerpDouble(squash, b.squash, t),
//         morph: t < 0.5 ? morph : b.morph,
//         progress: lerpDouble(progress, b.progress, t),
//         startAngle: lerpDouble(startAngle, b.startAngle, t),
//       );
//     }
//     return super.lerpTo(b, t);
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       runtimeType == other.runtimeType &&
//           other is _MorphBorder &&
//           side == other.side &&
//           squash == other.squash &&
//           morph == other.morph &&
//           progress == other.progress &&
//           startAngle == other.startAngle;

//   @override
//   int get hashCode =>
//       Object.hash(runtimeType, side, squash, morph, progress, startAngle);
// }
