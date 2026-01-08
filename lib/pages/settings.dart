import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:drift/drift.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material/material_shapes.dart';
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
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shizuku_apk_installer/shizuku_apk_installer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CustomListItemLeading extends StatelessWidget {
  const CustomListItemLeading({
    super.key,
    this.shrinkWrapHeight = false,
    this.containerShape,
    this.containerColor,
    this.contentColor,
    required this.child,
  });

  factory CustomListItemLeading.fromExtendedColor({
    required ExtendedColorPairing pairing,
    required ExtendedColor extendedColor,
    ShapeBorder? containerShape,
    Color? containerColor,
    Color? contentColor,
    required Widget child,
  }) => CustomListItemLeading(
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
    final shapeTheme = ShapeTheme.of(context);

    return SizedBox(
      width: 40.0,
      height: !shrinkWrapHeight ? 40.0 : null,
      child: Skeleton.leaf(
        child: Material.raw(
          clipBehavior: .antiAlias,
          borderOnForeground: false,
          shape:
              containerShape ??
              CornersBorder.rounded(corners: .all(shapeTheme.corner.full)),
          color: containerColor ?? Colors.transparent,
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
  final _sourceProvider = SourceProvider();
  late SettingsProvider _settingsProvider;
  late SettingsService _settings;

  late SplineInterpolation _updateIntervalInterpolator;

  var _updateInterval = 0;
  var _updateIntervalLabel = tr("neverManualOnly");
  var _showIntervalLabel = true;

  final _colorsNameMap = <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(obtainiumThemeColor): "Obtainium",
  };

  void _initUpdateIntervalInterpolator() {
    final nodes = <InterpolationNode>[
      for (var index = 0; index < _updateIntervalNodes.length; index++)
        InterpolationNode(
          x: index.toDouble() + 1.0,
          y: _updateIntervalNodes[index].toDouble(),
        ),
    ];
    _updateIntervalInterpolator = SplineInterpolation(nodes: nodes);
  }

  void _processIntervalSliderValue(double val) {
    if (val < 0.5) {
      _updateInterval = 0;
      _updateIntervalLabel = tr("neverManualOnly");
      return;
    }
    var valInterpolated = 0;
    if (val < 1) {
      valInterpolated = 15;
    } else {
      valInterpolated = _updateIntervalInterpolator.compute(val).round();
    }
    if (valInterpolated < 60) {
      _updateInterval = valInterpolated;
      _updateIntervalLabel = plural("minute", valInterpolated);
    } else if (valInterpolated < 8 * 60) {
      final valRounded = (valInterpolated / 15).floor() * 15;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural("hour", valRounded ~/ 60);
      final mins = valRounded % 60;
      if (mins != 0) _updateIntervalLabel += " ${plural("minute", mins)}";
    } else if (valInterpolated < 24 * 60) {
      final valRounded = (valInterpolated / 30).floor() * 30;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural("hour", valRounded / 60);
    } else if (valInterpolated < 7 * 24 * 60) {
      final valRounded = (valInterpolated / (12 * 60)).floor() * 12 * 60;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural("day", valRounded / (24 * 60));
    } else {
      final valRounded = (valInterpolated / (24 * 60)).floor() * 24 * 60;
      _updateInterval = valRounded;
      _updateIntervalLabel = plural("day", valRounded ~/ (24 * 60));
    }
  }

  void _onUseShizukuChanged(bool useShizuku) {
    if (useShizuku) {
      ShizukuApkInstaller.checkPermission().then((resCode) {
        _settingsProvider.useShizuku = resCode!.startsWith("granted");
        if (!mounted) return;
        switch (resCode) {
          case "binder_not_found":
            showError(ObtainiumError(tr("shizukuBinderNotFound")), context);
          case "old_shizuku":
            showError(ObtainiumError(tr("shizukuOld")), context);
          case "old_android_with_adb":
            showError(ObtainiumError(tr("shizukuOldAndroidWithADB")), context);
          case "denied":
            showError(ObtainiumError(tr("cancelled")), context);
        }
      });
    } else {
      _settingsProvider.useShizuku = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initUpdateIntervalInterpolator();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingsProvider = context.read<SettingsProvider>();
    _settings = context.read<SettingsService>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final height = MediaQuery.heightOf(context);
    final padding = MediaQuery.paddingOf(context);

    final t = Translations.of(context);

    final showBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final staticColors = StaticColors.of(context);

    Future<bool> colorPickerDialog() =>
        ColorPicker(
          mainAxisSize: .min,
          color: _settings.themeColor.value,
          onColorChanged: (value) => _settings.themeColor.value = value,
          actionButtons: const ColorPickerActionButtons(),
          padding: .zero,
          pickersEnabled: const {
            .both: false,
            .primary: false,
            .accent: false,
            .bw: false,
            .custom: true,
            .wheel: true,
          },
          pickerTypeLabels: {.custom: tr("standard"), .wheel: tr("custom")},
          wheelDiameter: 192,
          wheelSquareBorderRadius: 32,
          width: 48,
          height: 48,
          borderRadius: 24,
          spacing: 8,
          runSpacing: 8,
          enableShadesSelection: false,
          customColorSwatchesAndNames: _colorsNameMap,
          showMaterialName: true,
          showColorName: true,
          materialNameTextStyle: typescaleTheme.labelLarge.toTextStyle(
            color: colorTheme.onSurface,
          ),
          colorNameTextStyle: typescaleTheme.labelLarge.toTextStyle(
            color: colorTheme.onSurface,
          ),
          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
            longPressMenu: true,
          ),
          pickerTypeTextStyle: typescaleTheme.labelLarge.toTextStyle(
            color: colorTheme.onSecondaryContainer,
          ),
          selectedPickerTypeColor: colorTheme.secondary,
          selectedColorIcon: Symbols.check_rounded,
        ).showPickerDialog(
          context,
          constraints: BoxConstraints(
            minWidth: 280.0,
            maxWidth: 560.0,
            minHeight: 0.0,
            maxHeight: height * 2.0 / 3.0,
          ),
          titlePadding: const .fromLTRB(24.0, 24.0, 24.0, 16.0),
          contentPadding: const .symmetric(horizontal: 24.0),
          actionsPadding: const .symmetric(
            horizontal: 24.0,
            vertical: 24.0 - 4.0,
          ),
          title: Text(
            tr("selectX", args: [tr("colour").toLowerCase()]),
            textAlign: .center,
            style: typescaleTheme.titleLargeEmphasized.toTextStyle(
              color: colorTheme.onSurface,
            ),
          ),
        );

    void selectColor() async {
      final previousThemeColor = _settings.themeColor.value;
      final result = await colorPickerDialog();
      if (context.mounted && !result) {
        _settings.themeColor.value = previousThemeColor;
      }
    }

    final sourceSpecificFields = _sourceProvider.sources.map((e) {
      if (e.sourceConfigSettingFormItems.isNotEmpty) {
        return GeneratedForm(
          items: e.sourceConfigSettingFormItems.map((e) {
            if (e is GeneratedFormSwitch) {
              e.defaultValue = _settingsProvider.getSettingBool(e.key);
            } else {
              e.defaultValue = _settingsProvider.getSettingString(e.key);
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
                  _settingsProvider.setSettingBool(key, value == true);
                } else {
                  _settingsProvider.setSettingString(key, value ?? '');
                }
              });
            }
          },
          textFieldType: useBlackTheme ? .outlined : .filled,
        );
      } else {
        return const SizedBox.shrink();
      }
    });

    final containerOuterCorner = shapeTheme.corner.large;
    final containerInnerCorner = shapeTheme.corner.extraSmall;

    final disabledContainerColor = colorTheme.onSurface.withValues(alpha: 0.10);
    final disabledContentColor = colorTheme.onSurface.withValues(alpha: 0.38);

    final unselectedContainerColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surface;

    final selectedContainerColor = useBlackTheme
        ? colorTheme.primaryContainer
        : colorTheme.secondaryContainer;

    final unselectedOnContainerColor = useBlackTheme
        ? colorTheme.onSurface
        : colorTheme.onSurface;
    final unselectedOnContainerVariantColor = useBlackTheme
        ? colorTheme.onSurface
        : colorTheme.onSurfaceVariant;
    final selectedOnContainerColor = useBlackTheme
        ? colorTheme.onPrimaryContainer
        : colorTheme.onSecondaryContainer;
    final selectedOnContainerVariantColor = useBlackTheme
        ? colorTheme.onPrimaryContainer.withValues(alpha: 0.9)
        : colorTheme.onSecondaryContainer;

    final selectedListItemTheme = ListItemThemeDataPartial.from(
      containerColor: .all(selectedContainerColor),
      containerShape: .all(
        CornersBorder.rounded(
          corners: .all(shapeTheme.corner.large),
          // side: useBlackTheme
          //     ? BorderSide(width: 2.0, color: colorTheme.onPrimaryContainer)
          //     : .none,
        ),
      ),
      stateLayerColor: .all(
        useBlackTheme
            ? colorTheme.onPrimaryContainer
            : colorTheme.onSecondaryContainer,
      ),
      leadingIconTheme: .all(.from(color: selectedOnContainerVariantColor)),
      leadingTextStyle: .all(TextStyle(color: selectedOnContainerVariantColor)),
      overlineTextStyle: .all(
        TextStyle(color: selectedOnContainerVariantColor),
      ),
      headlineTextStyle: .all(
        typescaleTheme.bodyLargeEmphasized.toTextStyle(
          color: selectedOnContainerColor,
        ),
      ),
      supportingTextStyle: .all(
        TextStyle(color: selectedOnContainerVariantColor),
      ),
      trailingTextStyle: .all(
        TextStyle(color: selectedOnContainerVariantColor),
      ),
      trailingIconTheme: .all(.from(color: selectedOnContainerVariantColor)),
    );

    final unselectedListItemTheme = ListItemThemeDataPartial.from(
      containerColor: .all(unselectedContainerColor),
      containerShape: .resolveWith((states) {
        final CornersGeometry corners = switch (states) {
          _ when useBlackTheme => .all(containerOuterCorner),
          SegmentedListItemStates(isFirst: true, isLast: true) ||
          SelectableListItemStates(
            isSelected: true,
          ) => .all(containerOuterCorner),
          SegmentedListItemStates(isFirst: true) => .vertical(
            top: containerOuterCorner,
            bottom: containerInnerCorner,
          ),
          SegmentedListItemStates(isLast: true) => .vertical(
            top: containerInnerCorner,
            bottom: containerOuterCorner,
          ),
          _ => .all(containerInnerCorner),
        };
        return CornersBorder.rounded(corners: corners);
      }),
      leadingIconTheme: .all(
        .from(
          color: useBlackTheme
              ? colorTheme.primary
              : unselectedOnContainerVariantColor,
        ),
      ),
      leadingTextStyle: .all(
        TextStyle(color: unselectedOnContainerVariantColor),
      ),
      overlineTextStyle: .all(
        TextStyle(color: unselectedOnContainerVariantColor),
      ),
      headlineTextStyle: .all(typescaleTheme.bodyLargeEmphasized.toTextStyle()),
      supportingTextStyle: .all(
        TextStyle(color: unselectedOnContainerVariantColor),
      ),
      trailingTextStyle: .all(
        TextStyle(color: unselectedOnContainerVariantColor),
      ),
      trailingIconTheme: .all(.from(color: unselectedOnContainerVariantColor)),
    );

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    final Widget verticalSpace = const SizedBox(height: 2.0);

    final Widget updateIntervalSliderValWidget = KeyedSubtree(
      key: const ValueKey("updateIntervalSliderVal"),
      child: StatefulBuilder(
        builder: (context, setState) => Selector<SettingsProvider, double>(
          selector: (context, settingsProvider) =>
              settingsProvider.updateIntervalSliderVal,
          builder: (context, updateIntervalSliderVal, _) {
            _processIntervalSliderValue(updateIntervalSliderVal);
            final isSelected = updateIntervalSliderVal > 0.0;
            final activeIndicatorColor = useBlackTheme
                ? colorTheme.primary
                : isSelected
                ? colorTheme.secondary
                : colorTheme.primary;
            final trackColor = isSelected
                // TODO: pull value from watch spec
                ? useBlackTheme
                      ? colorTheme.surface.withValues(alpha: 0.3)
                      : colorTheme.surface
                : useBlackTheme
                ? colorTheme.primaryContainer
                : colorTheme.secondaryContainer;
            return ListItemTheme.merge(
              data: isSelected
                  ? selectedListItemTheme
                  : unselectedListItemTheme,
              child: ListItemContainer(
                isFirst: true,
                child: Flex.vertical(
                  crossAxisAlignment: .stretch,
                  children: [
                    ListItemLayout(
                      headline: Text(tr("bgUpdateCheckInterval")),
                      supportingText: Visibility.maintain(
                        visible: _showIntervalLabel,
                        child: Text(_updateIntervalLabel, maxLines: 1),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: activeIndicatorColor,
                          thumbColor: activeIndicatorColor,
                          inactiveTrackColor: trackColor,
                        ),
                        child: Slider(
                          value: updateIntervalSliderVal,
                          max: _updateIntervalNodes.length.toDouble(),
                          divisions: _updateIntervalNodes.length * 20,
                          label: _updateIntervalLabel,
                          onChanged: (value) {
                            _settingsProvider.updateIntervalSliderVal = value;
                            setState(() => _processIntervalSliderValue(value));
                          },
                          onChangeStart: (value) =>
                              setState(() => _showIntervalLabel = false),
                          onChangeEnd: (value) {
                            _settingsProvider.updateInterval = _updateInterval;
                            setState(() => _showIntervalLabel = true);
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
    );

    final Widget useFGServiceWidget = KeyedSubtree(
      key: const ValueKey("useFGService"),
      child: Selector<SettingsProvider, bool>(
        selector: (context, settingsProvider) => settingsProvider.useFGService,
        builder: (context, useFGService, _) => ListItemTheme.merge(
          data: useFGService ? selectedListItemTheme : unselectedListItemTheme,
          child: ListItemContainer(
            child: MergeSemantics(
              child: ListItemInteraction(
                onTap: () => _settingsProvider.useFGService = !useFGService,
                child: ListItemLayout(
                  padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                  trailingPadding: const .symmetric(
                    vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                  ),
                  headline: Text(tr("foregroundServiceExplanation")),
                  trailing: ExcludeFocus(
                    child: Switch(
                      onCheckedChanged: (value) =>
                          _settingsProvider.useFGService = value,
                      checked: useFGService,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget enableBackgroundUpdatesWidget = KeyedSubtree(
      key: const ValueKey("enableBackgroundUpdates"),
      child: Selector<SettingsProvider, bool>(
        selector: (context, settingsProvider) =>
            settingsProvider.enableBackgroundUpdates,
        builder: (context, enableBackgroundUpdates, _) => ListItemTheme.merge(
          data: enableBackgroundUpdates
              ? selectedListItemTheme
              : unselectedListItemTheme,
          child: ListItemContainer(
            child: Flex.vertical(
              crossAxisAlignment: .start,
              children: [
                MergeSemantics(
                  child: ListItemInteraction(
                    onTap: () => _settingsProvider.enableBackgroundUpdates =
                        !enableBackgroundUpdates,
                    child: ListItemLayout(
                      padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                      trailingPadding: const .symmetric(
                        vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                      ),
                      headline: Text(tr("enableBackgroundUpdates")),
                      trailing: ExcludeFocus(
                        child: Switch(
                          onCheckedChanged: (value) =>
                              _settingsProvider.enableBackgroundUpdates = value,
                          checked: enableBackgroundUpdates,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                  child: DefaultTextStyle(
                    style: TypescaleTheme.of(context).bodyMedium.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                    child: Flex.vertical(
                      crossAxisAlignment: .start,
                      spacing: 8.0,
                      children: [
                        Text(tr('backgroundUpdateReqsExplanation')),
                        Text(tr('backgroundUpdateLimitsExplanation')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final Widget bgUpdatesOnWiFiOnlyWidget = KeyedSubtree(
      key: const ValueKey("bgUpdatesOnWiFiOnly"),
      child: Selector<SettingsProvider, bool>(
        selector: (context, settingsProvider) =>
            settingsProvider.bgUpdatesOnWiFiOnly,
        builder: (context, bgUpdatesOnWiFiOnly, _) => ListItemTheme.merge(
          data: bgUpdatesOnWiFiOnly
              ? selectedListItemTheme
              : unselectedListItemTheme,
          child: ListItemContainer(
            child: MergeSemantics(
              child: ListItemInteraction(
                onTap: () => _settingsProvider.bgUpdatesOnWiFiOnly =
                    !bgUpdatesOnWiFiOnly,
                child: ListItemLayout(
                  padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                  trailingPadding: const .symmetric(
                    vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                  ),
                  headline: Text(tr("bgUpdatesOnWiFiOnly")),
                  trailing: ExcludeFocus(
                    child: Switch(
                      onCheckedChanged: (value) =>
                          _settingsProvider.bgUpdatesOnWiFiOnly = value,
                      checked: bgUpdatesOnWiFiOnly,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final Widget bgUpdatesWhileChargingOnlyWidget = KeyedSubtree(
      key: const ValueKey("bgUpdatesWhileChargingOnly"),
      child: Selector<SettingsProvider, bool>(
        selector: (context, settingsProvider) =>
            settingsProvider.bgUpdatesWhileChargingOnly,
        builder: (context, bgUpdatesWhileChargingOnly, _) =>
            ListItemTheme.merge(
              data: bgUpdatesWhileChargingOnly
                  ? selectedListItemTheme
                  : unselectedListItemTheme,
              child: ListItemContainer(
                child: MergeSemantics(
                  child: ListItemInteraction(
                    onTap: () => _settingsProvider.bgUpdatesWhileChargingOnly =
                        !bgUpdatesWhileChargingOnly,
                    child: ListItemLayout(
                      padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                      trailingPadding: const .symmetric(
                        vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                      ),
                      headline: Text(tr("bgUpdatesWhileChargingOnly")),
                      trailing: ExcludeFocus(
                        child: Switch(
                          onCheckedChanged: (value) =>
                              _settingsProvider.bgUpdatesWhileChargingOnly =
                                  value,
                          checked: bgUpdatesWhileChargingOnly,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ),
    );

    final listItems = <Widget>[
      updateIntervalSliderValWidget,
      Flex.vertical(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Selector<SettingsProvider, bool>(
            selector: (context, settingsProvider) =>
                settingsProvider.updateInterval > 0 &&
                ((DeviceInfo.androidInfo?.version.sdkInt ?? 0) >= 30 ||
                    settingsProvider.useShizuku),
            builder: (context, visible, child) => Visibility(
              visible: visible,
              maintainState: true,
              child: child!,
            ),
            child: Flex.vertical(
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                verticalSpace,
                useFGServiceWidget,
                verticalSpace,
                enableBackgroundUpdatesWidget,
                Selector<SettingsProvider, bool>(
                  selector: (context, settingsProvider) =>
                      settingsProvider.enableBackgroundUpdates,
                  builder: (context, enableBackgroundUpdates, child) =>
                      Visibility(
                        visible: enableBackgroundUpdates,
                        maintainState: true,
                        child: child!,
                      ),
                  child: Flex.vertical(
                    mainAxisSize: .min,
                    crossAxisAlignment: .stretch,
                    children: [
                      const SizedBox(height: 2.0),
                      bgUpdatesOnWiFiOnlyWidget,
                      const SizedBox(height: 2.0),
                      bgUpdatesWhileChargingOnlyWidget,
                    ],
                  ),
                ),
              ],
            ),
          ),
          verticalSpace,
          KeyedSubtree(
            key: const ValueKey("checkOnStart"),
            child: Selector<SettingsProvider, bool>(
              selector: (context, settingsProvider) =>
                  settingsProvider.checkOnStart,
              builder: (context, checkOnStart, _) => ListItemTheme.merge(
                data: checkOnStart
                    ? selectedListItemTheme
                    : unselectedListItemTheme,
                child: ListItemContainer(
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () =>
                          _settingsProvider.checkOnStart = !checkOnStart,
                      child: ListItemLayout(
                        padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                        trailingPadding: const .symmetric(
                          vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                        ),
                        headline: Text(tr("checkOnStart")),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                _settingsProvider.checkOnStart = value,
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
          verticalSpace,
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
                              _settingsProvider.checkUpdateOnDetailPage =
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
                            headline: Text(tr("checkUpdateOnDetailPage")),
                            trailing: ExcludeFocus(
                              child: Switch(
                                onCheckedChanged: (value) =>
                                    _settingsProvider.checkUpdateOnDetailPage =
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
          verticalSpace,
          KeyedSubtree(
            key: const ValueKey("onlyCheckInstalledOrTrackOnlyApps"),
            child: Selector<SettingsProvider, bool>(
              selector: (context, settingsProvider) =>
                  settingsProvider.onlyCheckInstalledOrTrackOnlyApps,
              builder: (context, onlyCheckInstalledOrTrackOnlyApps, _) =>
                  ListItemTheme.merge(
                    data: onlyCheckInstalledOrTrackOnlyApps
                        ? selectedListItemTheme
                        : unselectedListItemTheme,
                    child: ListItemContainer(
                      child: MergeSemantics(
                        child: ListItemInteraction(
                          onTap: () =>
                              _settingsProvider
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
                                    _settingsProvider
                                            .onlyCheckInstalledOrTrackOnlyApps =
                                        value,
                                checked: onlyCheckInstalledOrTrackOnlyApps,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          verticalSpace,
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
                            _settingsProvider.removeOnExternalUninstall =
                                !removeOnExternalUninstall,
                        child: ListItemLayout(
                          padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                          trailingPadding: const .symmetric(
                            vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                          ),
                          headline: Text(tr("removeOnExternalUninstall")),
                          trailing: ExcludeFocus(
                            child: Switch(
                              onCheckedChanged: (value) =>
                                  _settingsProvider.removeOnExternalUninstall =
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
          verticalSpace,
          KeyedSubtree(
            key: const ValueKey("parallelDownloads"),
            child: Selector<SettingsProvider, bool>(
              selector: (context, settingsProvider) =>
                  settingsProvider.parallelDownloads,
              builder: (context, parallelDownloads, _) => ListItemTheme.merge(
                data: parallelDownloads
                    ? selectedListItemTheme
                    : unselectedListItemTheme,
                child: ListItemContainer(
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => _settingsProvider.parallelDownloads =
                          !parallelDownloads,
                      child: ListItemLayout(
                        padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                        trailingPadding: const .symmetric(
                          vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                        ),
                        headline: Text(tr("parallelDownloads")),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                _settingsProvider.parallelDownloads = value,
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
          verticalSpace,
          KeyedSubtree(
            key: const ValueKey("beforeNewInstallsShareToAppVerifier"),
            child: Selector<SettingsProvider, bool>(
              selector: (context, settingsProvider) =>
                  settingsProvider.beforeNewInstallsShareToAppVerifier,
              builder: (context, beforeNewInstallsShareToAppVerifier, _) =>
                  ListItemTheme.merge(
                    data: beforeNewInstallsShareToAppVerifier
                        ? selectedListItemTheme
                        : unselectedListItemTheme,
                    child: ListItemContainer(
                      child: Flex.vertical(
                        crossAxisAlignment: .stretch,
                        children: [
                          MergeSemantics(
                            child: ListItemInteraction(
                              onTap: () =>
                                  _settingsProvider
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
                                  vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                                ),
                                headline: Text(
                                  tr("beforeNewInstallsShareToAppVerifier"),
                                ),
                                trailing: ExcludeFocus(
                                  child: Switch(
                                    onCheckedChanged: (value) =>
                                        _settingsProvider
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
                              leading: const Icon(Symbols.open_in_new_rounded),
                              supportingText: Text(tr("about")),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
          verticalSpace,
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
                      onTap: () => _onUseShizukuChanged(!useShizuku),
                      child: ListItemLayout(
                        padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                        trailingPadding: const .symmetric(
                          vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                        ),
                        headline: Text(tr("useShizuku")),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: _onUseShizukuChanged,
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
          verticalSpace,
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
                              _settingsProvider.shizukuPretendToBeGooglePlay =
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
                            headline: Text(tr("shizukuPretendToBeGooglePlay")),
                            trailing: ExcludeFocus(
                              child: Switch(
                                onCheckedChanged: (value) =>
                                    _settingsProvider
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
        ],
      ),
      const SizedBox(height: 16.0),
      Material(
        clipBehavior: .antiAlias,
        shape: CornersBorder.rounded(corners: .all(shapeTheme.corner.large)),
        color: unselectedContainerColor,
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
                    ? selectedContainerColor
                    : unselectedContainerColor,
              ),
              menuStyle: MenuStyle(
                maximumSize: WidgetStatePropertyAll(
                  Size(.infinity, math.min(280.0, height * 2.0 / 3.0)),
                ),
              ),
              expandedInsets: .zero,
              label: Text(tr("language")),
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              initialSelection: Outer(forcedLocale),
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  style: LegacyThemeFactory.createMenuButtonStyle(
                    colorTheme: colorTheme,
                    elevationTheme: elevationTheme,
                    shapeTheme: shapeTheme,
                    stateTheme: stateTheme,
                    typescaleTheme: typescaleTheme,
                    isFirst: true,
                    isLast: false,
                    isSelected: forcedLocale == null,
                  ),
                  value: const Outer(null),
                  label: tr("followSystem"),
                ),
                ...supportedLocales.mapIndexed(
                  (index, e) => DropdownMenuEntry(
                    style: LegacyThemeFactory.createMenuButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      isFirst: false,
                      isLast: index == supportedLocales.length - 1,
                      isSelected: e.key == forcedLocale,
                    ),
                    value: Outer(e.key),
                    label: e.value,
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == null) return;
                final resolvedValue = value.inner;
                _settingsProvider.forcedLocale = resolvedValue;
                if (resolvedValue != null) {
                  context.setLocale(resolvedValue);
                } else {
                  _settingsProvider.resetLocaleSafe(context);
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
          valueListenable: _settings.useBlackTheme,
          builder: (context, useBlackTheme, _) {
            final isDisabled =
                !DynamicColor.isDynamicColorAvailable() || useBlackTheme;
            return ValueListenableBuilder(
              valueListenable: _settings.useMaterialYou,
              builder: (context, useMaterialYou, _) {
                useMaterialYou = useMaterialYou && !isDisabled;
                final containerColor = isDisabled
                    ? disabledContainerColor
                    : null;
                final contentColor = isDisabled ? disabledContentColor : null;
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
                            ? () => _settings.useMaterialYou.value =
                                  !useMaterialYou
                            : null,
                        child: ListItemLayout(
                          padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
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
                                  ? _settings.useMaterialYou.setValue
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
            );
          },
        ),
      ),
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("useBlackTheme"),
        child: ValueListenableBuilder(
          valueListenable: _settings.useMaterialYou,
          builder: (context, useMaterialYou, _) {
            final isDisabled = useMaterialYou;
            final containerColor = isDisabled ? disabledContainerColor : null;
            final contentColor = isDisabled ? disabledContentColor : null;
            return ValueListenableBuilder(
              valueListenable: _settings.useBlackTheme,
              builder: (context, useBlackTheme, _) {
                useBlackTheme = useBlackTheme && !isDisabled;
                final textStyle = TextStyle(color: contentColor);
                return ListItemTheme.merge(
                  data: useBlackTheme
                      ? selectedListItemTheme
                      : unselectedListItemTheme,
                  child: ListItemContainer(
                    child: MergeSemantics(
                      child: ListItemInteraction(
                        onTap: !isDisabled
                            ? () =>
                                  _settings.useBlackTheme.value = !useBlackTheme
                            : null,
                        child: ListItemLayout(
                          padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                          trailingPadding: const .symmetric(
                            vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                          ),
                          headline: Text("Pure black theme", style: textStyle),
                          supportingText: Text(
                            "Feature is work-in-progress. Visual artifacts may occur.",
                            style: textStyle,
                          ),
                          trailing: ExcludeFocus(
                            child: Switch(
                              onCheckedChanged: !isDisabled
                                  ? _settings.useBlackTheme.setValue
                                  : null,
                              checked: useBlackTheme,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      KeyedSubtree(
        key: const ValueKey("selectColor"),
        child: ValueListenableBuilder(
          valueListenable: _settings.useMaterialYou,
          builder: (context, useMaterialYou, _) {
            useMaterialYou =
                useMaterialYou && DynamicColor.isDynamicColorAvailable();
            final isDisabled = useMaterialYou;
            final containerColor = isDisabled ? disabledContainerColor : null;
            final contentColor = isDisabled ? disabledContentColor : null;
            final textStyle = TextStyle(color: contentColor);
            return Padding(
              padding: const .only(top: 2.0),
              child: ValueListenableBuilder(
                valueListenable: _settings.themeColor,
                builder: (context, themeColor, _) {
                  final isSelected = themeColor != obtainiumThemeColor;
                  return ListItemTheme.merge(
                    data: !isDisabled && isSelected
                        ? selectedListItemTheme
                        : unselectedListItemTheme,
                    child: ListItemContainer(
                      child: ListItemInteraction(
                        onTap: !isDisabled ? selectColor : null,
                        child: ListItemLayout(
                          headline: Text(
                            tr("selectX", args: [tr("colour").toLowerCase()]),
                            style: textStyle,
                          ),
                          supportingText: Text(
                            "${ColorTools.nameThatColor(themeColor)} "
                            "(${ColorTools.materialNameAndCode(themeColor, colorSwatchNameMap: _colorsNameMap)})",
                            style: textStyle,
                          ),
                          trailing: ColorIndicator(
                            width: 40,
                            height: 40,
                            borderRadius: 20,
                            color: containerColor ?? themeColor,
                            onSelectFocus: false,
                            onSelect: !isDisabled ? selectColor : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("themeModeAndVariant"),
        child: Flex.horizontal(
          spacing: 2.0,
          children: [
            KeyedSubtree(
              key: const ValueKey("themeMode"),
              child: Flexible.tight(
                child: ValueListenableBuilder(
                  valueListenable: _settings.themeMode,
                  builder: (context, themeMode, _) {
                    final isSelected = themeMode != .system;
                    return DropdownMenuFormField<ThemeMode>(
                      inputDecorationTheme: InputDecorationThemeData(
                        contentPadding: const .symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        border: CornersInputBorder.rounded(
                          corners: isSelected
                              ? .all(shapeTheme.corner.large)
                              : .directional(
                                  topStart: shapeTheme.corner.extraSmall,
                                  topEnd: shapeTheme.corner.extraSmall,
                                  bottomStart: shapeTheme.corner.large,
                                  bottomEnd: shapeTheme.corner.extraSmall,
                                ),
                        ),
                        filled: true,
                        fillColor: isSelected
                            ? selectedContainerColor
                            : unselectedContainerColor,
                      ),
                      expandedInsets: .zero,
                      textStyle: typescaleTheme.bodyLarge.toTextStyle(),
                      label: Text(tr("theme")),
                      initialSelection: themeMode,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          style: LegacyThemeFactory.createMenuButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            isFirst: true,
                            isLast: false,
                            isSelected: themeMode == .system,
                          ),
                          value: .system,
                          leadingIcon: const IconLegacy(
                            Symbols.auto_mode_rounded,
                          ),
                          label: tr("followSystem"),
                        ),
                        DropdownMenuEntry(
                          style: LegacyThemeFactory.createMenuButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            isFirst: false,
                            isLast: false,
                            isSelected: themeMode == .light,
                          ),
                          value: .light,
                          leadingIcon: const IconLegacy(
                            Symbols.light_mode_rounded,
                          ),
                          label: tr("light"),
                        ),
                        DropdownMenuEntry(
                          style: LegacyThemeFactory.createMenuButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            isFirst: false,
                            isLast: true,
                            isSelected: themeMode == .dark,
                          ),
                          value: .dark,
                          leadingIcon: const IconLegacy(
                            Symbols.dark_mode_rounded,
                          ),
                          label: tr("dark"),
                        ),
                      ],
                      onSelected: (value) {
                        if (value != null) {
                          _settings.themeMode.value = value;
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            KeyedSubtree(
              key: const ValueKey("themeVariant"),
              child: Flexible.tight(
                child: ValueListenableBuilder(
                  valueListenable: _settings.themeVariant,
                  builder: (context, themeVariant, _) {
                    final isSelected =
                        themeVariant.dynamicSchemeVariant !=
                        ThemeVariant.system.dynamicSchemeVariant;
                    return DropdownMenuFormField<ThemeVariant>(
                      inputDecorationTheme: InputDecorationThemeData(
                        contentPadding: const .symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        border: CornersInputBorder.rounded(
                          corners: isSelected
                              ? .all(shapeTheme.corner.large)
                              : .directional(
                                  topStart: shapeTheme.corner.extraSmall,
                                  topEnd: shapeTheme.corner.extraSmall,
                                  bottomStart: shapeTheme.corner.extraSmall,
                                  bottomEnd: shapeTheme.corner.large,
                                ),
                        ),
                        filled: true,
                        fillColor: isSelected
                            ? selectedContainerColor
                            : unselectedContainerColor,
                      ),
                      expandedInsets: .zero,
                      textStyle: typescaleTheme.bodyLarge.toTextStyle(),
                      label: Text("Color scheme"),
                      initialSelection: themeVariant,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          style: LegacyThemeFactory.createMenuButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            isFirst: true,
                            isLast: false,
                            isSelected: themeVariant == .calm,
                          ),
                          value: .calm,
                          leadingIcon: const IconLegacy(
                            Symbols.moon_stars_rounded,
                            fill: 1.0,
                          ),
                          label: "Calm",
                        ),
                        DropdownMenuEntry(
                          style: LegacyThemeFactory.createMenuButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            isFirst: false,
                            isLast: false,
                            isSelected: themeVariant == .pastel,
                          ),
                          value: .pastel,
                          leadingIcon: const IconLegacy(
                            Symbols.brush_rounded,
                            fill: 1.0,
                          ),
                          label: "Pastel",
                        ),
                        DropdownMenuEntry(
                          style: LegacyThemeFactory.createMenuButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            isFirst: false,
                            isLast: false,
                            isSelected: themeVariant == .juicy,
                          ),
                          value: .juicy,
                          leadingIcon: const IconLegacy(
                            Symbols.nutrition_rounded,
                            fill: 1.0,
                          ),
                          label: "Juicy",
                        ),
                        DropdownMenuEntry(
                          style: LegacyThemeFactory.createMenuButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            typescaleTheme: typescaleTheme,
                            isFirst: false,
                            isLast: true,
                            isSelected: themeVariant == .creative,
                          ),
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
                          _settings.themeVariant.value = value;
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16.0),
      KeyedSubtree(
        key: const ValueKey("sortColumnAndOrder"),
        child: Flex.horizontal(
          spacing: 2.0,
          children: [
            KeyedSubtree(
              key: const ValueKey("sortColumn"),
              child: Flexible.tight(
                child: Selector<SettingsProvider, SortColumnSettings>(
                  selector: (context, settingsProvider) =>
                      settingsProvider.sortColumn,
                  builder: (context, sortColumn, _) =>
                      DropdownMenuFormField<SortColumnSettings>(
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
                          fillColor: unselectedContainerColor,
                        ),
                        expandedInsets: .zero,
                        label: Text(tr("appSortBy")),
                        initialSelection: sortColumn,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            style: LegacyThemeFactory.createMenuButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              typescaleTheme: typescaleTheme,
                              isFirst: true,
                              isLast: false,
                              isSelected: sortColumn == .authorName,
                            ),
                            value: .authorName,
                            label: tr("authorName"),
                          ),
                          DropdownMenuEntry(
                            style: LegacyThemeFactory.createMenuButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              typescaleTheme: typescaleTheme,
                              isFirst: false,
                              isLast: false,
                              isSelected: sortColumn == .nameAuthor,
                            ),
                            value: .nameAuthor,
                            label: tr("nameAuthor"),
                          ),
                          DropdownMenuEntry(
                            style: LegacyThemeFactory.createMenuButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              typescaleTheme: typescaleTheme,
                              isFirst: false,
                              isLast: false,
                              isSelected: sortColumn == .added,
                            ),
                            value: .added,
                            label: tr("asAdded"),
                          ),
                          DropdownMenuEntry(
                            style: LegacyThemeFactory.createMenuButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              typescaleTheme: typescaleTheme,
                              isFirst: false,
                              isLast: true,
                              isSelected: sortColumn == .releaseDate,
                            ),
                            value: .releaseDate,
                            label: tr("releaseDate"),
                          ),
                        ],
                        onSelected: (value) {
                          if (value != null) {
                            _settingsProvider.sortColumn = value;
                          }
                        },
                      ),
                ),
              ),
            ),
            KeyedSubtree(
              key: const ValueKey("sortOrder"),
              child: Flexible.tight(
                child: Selector<SettingsProvider, SortOrderSettings>(
                  selector: (context, settingsProvider) =>
                      settingsProvider.sortOrder,
                  builder: (context, sortOrder, _) =>
                      DropdownMenuFormField<SortOrderSettings>(
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
                          fillColor: unselectedContainerColor,
                        ),
                        expandedInsets: .zero,
                        label: Text(tr("appSortOrder")),
                        initialSelection: sortOrder,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            style: LegacyThemeFactory.createMenuButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              typescaleTheme: typescaleTheme,
                              isFirst: true,
                              isLast: false,
                              isSelected: sortOrder == .ascending,
                            ),
                            value: .ascending,
                            label: tr("ascending"),
                          ),
                          DropdownMenuEntry(
                            style: LegacyThemeFactory.createMenuButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              typescaleTheme: typescaleTheme,
                              isFirst: false,
                              isLast: true,
                              isSelected: sortOrder == .descending,
                            ),
                            value: .descending,
                            label: tr("descending"),
                          ),
                        ],
                        onSelected: (value) {
                          if (value != null) {
                            _settingsProvider.sortOrder = value;
                          }
                        },
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("showAppWebpage"),
        child: Selector<SettingsProvider, bool>(
          selector: (context, settingsProvider) =>
              settingsProvider.showAppWebpage,
          builder: (context, showAppWebpage, _) => ListItemTheme.merge(
            data: showAppWebpage
                ? selectedListItemTheme
                : unselectedListItemTheme,
            child: ListItemContainer(
              child: MergeSemantics(
                child: ListItemInteraction(
                  onTap: () =>
                      _settingsProvider.showAppWebpage = !showAppWebpage,
                  child: ListItemLayout(
                    padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                    trailingPadding: const .symmetric(
                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                    ),
                    headline: Text(tr("showWebInAppView")),
                    trailing: ExcludeFocus(
                      child: Switch(
                        onCheckedChanged: (value) =>
                            _settingsProvider.showAppWebpage = value,
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
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("pinUpdates"),
        child: Selector<SettingsProvider, bool>(
          selector: (context, settingsProvider) => settingsProvider.pinUpdates,
          builder: (context, pinUpdates, _) => ListItemTheme.merge(
            data: pinUpdates ? selectedListItemTheme : unselectedListItemTheme,
            child: ListItemContainer(
              child: MergeSemantics(
                child: ListItemInteraction(
                  onTap: () => _settingsProvider.pinUpdates = !pinUpdates,
                  child: ListItemLayout(
                    padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                    trailingPadding: const .symmetric(
                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                    ),
                    headline: Text(tr("pinUpdates")),
                    trailing: ExcludeFocus(
                      child: Switch(
                        onCheckedChanged: (value) =>
                            _settingsProvider.pinUpdates = value,
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
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("buryNonInstalled"),
        child: Selector<SettingsProvider, bool>(
          selector: (context, settingsProvider) =>
              settingsProvider.buryNonInstalled,
          builder: (context, buryNonInstalled, _) => ListItemTheme.merge(
            data: buryNonInstalled
                ? selectedListItemTheme
                : unselectedListItemTheme,
            child: ListItemContainer(
              child: MergeSemantics(
                child: ListItemInteraction(
                  onTap: () =>
                      _settingsProvider.buryNonInstalled = !buryNonInstalled,
                  child: ListItemLayout(
                    padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                    trailingPadding: const .symmetric(
                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                    ),
                    headline: Text(tr("moveNonInstalledAppsToBottom")),
                    trailing: ExcludeFocus(
                      child: Switch(
                        onCheckedChanged: (value) =>
                            _settingsProvider.buryNonInstalled = value,
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
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("groupByCategory"),
        child: Selector<SettingsProvider, bool>(
          selector: (context, settingsProvider) =>
              settingsProvider.groupByCategory,
          builder: (context, groupByCategory, _) => ListItemTheme.merge(
            data: groupByCategory
                ? selectedListItemTheme
                : unselectedListItemTheme,
            child: ListItemContainer(
              child: MergeSemantics(
                child: ListItemInteraction(
                  onTap: () =>
                      _settingsProvider.groupByCategory = !groupByCategory,
                  child: ListItemLayout(
                    padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                    trailingPadding: const .symmetric(
                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                    ),
                    headline: Text(tr("groupByCategory")),
                    trailing: ExcludeFocus(
                      child: Switch(
                        onCheckedChanged: (value) =>
                            _settingsProvider.groupByCategory = value,
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
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("hideTrackOnlyWarning"),
        child: Selector<SettingsProvider, bool>(
          selector: (context, settingsProvider) =>
              settingsProvider.hideTrackOnlyWarning,
          builder: (context, hideTrackOnlyWarning, _) => ListItemTheme.merge(
            data: _settingsProvider.hideTrackOnlyWarning
                ? selectedListItemTheme
                : unselectedListItemTheme,
            child: ListItemContainer(
              child: MergeSemantics(
                child: ListItemInteraction(
                  onTap: () => _settingsProvider.hideTrackOnlyWarning =
                      !hideTrackOnlyWarning,
                  child: ListItemLayout(
                    padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                    trailingPadding: const .symmetric(
                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                    ),
                    headline: Text(tr("dontShowTrackOnlyWarnings")),
                    trailing: ExcludeFocus(
                      child: Switch(
                        onCheckedChanged: (value) =>
                            _settingsProvider.hideTrackOnlyWarning = value,
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
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("hideAPKOriginWarning"),
        child: Selector<SettingsProvider, bool>(
          selector: (context, settingsProvider) =>
              settingsProvider.hideAPKOriginWarning,
          builder: (context, hideAPKOriginWarning, _) => ListItemTheme.merge(
            data: hideAPKOriginWarning
                ? selectedListItemTheme
                : unselectedListItemTheme,
            child: ListItemContainer(
              isLast: true,
              child: MergeSemantics(
                child: ListItemInteraction(
                  onTap: () => _settingsProvider.hideAPKOriginWarning =
                      !hideAPKOriginWarning,
                  child: ListItemLayout(
                    padding: const .fromLTRB(16.0, 0.0, 16.0 - 8.0, 0.0),
                    trailingPadding: const .symmetric(
                      vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                    ),
                    headline: Text(tr("dontShowAPKOriginWarnings")),
                    trailing: ExcludeFocus(
                      child: Switch(
                        onCheckedChanged: (value) =>
                            _settingsProvider.hideAPKOriginWarning = value,
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
      Material(
        clipBehavior: .antiAlias,
        shape: CornersBorder.rounded(corners: .all(shapeTheme.corner.large)),
        color: unselectedContainerColor,
        child: const Padding(
          padding: .all(16.0),
          child: CategoryEditorSelector(
            showLabelWhenNotEmpty: false,
            singleSelect: true,
            alignment: .start,
          ),
        ),
      ),
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
                trailing: const Icon(Symbols.keyboard_arrow_right_rounded),
              ),
            ),
          ),
        ),
      ),
      verticalSpace,
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
                leading: const Icon(Symbols.help_rounded, fill: 1.0),
                headline: Text(tr("wiki")),
                trailing: const Icon(Symbols.keyboard_arrow_right_rounded),
              ),
            ),
          ),
        ),
      ),
      verticalSpace,
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
                trailing: const Icon(Symbols.keyboard_arrow_right_rounded),
              ),
            ),
          ),
        ),
      ),
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("appLogs"),
        child: ListItemTheme.merge(
          data: unselectedListItemTheme,
          child: ListItemContainer(
            child: ListItemInteraction(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const _LogsPage(),
                ),
              ),
              child: ListItemLayout(
                leading: const Icon(Symbols.bug_report_rounded, fill: 1.0),
                headline: Text(tr("appLogs")),
                trailing: const Icon(Symbols.keyboard_arrow_right_rounded),
              ),
            ),
          ),
        ),
      ),
      verticalSpace,
      KeyedSubtree(
        key: const ValueKey("importExport"),
        child: ListItemTheme.merge(
          data: unselectedListItemTheme,
          child: ListItemContainer(
            isLast: true,
            child: ListItemInteraction(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ImportExportPage(),
                ),
              ),
              child: ListItemLayout(
                leading: const Icon(Symbols.swap_vert_rounded, fill: 1.0),
                headline: Text(tr("importExport")),
                trailing: const Icon(Symbols.keyboard_arrow_right_rounded),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16.0),
      const Divider(indent: 16.0, endIndent: 16.0, height: 0.0),
      const SizedBox(height: 16.0),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            CustomAppBar(
              type: showBackButton ? .small : .largeFlexible,
              expandedContainerColor: backgroundColor,
              collapsedContainerColor: backgroundColor,
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
                textAlign: !showBackButton ? .center : .start,
              ),
            ),
            SwitchTheme.merge(
              data: CustomThemeFactory.createSwitchTheme(
                colorTheme: colorTheme,
                shapeTheme: shapeTheme,
                stateTheme: stateTheme,
                size: useBlackTheme ? .black : .standard,
                color: useBlackTheme ? .black : .listItemPhone,
              ),
              // Using eager builds is actually faster for small lists!!!
              child: SliverToBoxAdapter(
                child: Padding(
                  padding: .fromLTRB(8.0, showBackButton ? 0.0 : 4.0, 8.0, 0.0),
                  child: Flex.vertical(
                    mainAxisSize: .min,
                    crossAxisAlignment: .stretch,
                    children: listItems,
                  ),
                ),
              ),
              // child: SliverPadding(
              //   padding: .fromLTRB(8.0, showBackButton ? 0.0 : 4.0, 8.0, 0.0),
              //   // TODO: fix switches reparenting (add ValueKey or GlobalKey to list items)
              //   sliver: SliverList.list(children: listItems),
              // ),
            ),
            ListItemTheme.merge(
              data: CustomThemeFactory.createListItemTheme(
                colorTheme: colorTheme,
                elevationTheme: elevationTheme,
                shapeTheme: shapeTheme,
                stateTheme: stateTheme,
                typescaleTheme: typescaleTheme,
                variant: .settings,
              ),
              child: SliverPadding(
                padding: const .symmetric(horizontal: 8.0),
                sliver: SliverList.list(
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
                      valueListenable: _settings.developerMode,
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
                          isLast: !developerMode,
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
                                              MaterialPageRoute<void>(
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
                                            CustomListItemLeading.fromExtendedColor(
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
                                  onTap: () => _settings.developerMode.value =
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
                                            _settings.developerMode.setValue,
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
                    ValueListenableBuilder(
                      valueListenable: _settings.developerMode,
                      builder: (context, developerMode, child) => developerMode
                          ? Padding(
                              padding: const .only(top: 2.0),
                              child: child,
                            )
                          : const SizedBox.shrink(),
                      child: ListItemContainer(
                        isLast: true,
                        child: ListItemInteraction(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const ImportExportPage(),
                            ),
                          ),
                          child: ListItemLayout(
                            leading: CustomListItemLeading.fromExtendedColor(
                              extendedColor: staticColors.purple,
                              pairing: _defaultPairing,
                              containerShape: RoundedPolygonBorder(
                                polygon: MaterialShapes.pill,
                              ),
                              child: const Icon(
                                Symbols.swap_vert_rounded,
                                fill: 1.0,
                              ),
                            ),
                            headline: Text(tr("importExport")),
                            trailing: const Icon(
                              Symbols.keyboard_arrow_right_rounded,
                            ),
                          ),
                        ),
                      ),
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

  static const List<int> _updateIntervalNodes = <int>[
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
    this.alignment = .start,
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

    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

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

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CustomAppBar(
              type: .small,
              expandedContainerColor: backgroundColor,
              collapsedContainerColor: backgroundColor,
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
                          (value) => DropdownMenuEntry(
                            style: LegacyThemeFactory.createMenuButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              typescaleTheme: typescaleTheme,
                              isSelected: value == _selectedDays,
                            ),
                            value: value,
                            label: plural("day", value),
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
