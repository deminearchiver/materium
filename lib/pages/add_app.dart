import 'package:easy_localization/easy_localization.dart';
import 'package:materium/flutter.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/generated_form.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/app.dart';
import 'package:materium/pages/developer.dart';
import 'package:materium/pages/import_export.dart';
import 'package:materium/pages/settings.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/notifications_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:provider/provider.dart';
import 'package:super_keyboard/super_keyboard.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AddAppPage extends StatefulWidget {
  const AddAppPage({super.key, this.input});

  final String? input;

  @override
  State<AddAppPage> createState() => AddAppPageState();
}

class AddAppPageState extends State<AddAppPage> {
  bool gettingAppInfo = false;
  bool searching = false;

  String userInput = '';
  String searchQuery = '';
  String? pickedSourceOverride;
  String? previousPickedSourceOverride;
  AppSource? pickedSource;
  Map<String, dynamic> additionalSettings = {};
  bool additionalSettingsValid = true;
  bool inferAppIdIfOptional = true;
  List<String> pickedCategories = [];
  int urlInputKey = 0;
  SourceProvider sourceProvider = SourceProvider();

  void linkFn(String input) {
    try {
      if (input.isEmpty) {
        throw UnsupportedURLError();
      }
      sourceProvider.getSource(input);
      changeUserInput(input, true, false, updateUrlInput: true);
    } catch (e) {
      showError(e, context);
    }
  }

  void changeUserInput(
    String input,
    bool valid,
    bool isBuilding, {
    bool updateUrlInput = false,
    String? overrideSource,
  }) {
    userInput = input;
    if (!isBuilding) {
      setState(() {
        if (overrideSource != null) {
          pickedSourceOverride = overrideSource;
        }
        bool overrideChanged =
            pickedSourceOverride != previousPickedSourceOverride;
        previousPickedSourceOverride = pickedSourceOverride;
        if (updateUrlInput) {
          urlInputKey++;
        }
        var prevHost = pickedSource?.hosts.isNotEmpty == true
            ? pickedSource?.hosts[0]
            : null;
        var source = valid
            ? sourceProvider.getSource(
                userInput,
                overrideSource: pickedSourceOverride,
              )
            : null;
        if (pickedSource.runtimeType != source.runtimeType ||
            overrideChanged ||
            (prevHost != null && prevHost != source?.hosts[0])) {
          pickedSource = source;
          pickedSource?.runOnAddAppInputChange(userInput);
          additionalSettings = source != null
              ? getDefaultValuesFromFormItems(
                  source.combinedAppSpecificSettingFormItems,
                )
              : {};
          additionalSettingsValid = source != null
              ? !sourceProvider.ifRequiredAppSpecificSettingsExist(source)
              : true;
          inferAppIdIfOptional = true;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.input case final input?) {
      linkFn(input);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsService>();
    final appsProvider = context.read<AppsProvider>();
    final notificationsProvider = context.read<NotificationsProvider>();

    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final showBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    final hideTrackOnlyWarning = context.select<SettingsProvider, bool>(
      (settingsProvider) => settingsProvider.hideTrackOnlyWarning,
    );

    final searchDeselected = context.select<SettingsProvider, List<String>>(
      (settingsProvider) => settingsProvider.searchDeselected,
    );

    bool doingSomething = gettingAppInfo || searching;

    Future<bool> getTrackOnlyConfirmationIfNeeded(
      bool userPickedTrackOnly, {
      bool ignoreHideSetting = false,
    }) async {
      var useTrackOnly = userPickedTrackOnly || pickedSource!.enforceTrackOnly;
      if (useTrackOnly && (!hideTrackOnlyWarning || ignoreHideSetting)) {
        var values = await showDialog(
          context: context,
          builder: (ctx) {
            return GeneratedFormModal(
              initValid: true,
              title: tr(
                'xIsTrackOnly',
                args: [
                  pickedSource!.enforceTrackOnly ? tr('source') : tr('app'),
                ],
              ),
              items: [
                [GeneratedFormSwitch('hide', label: tr('dontShowAgain'))],
              ],
              message:
                  '${pickedSource!.enforceTrackOnly ? tr('appsFromSourceAreTrackOnly') : tr('youPickedTrackOnly')}\n\n${tr('trackOnlyAppDescription')}',
            );
          },
        );
        if (context.mounted && values != null) {
          context.read<SettingsProvider>().hideTrackOnlyWarning =
              values["hide"] == true;
        }
        return useTrackOnly && values != null;
      } else {
        return true;
      }
    }

    Future<bool> getReleaseDateAsVersionConfirmationIfNeeded(
      bool userPickedTrackOnly,
    ) async {
      return (!(additionalSettings['releaseDateAsVersion'] == true &&
          await showDialog(
                context: context,
                builder: (ctx) {
                  return GeneratedFormModal(
                    title: tr('releaseDateAsVersion'),
                    items: const [],
                    message: tr('releaseDateAsVersionExplanation'),
                  );
                },
              ) ==
              null));
    }

    Future<void> addApp({bool resetUserInputAfter = false}) async {
      setState(() {
        gettingAppInfo = true;
      });
      try {
        var userPickedTrackOnly = additionalSettings['trackOnly'] == true;
        App? app;
        if ((await getTrackOnlyConfirmationIfNeeded(userPickedTrackOnly)) &&
            (await getReleaseDateAsVersionConfirmationIfNeeded(
              userPickedTrackOnly,
            ))) {
          var trackOnly = pickedSource!.enforceTrackOnly || userPickedTrackOnly;
          app = await sourceProvider.getApp(
            pickedSource!,
            userInput.trim(),
            additionalSettings,
            trackOnlyOverride: trackOnly,
            sourceIsOverriden: pickedSourceOverride != null,
            inferAppIdIfOptional: inferAppIdIfOptional,
          );
          // Only download the APK here if you need to for the package ID
          if (isTempId(app) && app.additionalSettings['trackOnly'] != true) {
            if (!context.mounted) return;
            var apkUrl = await appsProvider.confirmAppFileUrl(
              app,
              context,
              false,
            );
            if (apkUrl == null) {
              throw ObtainiumError(tr('cancelled'));
            }
            app.preferredApkIndex = app.apkUrls
                .map((e) => e.value)
                .toList()
                .indexOf(apkUrl.value);
            var downloadedArtifact = await appsProvider.downloadApp(
              app,
              globalNavigatorKey.currentContext,
              notificationsProvider: notificationsProvider,
            );
            DownloadedApk? downloadedFile;
            DownloadedDir? downloadedDir;
            if (downloadedArtifact is DownloadedApk) {
              downloadedFile = downloadedArtifact;
            } else {
              downloadedDir = downloadedArtifact as DownloadedDir;
            }
            app.id = downloadedFile?.appId ?? downloadedDir!.appId;
          }
          if (appsProvider.apps.containsKey(app.id)) {
            throw ObtainiumError(tr('appAlreadyAdded'));
          }
          if (app.additionalSettings['trackOnly'] == true ||
              app.additionalSettings['versionDetection'] != true) {
            app.installedVersion = app.latestVersion;
          }
          app.categories = pickedCategories;
          await appsProvider.saveApps([app], onlyIfExists: false);
        }
        if (app != null && context.mounted) {
          final navigator =
              globalNavigatorKey.currentState ?? Navigator.maybeOf(context);
          if (navigator != null && navigator.mounted) {
            navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => AppPage(appId: app!.id)),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          showError(e, context);
        }
      } finally {
        if (context.mounted) {
          setState(() {
            gettingAppInfo = false;
            if (resetUserInputAfter) {
              changeUserInput('', false, true);
            }
          });
        }
      }
    }

    Widget getUrlInputRow() => Flex.horizontal(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO: make TextFields height 56dp across the app
        Flexible.tight(
          flex: 2,
          child: GeneratedForm(
            key: Key(urlInputKey.toString()),
            items: [
              [
                GeneratedFormTextField(
                  'appSourceURL',
                  label: tr('appSourceURL'),
                  defaultValue: userInput,
                  additionalValidators: [
                    (value) {
                      try {
                        sourceProvider
                            .getSource(
                              value ?? '',
                              overrideSource: pickedSourceOverride,
                            )
                            .standardizeUrl(value ?? '');
                      } catch (e) {
                        return e is String
                            ? e
                            : e is ObtainiumError
                            ? e.toString()
                            : tr('error');
                      }
                      return null;
                    },
                  ],
                ),
              ],
            ],
            onValueChanges: (values, valid, isBuilding) {
              changeUserInput(values['appSourceURL']!, valid, isBuilding);
            },
          ),
        ),
        const SizedBox(width: 16),
        Flexible.tight(
          flex: 1,
          child: FilledButton(
            onPressed:
                doingSomething ||
                    pickedSource == null ||
                    (pickedSource!
                            .combinedAppSpecificSettingFormItems
                            .isNotEmpty &&
                        !additionalSettingsValid)
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    addApp();
                  },
            style: ButtonStyle(
              animationDuration: Duration.zero,
              elevation: const WidgetStatePropertyAll(0.0),
              shadowColor: WidgetStateColor.transparent,
              minimumSize: const WidgetStatePropertyAll(Size(48.0, 56.0)),
              fixedSize: const WidgetStatePropertyAll(null),
              maximumSize: const WidgetStatePropertyAll(Size.infinite),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              iconSize: const WidgetStatePropertyAll(24.0),
              shape: WidgetStatePropertyAll(
                CornersBorder.rounded(
                  corners: Corners.all(shapeTheme.corner.full),
                ),
              ),

              overlayColor: WidgetStateLayerColor(
                color: WidgetStatePropertyAll(colorTheme.onPrimary),
                opacity: stateTheme.asWidgetStateLayerOpacity,
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
                (states) =>
                    (states.contains(WidgetState.disabled)
                            ? typescaleTheme.titleMedium
                            : typescaleTheme.titleMediumEmphasized)
                        .toTextStyle(),
              ),
            ),
            child: Stack(
              children: [
                Visibility.maintain(
                  visible: !gettingAppInfo,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Align.center(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Text(
                        tr('add'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (gettingAppInfo)
                  Positioned.fill(
                    child: Align.center(
                      child: SizedBox.square(
                        dimension: 36.0,
                        child: CircularProgressIndicator(
                          value: null,
                          strokeWidth: 3.0,
                          color: colorTheme.onSurface.withValues(alpha: 0.38),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    Future<void> runSearch({bool filtered = true}) async {
      setState(() {
        searching = true;
      });
      final sourceStrings = <String, List<String>>{};
      sourceProvider.sources.where((e) => e.canSearch).forEach((s) {
        sourceStrings[s.name] = [s.name];
      });
      try {
        final searchSources =
            await showDialog<List<String>?>(
              context: context,
              builder: (ctx) {
                return SelectionModal(
                  title: tr(
                    'selectX',
                    args: [plural('source', 2).toLowerCase()],
                  ),
                  entries: sourceStrings,
                  selectedByDefault: true,
                  onlyOneSelectionAllowed: false,
                  titlesAreLinks: false,
                  deselectThese: searchDeselected,
                );
              },
            ) ??
            [];
        if (!context.mounted) return;
        if (searchSources.isNotEmpty) {
          context.read<SettingsProvider>().searchDeselected = sourceStrings.keys
              .where((s) => !searchSources.contains(s))
              .toList();
          final List<MapEntry<String, Map<String, List<String>>>?>
          results = (await Future.wait(
            sourceProvider.sources
                .where((e) => searchSources.contains(e.name))
                .map((e) async {
                  try {
                    Map<String, dynamic>? querySettings = {};
                    if (e.includeAdditionalOptsInMainSearch) {
                      querySettings = await showDialog<Map<String, dynamic>?>(
                        context: context,
                        builder: (ctx) {
                          return GeneratedFormModal(
                            title: tr('searchX', args: [e.name]),
                            items: [
                              ...e.searchQuerySettingFormItems.map((e) => [e]),
                              [
                                GeneratedFormTextField(
                                  'url',
                                  label: e.hosts.isNotEmpty
                                      ? tr('overrideSource')
                                      : plural('url', 1).substring(2),
                                  autoCompleteOptions: [
                                    ...(e.hosts.isNotEmpty ? [e.hosts[0]] : []),
                                    ...appsProvider.apps.values
                                        .where(
                                          (a) =>
                                              sourceProvider
                                                  .getSource(
                                                    a.app.url,
                                                    overrideSource:
                                                        a.app.overrideSource,
                                                  )
                                                  .runtimeType ==
                                              e.runtimeType,
                                        )
                                        .map((a) {
                                          var uri = Uri.parse(a.app.url);
                                          return '${uri.origin}${uri.path}';
                                        }),
                                  ],
                                  defaultValue: e.hosts.isNotEmpty
                                      ? e.hosts[0]
                                      : '',
                                  required: true,
                                ),
                              ],
                            ],
                          );
                        },
                      );
                      if (querySettings == null) {
                        return null;
                      }
                    }
                    return MapEntry(
                      e.runtimeType.toString(),
                      await e.search(searchQuery, querySettings: querySettings),
                    );
                  } catch (err) {
                    if (err is! CredsNeededError) {
                      rethrow;
                    } else {
                      err.unexpected = true;
                      if (context.mounted) showError(err, context);
                      return null;
                    }
                  }
                }),
          )).where((a) => a != null).toList();

          // Interleave results instead of simple reduce
          final res = <String, MapEntry<String, List<String>>>{};
          var si = 0;
          var done = false;
          while (!done) {
            done = true;
            for (final r in results) {
              final sourceName = r!.key;
              if (r.value.length > si) {
                done = false;
                final singleRes = r.value.entries.elementAt(si);
                res[singleRes.key] = MapEntry(sourceName, singleRes.value);
              }
            }
            si++;
          }
          if (res.isEmpty) {
            throw ObtainiumError(tr('noResults'));
          }
          if (!context.mounted) return;
          final selectedUrls = res.isEmpty
              ? <String>[]
              : await showDialog<List<String>?>(
                  context: context,
                  builder: (ctx) {
                    return SelectionModal(
                      entries: res.map((k, v) => MapEntry(k, v.value)),
                      selectedByDefault: false,
                      onlyOneSelectionAllowed: true,
                    );
                  },
                );
          if (selectedUrls != null && selectedUrls.isNotEmpty) {
            final sourceName = res[selectedUrls[0]]?.key;
            changeUserInput(
              selectedUrls[0],
              true,
              false,
              updateUrlInput: true,
              overrideSource: sourceName,
            );
          }
        }
      } catch (e) {
        if (context.mounted) showError(e, context);
      } finally {
        if (context.mounted) {
          setState(() {
            searching = false;
          });
        }
      }
    }

    Widget getHTMLSourceOverrideDropdown() => Flex.vertical(
      children: [
        Flex.horizontal(
          children: [
            Flexible.tight(
              child: GeneratedForm(
                items: [
                  [
                    GeneratedFormDropdown(
                      'overrideSource',
                      defaultValue: pickedSourceOverride ?? '',
                      [
                        MapEntry('', tr('none')),
                        ...sourceProvider.sources
                            .where(
                              (s) =>
                                  s.allowOverride ||
                                  (pickedSource != null &&
                                      pickedSource.runtimeType ==
                                          s.runtimeType),
                            )
                            .map(
                              (s) => MapEntry(s.runtimeType.toString(), s.name),
                            ),
                      ],
                      label: tr('overrideSource'),
                    ),
                  ],
                ],
                onValueChanges: (values, valid, isBuilding) {
                  void fn() {
                    pickedSourceOverride =
                        (values['overrideSource'] == null ||
                            values['overrideSource'] == '')
                        ? null
                        : values['overrideSource'];
                  }

                  if (!isBuilding) {
                    setState(() {
                      fn();
                    });
                  } else {
                    fn();
                  }
                  changeUserInput(userInput, valid, isBuilding);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );

    bool shouldShowSearchBar() =>
        sourceProvider.sources.where((e) => e.canSearch).isNotEmpty &&
        pickedSource == null &&
        userInput.isEmpty;

    Widget getSearchBarRow() => Flex.horizontal(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible.tight(
          flex: 2,
          child: GeneratedForm(
            items: [
              [
                GeneratedFormTextField(
                  'searchSomeSources',
                  label: tr('searchSomeSourcesLabel'),
                  required: false,
                ),
              ],
            ],
            onValueChanges: (values, valid, isBuilding) {
              if (values.isNotEmpty && valid && !isBuilding) {
                setState(() {
                  searchQuery = values['searchSomeSources']!.trim();
                });
              }
            },
          ),
        ),
        const SizedBox(width: 8.0),
        Flexible.tight(
          flex: 1,
          child: FilledButton(
            onPressed: searchQuery.isEmpty || doingSomething
                ? null
                : () {
                    runSearch();
                  },
            style: ButtonStyle(
              animationDuration: Duration.zero,
              elevation: const WidgetStatePropertyAll(0.0),
              shadowColor: WidgetStateColor.transparent,
              minimumSize: const WidgetStatePropertyAll(Size(48.0, 56.0)),
              fixedSize: const WidgetStatePropertyAll(null),
              maximumSize: const WidgetStatePropertyAll(Size.infinite),
              padding: const WidgetStatePropertyAll(EdgeInsets.zero),
              iconSize: const WidgetStatePropertyAll(24.0),
              shape: WidgetStatePropertyAll(
                CornersBorder.rounded(
                  corners: Corners.all(shapeTheme.corner.full),
                ),
              ),

              overlayColor: WidgetStateLayerColor(
                color: WidgetStatePropertyAll(colorTheme.onPrimary),
                opacity: stateTheme.asWidgetStateLayerOpacity,
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
                (states) =>
                    (states.contains(WidgetState.disabled)
                            ? typescaleTheme.titleMedium
                            : typescaleTheme.titleMediumEmphasized)
                        .toTextStyle(),
              ),
            ),
            child: Stack(
              children: [
                Visibility.maintain(
                  visible: !searching,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Align.center(
                      widthFactor: 1.0,
                      heightFactor: 1.0,
                      child: Text(
                        tr('search'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (searching)
                  Positioned.fill(
                    child: Align.center(
                      child: SizedBox.square(
                        dimension: 36.0,
                        child: CircularProgressIndicator(
                          value: null,
                          strokeWidth: 3.0,
                          color: colorTheme.onSurface.withValues(alpha: 0.38),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget getAdditionalOptsCol() => Flex.vertical(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          tr('additionalOptsFor', args: [pickedSource?.name ?? tr('source')]),
          style: TextStyle(
            color: colorTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GeneratedForm(
          key: Key(
            '${pickedSource.runtimeType.toString()}-${pickedSource?.hostChanged.toString()}-${pickedSource?.hostIdenticalDespiteAnyChange.toString()}',
          ),
          items: [
            ...pickedSource!.combinedAppSpecificSettingFormItems,
            ...(pickedSourceOverride != null
                ? pickedSource!.sourceConfigSettingFormItems.map((e) => [e])
                : []),
          ],
          onValueChanges: (values, valid, isBuilding) {
            if (!isBuilding) {
              setState(() {
                additionalSettings = values;
                additionalSettingsValid = valid;
              });
            }
          },
        ),
        Flex.vertical(
          children: [
            const SizedBox(height: 16),
            CategoryEditorSelector(
              alignment: WrapAlignment.start,
              onSelected: (categories) {
                pickedCategories = categories;
              },
            ),
          ],
        ),
        if (pickedSource != null && pickedSource!.appIdInferIsOptional)
          GeneratedForm(
            key: const Key('inferAppIdIfOptional'),
            items: [
              [
                GeneratedFormSwitch(
                  'inferAppIdIfOptional',
                  label: tr('tryInferAppIdFromCode'),
                  defaultValue: inferAppIdIfOptional,
                ),
              ],
            ],
            onValueChanges: (values, valid, isBuilding) {
              if (!isBuilding) {
                setState(() {
                  inferAppIdIfOptional = values['inferAppIdIfOptional'];
                });
              }
            },
          ),
        if (pickedSource != null && pickedSource!.enforceTrackOnly)
          GeneratedForm(
            key: Key(
              '${pickedSource.runtimeType.toString()}-${pickedSource?.hostChanged.toString()}-${pickedSource?.hostIdenticalDespiteAnyChange.toString()}-appId',
            ),
            items: [
              [
                GeneratedFormTextField(
                  'appId',
                  label: '${tr('appId')} - ${tr('custom')}',
                  required: false,
                  additionalValidators: [
                    (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      final isValid = RegExp(
                        r'^([A-Za-z]{1}[A-Za-z\d_]*\.)+[A-Za-z][A-Za-z\d_]*$',
                      ).hasMatch(value);
                      if (!isValid) {
                        return tr('invalidInput');
                      }
                      return null;
                    },
                  ],
                ),
              ],
            ],
            onValueChanges: (values, valid, isBuilding) {
              if (!isBuilding) {
                setState(() {
                  additionalSettings['appId'] = values['appId'];
                });
              }
            },
          ),
      ],
    );

    Widget getSourcesListWidget() => Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return GeneratedFormModal(
                    singleNullReturnButton: tr('ok'),
                    title: tr('supportedSources'),
                    items: const [],
                    additionalWidgets: [
                      ...sourceProvider.sources.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: GestureDetector(
                            onTap: e.hosts.isNotEmpty
                                ? () {
                                    launchUrlString(
                                      'https://${e.hosts[0]}',
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                : null,
                            child: Text(
                              '${e.name}${e.enforceTrackOnly ? ' ${tr('trackOnlyInBrackets')}' : ''}${e.canSearch ? ' ${tr('searchableInBrackets')}' : ''}',
                              style: TextStyle(
                                decoration: e.hosts.isNotEmpty
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${tr('note')}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(tr('selfHostedNote', args: [tr('overrideSource')])),
                    ],
                  );
                },
              );
            },
            child: Text(
              tr('supportedSources'),
              style: typescaleTheme.labelLarge.toTextStyle().copyWith(
                color: colorTheme.tertiary,
                decoration: TextDecoration.underline,
                decorationColor: colorTheme.tertiary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              launchUrlString(
                'https://apps.obtainium.imranr.dev/',
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text(
              tr('crowdsourcedConfigsShort'),
              style: typescaleTheme.labelLarge.toTextStyle().copyWith(
                color: colorTheme.tertiary,
                decoration: TextDecoration.underline,
                decorationColor: colorTheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );

    final padding = MediaQuery.paddingOf(context);

    return SuperKeyboardBuilder(
      builder: (context, mobileGeometry) {
        debugPrint(
          "${mobileGeometry.bottomPadding} ${mobileGeometry.keyboardHeight}",
        );
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: backgroundColor,
          bottomNavigationBar: pickedSource == null
              ? Padding(
                  padding: .fromLTRB(
                    padding.left,
                    0.0,
                    padding.right,
                    padding.bottom,
                  ),
                  child: getSourcesListWidget(),
                )
              : null,
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
                    tr("addApp"),
                    textAlign: !showBackButton ? .center : .start,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const .fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: Material(
                      clipBehavior: .antiAlias,
                      shape: CornersBorder.rounded(
                        corners: .all(shapeTheme.corner.large),
                      ),
                      color: colorTheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Flex.vertical(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            getUrlInputRow(),
                            const SizedBox(height: 16),
                            if (pickedSource != null)
                              getHTMLSourceOverrideDropdown(),
                            if (shouldShowSearchBar()) getSearchBarRow(),
                            if (pickedSource != null)
                              FutureBuilder(
                                builder: (ctx, val) {
                                  return val.data != null &&
                                          val.data!.isNotEmpty
                                      ? Text(
                                          val.data!,
                                          style: typescaleTheme.bodySmall
                                              .toTextStyle(),
                                        )
                                      : const SizedBox();
                                },
                                future: pickedSource?.getSourceNote(),
                              ),
                            if (pickedSource != null) getAdditionalOptsCol(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
              ],
            ),
          ),
        );
      },
    );
  }
}
