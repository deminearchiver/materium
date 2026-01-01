import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:drift/drift.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material/material_shapes.dart';
import 'package:materium/components/custom_list.dart';
import 'package:materium/components/custom_refresh_indicator.dart';
import 'package:materium/database/database.dart';
import 'package:materium/equations.dart';
import 'package:materium/flutter.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/generated_form.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/developer.dart';
import 'package:materium/pages/import_export.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/logs_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:materium/theme/legacy.dart';
import 'package:materium/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shizuku_apk_installer/shizuku_apk_installer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsListItemLeading extends StatelessWidget {
  const SettingsListItemLeading({
    super.key,
    this.shrinkWrapHeight = false,
    this.containerShape,
    this.containerColor,
    this.contentColor,
    required this.child,
  });

  factory SettingsListItemLeading.fromExtendedColor({
    required ExtendedColorPairing pairing,
    required ExtendedColor extendedColor,
    ShapeBorder? containerShape,
    Color? containerColor,
    Color? contentColor,
    required Widget child,
  }) => SettingsListItemLeading(
    containerShape: containerShape,
    containerColor:
        containerColor ?? pairing.resolveContainerColor(extendedColor),
    contentColor: contentColor ?? pairing.resolveContentColor(extendedColor),
    child: child,
  );

  final bool shrinkWrapHeight;
  final ShapeBorder? containerShape;
  final Color? containerColor;
  final Color? contentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.0,
      height: !shrinkWrapHeight ? 40.0 : null,
      child: Skeleton.leaf(
        child: Material(
          clipBehavior: .antiAlias,
          borderOnForeground: false,
          shape: containerShape,
          color: containerColor,
          child: DefaultTextStyle.merge(
            textAlign: .center,
            maxLines: 1,
            softWrap: false,
            overflow: .visible,
            style: TextStyle(color: contentColor),
            child: IconTheme.merge(
              data: .from(opticalSize: 24.0, size: 24.0, color: contentColor),
              child: Align.center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const List<int> updateIntervalNodes = <int>[
    15,
    30,
    60,
    120,
    180,
    360,
    720,
    1440,
    4320,
    10080,
    20160,
    43200,
  ];

  int updateInterval = 0;

  late SplineInterpolation updateIntervalInterpolator;

  String updateIntervalLabel = tr('neverManualOnly');

  bool showIntervalLabel = true;

  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
        ColorTools.createPrimarySwatch(obtainiumThemeColor): "Obtainium",
      };

  void initUpdateIntervalInterpolator() {
    final nodes = <InterpolationNode>[
      for (var index = 0; index < updateIntervalNodes.length; index++)
        InterpolationNode(
          x: index.toDouble() + 1.0,
          y: updateIntervalNodes[index].toDouble(),
        ),
    ];
    updateIntervalInterpolator = SplineInterpolation(nodes: nodes);
  }

  void processIntervalSliderValue(double val) {
    if (val < 0.5) {
      updateInterval = 0;
      updateIntervalLabel = tr("neverManualOnly");
      return;
    }
    var valInterpolated = 0;
    if (val < 1) {
      valInterpolated = 15;
    } else {
      valInterpolated = updateIntervalInterpolator.compute(val).round();
    }
    if (valInterpolated < 60) {
      updateInterval = valInterpolated;
      updateIntervalLabel = plural("minute", valInterpolated);
    } else if (valInterpolated < 8 * 60) {
      final valRounded = (valInterpolated / 15).floor() * 15;
      updateInterval = valRounded;
      updateIntervalLabel = plural("hour", valRounded ~/ 60);
      final mins = valRounded % 60;
      if (mins != 0) updateIntervalLabel += " ${plural("minute", mins)}";
    } else if (valInterpolated < 24 * 60) {
      final valRounded = (valInterpolated / 30).floor() * 30;
      updateInterval = valRounded;
      updateIntervalLabel = plural("hour", valRounded / 60);
    } else if (valInterpolated < 7 * 24 * 60) {
      final valRounded = (valInterpolated / (12 * 60)).floor() * 12 * 60;
      updateInterval = valRounded;
      updateIntervalLabel = plural("day", valRounded / (24 * 60));
    } else {
      final valRounded = (valInterpolated / (24 * 60)).floor() * 24 * 60;
      updateInterval = valRounded;
      updateIntervalLabel = plural("day", valRounded ~/ (24 * 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final settings = context.read<SettingsService>();
    final sourceProvider = SourceProvider();

    final padding = MediaQuery.paddingOf(context);
    final t = Translations.of(context);
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final staticColors = StaticColors.of(context);

    final updateIntervalSliderVal = context.select<SettingsProvider, double>(
      (settingsProvider) => settingsProvider.updateIntervalSliderVal,
    );

    initUpdateIntervalInterpolator();
    processIntervalSliderValue(updateIntervalSliderVal);

    void onUseShizukuChanged(bool useShizuku) {
      if (useShizuku) {
        ShizukuApkInstaller.checkPermission().then((resCode) {
          settingsProvider.useShizuku = resCode!.startsWith("granted");
          if (!context.mounted) return;
          switch (resCode) {
            case "binder_not_found":
              showError(ObtainiumError(tr("shizukuBinderNotFound")), context);
            case "old_shizuku":
              showError(ObtainiumError(tr("shizukuOld")), context);
            case "old_android_with_adb":
              showError(
                ObtainiumError(tr("shizukuOldAndroidWithADB")),
                context,
              );
            case "denied":
              showError(ObtainiumError(tr("cancelled")), context);
          }
        });
      } else {
        settingsProvider.useShizuku = false;
      }
    }

    Future<bool> colorPickerDialog() =>
        ColorPicker(
          color: settings.themeColor.value,
          onColorChanged: (value) =>
              setState(() => settings.themeColor.value = value),
          actionButtons: const ColorPickerActionButtons(
            okButton: true,
            closeButton: true,
            dialogActionButtons: false,
          ),
          pickersEnabled: const {
            .both: false,
            .primary: false,
            .accent: false,
            .bw: false,
            .custom: true,
            .wheel: true,
          },
          pickerTypeLabels: {.custom: tr("standard"), .wheel: tr("custom")},
          title: Text(
            tr("selectX", args: [tr("colour").toLowerCase()]),
            style: typescaleTheme.titleLarge.toTextStyle(
              color: colorTheme.onSurface,
            ),
          ),
          wheelDiameter: 192,
          wheelSquareBorderRadius: 32,
          width: 48,
          height: 48,
          borderRadius: 24,
          spacing: 8,
          runSpacing: 8,
          enableShadesSelection: false,
          customColorSwatchesAndNames: colorsNameMap,
          showMaterialName: true,
          showColorName: true,
          materialNameTextStyle: typescaleTheme.bodySmall.toTextStyle(),
          colorNameTextStyle: typescaleTheme.bodySmall.toTextStyle(),
          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
            longPressMenu: true,
          ),
          pickerTypeTextStyle: typescaleTheme.labelLarge.toTextStyle(
            color: colorTheme.onSecondaryContainer,
          ),
          selectedPickerTypeColor: colorTheme.secondary,
        ).showPickerDialog(
          context,
          transitionDuration: const Duration(milliseconds: 500),
          transitionBuilder: (context, a1, a2, widget) {
            final curvedValue = const EasingThemeData.fallback().emphasized
                .transform(a1.value);
            return Transform.scale(
              scale: curvedValue,
              alignment: Alignment.center,
              child: Opacity(opacity: curvedValue, child: widget),
            );
          },
        );

    void selectColor() async {
      final previousThemeColor = settings.themeColor.value;
      final result = await colorPickerDialog();
      if (context.mounted && !result) {
        setState(() => settings.themeColor.value = previousThemeColor);
      }
    }

    final sourceSpecificFields = sourceProvider.sources.map((e) {
      if (e.sourceConfigSettingFormItems.isNotEmpty) {
        return GeneratedForm(
          items: e.sourceConfigSettingFormItems.map((e) {
            if (e is GeneratedFormSwitch) {
              e.defaultValue = settingsProvider.getSettingBool(e.key);
            } else {
              e.defaultValue = settingsProvider.getSettingString(e.key);
            }
            return [e];
          }).toList(),
          onValueChanges: (values, valid, isBuilding) {
            if (valid && !isBuilding) {
              values.forEach((key, value) {
                final formItem = e.sourceConfigSettingFormItems
                    .where((i) => i.key == key)
                    .firstOrNull;
                if (formItem is GeneratedFormSwitch) {
                  settingsProvider.setSettingBool(key, value == true);
                } else {
                  settingsProvider.setSettingString(key, value ?? '');
                }
              });
            }
          },
        );
      } else {
        return Container();
      }
    });

    final showBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final disabledContainerColor = colorTheme.onSurface.withValues(alpha: 0.10);
    final disabledContentColor = colorTheme.onSurface.withValues(alpha: 0.38);

    final selectedListItemTheme = ListItemThemeDataPartial.from(
      containerColor: .all(colorTheme.secondaryContainer),
      containerShape: .all(
        CornersBorder.rounded(corners: .all(shapeTheme.corner.large)),
      ),
      stateLayerColor: .all(colorTheme.onSecondaryContainer),
      leadingIconTheme: .all(.from(color: colorTheme.onSecondaryContainer)),
      leadingTextStyle: .all(TextStyle(color: colorTheme.onSecondaryContainer)),
      overlineTextStyle: .all(
        TextStyle(color: colorTheme.onSecondaryContainer),
      ),
      headlineTextStyle: .all(
        TextStyle(color: colorTheme.onSecondaryContainer),
      ),
      supportingTextStyle: .all(
        TextStyle(color: colorTheme.onSecondaryContainer),
      ),
      trailingTextStyle: .all(
        TextStyle(color: colorTheme.onSecondaryContainer),
      ),
      trailingIconTheme: .all(.from(color: colorTheme.onSecondaryContainer)),
    );

    final unselectedListItemTheme = ListItemThemeDataPartial.from(
      containerColor: .all(colorTheme.surface),
    );

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            ValueListenableBuilder(
              valueListenable: settings.developerMode,
              builder: (context, developerMode, _) => CustomAppBar(
                type: developerMode || showBackButton ? .small : .largeFlexible,
                expandedContainerColor: colorTheme.surfaceContainer,
                collapsedContainerColor: colorTheme.surfaceContainer,
                collapsedPadding: showBackButton
                    ? const .fromSTEB(8.0 + 40.0 + 8.0, 0.0, 16.0, 0.0)
                    : null,
                leading: showBackButton
                    ? const Padding(
                        padding: .fromSTEB(8.0 - 4.0, 0.0, 8.0 - 4.0, 0.0),
                        child: DeveloperPageBackButton(),
                      )
                    : null,
                title: Text(
                  tr("settings"),
                  textAlign: developerMode && !showBackButton
                      ? .center
                      : .start,
                ),
              ),
            ),
            SliverPadding(
              padding: .fromLTRB(8.0, showBackButton ? 0.0 : 4.0, 8.0, 16.0),
              // TODO: fix switches reparenting (add ValueKey or GlobalKey to list items)
              sliver: SliverList.list(
                children: [
                  KeyedSubtree(
                    key: const ValueKey("updateIntervalSliderVal"),
                    child: Selector<SettingsProvider, double>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.updateIntervalSliderVal,
                      builder: (context, updateIntervalSliderVal, _) {
                        final isSelected = updateIntervalSliderVal > 0.0;
                        final activeIndicatorColor = isSelected
                            ? colorTheme.primary
                            : colorTheme.primary;
                        final trackColor = isSelected
                            ? colorTheme.surfaceContainer
                            // ? colorTheme.onSecondaryContainer.withValues(
                            //     alpha: 0.38,
                            //   )
                            : colorTheme.secondaryContainer;
                        return ListItemTheme.merge(
                          data: isSelected
                              ? selectedListItemTheme
                              : unselectedListItemTheme,
                          child: ListItemContainer(
                            isFirst: true,
                            child: Flex.vertical(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListItemLayout(
                                  headline: Text(tr("bgUpdateCheckInterval")),
                                  supportingText: Visibility.maintain(
                                    visible: showIntervalLabel,
                                    child: Text(
                                      updateIntervalLabel,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16.0,
                                    0.0,
                                    16.0,
                                    12.0,
                                  ),
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: activeIndicatorColor,
                                      thumbColor: activeIndicatorColor,
                                      inactiveTrackColor: trackColor,
                                    ),
                                    child: Slider(
                                      value: updateIntervalSliderVal,
                                      max: updateIntervalNodes.length
                                          .toDouble(),
                                      divisions:
                                          updateIntervalNodes.length * 20,
                                      label: updateIntervalLabel,
                                      onChanged: (value) {
                                        settingsProvider
                                                .updateIntervalSliderVal =
                                            value;
                                        setState(
                                          () =>
                                              processIntervalSliderValue(value),
                                        );
                                      },
                                      onChangeStart: (value) => setState(
                                        () => showIntervalLabel = false,
                                      ),
                                      onChangeEnd: (value) {
                                        settingsProvider.updateInterval =
                                            updateInterval;
                                        setState(
                                          () => showIntervalLabel = true,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if ((settingsProvider.updateInterval > 0) &&
                      (((DeviceInfo.androidInfo?.version.sdkInt ?? 0) >= 30) ||
                          settingsProvider.useShizuku))
                    Flex.vertical(
                      mainAxisSize: .min,
                      crossAxisAlignment: .stretch,
                      children: [
                        const SizedBox(height: 2.0),
                        KeyedSubtree(
                          key: const ValueKey("useFGService"),
                          child: Selector<SettingsProvider, bool>(
                            selector: (context, settingsProvider) =>
                                settingsProvider.useFGService,
                            builder: (context, useFGService, _) =>
                                ListItemTheme.merge(
                                  data: useFGService
                                      ? selectedListItemTheme
                                      : unselectedListItemTheme,
                                  child: ListItemContainer(
                                    child: MergeSemantics(
                                      child: ListItemInteraction(
                                        onTap: () =>
                                            settingsProvider.useFGService =
                                                !useFGService,
                                        child: ListItemLayout(
                                          padding: const .fromLTRB(
                                            16.0,
                                            0.0,
                                            16.0 - 8.0,
                                            0.0,
                                          ),
                                          trailingPadding: const .symmetric(
                                            vertical:
                                                (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                          ),
                                          headline: Text(
                                            tr("foregroundServiceExplanation"),
                                          ),
                                          trailing: ExcludeFocus(
                                            child: Switch(
                                              onCheckedChanged: (value) =>
                                                  settingsProvider
                                                          .useFGService =
                                                      value,
                                              checked: useFGService,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        KeyedSubtree(
                          key: const ValueKey("enableBackgroundUpdates"),
                          child: Selector<SettingsProvider, bool>(
                            selector: (context, settingsProvider) =>
                                settingsProvider.enableBackgroundUpdates,
                            builder: (context, enableBackgroundUpdates, _) =>
                                ListItemTheme.merge(
                                  data: enableBackgroundUpdates
                                      ? selectedListItemTheme
                                      : unselectedListItemTheme,
                                  child: ListItemContainer(
                                    child: Flex.vertical(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MergeSemantics(
                                          child: ListItemInteraction(
                                            onTap: () =>
                                                settingsProvider
                                                        .enableBackgroundUpdates =
                                                    !enableBackgroundUpdates,
                                            child: ListItemLayout(
                                              padding: const .fromLTRB(
                                                16.0,
                                                0.0,
                                                16.0 - 8.0,
                                                0.0,
                                              ),
                                              trailingPadding: const .symmetric(
                                                vertical:
                                                    (32.0 + 2 * 10.0 - 48.0) /
                                                    2.0,
                                              ),
                                              headline: Text(
                                                tr("enableBackgroundUpdates"),
                                              ),
                                              trailing: ExcludeFocus(
                                                child: Switch(
                                                  onCheckedChanged: (value) =>
                                                      settingsProvider
                                                              .enableBackgroundUpdates =
                                                          value,
                                                  checked:
                                                      enableBackgroundUpdates,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            16.0,
                                            0.0,
                                            16.0,
                                            12.0,
                                          ),
                                          child: DefaultTextStyle(
                                            style: TypescaleTheme.of(context)
                                                .bodyMedium
                                                .toTextStyle(
                                                  color: colorTheme
                                                      .onSurfaceVariant,
                                                ),
                                            child: Flex.vertical(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              spacing: 8.0,
                                              children: [
                                                Text(
                                                  tr(
                                                    'backgroundUpdateReqsExplanation',
                                                  ),
                                                ),
                                                Text(
                                                  tr(
                                                    'backgroundUpdateLimitsExplanation',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        Selector<SettingsProvider, bool>(
                          selector: (context, settingsProvider) =>
                              settingsProvider.enableBackgroundUpdates,
                          builder: (context, enableBackgroundUpdates, child) =>
                              enableBackgroundUpdates
                              ? child!
                              : const SizedBox.shrink(),
                          child: Flex.vertical(
                            children: [
                              const SizedBox(height: 2.0),
                              KeyedSubtree(
                                key: const ValueKey("bgUpdatesOnWiFiOnly"),
                                child: Selector<SettingsProvider, bool>(
                                  selector: (context, settingsProvider) =>
                                      settingsProvider.bgUpdatesOnWiFiOnly,
                                  builder: (context, bgUpdatesOnWiFiOnly, _) =>
                                      ListItemTheme.merge(
                                        data: bgUpdatesOnWiFiOnly
                                            ? selectedListItemTheme
                                            : unselectedListItemTheme,
                                        child: ListItemContainer(
                                          child: MergeSemantics(
                                            child: ListItemInteraction(
                                              onTap: () =>
                                                  settingsProvider
                                                          .bgUpdatesOnWiFiOnly =
                                                      !bgUpdatesOnWiFiOnly,
                                              child: ListItemLayout(
                                                padding: const .fromLTRB(
                                                  16.0,
                                                  0.0,
                                                  16.0 - 8.0,
                                                  0.0,
                                                ),
                                                trailingPadding:
                                                    const .symmetric(
                                                      vertical:
                                                          (32.0 +
                                                              2 * 10.0 -
                                                              48.0) /
                                                          2.0,
                                                    ),
                                                headline: Text(
                                                  tr("bgUpdatesOnWiFiOnly"),
                                                ),
                                                trailing: ExcludeFocus(
                                                  child: Switch(
                                                    onCheckedChanged: (value) =>
                                                        settingsProvider
                                                                .bgUpdatesOnWiFiOnly =
                                                            value,
                                                    checked:
                                                        bgUpdatesOnWiFiOnly,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              KeyedSubtree(
                                key: const ValueKey(
                                  "bgUpdatesWhileChargingOnly",
                                ),
                                child: Selector<SettingsProvider, bool>(
                                  selector: (context, settingsProvider) =>
                                      settingsProvider
                                          .bgUpdatesWhileChargingOnly,
                                  builder:
                                      (
                                        context,
                                        bgUpdatesWhileChargingOnly,
                                        _,
                                      ) => ListItemTheme.merge(
                                        data: bgUpdatesWhileChargingOnly
                                            ? selectedListItemTheme
                                            : unselectedListItemTheme,
                                        child: ListItemContainer(
                                          child: MergeSemantics(
                                            child: ListItemInteraction(
                                              onTap: () =>
                                                  settingsProvider
                                                          .bgUpdatesWhileChargingOnly =
                                                      !bgUpdatesWhileChargingOnly,
                                              child: ListItemLayout(
                                                padding: const .fromLTRB(
                                                  16.0,
                                                  0.0,
                                                  16.0 - 8.0,
                                                  0.0,
                                                ),
                                                trailingPadding:
                                                    const .symmetric(
                                                      vertical:
                                                          (32.0 +
                                                              2 * 10.0 -
                                                              48.0) /
                                                          2.0,
                                                    ),
                                                headline: Text(
                                                  tr(
                                                    "bgUpdatesWhileChargingOnly",
                                                  ),
                                                ),
                                                trailing: ExcludeFocus(
                                                  child: Switch(
                                                    onCheckedChanged: (value) =>
                                                        settingsProvider
                                                                .bgUpdatesWhileChargingOnly =
                                                            value,
                                                    checked:
                                                        bgUpdatesWhileChargingOnly,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("checkOnStart"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.checkOnStart,
                      builder: (context, checkOnStart, _) =>
                          ListItemTheme.merge(
                            data: checkOnStart
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () => settingsProvider.checkOnStart =
                                      !checkOnStart,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(tr("checkOnStart")),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider.checkOnStart =
                                                value,
                                        checked: checkOnStart,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("checkUpdateOnDetailPage"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.checkUpdateOnDetailPage,
                      builder: (context, checkUpdateOnDetailPage, _) =>
                          ListItemTheme.merge(
                            data: checkUpdateOnDetailPage
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider.checkUpdateOnDetailPage =
                                          !checkUpdateOnDetailPage,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(
                                      tr("checkUpdateOnDetailPage"),
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider
                                                    .checkUpdateOnDetailPage =
                                                value,
                                        checked: checkUpdateOnDetailPage,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("onlyCheckInstalledOrTrackOnlyApps"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.onlyCheckInstalledOrTrackOnlyApps,
                      builder:
                          (
                            context,
                            onlyCheckInstalledOrTrackOnlyApps,
                            _,
                          ) => ListItemTheme.merge(
                            data: onlyCheckInstalledOrTrackOnlyApps
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider
                                              .onlyCheckInstalledOrTrackOnlyApps =
                                          !onlyCheckInstalledOrTrackOnlyApps,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(
                                      tr("onlyCheckInstalledOrTrackOnlyApps"),
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider
                                                    .onlyCheckInstalledOrTrackOnlyApps =
                                                value,
                                        checked:
                                            onlyCheckInstalledOrTrackOnlyApps,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("removeOnExternalUninstall"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.removeOnExternalUninstall,
                      builder: (context, removeOnExternalUninstall, _) =>
                          ListItemTheme.merge(
                            data: removeOnExternalUninstall
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: ListItemInteraction(
                                onTap: () =>
                                    settingsProvider.removeOnExternalUninstall =
                                        !removeOnExternalUninstall,
                                child: ListItemLayout(
                                  padding: const .fromLTRB(
                                    16.0,
                                    0.0,
                                    16.0 - 8.0,
                                    0.0,
                                  ),
                                  trailingPadding: const .symmetric(
                                    vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                  ),
                                  headline: Text(
                                    tr("removeOnExternalUninstall"),
                                  ),
                                  trailing: ExcludeFocus(
                                    child: Switch(
                                      onCheckedChanged: (value) =>
                                          settingsProvider
                                                  .removeOnExternalUninstall =
                                              value,
                                      checked: removeOnExternalUninstall,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("parallelDownloads"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.parallelDownloads,
                      builder: (context, parallelDownloads, _) =>
                          ListItemTheme.merge(
                            data: parallelDownloads
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider.parallelDownloads =
                                          !parallelDownloads,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(tr("parallelDownloads")),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider.parallelDownloads =
                                                value,
                                        checked: parallelDownloads,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("beforeNewInstallsShareToAppVerifier"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.beforeNewInstallsShareToAppVerifier,
                      builder:
                          (
                            context,
                            beforeNewInstallsShareToAppVerifier,
                            _,
                          ) => ListItemTheme.merge(
                            data: beforeNewInstallsShareToAppVerifier
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: Flex.vertical(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  MergeSemantics(
                                    child: ListItemInteraction(
                                      onTap: () =>
                                          settingsProvider
                                                  .beforeNewInstallsShareToAppVerifier =
                                              !beforeNewInstallsShareToAppVerifier,
                                      child: ListItemLayout(
                                        padding: const .fromLTRB(
                                          16.0,
                                          0.0,
                                          16.0 - 8.0,
                                          0.0,
                                        ),
                                        trailingPadding: const .symmetric(
                                          vertical:
                                              (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                        ),
                                        headline: Text(
                                          tr(
                                            "beforeNewInstallsShareToAppVerifier",
                                          ),
                                        ),
                                        trailing: ExcludeFocus(
                                          child: Switch(
                                            onCheckedChanged: (value) =>
                                                settingsProvider
                                                        .beforeNewInstallsShareToAppVerifier =
                                                    value,
                                            checked:
                                                beforeNewInstallsShareToAppVerifier,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListItemInteraction(
                                    onTap: () => launchUrlString(
                                      "https://github.com/soupslurpr/AppVerifier",
                                      mode: LaunchMode.externalApplication,
                                    ),
                                    child: ListItemLayout(
                                      leading: const Icon(
                                        Symbols.open_in_new_rounded,
                                      ),
                                      supportingText: Text(tr("about")),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("useShizuku"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.useShizuku,
                      builder: (context, useShizuku, _) => ListItemTheme.merge(
                        data: useShizuku
                            ? selectedListItemTheme
                            : unselectedListItemTheme,
                        child: ListItemContainer(
                          child: MergeSemantics(
                            child: ListItemInteraction(
                              onTap: () => onUseShizukuChanged(!useShizuku),
                              child: ListItemLayout(
                                padding: const .fromLTRB(
                                  16.0,
                                  0.0,
                                  16.0 - 8.0,
                                  0.0,
                                ),
                                trailingPadding: const .symmetric(
                                  vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                ),
                                headline: Text(tr("useShizuku")),
                                trailing: ExcludeFocus(
                                  child: Switch(
                                    onCheckedChanged: onUseShizukuChanged,
                                    checked: useShizuku,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("shizukuPretendToBeGooglePlay"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.shizukuPretendToBeGooglePlay,
                      builder: (context, shizukuPretendToBeGooglePlay, _) =>
                          ListItemTheme.merge(
                            data: shizukuPretendToBeGooglePlay
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              isLast: true,
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider
                                              .shizukuPretendToBeGooglePlay =
                                          !shizukuPretendToBeGooglePlay,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(
                                      tr("shizukuPretendToBeGooglePlay"),
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider
                                                    .shizukuPretendToBeGooglePlay =
                                                value,
                                        checked: shizukuPretendToBeGooglePlay,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Material(
                    clipBehavior: .antiAlias,
                    shape: CornersBorder.rounded(
                      corners: .all(shapeTheme.corner.large),
                    ),
                    color: colorTheme.surface,
                    child: Padding(
                      padding: const .all(16.0),
                      child: Flex.vertical(
                        mainAxisSize: .min,
                        crossAxisAlignment: .stretch,
                        children: sourceSpecificFields.toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  KeyedSubtree(
                    key: const ValueKey("language"),
                    child: Selector<SettingsProvider, Locale?>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.forcedLocale,
                      builder: (context, forcedLocale, _) {
                        final isSelected = forcedLocale != null;
                        return DropdownMenuFormField<Outer<Locale?>>(
                          inputDecorationTheme: InputDecorationThemeData(
                            contentPadding: const .symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            border: CornersInputBorder.rounded(
                              corners: .all(shapeTheme.corner.large),
                            ),
                            filled: true,
                            fillColor: isSelected
                                ? colorTheme.secondaryContainer
                                : colorTheme.surface,
                          ),
                          expandedInsets: .zero,
                          label: Text(tr("language")),
                          enableFilter: true,
                          enableSearch: true,
                          requestFocusOnTap: true,
                          initialSelection: Outer(forcedLocale),
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: const Outer(null),
                              label: tr("followSystem"),
                            ),
                            ...supportedLocales.map(
                              (e) => DropdownMenuEntry(
                                value: Outer(e.key),
                                label: e.value,
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == null) return;
                            final resolvedValue = value.inner;
                            settingsProvider.forcedLocale = resolvedValue;
                            if (resolvedValue != null) {
                              context.setLocale(resolvedValue);
                            } else {
                              settingsProvider.resetLocaleSafe(context);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  KeyedSubtree(
                    key: const ValueKey("useMaterialYou"),
                    child: ValueListenableBuilder(
                      valueListenable: settings.useMaterialYou,
                      builder: (context, useMaterialYou, _) {
                        final isDisabled =
                            !DynamicColor.isDynamicColorAvailable();
                        useMaterialYou = useMaterialYou && !isDisabled;
                        final containerColor = isDisabled
                            ? disabledContainerColor
                            : null;
                        final contentColor = isDisabled
                            ? disabledContentColor
                            : null;
                        final textStyle = TextStyle(color: contentColor);
                        return ListItemTheme.merge(
                          data: useMaterialYou
                              ? selectedListItemTheme
                              : unselectedListItemTheme,
                          child: ListItemContainer(
                            isFirst: true,
                            child: MergeSemantics(
                              child: ListItemInteraction(
                                onTap: !isDisabled
                                    ? () => settings.useMaterialYou.value =
                                          !useMaterialYou
                                    : null,
                                child: ListItemLayout(
                                  padding: const .fromLTRB(
                                    16.0,
                                    0.0,
                                    16.0 - 8.0,
                                    0.0,
                                  ),
                                  trailingPadding: const .symmetric(
                                    vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                  ),
                                  headline: Text(
                                    tr("useMaterialYou"),
                                    style: textStyle,
                                  ),
                                  trailing: ExcludeFocus(
                                    child: Switch(
                                      onCheckedChanged: !isDisabled
                                          ? settings.useMaterialYou.setValue
                                          : null,
                                      checked: useMaterialYou,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  KeyedSubtree(
                    key: const ValueKey("selectColor"),
                    child: ValueListenableBuilder(
                      valueListenable: settings.useMaterialYou,
                      builder: (context, useMaterialYou, _) {
                        useMaterialYou =
                            useMaterialYou &&
                            DynamicColor.isDynamicColorAvailable();
                        final isDisabled = useMaterialYou;
                        final containerColor = isDisabled
                            ? disabledContainerColor
                            : null;
                        final contentColor = isDisabled
                            ? disabledContentColor
                            : null;
                        final textStyle = TextStyle(color: contentColor);
                        return Padding(
                          padding: const .only(top: 2.0),
                          child: ListItemTheme.merge(
                            data: unselectedListItemTheme,
                            child: ListItemContainer(
                              child: ListItemInteraction(
                                onTap: !isDisabled ? selectColor : null,
                                child: ValueListenableBuilder(
                                  valueListenable: settings.themeColor,
                                  builder: (context, themeColor, _) => ListItemLayout(
                                    headline: Text(
                                      tr(
                                        "selectX",
                                        args: [tr("colour").toLowerCase()],
                                      ),
                                      style: textStyle,
                                    ),
                                    supportingText: Text(
                                      "${ColorTools.nameThatColor(themeColor)} "
                                      "(${ColorTools.materialNameAndCode(themeColor, colorSwatchNameMap: colorsNameMap)})",
                                      style: textStyle,
                                    ),
                                    trailing: ColorIndicator(
                                      width: 40,
                                      height: 40,
                                      borderRadius: 20,
                                      color: containerColor ?? themeColor,
                                      onSelectFocus: false,
                                      onSelect: !isDisabled
                                          ? selectColor
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Flex.horizontal(
                    spacing: 2.0,
                    children: [
                      Flexible.tight(
                        child: ValueListenableBuilder(
                          valueListenable: settings.themeMode,
                          builder: (context, themeMode, _) {
                            final isSelected = themeMode != .system;
                            return DropdownMenuFormField<ThemeMode>(
                              key: const ValueKey("themeMode"),
                              inputDecorationTheme: InputDecorationThemeData(
                                contentPadding: const .symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                border: CornersInputBorder.rounded(
                                  corners: isSelected
                                      ? .all(shapeTheme.corner.large)
                                      : .directional(
                                          topStart:
                                              shapeTheme.corner.extraSmall,
                                          topEnd: shapeTheme.corner.extraSmall,
                                          bottomStart: shapeTheme.corner.large,
                                          bottomEnd:
                                              shapeTheme.corner.extraSmall,
                                        ),
                                ),
                                filled: true,
                                fillColor: isSelected
                                    ? colorTheme.secondaryContainer
                                    : colorTheme.surface,
                              ),
                              expandedInsets: .zero,
                              textStyle: typescaleTheme.titleMediumEmphasized
                                  .toTextStyle(),
                              label: Text(tr("theme")),
                              initialSelection: themeMode,
                              dropdownMenuEntries: [
                                DropdownMenuEntry(
                                  value: .system,
                                  leadingIcon: const IconLegacy(
                                    Symbols.auto_mode_rounded,
                                  ),
                                  label: tr("followSystem"),
                                ),
                                DropdownMenuEntry(
                                  value: .light,
                                  leadingIcon: const IconLegacy(
                                    Symbols.light_mode_rounded,
                                  ),
                                  label: tr("light"),
                                ),
                                DropdownMenuEntry(
                                  value: .dark,
                                  leadingIcon: const IconLegacy(
                                    Symbols.dark_mode_rounded,
                                  ),
                                  label: tr("dark"),
                                ),
                              ],
                              onSelected: (value) {
                                if (value != null) {
                                  settings.themeMode.value = value;
                                }
                              },
                            );
                          },
                        ),
                      ),
                      Flexible.tight(
                        child: ValueListenableBuilder(
                          valueListenable: settings.themeVariant,
                          builder: (context, themeVariant, _) {
                            final isSelected =
                                themeVariant.dynamicSchemeVariant !=
                                ThemeVariant.system.dynamicSchemeVariant;
                            return DropdownMenuFormField<ThemeVariant>(
                              key: const ValueKey("themeVariant"),
                              inputDecorationTheme: InputDecorationThemeData(
                                contentPadding: const .symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                border: CornersInputBorder.rounded(
                                  corners: isSelected
                                      ? .all(shapeTheme.corner.large)
                                      : .directional(
                                          topStart:
                                              shapeTheme.corner.extraSmall,
                                          topEnd: shapeTheme.corner.extraSmall,
                                          bottomStart:
                                              shapeTheme.corner.extraSmall,
                                          bottomEnd: shapeTheme.corner.large,
                                        ),
                                ),
                                filled: true,
                                fillColor: isSelected
                                    ? colorTheme.secondaryContainer
                                    : colorTheme.surface,
                              ),
                              expandedInsets: .zero,
                              textStyle: typescaleTheme.titleMediumEmphasized
                                  .toTextStyle(),
                              label: Text("Color scheme"),
                              initialSelection: themeVariant,
                              dropdownMenuEntries: [
                                DropdownMenuEntry(
                                  value: .calm,
                                  leadingIcon: const IconLegacy(
                                    Symbols.moon_stars_rounded,
                                    fill: 1.0,
                                  ),
                                  label: "Calm",
                                ),
                                DropdownMenuEntry(
                                  value: .pastel,
                                  leadingIcon: const IconLegacy(
                                    Symbols.brush_rounded,
                                    fill: 1.0,
                                  ),
                                  label: "Pastel",
                                ),
                                DropdownMenuEntry(
                                  value: .juicy,
                                  leadingIcon: const IconLegacy(
                                    Symbols.nutrition_rounded,
                                    fill: 1.0,
                                  ),
                                  label: "Juicy",
                                ),
                                DropdownMenuEntry(
                                  value: .creative,
                                  leadingIcon: const IconLegacy(
                                    Symbols.draw_abstract_rounded,
                                    fill: 1.0,
                                  ),
                                  label: "Creative",
                                ),
                              ],
                              onSelected: (value) {
                                if (value != null) {
                                  settings.themeVariant.value = value;
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Flex.horizontal(
                    spacing: 2.0,
                    children: [
                      Flexible.tight(
                        key: const ValueKey("appSortBy"),
                        child: DropdownMenuFormField<SortColumnSettings>(
                          inputDecorationTheme: InputDecorationThemeData(
                            contentPadding: const .symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            border: CornersInputBorder.rounded(
                              corners: .directional(
                                topStart: shapeTheme.corner.large,
                                topEnd: shapeTheme.corner.extraSmall,
                                bottomStart: shapeTheme.corner.extraSmall,
                                bottomEnd: shapeTheme.corner.extraSmall,
                              ),
                            ),
                            filled: true,
                            fillColor: colorTheme.surface,
                          ),
                          expandedInsets: .zero,
                          label: Text(tr("appSortBy")),
                          initialSelection: settingsProvider.sortColumn,
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: .authorName,
                              label: tr("authorName"),
                            ),
                            DropdownMenuEntry(
                              value: .nameAuthor,
                              label: tr("nameAuthor"),
                            ),
                            DropdownMenuEntry(
                              value: .added,
                              label: tr("asAdded"),
                            ),
                            DropdownMenuEntry(
                              value: .releaseDate,
                              label: tr("releaseDate"),
                            ),
                          ],
                          onSelected: (value) {
                            if (value != null) {
                              settingsProvider.sortColumn = value;
                            }
                          },
                        ),
                      ),
                      Flexible.tight(
                        key: const ValueKey("appSortOrder"),
                        child: DropdownMenuFormField<SortOrderSettings>(
                          inputDecorationTheme: InputDecorationThemeData(
                            contentPadding: const .symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            border: CornersInputBorder.rounded(
                              corners: .directional(
                                topStart: shapeTheme.corner.extraSmall,
                                topEnd: shapeTheme.corner.large,
                                bottomStart: shapeTheme.corner.extraSmall,
                                bottomEnd: shapeTheme.corner.extraSmall,
                              ),
                            ),
                            filled: true,
                            fillColor: colorTheme.surface,
                          ),
                          expandedInsets: .zero,
                          label: Text(tr("appSortOrder")),
                          initialSelection: settingsProvider.sortOrder,
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                              value: .ascending,
                              label: tr("ascending"),
                            ),
                            DropdownMenuEntry(
                              value: .descending,
                              label: tr("descending"),
                            ),
                          ],
                          onSelected: (value) {
                            if (value != null) {
                              settingsProvider.sortOrder = value;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("showAppWebpage"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.showAppWebpage,
                      builder: (context, showAppWebpage, _) =>
                          ListItemTheme.merge(
                            data: showAppWebpage
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () => settingsProvider.showAppWebpage =
                                      !showAppWebpage,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(tr("showWebInAppView")),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider.showAppWebpage =
                                                value,
                                        checked: showAppWebpage,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("pinUpdates"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.pinUpdates,
                      builder: (context, pinUpdates, _) => ListItemTheme.merge(
                        data: pinUpdates
                            ? selectedListItemTheme
                            : unselectedListItemTheme,
                        child: ListItemContainer(
                          child: MergeSemantics(
                            child: ListItemInteraction(
                              onTap: () =>
                                  settingsProvider.pinUpdates = !pinUpdates,
                              child: ListItemLayout(
                                padding: const .fromLTRB(
                                  16.0,
                                  0.0,
                                  16.0 - 8.0,
                                  0.0,
                                ),
                                trailingPadding: const .symmetric(
                                  vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                ),
                                headline: Text(tr("pinUpdates")),
                                trailing: ExcludeFocus(
                                  child: Switch(
                                    onCheckedChanged: (value) =>
                                        settingsProvider.pinUpdates = value,
                                    checked: pinUpdates,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("buryNonInstalled"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.buryNonInstalled,
                      builder: (context, buryNonInstalled, _) =>
                          ListItemTheme.merge(
                            data: buryNonInstalled
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider.buryNonInstalled =
                                          !buryNonInstalled,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(
                                      tr("moveNonInstalledAppsToBottom"),
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider.buryNonInstalled =
                                                value,
                                        checked: buryNonInstalled,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("groupByCategory"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.groupByCategory,
                      builder: (context, groupByCategory, _) =>
                          ListItemTheme.merge(
                            data: groupByCategory
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider.groupByCategory =
                                          !groupByCategory,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(tr("groupByCategory")),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider.groupByCategory =
                                                value,
                                        checked: groupByCategory,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("hideTrackOnlyWarning"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.hideTrackOnlyWarning,
                      builder: (context, hideTrackOnlyWarning, _) =>
                          ListItemTheme.merge(
                            data: settingsProvider.hideTrackOnlyWarning
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider.hideTrackOnlyWarning =
                                          !hideTrackOnlyWarning,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(
                                      tr("dontShowTrackOnlyWarnings"),
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider
                                                    .hideTrackOnlyWarning =
                                                value,
                                        checked: hideTrackOnlyWarning,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("hideAPKOriginWarning"),
                    child: Selector<SettingsProvider, bool>(
                      selector: (context, settingsProvider) =>
                          settingsProvider.hideAPKOriginWarning,
                      builder: (context, hideAPKOriginWarning, _) =>
                          ListItemTheme.merge(
                            data: hideAPKOriginWarning
                                ? selectedListItemTheme
                                : unselectedListItemTheme,
                            child: ListItemContainer(
                              isLast: true,
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider.hideAPKOriginWarning =
                                          !hideAPKOriginWarning,
                                  child: ListItemLayout(
                                    padding: const .fromLTRB(
                                      16.0,
                                      0.0,
                                      16.0 - 8.0,
                                      0.0,
                                    ),
                                    trailingPadding: const .symmetric(
                                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    headline: Text(
                                      tr("dontShowAPKOriginWarnings"),
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider
                                                    .hideAPKOriginWarning =
                                                value,
                                        checked: hideAPKOriginWarning,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const CategoryEditorSelector(showLabelWhenNotEmpty: false),
                  const SizedBox(height: 16.0),
                  KeyedSubtree(
                    key: const ValueKey("appSource"),
                    child: ListItemTheme.merge(
                      data: unselectedListItemTheme,
                      child: ListItemContainer(
                        isFirst: true,
                        child: ListItemInteraction(
                          onTap: () => launchUrlString(
                            SettingsProvider.sourceUrl,
                            mode: LaunchMode.externalApplication,
                          ),
                          child: ListItemLayout(
                            leading: const Icon(Symbols.code_rounded),
                            headline: Text(tr("appSource")),
                            trailing: const Icon(
                              Symbols.keyboard_arrow_right_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("wiki"),
                    child: ListItemTheme.merge(
                      data: unselectedListItemTheme,
                      child: ListItemContainer(
                        child: ListItemInteraction(
                          onTap: () => launchUrlString(
                            "https://wiki.obtainium.imranr.dev/",
                            mode: LaunchMode.externalApplication,
                          ),
                          child: ListItemLayout(
                            leading: const Icon(
                              Symbols.help_rounded,
                              fill: 1.0,
                            ),
                            headline: Text(tr("wiki")),
                            trailing: const Icon(
                              Symbols.keyboard_arrow_right_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("crowdsourcedConfigs"),
                    child: ListItemTheme.merge(
                      data: unselectedListItemTheme,
                      child: ListItemContainer(
                        child: ListItemInteraction(
                          onTap: () => launchUrlString(
                            "https://apps.obtainium.imranr.dev/",
                            mode: LaunchMode.externalApplication,
                          ),
                          child: ListItemLayout(
                            leading: const Icon(Symbols.apps_rounded),
                            headline: Text(tr("crowdsourcedConfigsLabel")),
                            trailing: const Icon(
                              Symbols.keyboard_arrow_right_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  KeyedSubtree(
                    key: const ValueKey("appLogs"),
                    child: ListItemTheme.merge(
                      data: unselectedListItemTheme,
                      child: ListItemContainer(
                        isLast: true,
                        child: ListItemInteraction(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const _LogsPage(),
                            ),
                          ),
                          child: ListItemLayout(
                            leading: const Icon(
                              Symbols.bug_report_rounded,
                              fill: 1.0,
                            ),
                            headline: Text(tr("appLogs")),
                            trailing: const Icon(
                              Symbols.keyboard_arrow_right_rounded,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const .symmetric(horizontal: 8.0),
              sliver: ListItemTheme.merge(
                data: CustomThemeFactory.createListItemTheme(
                  colorTheme: colorTheme,
                  elevationTheme: elevationTheme,
                  shapeTheme: shapeTheme,
                  stateTheme: stateTheme,
                  typescaleTheme: typescaleTheme,
                  variant: .settings,
                ),
                child: SliverList.list(
                  children: [
                    // ListItemContainer(
                    //   isFirst: true,
                    //   child: ListItemInteraction(
                    //     onTap: () {},
                    //     child: ListItemLayout(
                    //       leading: SettingsListItemLeading.fromExtendedColor(
                    //         extendedColor: staticColors.red,
                    //         pairing: _defaultPairing,
                    //         containerShape: RoundedPolygonBorder(
                    //           polygon: MaterialShapes.circle,
                    //         ),
                    //         child: const Icon(Symbols.info_rounded, fill: 1.0),
                    //       ),
                    //       headline: Text("About Materium"),
                    //       supportingText: Text(
                    //         "Information, socials and contributors",
                    //       ),
                    //       trailing: const Icon(
                    //         Symbols.keyboard_arrow_right_rounded,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 2.0),
                    // ListItemContainer(
                    //   child: ListItemInteraction(
                    //     onTap: () {},
                    //     child: ListItemLayout(
                    //       leading: SettingsListItemLeading.fromExtendedColor(
                    //         extendedColor: staticColors.red,
                    //         pairing: _defaultPairing,
                    //         containerShape: RoundedPolygonBorder(
                    //           polygon: MaterialShapes.clover8Leaf,
                    //         ),
                    //         child: const Icon(Symbols.support_rounded, fill: 1.0),
                    //       ),
                    //       headline: Text("Help & support"),
                    //       supportingText: Text(
                    //         "Get help, report a bug or request a feature",
                    //       ),
                    //       trailing: const Icon(
                    //         Symbols.keyboard_arrow_right_rounded,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 16.0),
                    ValueListenableBuilder(
                      key: const ValueKey("developerMode"),
                      valueListenable: settings.developerMode,
                      builder: (context, developerMode, _) {
                        final isDisabled = !developerMode;
                        final containerColor = isDisabled
                            ? disabledContainerColor
                            : null;
                        final contentColor = isDisabled
                            ? disabledContentColor
                            : null;
                        return ListItemContainer(
                          isFirst: true,
                          isLast: true,
                          child: IntrinsicHeight(
                            child: Flex.horizontal(
                              crossAxisAlignment: .stretch,
                              children: [
                                Flexible.tight(
                                  child: Tooltip(
                                    message: isDisabled
                                        ? t
                                              .settingsPage
                                              .items
                                              .developerMode
                                              .disabledTooltip
                                        : "",
                                    child: ListItemInteraction(
                                      stateLayerShape: .all(
                                        CornersBorder.rounded(
                                          corners:
                                              CornersDirectional.horizontal(
                                                end: shapeTheme
                                                    .corner
                                                    .extraSmall,
                                              ),
                                        ),
                                      ),
                                      onTap: developerMode
                                          ? () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const DeveloperPage(),
                                              ),
                                            )
                                          : null,
                                      child: ListItemLayout(
                                        padding: const .directional(
                                          start: 16.0,
                                          end: 12.0,
                                        ),
                                        leading:
                                            SettingsListItemLeading.fromExtendedColor(
                                              extendedColor:
                                                  staticColors.purple,
                                              pairing: _defaultPairing,
                                              containerShape:
                                                  RoundedPolygonBorder(
                                                    polygon: MaterialShapes
                                                        .pixelCircle,
                                                  ),
                                              containerColor: containerColor,
                                              contentColor: contentColor,
                                              child: const Icon(
                                                Symbols.developer_mode_rounded,
                                                fill: 1.0,
                                              ),
                                            ),
                                        headline: Text(
                                          t
                                              .settingsPage
                                              .items
                                              .developerMode
                                              .label,
                                          style: TextStyle(color: contentColor),
                                        ),
                                        supportingText: Text(
                                          t
                                              .settingsPage
                                              .items
                                              .developerMode
                                              .description,
                                          style: TextStyle(color: contentColor),
                                        ),
                                        trailing: Icon(
                                          Symbols.keyboard_arrow_right_rounded,
                                          color: contentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  thickness: 1.0,
                                  width: 1.0,
                                  indent: 10.0,
                                  endIndent: 10.0,
                                  color: colorTheme.outlineVariant,
                                ),
                                ListItemInteraction(
                                  stateLayerShape: .all(
                                    CornersBorder.rounded(
                                      corners: CornersDirectional.horizontal(
                                        start: shapeTheme.corner.extraSmall,
                                      ),
                                    ),
                                  ),
                                  onTap: () => settings.developerMode.value =
                                      !developerMode,
                                  child: Padding(
                                    padding: const .fromSTEB(
                                      12.0 - 8.0,
                                      (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                      16.0 - 8.0,
                                      (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                    ),
                                    child: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged:
                                            settings.developerMode.setValue,
                                        checked: developerMode,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
          ],
        ),
      ),
    );
  }

  static const _defaultPairing = ExtendedColorPairing.variantOnFixed;
}

class _SettingsLanguageView extends StatefulWidget {
  const _SettingsLanguageView({super.key});

  @override
  State<_SettingsLanguageView> createState() => _SettingsLanguageViewState();
}

class _SettingsLanguageViewState extends State<_SettingsLanguageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [CustomAppBar(type: .small, title: Text(tr("language")))],
        ),
      ),
    );
  }
}

class CategoryEditorSelector extends StatefulWidget {
  const CategoryEditorSelector({
    super.key,
    this.onSelected,
    this.singleSelect = false,
    this.preselected = const {},
    this.alignment = WrapAlignment.start,
    this.showLabelWhenNotEmpty = true,
  });

  final void Function(List<String> categories)? onSelected;
  final bool singleSelect;
  final Set<String> preselected;
  final WrapAlignment alignment;
  final bool showLabelWhenNotEmpty;

  @override
  State<CategoryEditorSelector> createState() => _CategoryEditorSelectorState();
}

class _CategoryEditorSelectorState extends State<CategoryEditorSelector> {
  var _storedValues = <String, MapEntry<int, bool>>{};

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final appsProvider = context.watch<AppsProvider>();

    _storedValues = settingsProvider.categories.map(
      (key, value) => MapEntry(
        key,
        MapEntry(
          value,
          _storedValues[key]?.value ?? widget.preselected.contains(key),
        ),
      ),
    );

    return GeneratedForm(
      onValueChanges: ((values, valid, isBuilding) {
        if (!isBuilding) {
          _storedValues =
              values["categories"] as Map<String, MapEntry<int, bool>>;
          settingsProvider.setCategories(
            _storedValues.map((key, value) => MapEntry(key, value.key)),
            appsProvider: appsProvider,
          );
          if (widget.onSelected != null) {
            widget.onSelected!(
              _storedValues.keys.where((k) => _storedValues[k]!.value).toList(),
            );
          }
        }
      }),
      items: [
        [
          GeneratedFormTagInput(
            "categories",
            label: tr("categories"),
            emptyMessage: tr("noCategories"),
            defaultValue: _storedValues,
            alignment: widget.alignment,
            deleteConfirmationMessage: MapEntry(
              tr("deleteCategoriesQuestion"),
              tr("categoryDeleteWarning"),
            ),
            singleSelect: widget.singleSelect,
            showLabelWhenNotEmpty: widget.showLabelWhenNotEmpty,
          ),
        ],
      ],
    );
  }
}

class _LogsPage extends StatefulWidget {
  const _LogsPage({super.key});

  @override
  State<_LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<_LogsPage> {
  static const List<int> _days = <int>[7, 5, 4, 3, 2, 1];

  int _selectedDays = _days.first;

  late Stream<List<Log>> _logsDescending;

  MultiSelectable<Log> _selectLogs({
    int? days,
    required OrderingMode orderingMode,
  }) {
    final after = days != null
        ? DateTime.now().subtract(Duration(days: days))
        : null;
    return LogsProvider.instance.select(
      after: after,
      orderingMode: orderingMode,
    );
  }

  void _refreshLogs() {
    _logsDescending = _selectLogs(
      days: _selectedDays,
      orderingMode: .desc,
    ).watch();
  }

  String _buildLogsString(List<Log> logs) {
    if (logs.isEmpty) return tr("noLogs");

    final buffer = StringBuffer();
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i];
      final isLast = i == logs.length - 1;
      final text =
          "[${log.level.name.toUpperCase()}] "
          "(${log.createdAt}) "
          "${log.message}"
          "${!isLast ? "\n\n" : ""}";
      buffer.write(text);
    }
    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    final logsProvider = LogsProvider.instance;
    final settings = context.read<SettingsService>();

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final staticColors = StaticColors.of(context);

    final actionButtonStyle = LegacyThemeFactory.createButtonStyle(
      colorTheme: colorTheme,
      elevationTheme: elevationTheme,
      shapeTheme: shapeTheme,
      stateTheme: stateTheme,
      typescaleTheme: typescaleTheme,
      size: .medium,
      shape: .square,
      color: .filled,
    );

    final developerButtonStyle = LegacyThemeFactory.createButtonStyle(
      colorTheme: colorTheme,
      elevationTheme: elevationTheme,
      shapeTheme: shapeTheme,
      stateTheme: stateTheme,
      typescaleTheme: typescaleTheme,
      size: .small,
      shape: .round,
      color: .tonal,
    );

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CustomAppBar(
              type: .small,
              expandedContainerColor: colorTheme.surfaceContainer,
              collapsedContainerColor: colorTheme.surfaceContainer,
              collapsedPadding: const .fromSTEB(
                8.0 + 40.0 + 8.0,
                0.0,
                16.0,
                0.0,
              ),
              leading: const Padding(
                padding: .fromSTEB(8.0 - 4.0, 0.0, 8.0 - 4.0, 0.0),
                child: DeveloperPageBackButton(),
              ),
              title: Text(tr("appLogs")),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
              sliver: SliverList.list(
                children: [
                  DropdownMenuFormField<int>(
                    expandedInsets: EdgeInsets.zero,
                    inputDecorationTheme: const InputDecorationThemeData(
                      border: UnderlineInputBorder(),
                      filled: true,
                    ),
                    initialSelection: _selectedDays,
                    dropdownMenuEntries: _days
                        .map(
                          (e) => DropdownMenuEntry(
                            value: e,
                            label: plural("day", e),
                          ),
                        )
                        .toList(),
                    onSelected: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDays = value;
                          _refreshLogs();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Flex.horizontal(
                    spacing: 8.0,
                    children: [
                      Flexible.tight(
                        child: FilledButton.icon(
                          style: actionButtonStyle,
                          onPressed: () async {
                            final result =
                                (await showDialog<Map<String, dynamic>?>(
                                  context: context,
                                  builder: (ctx) {
                                    return GeneratedFormModal(
                                      title: tr("appLogs"),
                                      items: const [],
                                      initValid: true,
                                      message: tr("removeFromObtainium"),
                                    );
                                  },
                                )) !=
                                null;
                            if (result) {
                              logsProvider.clear();
                            }
                          },
                          icon: const IconLegacy(
                            Symbols.delete_forever_rounded,
                            fill: 1.0,
                          ),
                          label: Text(tr("remove")),
                        ),
                      ),
                      Flexible.tight(
                        child: FilledButton.icon(
                          style: actionButtonStyle,
                          onPressed: () async {
                            final logsAscending = await _selectLogs(
                              orderingMode: OrderingMode.asc,
                            ).get();
                            await SharePlus.instance.share(
                              ShareParams(
                                text: _buildLogsString(logsAscending),
                                subject: tr("appLogs"),
                              ),
                            );
                          },
                          icon: const IconLegacy(
                            Symbols.share_rounded,
                            fill: 1.0,
                          ),
                          label: Text(tr("share")),
                        ),
                      ),
                    ],
                  ),
                  ValueListenableBuilder(
                    valueListenable: settings.developerMode,
                    builder: (context, developerMode, _) => developerMode
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(
                              0.0,
                              16.0 - 4.0,
                              0.0,
                              16.0 - 4.0,
                            ),
                            child: FilledButton.icon(
                              style: developerButtonStyle,
                              onPressed: () async {
                                for (final level in LogLevels.values) {
                                  await LogsProvider.instance.add(
                                    "Hello world!",
                                    level: level,
                                  );
                                }
                              },
                              icon: const IconLegacy(
                                Symbols.add_notes_rounded,
                                fill: 1.0,
                                size: 20.0,
                                opticalSize: 20.0,
                              ),
                              label: const Text("Add demo records"),
                            ),
                          )
                        : const SizedBox(height: 16.0),
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: _logsDescending,
              builder: (context, snapshot) {
                final logs = snapshot.data;
                const spacing = 2.0;
                return logs != null
                    ? SliverPadding(
                        padding: const .fromLTRB(8.0, 0.0, 8.0, 16.0),
                        sliver: ListItemTheme.merge(
                          data: CustomThemeFactory.createListItemTheme(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            variant: .logs,
                          ),
                          child: SliverList.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final isFirst = index == 0;
                              final isLast = index == logs.length - 1;

                              final icon = switch (log.level) {
                                .info => const Icon(
                                  Symbols.info_rounded,
                                  fill: 0.0,
                                ),
                                .warning => const Icon(
                                  Symbols.warning_rounded,
                                  fill: 1.0,
                                ),
                                .error => const Icon(
                                  Symbols.error_rounded,
                                  fill: 1.0,
                                ),
                                .debug => const Icon(
                                  Symbols.bug_report_rounded,
                                  fill: 1.0,
                                ),
                              };
                              final iconColor = switch (log.level) {
                                .info => staticColors.blue.color,
                                .warning => staticColors.yellow.color,
                                .error => staticColors.red.color,
                                .debug => staticColors.cyan.color,
                              };

                              return KeyedSubtree(
                                key: ValueKey(log.id),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    0.0,
                                    isFirst ? 0.0 : spacing / 2.0,
                                    0.0,
                                    isLast ? 0.0 : spacing / 2.0,
                                  ),
                                  child: Tooltip(
                                    message: "ID: ${log.id}",
                                    child: ListItemContainer(
                                      isFirst: isFirst,
                                      isLast: isLast,
                                      child: ListItemInteraction(
                                        onTap: () async {
                                          await Fluttertoast.showToast(
                                            msg: "Not yet implemented!",
                                            toastLength: Toast.LENGTH_SHORT,
                                          );
                                        },
                                        child: ListItemLayout(
                                          alignment: .top,
                                          leading: IconTheme.merge(
                                            data: IconThemeDataPartial.from(
                                              color: iconColor,
                                            ),
                                            child: icon,
                                          ),
                                          overline: Text("${log.createdAt}"),
                                          headline: Text(log.message),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
          ],
        ),
      ),
    );
  }
}

class CornersInputBorder extends InputBorder {
  const CornersInputBorder({
    super.borderSide = .none,
    required this.delegate,
    this.corners = .none,
  });

  const CornersInputBorder.rounded({
    super.borderSide = .none,
    this.corners = .none,
  }) : delegate = .rounded;

  const CornersInputBorder.cut({super.borderSide = .none, this.corners = .none})
    : delegate = .cut;

  const CornersInputBorder.superellipse({
    super.borderSide = .none,
    this.corners = .none,
  }) : delegate = .superellipse;

  final CornersBorderDelegate delegate;
  final CornersGeometry corners;

  @override
  CornersInputBorder scale(double t) => CornersInputBorder(
    borderSide: borderSide.scale(t),
    delegate: delegate.scale(t),
    corners: corners * t,
  );

  @override
  CornersInputBorder copyWith({
    BorderSide? borderSide,
    CornersBorderDelegate? delegate,
    CornersGeometry? corners,
  }) => CornersInputBorder(
    borderSide: borderSide ?? this.borderSide,
    delegate: delegate ?? this.delegate,
    corners: corners ?? this.corners,
  );

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => .all(borderSide.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      delegate.getInnerPath(
        rect: rect,
        side: borderSide,
        borderRadius: corners.resolve(textDirection).toBorderRadius(rect.size),
      );
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      delegate.getOuterPath(
        rect: rect,
        side: borderSide,
        borderRadius: corners.resolve(textDirection).toBorderRadius(rect.size),
      );

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {}

  @override
  String toString() =>
      "${objectRuntimeType(this, "CornersInputBorder")}"
      "(borderSide: $borderSide, delegate: $delegate, corners: $corners)";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is CornersInputBorder &&
          borderSide == other.borderSide &&
          delegate == other.delegate &&
          corners == other.corners;

  @override
  int get hashCode => Object.hash(runtimeType, borderSide, delegate, corners);
}
