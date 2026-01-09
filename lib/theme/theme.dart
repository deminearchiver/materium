import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:materium/flutter.dart';

// ignore: implementation_imports
import 'package:material/src/material_shapes/material_shapes.dart';

enum CustomCheckboxColor { standard, listItemPhone, listItemWatch, black }

enum CustomRadioButtonColor { standard, listItemPhone, listItemWatch, black }

enum CustomSwitchSize { standard, nowInAndroid, black }

enum CustomSwitchColor {
  standard,
  listItemPhone,
  listItemWatch,
  nowInAndroid,
  black,
}

enum CustomListItemColor {
  settings,
  licenses,
  logs,
  materiumNormal,
  materiumBlack,
}

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
    .standard => const .from(),
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
    .black => .from(
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
            colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
          _ => null,
        },
      ),
      iconOutlineColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonDisabledStates() => null,
          RadioButtonStates(isSelected: false) => colorTheme.onSurface,
          RadioButtonStates(isSelected: true) => colorTheme.onPrimaryContainer,
        },
      ),
      iconDotColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonDisabledStates() => null,
          RadioButtonStates(isSelected: false) => colorTheme.onSurface,
          RadioButtonStates(isSelected: true) => colorTheme.onPrimaryContainer,
        },
      ),
    ),
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
              SwitchEnabledStates(isPressed: true) => 4.0,
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
    required CustomListItemColor color,
  }) => switch (color) {
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
    .materiumNormal => .from(),
    .materiumBlack => .from(),
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
