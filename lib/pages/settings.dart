import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:drift/drift.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:materium/theme/legacy.dart';
import 'package:materium/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shizuku_apk_installer/shizuku_apk_installer.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    final List<InterpolationNode> nodes = <InterpolationNode>[
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
      updateIntervalLabel = tr('neverManualOnly');
      return;
    }
    int valInterpolated = 0;
    if (val < 1) {
      valInterpolated = 15;
    } else {
      valInterpolated = updateIntervalInterpolator.compute(val).round();
    }
    if (valInterpolated < 60) {
      updateInterval = valInterpolated;
      updateIntervalLabel = plural('minute', valInterpolated);
    } else if (valInterpolated < 8 * 60) {
      int valRounded = (valInterpolated / 15).floor() * 15;
      updateInterval = valRounded;
      updateIntervalLabel = plural('hour', valRounded ~/ 60);
      int mins = valRounded % 60;
      if (mins != 0) updateIntervalLabel += " ${plural('minute', mins)}";
    } else if (valInterpolated < 24 * 60) {
      int valRounded = (valInterpolated / 30).floor() * 30;
      updateInterval = valRounded;
      updateIntervalLabel = plural('hour', valRounded / 60);
    } else if (valInterpolated < 7 * 24 * 60) {
      int valRounded = (valInterpolated / (12 * 60)).floor() * 12 * 60;
      updateInterval = valRounded;
      updateIntervalLabel = plural('day', valRounded / (24 * 60));
    } else {
      int valRounded = (valInterpolated / (24 * 60)).floor() * 24 * 60;
      updateInterval = valRounded;
      updateIntervalLabel = plural('day', valRounded ~/ (24 * 60));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final sourceProvider = SourceProvider();

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final staticColors = StaticColorsData.fallback(
      variant: DynamicSchemeVariant.tonalSpot,
      brightness: Theme.brightnessOf(context),
      specVersion: DynamicSchemeSpecVersion.spec2025,
    ).harmonizeWithPrimary(colorTheme);

    initUpdateIntervalInterpolator();
    processIntervalSliderValue(settingsProvider.updateIntervalSliderVal);

    void onUseShizukuChanged(bool useShizuku) {
      if (useShizuku) {
        ShizukuApkInstaller.checkPermission().then((resCode) {
          settingsProvider.useShizuku = resCode!.startsWith('granted');
          if (!context.mounted) return;
          switch (resCode) {
            case 'binder_not_found':
              showError(ObtainiumError(tr('shizukuBinderNotFound')), context);
            case 'old_shizuku':
              showError(ObtainiumError(tr('shizukuOld')), context);
            case 'old_android_with_adb':
              showError(
                ObtainiumError(tr('shizukuOldAndroidWithADB')),
                context,
              );
            case 'denied':
              showError(ObtainiumError(tr('cancelled')), context);
          }
        });
      } else {
        settingsProvider.useShizuku = false;
      }
    }

    Future<bool> colorPickerDialog() =>
        ColorPicker(
          color: settingsProvider.themeColor,
          onColorChanged: (color) =>
              setState(() => settingsProvider.themeColor = color),
          actionButtons: const ColorPickerActionButtons(
            okButton: true,
            closeButton: true,
            dialogActionButtons: false,
          ),
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: false,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
            ColorPickerType.bw: false,
            ColorPickerType.custom: true,
            ColorPickerType.wheel: true,
          },
          pickerTypeLabels: <ColorPickerType, String>{
            ColorPickerType.custom: tr('standard'),
            ColorPickerType.wheel: tr('custom'),
          },
          title: Text(
            tr('selectX', args: [tr('colour').toLowerCase()]),
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
            final curvedValue = Curves.easeInOutCubicEmphasized.transform(
              a1.value,
            );
            return Transform.scale(
              scale: curvedValue,
              alignment: Alignment.center,
              child: Opacity(opacity: curvedValue, child: widget),
            );
          },
        );

    void selectColor() async {
      final previousThemeColor = settingsProvider.themeColor;
      final result = await colorPickerDialog();
      if (context.mounted && !result) {
        setState(() => settingsProvider.themeColor = previousThemeColor);
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

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomScrollView(
        slivers: <Widget>[
          CustomAppBar(
            type: CustomAppBarType.largeFlexible,
            behavior: CustomAppBarBehavior.duplicate,
            expandedContainerColor: colorTheme.surfaceContainer,
            collapsedContainerColor: colorTheme.surfaceContainer,
            title: Text(tr("settings")),
            // subtitle: kDebugMode ? const Text("Debug mode") : null,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            // TODO: fix switches reparenting (add ValueKey or GlobalKey to list items)
            sliver: SliverList.list(
              children: [
                if (settingsProvider.developerModeV1) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Experimental",
                      style: typescaleTheme.labelLarge.toTextStyle(
                        color: colorTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ListItemContainer(
                    isFirst: true,
                    child: ListItemInteraction(
                      onTap: () async {
                        await Fluttertoast.showToast(
                          msg: "Not yet implemented!",
                          toastLength: Toast.LENGTH_SHORT,
                        );
                      },
                      child: ListItemLayout(
                        leading: SizedBox.square(
                          dimension: 40.0,
                          child: Material(
                            animationDuration: Duration.zero,
                            type: MaterialType.card,
                            clipBehavior: Clip.antiAlias,
                            color: staticColors.orange.colorFixed,
                            shape: const StadiumBorder(),
                            child: Align.center(
                              child: Icon(
                                Symbols.palette_rounded,
                                fill: 1.0,
                                color: staticColors.orange.onColorFixedVariant,
                              ),
                            ),
                          ),
                        ),
                        headline: const Text("Appearance"),
                        supportingText: const Text(
                          "User interface preferences",
                        ),
                        trailing: const Icon(
                          Symbols.keyboard_arrow_right_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  ListItemContainer(
                    child: ListItemInteraction(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImportExportPage(),
                        ),
                      ),
                      child: ListItemLayout(
                        leading: SizedBox.square(
                          dimension: 40.0,
                          child: Material(
                            animationDuration: Duration.zero,
                            type: MaterialType.card,
                            clipBehavior: Clip.antiAlias,
                            color: staticColors.blue.colorFixed,
                            shape: const StadiumBorder(),
                            child: Align.center(
                              child: Icon(
                                Symbols.sync_alt_rounded,
                                fill: 1.0,
                                color: staticColors.blue.onColorFixedVariant,
                              ),
                            ),
                          ),
                        ),
                        headline: const Text("Backup"),
                        supportingText: const Text(
                          "Import or export your Obtainium data",
                        ),
                        trailing: const Icon(
                          Symbols.keyboard_arrow_right_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  ListItemContainer(
                    child: MergeSemantics(
                      child: ListItemInteraction(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DeveloperPage(),
                          ),
                        ),
                        child: ListItemLayout(
                          isMultiline: true,
                          leading: SizedBox.square(
                            dimension: 40.0,
                            child: Material(
                              animationDuration: Duration.zero,
                              type: MaterialType.card,
                              clipBehavior: Clip.antiAlias,
                              color: staticColors.cyan.colorFixed,
                              shape: const StadiumBorder(),
                              child: Align.center(
                                child: Icon(
                                  Symbols.developer_mode_rounded,
                                  fill: 1.0,
                                  color: staticColors.cyan.onColorFixedVariant,
                                ),
                              ),
                            ),
                          ),
                          headline: const Text("Developer options"),
                          supportingText: const Text("Options for developers"),
                          trailing: const Icon(
                            Symbols.keyboard_arrow_right_rounded,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  ListItemContainer(
                    isLast: true,
                    child: ListItemInteraction(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      ),
                      child: ListItemLayout(
                        leading: SizedBox.square(
                          dimension: 40.0,
                          child: Material(
                            animationDuration: Duration.zero,
                            type: MaterialType.card,
                            clipBehavior: Clip.antiAlias,
                            color: staticColors.purple.colorFixed,
                            shape: const StadiumBorder(),
                            child: Align.center(
                              child: Icon(
                                Symbols.info_rounded,
                                fill: 1.0,
                                color: staticColors.purple.onColorFixedVariant,
                              ),
                            ),
                          ),
                        ),
                        headline: const Text("About"),
                        supportingText: const Text("App version and info"),
                        trailing: const Icon(
                          Symbols.keyboard_arrow_right_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    tr("updates"),
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                ListItemContainer(
                  isFirst: true,
                  child: Flex.vertical(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListItemLayout(
                        isMultiline: true,
                        headline: Text(tr("bgUpdateCheckInterval")),
                        supportingText: Visibility.maintain(
                          visible: showIntervalLabel,
                          child: Text(updateIntervalLabel, maxLines: 1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          16.0,
                          12.0,
                        ),
                        child: Slider(
                          value: settingsProvider.updateIntervalSliderVal,
                          max: updateIntervalNodes.length.toDouble(),
                          divisions: updateIntervalNodes.length * 20,
                          label: updateIntervalLabel,
                          onChanged: (value) => setState(() {
                            settingsProvider.updateIntervalSliderVal = value;
                            processIntervalSliderValue(value);
                          }),
                          onChangeStart: (value) => setState(() {
                            showIntervalLabel = false;
                          }),
                          onChangeEnd: (value) => setState(() {
                            showIntervalLabel = true;
                            settingsProvider.updateInterval = updateInterval;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((settingsProvider.updateInterval > 0) &&
                    (((DeviceInfo.androidInfo?.version.sdkInt ?? 0) >= 30) ||
                        settingsProvider.useShizuku))
                  Flex.vertical(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => settingsProvider.useFGService =
                                !settingsProvider.useFGService,
                            child: ListItemLayout(
                              isMultiline: true,
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                12.0,
                                16.0 - 8.0,
                                12.0,
                              ),
                              headline: Text(
                                tr("foregroundServiceExplanation"),
                                maxLines: 3,
                              ),
                              trailing: ExcludeFocus(
                                child: Switch(
                                  onCheckedChanged: (value) =>
                                      settingsProvider.useFGService = value,
                                  checked: settingsProvider.useFGService,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        child: Flex.vertical(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MergeSemantics(
                              child: ListItemInteraction(
                                onTap: () =>
                                    settingsProvider.enableBackgroundUpdates =
                                        !settingsProvider
                                            .enableBackgroundUpdates,
                                child: ListItemLayout(
                                  isMultiline: false,
                                  padding: const EdgeInsets.fromLTRB(
                                    16.0,
                                    8.0,
                                    16.0 - 8.0,
                                    8.0,
                                  ),
                                  headline: Text(tr("enableBackgroundUpdates")),
                                  trailing: ExcludeFocus(
                                    child: Switch(
                                      onCheckedChanged: (value) =>
                                          settingsProvider
                                                  .enableBackgroundUpdates =
                                              value,
                                      checked: settingsProvider
                                          .enableBackgroundUpdates,
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
                                style: TypescaleTheme.of(context).bodyMedium
                                    .toTextStyle(
                                      color: colorTheme.onSurfaceVariant,
                                    ),
                                child: Flex.vertical(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8.0,
                                  children: [
                                    Text(tr('backgroundUpdateReqsExplanation')),
                                    Text(
                                      tr('backgroundUpdateLimitsExplanation'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (settingsProvider.enableBackgroundUpdates)
                        Flex.vertical(
                          children: [
                            const SizedBox(height: 2.0),
                            ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider.bgUpdatesOnWiFiOnly =
                                          !settingsProvider.bgUpdatesOnWiFiOnly,
                                  child: ListItemLayout(
                                    isMultiline: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      16.0,
                                      12.0,
                                      16.0 - 8.0,
                                      12.0,
                                    ),
                                    headline: Text(
                                      tr("bgUpdatesOnWiFiOnly"),
                                      maxLines: 3,
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider
                                                    .bgUpdatesOnWiFiOnly =
                                                value,
                                        checked: settingsProvider
                                            .bgUpdatesOnWiFiOnly,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            ListItemContainer(
                              child: MergeSemantics(
                                child: ListItemInteraction(
                                  onTap: () =>
                                      settingsProvider
                                              .bgUpdatesWhileChargingOnly =
                                          !settingsProvider
                                              .bgUpdatesWhileChargingOnly,
                                  child: ListItemLayout(
                                    isMultiline: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      16.0,
                                      12.0,
                                      16.0 - 8.0,
                                      12.0,
                                    ),
                                    headline: Text(
                                      tr("bgUpdatesWhileChargingOnly"),
                                      maxLines: 3,
                                    ),
                                    trailing: ExcludeFocus(
                                      child: Switch(
                                        onCheckedChanged: (value) =>
                                            settingsProvider
                                                    .bgUpdatesWhileChargingOnly =
                                                value,
                                        checked: settingsProvider
                                            .bgUpdatesWhileChargingOnly,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.checkOnStart =
                          !settingsProvider.checkOnStart,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(tr("checkOnStart"), maxLines: 3),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.checkOnStart = value,
                            checked: settingsProvider.checkOnStart,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.checkUpdateOnDetailPage =
                          !settingsProvider.checkUpdateOnDetailPage,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(
                          tr("checkUpdateOnDetailPage"),
                          maxLines: 3,
                        ),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.checkUpdateOnDetailPage =
                                    value,
                            checked: settingsProvider.checkUpdateOnDetailPage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () =>
                          settingsProvider.onlyCheckInstalledOrTrackOnlyApps =
                              !settingsProvider
                                  .onlyCheckInstalledOrTrackOnlyApps,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(
                          tr("onlyCheckInstalledOrTrackOnlyApps"),
                          maxLines: 3,
                        ),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider
                                        .onlyCheckInstalledOrTrackOnlyApps =
                                    value,
                            checked: settingsProvider
                                .onlyCheckInstalledOrTrackOnlyApps,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: ListItemInteraction(
                    onTap: () => settingsProvider.removeOnExternalUninstall =
                        !settingsProvider.removeOnExternalUninstall,
                    child: ListItemLayout(
                      isMultiline: true,
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        12.0,
                        16.0 - 8.0,
                        12.0,
                      ),
                      headline: Text(
                        tr("removeOnExternalUninstall"),
                        maxLines: 3,
                      ),
                      trailing: ExcludeFocus(
                        child: Switch(
                          onCheckedChanged: (value) =>
                              settingsProvider.removeOnExternalUninstall =
                                  value,
                          checked: settingsProvider.removeOnExternalUninstall,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.parallelDownloads =
                          !settingsProvider.parallelDownloads,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(tr("parallelDownloads"), maxLines: 3),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.parallelDownloads = value,
                            checked: settingsProvider.parallelDownloads,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: Flex.vertical(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MergeSemantics(
                        child: ListItemInteraction(
                          onTap: () =>
                              settingsProvider
                                      .beforeNewInstallsShareToAppVerifier =
                                  !settingsProvider
                                      .beforeNewInstallsShareToAppVerifier,
                          child: ListItemLayout(
                            isMultiline: true,
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              12.0,
                              16.0 - 8.0,
                              12.0,
                            ),
                            headline: Text(
                              tr("beforeNewInstallsShareToAppVerifier"),
                              maxLines: 3,
                            ),
                            trailing: ExcludeFocus(
                              child: Switch(
                                onCheckedChanged: (value) =>
                                    settingsProvider
                                            .beforeNewInstallsShareToAppVerifier =
                                        value,
                                checked: settingsProvider
                                    .beforeNewInstallsShareToAppVerifier,
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
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () =>
                          onUseShizukuChanged(!settingsProvider.useShizuku),
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(tr("useShizuku"), maxLines: 3),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: onUseShizukuChanged,
                            checked: settingsProvider.useShizuku,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  isLast: true,
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () =>
                          settingsProvider.shizukuPretendToBeGooglePlay =
                              !settingsProvider.shizukuPretendToBeGooglePlay,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(
                          tr("shizukuPretendToBeGooglePlay"),
                          maxLines: 3,
                        ),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.shizukuPretendToBeGooglePlay =
                                    value,
                            checked:
                                settingsProvider.shizukuPretendToBeGooglePlay,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0 + 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    tr("sourceSpecific"),
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                ...sourceSpecificFields,
                const SizedBox(height: 12.0 + 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    tr("appearance"),
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                if (DynamicColor.isDynamicColorAvailable())
                  ListItemContainer(
                    key: const ValueKey("useMaterialYou"),
                    isFirst: true,
                    isLast: settingsProvider.useMaterialYou,
                    child: MergeSemantics(
                      child: ListItemInteraction(
                        onTap: () => settingsProvider.useMaterialYou =
                            !settingsProvider.useMaterialYou,
                        child: ListItemLayout(
                          isMultiline: true,
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            12.0,
                            16.0 - 8.0,
                            12.0,
                          ),
                          headline: Text(tr("useMaterialYou"), maxLines: 2),
                          trailing: ExcludeFocus(
                            child: Switch(
                              onCheckedChanged: (value) =>
                                  settingsProvider.useMaterialYou = value,
                              checked: settingsProvider.useMaterialYou,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!settingsProvider.useMaterialYou) ...[
                  const SizedBox(height: 2.0),
                  ListItemContainer(
                    isLast: true,
                    child: ListItemInteraction(
                      onTap: selectColor,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0,
                          12.0,
                        ),
                        headline: Text(
                          tr('selectX', args: [tr('colour').toLowerCase()]),
                        ),
                        supportingText: Text(
                          "${ColorTools.nameThatColor(settingsProvider.themeColor)} "
                          "(${ColorTools.materialNameAndCode(settingsProvider.themeColor, colorSwatchNameMap: colorsNameMap)})",
                          maxLines: 2,
                        ),
                        trailing: ColorIndicator(
                          width: 40,
                          height: 40,
                          borderRadius: 20,
                          color: settingsProvider.themeColor,
                          onSelectFocus: false,
                          onSelect: selectColor,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16.0),
                DropdownMenuFormField<ThemeSettings>(
                  expandedInsets: EdgeInsets.zero,
                  inputDecorationTheme: const InputDecorationThemeData(
                    border: UnderlineInputBorder(),
                    filled: true,
                  ),
                  textStyle: typescaleTheme.titleMediumEmphasized.toTextStyle(),
                  label: Text(tr("theme")),
                  initialSelection: settingsProvider.theme,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: ThemeSettings.system,
                      leadingIcon: const IconLegacy(Symbols.auto_mode_rounded),
                      label: tr("followSystem"),
                    ),
                    DropdownMenuEntry(
                      value: ThemeSettings.light,
                      leadingIcon: const IconLegacy(Symbols.light_mode_rounded),
                      label: tr("light"),
                    ),
                    DropdownMenuEntry(
                      value: ThemeSettings.dark,
                      leadingIcon: const IconLegacy(Symbols.dark_mode_rounded),
                      label: tr("dark"),
                    ),
                  ],
                  onSelected: (value) {
                    if (value != null) {
                      settingsProvider.theme = value;
                    }
                  },
                ),
                const SizedBox(height: 4.0),
                if (settingsProvider.theme == ThemeSettings.system &&
                    (DeviceInfo.androidInfo?.version.sdkInt ?? 30) < 29)
                  Text(
                    tr('followSystemThemeExplanation'),
                    style: typescaleTheme.labelSmall.toTextStyle(),
                  ),
                const SizedBox(height: 12.0),
                Flex.horizontal(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible.tight(
                      child: DropdownMenuFormField<SortColumnSettings>(
                        expandedInsets: EdgeInsets.zero,
                        inputDecorationTheme: const InputDecorationThemeData(
                          border: UnderlineInputBorder(),
                          filled: true,
                        ),
                        label: Text(tr('appSortBy')),
                        initialSelection: settingsProvider.sortColumn,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: SortColumnSettings.authorName,
                            label: tr('authorName'),
                          ),
                          DropdownMenuEntry(
                            value: SortColumnSettings.nameAuthor,
                            label: tr('nameAuthor'),
                          ),
                          DropdownMenuEntry(
                            value: SortColumnSettings.added,
                            label: tr('asAdded'),
                          ),
                          DropdownMenuEntry(
                            value: SortColumnSettings.releaseDate,
                            label: tr('releaseDate'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value != null) {
                            settingsProvider.sortColumn = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible.tight(
                      child: DropdownMenuFormField<SortOrderSettings>(
                        expandedInsets: EdgeInsets.zero,
                        inputDecorationTheme: const InputDecorationThemeData(
                          border: UnderlineInputBorder(),
                          filled: true,
                        ),
                        label: Text(tr('appSortOrder')),
                        initialSelection: settingsProvider.sortOrder,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: SortOrderSettings.ascending,
                            label: tr('ascending'),
                          ),
                          DropdownMenuEntry(
                            value: SortOrderSettings.descending,
                            label: tr('descending'),
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
                const SizedBox(height: 16.0),
                DropdownMenuFormField<Locale?>(
                  expandedInsets: EdgeInsets.zero,
                  inputDecorationTheme: const InputDecorationThemeData(
                    border: UnderlineInputBorder(),
                    filled: true,
                  ),
                  label: Text(tr('language')),
                  enableFilter: true,
                  enableSearch: true,
                  requestFocusOnTap: true,
                  initialSelection: settingsProvider.forcedLocale,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: null, label: tr('followSystem')),
                    ...supportedLocales.map(
                      (e) => DropdownMenuEntry(value: e.key, label: e.value),
                    ),
                  ],
                  onSelected: (value) {
                    settingsProvider.forcedLocale = value;
                    if (value != null) {
                      context.setLocale(value);
                    } else {
                      settingsProvider.resetLocaleSafe(context);
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                ListItemContainer(
                  isFirst: true,
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.showAppWebpage =
                          !settingsProvider.showAppWebpage,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(tr("showWebInAppView"), maxLines: 3),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.showAppWebpage = value,
                            checked: settingsProvider.showAppWebpage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  key: const ValueKey("pinUpdates"),
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.pinUpdates =
                          !settingsProvider.pinUpdates,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(tr("pinUpdates"), maxLines: 3),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.pinUpdates = value,
                            checked: settingsProvider.pinUpdates,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  key: const ValueKey("buryNonInstalled"),
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.buryNonInstalled =
                          !settingsProvider.buryNonInstalled,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(
                          tr("moveNonInstalledAppsToBottom"),
                          maxLines: 3,
                        ),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.buryNonInstalled = value,
                            checked: settingsProvider.buryNonInstalled,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  key: const ValueKey("groupByCategory"),
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.groupByCategory =
                          !settingsProvider.groupByCategory,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(tr("groupByCategory"), maxLines: 3),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.groupByCategory = value,
                            checked: settingsProvider.groupByCategory,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  key: const ValueKey("hideTrackOnlyWarning"),
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.hideTrackOnlyWarning =
                          !settingsProvider.hideTrackOnlyWarning,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(
                          tr("dontShowTrackOnlyWarnings"),
                          maxLines: 3,
                        ),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.hideTrackOnlyWarning = value,
                            checked: settingsProvider.hideTrackOnlyWarning,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  key: const ValueKey("hideAPKOriginWarning"),
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.hideAPKOriginWarning =
                          !settingsProvider.hideAPKOriginWarning,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: Text(
                          tr("dontShowAPKOriginWarnings"),
                          maxLines: 3,
                        ),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.hideAPKOriginWarning = value,
                            checked: settingsProvider.hideAPKOriginWarning,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  key: const ValueKey("developerModeV1"),
                  isLast: true,
                  child: MergeSemantics(
                    child: ListItemInteraction(
                      onTap: () => settingsProvider.developerModeV1 =
                          !settingsProvider.developerModeV1,
                      child: ListItemLayout(
                        isMultiline: true,
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0 - 8.0,
                          12.0,
                        ),
                        headline: const Text("Developer Mode"),
                        trailing: ExcludeFocus(
                          child: Switch(
                            onCheckedChanged: (value) =>
                                settingsProvider.developerModeV1 = value,
                            checked: settingsProvider.developerModeV1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 2.0),
                // ListItemContainer(
                //   isLast: true,
                //   child: MergeSemantics(
                //     child: ListItemInteraction(
                //       onTap: () => settingsProvider.highlightTouchTargets =
                //           !settingsProvider.highlightTouchTargets,
                //       child: ListItemLayout(
                //         isMultiline: true,
                //         padding: const EdgeInsets.fromLTRB(
                //           16.0,
                //           12.0,
                //           16.0 - 8.0,
                //           12.0,
                //         ),
                //         headline: Text(
                //           tr("highlightTouchTargets"),
                //           maxLines: 3,
                //         ),
                //         trailing: ExcludeFocus(
                //           child: Switch(
                //             onCheckedChanged: (value) =>
                //                 settingsProvider.highlightTouchTargets = value,
                //             checked: settingsProvider.highlightTouchTargets,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 12.0 + 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    tr("categories"),
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const CategoryEditorSelector(showLabelWhenNotEmpty: false),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    tr("about"),
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                ListItemContainer(
                  isFirst: true,
                  child: ListItemInteraction(
                    onTap: () => launchUrlString(
                      SettingsProvider.sourceUrl,
                      mode: LaunchMode.externalApplication,
                    ),
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: const Icon(Symbols.code_rounded),
                      headline: Text(tr("appSource"), maxLines: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: ListItemInteraction(
                    onTap: () => launchUrlString(
                      "https://wiki.obtainium.imranr.dev/",
                      mode: LaunchMode.externalApplication,
                    ),
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: const Icon(Symbols.help_rounded, fill: 1.0),
                      headline: Text(tr("wiki"), maxLines: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  child: ListItemInteraction(
                    onTap: () => launchUrlString(
                      "https://apps.obtainium.imranr.dev/",
                      mode: LaunchMode.externalApplication,
                    ),
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: const Icon(Symbols.apps_rounded),
                      headline: Text(
                        tr("crowdsourcedConfigsLabel"),
                        maxLines: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                ListItemContainer(
                  isLast: true,
                  child: ListItemInteraction(
                    onTap: () =>
                        LogsProvider.instance.select().get().then((logs) {
                          if (!context.mounted) return;
                          if (logs.isEmpty) {
                            showMessage(ObtainiumError(tr('noLogs')), context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const _LogsPage(),
                              ),
                            );
                          }
                        }),
                    child: ListItemLayout(
                      isMultiline: true,
                      leading: const Icon(
                        Symbols.bug_report_rounded,
                        fill: 1.0,
                      ),
                      headline: Text(tr("appLogs"), maxLines: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryEditorSelector extends StatefulWidget {
  final void Function(List<String> categories)? onSelected;
  final bool singleSelect;
  final Set<String> preselected;
  final WrapAlignment alignment;
  final bool showLabelWhenNotEmpty;
  const CategoryEditorSelector({
    super.key,
    this.onSelected,
    this.singleSelect = false,
    this.preselected = const {},
    this.alignment = WrapAlignment.start,
    this.showLabelWhenNotEmpty = true,
  });

  @override
  State<CategoryEditorSelector> createState() => _CategoryEditorSelectorState();
}

class _CategoryEditorSelectorState extends State<CategoryEditorSelector> {
  Map<String, MapEntry<int, bool>> storedValues = {};

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final appsProvider = context.watch<AppsProvider>();
    storedValues = settingsProvider.categories.map(
      (key, value) => MapEntry(
        key,
        MapEntry(
          value,
          storedValues[key]?.value ?? widget.preselected.contains(key),
        ),
      ),
    );
    return GeneratedForm(
      items: [
        [
          GeneratedFormTagInput(
            'categories',
            label: tr('categories'),
            emptyMessage: tr('noCategories'),
            defaultValue: storedValues,
            alignment: widget.alignment,
            deleteConfirmationMessage: MapEntry(
              tr('deleteCategoriesQuestion'),
              tr('categoryDeleteWarning'),
            ),
            singleSelect: widget.singleSelect,
            showLabelWhenNotEmpty: widget.showLabelWhenNotEmpty,
          ),
        ],
      ],
      onValueChanges: ((values, valid, isBuilding) {
        if (!isBuilding) {
          storedValues =
              values['categories'] as Map<String, MapEntry<int, bool>>;
          settingsProvider.setCategories(
            storedValues.map((key, value) => MapEntry(key, value.key)),
            appsProvider: appsProvider,
          );
          if (widget.onSelected != null) {
            widget.onSelected!(
              storedValues.keys.where((k) => storedValues[k]!.value).toList(),
            );
          }
        }
      }),
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
      orderingMode: OrderingMode.desc,
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
    final settingsProvider = context.read<SettingsProvider>();

    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final staticColors = StaticColorsData.fallback(
      variant: DynamicSchemeVariant.tonalSpot,
      brightness: Theme.brightnessOf(context),
      specVersion: DynamicSchemeSpecVersion.spec2025,
    ).harmonizeWithPrimary(colorTheme);

    final actionButtonStyle = ButtonStyle(
      animationDuration: Duration.zero,
      elevation: const WidgetStatePropertyAll(0.0),
      shadowColor: WidgetStateColor.transparent,
      minimumSize: const WidgetStatePropertyAll(Size(48.0, 56.0)),
      fixedSize: const WidgetStatePropertyAll(null),
      maximumSize: const WidgetStatePropertyAll(Size.infinite),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      ),
      iconSize: const WidgetStatePropertyAll(24.0),
      shape: WidgetStatePropertyAll(
        CornersBorder.rounded(corners: Corners.all(shapeTheme.corner.large)),
      ),
      overlayColor: WidgetStateLayerColor(
        color: WidgetStatePropertyAll(colorTheme.onPrimary),
        opacity: stateTheme.stateLayerOpacity,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colorTheme.onSurface.withValues(alpha: 0.1)
            : colorTheme.primary,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colorTheme.onSurface.withValues(alpha: 0.38)
            : colorTheme.onPrimary,
      ),
      textStyle: WidgetStateProperty.resolveWith(
        (states) => typescaleTheme.titleMedium.toTextStyle(),
      ),
    );

    final developerButtonStyle = ButtonStyle(
      animationDuration: Duration.zero,
      elevation: const WidgetStatePropertyAll(0.0),
      shadowColor: WidgetStateColor.transparent,
      minimumSize: const WidgetStatePropertyAll(Size(48.0, 40.0)),
      fixedSize: const WidgetStatePropertyAll(null),
      maximumSize: const WidgetStatePropertyAll(Size.infinite),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
      ),
      iconSize: const WidgetStatePropertyAll(20.0),
      shape: WidgetStatePropertyAll(
        CornersBorder.rounded(corners: Corners.all(shapeTheme.corner.full)),
      ),
      overlayColor: WidgetStateLayerColor(
        color: WidgetStatePropertyAll(colorTheme.onSurfaceVariant),
        opacity: stateTheme.stateLayerOpacity,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colorTheme.onSurface.withValues(alpha: 0.1)
            : colorTheme.surfaceBright,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colorTheme.onSurface.withValues(alpha: 0.38)
            : colorTheme.onSurfaceVariant,
      ),
      textStyle: WidgetStateProperty.resolveWith(
        (states) => typescaleTheme.labelLarge.toTextStyle(),
      ),
    );

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomRefreshIndicator(
        onRefresh: () async {
          if (kDebugMode) {
            await Future.delayed(const Duration(seconds: 5));
          }
          _refreshLogs();
          await Fluttertoast.showToast(msg: "Refreshed logs!");
        },
        edgeOffset: padding.top + 120.0,
        displacement: 80.0,
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              CustomAppBar(
                leading: const Padding(
                  padding: EdgeInsets.only(left: 8.0 - 4.0),
                  child: DeveloperPageBackButton(),
                ),
                type: CustomAppBarType.largeFlexible,
                behavior: CustomAppBarBehavior.duplicate,
                expandedContainerColor: colorTheme.surfaceContainer,
                collapsedContainerColor: colorTheme.surfaceContainer,
                collapsedPadding: const EdgeInsets.fromLTRB(
                  8.0 + 40.0 + 8.0,
                  0.0,
                  16.0,
                  0.0,
                ),
                title: Text(tr("appLogs")),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
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
                    ListenableBuilder(
                      listenable: settingsProvider,
                      builder: (context, child) =>
                          settingsProvider.developerModeV1
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
                          padding: const EdgeInsetsGeometry.fromLTRB(
                            16.0,
                            0.0,
                            16.0,
                            16.0,
                          ),
                          sliver: SliverList.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final isFirst = index == 0;
                              final isLast = index == logs.length - 1;
                              final icon = switch (log.level) {
                                LogLevels.info => const Icon(
                                  Symbols.info_rounded,
                                  fill: 1.0,
                                ),
                                LogLevels.warning => const Icon(
                                  Symbols.warning_rounded,
                                  fill: 1.0,
                                ),
                                LogLevels.error => const Icon(
                                  Symbols.error_rounded,
                                  fill: 1.0,
                                ),
                                LogLevels.debug => const Icon(
                                  Symbols.bug_report_rounded,
                                  fill: 1.0,
                                ),
                              };
                              final iconBackgroundColor = switch (log.level) {
                                LogLevels.info =>
                                  staticColors.blue.colorContainer,
                                LogLevels.warning =>
                                  staticColors.yellow.colorContainer,
                                LogLevels.error =>
                                  staticColors.red.colorContainer,
                                LogLevels.debug =>
                                  staticColors.cyan.colorContainer,
                              };
                              final iconForegroundColor = switch (log.level) {
                                LogLevels.info =>
                                  staticColors.blue.onColorContainer,
                                LogLevels.warning =>
                                  staticColors.yellow.onColorContainer,
                                LogLevels.error =>
                                  staticColors.red.onColorContainer,
                                LogLevels.debug =>
                                  staticColors.cyan.onColorContainer,
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
                                          isMultiline: true,
                                          leading: SizedBox.square(
                                            dimension: 40.0,
                                            child: Material(
                                              animationDuration: Duration.zero,
                                              type: MaterialType.card,
                                              clipBehavior: Clip.antiAlias,
                                              color: iconBackgroundColor,
                                              shape: const StadiumBorder(),
                                              child: Align.center(
                                                child: IconTheme.merge(
                                                  data:
                                                      IconThemeDataPartial.from(
                                                        color:
                                                            iconForegroundColor,
                                                      ),
                                                  child: icon,
                                                ),
                                              ),
                                            ),
                                          ),
                                          headline: Text(log.message),
                                          supportingText: Text(
                                            log.createdAt.toString(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
            ],
          ),
        ),
      ),
    );
  }
}
