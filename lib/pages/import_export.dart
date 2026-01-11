import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/flutter.dart';
import 'package:materium/app_sources/fdroidrepo.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/generated_form.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/pages/developer.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  bool importInProgress = false;

  @override
  Widget build(BuildContext context) {
    final sourceProvider = SourceProvider();
    final appsProvider = context.watch<AppsProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = context.read<SettingsService>();

    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final padding = MediaQuery.paddingOf(context);

    final showBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    void urlListImport({String? initValue, bool overrideInitValid = false}) {
      showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (ctx) {
          return GeneratedFormModal(
            initValid: overrideInitValid,
            title: tr('importFromURLList'),
            items: [
              [
                GeneratedFormTextField(
                  'appURLList',
                  defaultValue: initValue ?? '',
                  label: tr('appURLList'),
                  max: 7,
                  additionalValidators: [
                    (dynamic value) {
                      if (value != null && value.isNotEmpty) {
                        var lines = value.trim().split('\n');
                        for (int i = 0; i < lines.length; i++) {
                          try {
                            sourceProvider.getSource(lines[i]);
                          } catch (e) {
                            return '${tr('line')} ${i + 1}: $e';
                          }
                        }
                      }
                      return null;
                    },
                  ],
                ),
              ],
            ],
          );
        },
      ).then((values) {
        if (values != null) {
          var urls = (values['appURLList'] as String).split('\n');
          setState(() {
            importInProgress = true;
          });
          appsProvider
              .addAppsByURL(urls)
              .then((errors) {
                if (errors.isEmpty) {
                  showMessage(
                    tr(
                      'importedX',
                      args: [plural('apps', urls.length).toLowerCase()],
                    ),
                    context,
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return ImportErrorDialog(
                        urlsLength: urls.length,
                        errors: errors,
                      );
                    },
                  );
                }
              })
              .catchError((e) {
                showError(e, context);
              })
              .whenComplete(() {
                setState(() {
                  importInProgress = false;
                });
              });
        }
      });
    }

    Future<void> runObtainiumExport({bool pickOnly = false}) async {
      HapticFeedback.selectionClick();
      appsProvider
          .export(
            pickOnly:
                pickOnly || (await settingsProvider.getExportDir()) == null,
            sp: settingsProvider,
          )
          .then((String? result) {
            if (result != null) {
              showMessage(tr('exportedTo', args: [result]), context);
            }
          })
          .catchError((e) {
            showError(e, context);
          });
    }

    void runObtainiumImport() {
      HapticFeedback.selectionClick();
      FilePicker.platform
          .pickFiles()
          .then((result) {
            setState(() {
              importInProgress = true;
            });
            if (result != null) {
              String data = File(result.files.single.path!).readAsStringSync();
              try {
                jsonDecode(data);
              } catch (e) {
                throw ObtainiumError(tr('invalidInput'));
              }
              appsProvider.import(data).then((value) {
                var cats = settingsProvider.categories;
                appsProvider.apps.forEach((key, value) {
                  for (var c in value.app.categories) {
                    if (!cats.containsKey(c)) {
                      cats[c] = generateRandomLightColor().toARGB32();
                    }
                  }
                });
                appsProvider.addMissingCategories(settingsProvider);
                showMessage(
                  '${tr('importedX', args: [plural('apps', value.key.length).toLowerCase()])}${value.value ? ' + ${tr('settings').toLowerCase()}' : ''}',
                  context,
                );
              });
            } else {
              // User canceled the picker
            }
          })
          .catchError((e) {
            showError(e, context);
          })
          .whenComplete(() {
            setState(() {
              importInProgress = false;
            });
          });
    }

    void runUrlImport() {
      FilePicker.platform.pickFiles().then((result) {
        if (result != null) {
          urlListImport(
            overrideInitValid: true,
            initValue: RegExp('https?://[^"]+')
                .allMatches(File(result.files.single.path!).readAsStringSync())
                .map((e) => e.input.substring(e.start, e.end))
                .toSet()
                .toList()
                .where((url) {
                  try {
                    sourceProvider.getSource(url);
                    return true;
                  } catch (e) {
                    return false;
                  }
                })
                .join('\n'),
          );
        }
      });
    }

    void runSourceSearch(AppSource source) {
      () async {
            var values = await showDialog<Map<String, dynamic>?>(
              context: context,
              builder: (ctx) {
                return GeneratedFormModal(
                  title: tr('searchX', args: [source.name]),
                  items: [
                    [
                      GeneratedFormTextField(
                        'searchQuery',
                        label: tr('searchQuery'),
                        required: source.name != FDroidRepo().name,
                      ),
                    ],
                    ...source.searchQuerySettingFormItems.map((e) => [e]),
                    [
                      GeneratedFormTextField(
                        'url',
                        label: source.hosts.isNotEmpty
                            ? tr('overrideSource')
                            : plural('url', 1).substring(2),
                        defaultValue: source.hosts.isNotEmpty
                            ? source.hosts[0]
                            : '',
                        required: true,
                      ),
                    ],
                  ],
                );
              },
            );
            if (values != null) {
              setState(() {
                importInProgress = true;
              });
              if (source.hosts.isEmpty || values['url'] != source.hosts[0]) {
                source = sourceProvider.getSource(
                  values['url'],
                  overrideSource: source.runtimeType.toString(),
                );
              }
              var urlsWithDescriptions = await source.search(
                values['searchQuery'] as String,
                querySettings: values,
              );
              if (urlsWithDescriptions.isNotEmpty) {
                var selectedUrls = await showDialog<List<String>?>(
                  context: context,
                  builder: (ctx) {
                    return SelectionModal(
                      entries: urlsWithDescriptions,
                      selectedByDefault: false,
                    );
                  },
                );
                if (selectedUrls != null && selectedUrls.isNotEmpty) {
                  var errors = await appsProvider.addAppsByURL(
                    selectedUrls,
                    sourceOverride: source,
                  );
                  if (errors.isEmpty) {
                    showMessage(
                      tr(
                        'importedX',
                        args: [
                          plural('apps', selectedUrls.length).toLowerCase(),
                        ],
                      ),
                      context,
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return ImportErrorDialog(
                          urlsLength: selectedUrls.length,
                          errors: errors,
                        );
                      },
                    );
                  }
                }
              } else {
                throw ObtainiumError(tr('noResults'));
              }
            }
          }()
          .catchError((e) {
            showError(e, context);
          })
          .whenComplete(() {
            setState(() {
              importInProgress = false;
            });
          });
    }

    void runMassSourceImport(MassAppUrlSource source) {
      () async {
            var values = await showDialog<Map<String, dynamic>?>(
              context: context,
              builder: (ctx) {
                return GeneratedFormModal(
                  title: tr('importX', args: [source.name]),
                  items: source.requiredArgs
                      .map((e) => [GeneratedFormTextField(e, label: e)])
                      .toList(),
                );
              },
            );
            if (values != null) {
              setState(() {
                importInProgress = true;
              });
              var urlsWithDescriptions = await source.getUrlsWithDescriptions(
                values.values.map((e) => e.toString()).toList(),
              );
              var selectedUrls = await showDialog<List<String>?>(
                context: context,
                builder: (ctx) {
                  return SelectionModal(entries: urlsWithDescriptions);
                },
              );
              if (selectedUrls != null) {
                var errors = await appsProvider.addAppsByURL(selectedUrls);
                if (errors.isEmpty) {
                  showMessage(
                    tr(
                      'importedX',
                      args: [plural('apps', selectedUrls.length).toLowerCase()],
                    ),
                    context,
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return ImportErrorDialog(
                        urlsLength: selectedUrls.length,
                        errors: errors,
                      );
                    },
                  );
                }
              }
            }
          }()
          .catchError((e) {
            showError(e, context);
          })
          .whenComplete(() {
            setState(() {
              importInProgress = false;
            });
          });
    }

    var sourceStrings = <String, List<String>>{};
    sourceProvider.sources.where((e) => e.canSearch).forEach((s) {
      sourceStrings[s.name] = [s.name];
    });

    Widget getSliverAppBar() => CustomAppBar(
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
        tr("importExport"),
        textAlign: !showBackButton ? .center : .start,
      ),
    );

    final otherImportButtonsStyle = LegacyThemeFactory.createButtonStyle(
      colorTheme: colorTheme,
      elevationTheme: elevationTheme,
      shapeTheme: shapeTheme,
      stateTheme: stateTheme,
      typescaleTheme: typescaleTheme,
      size: .small,
      shape: .square,
      color: .filled,
      containerColor: useBlackTheme
          ? colorTheme.surfaceContainer
          : colorTheme.surfaceContainerHighest,
      contentColor: useBlackTheme
          ? colorTheme.primary
          : colorTheme.onSurfaceVariant,
    );

    Widget getSliverList() => SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      sliver: SliverList.list(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              tr("obtainiumExport"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typescaleTheme.labelLarge.toTextStyle(
                color: colorTheme.onSurfaceVariant,
              ),
            ),
          ),
          FutureBuilder(
            future: settingsProvider.getExportDir(),
            builder: (context, snapshot) {
              final hasExportDir = snapshot.data != null;
              return Flex.vertical(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    // style: ButtonStyle(
                    //   animationDuration: Duration.zero,
                    //   elevation: const WidgetStatePropertyAll(0.0),
                    //   shadowColor: WidgetStateColor.transparent,
                    //   minimumSize: const WidgetStatePropertyAll(
                    //     Size(48.0, 56.0),
                    //   ),
                    //   fixedSize: const WidgetStatePropertyAll(null),
                    //   maximumSize: const WidgetStatePropertyAll(Size.infinite),
                    //   padding: const WidgetStatePropertyAll(
                    //     EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    //   ),
                    //   iconSize: const WidgetStatePropertyAll(24.0),
                    //   shape: WidgetStatePropertyAll(
                    //     CornersBorder.rounded(
                    //       corners: Corners.all(shapeTheme.corner.large),
                    //     ),
                    //   ),
                    //   overlayColor: WidgetStateLayerColor(
                    //     color: WidgetStatePropertyAll(
                    //       hasExportDir
                    //           ? colorTheme.onSurfaceVariant
                    //           : colorTheme.onPrimary,
                    //     ),
                    //     opacity: stateTheme.asWidgetStateLayerOpacity,
                    //   ),
                    //   backgroundColor: WidgetStateProperty.resolveWith(
                    //     (states) => states.contains(WidgetState.disabled)
                    //         ? colorTheme.onSurface.withValues(alpha: 0.1)
                    //         : hasExportDir
                    //         ? colorTheme.surfaceBright
                    //         : colorTheme.primary,
                    //   ),
                    //   foregroundColor: WidgetStateProperty.resolveWith(
                    //     (states) => states.contains(WidgetState.disabled)
                    //         ? colorTheme.onSurface.withValues(alpha: 0.38)
                    //         : hasExportDir
                    //         ? colorTheme.onSurfaceVariant
                    //         : colorTheme.onPrimary,
                    //   ),
                    //   textStyle: WidgetStateProperty.resolveWith(
                    //     (states) =>
                    //         (hasExportDir
                    //                 ? typescaleTheme.titleMedium
                    //                 : typescaleTheme.titleMediumEmphasized)
                    //             .toTextStyle(),
                    //   ),
                    // ),
                    style: LegacyThemeFactory.createButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      size: .medium,
                      shape: .square,
                      color: .filled,
                      isSelected: !hasExportDir,
                      unselectedContainerColor: useBlackTheme
                          ? colorTheme.surfaceContainer
                          : colorTheme.surfaceContainerHighest,
                      unselectedContentColor: colorTheme.primary,
                      unselectedTextStyle: typescaleTheme.titleMedium
                          .toTextStyle(),
                      selectedTextStyle: typescaleTheme.titleMediumEmphasized
                          .toTextStyle(),
                    ),
                    onPressed: importInProgress
                        ? null
                        : () {
                            runObtainiumExport(pickOnly: true);
                          },
                    icon: const Icon(
                      Symbols.folder_open_rounded,
                      fill: 1.0,
                      opticalSize: 24.0,
                    ),
                    label: Text(
                      tr('pickExportDir'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  FilledButton.icon(
                    style: LegacyThemeFactory.createButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      size: .medium,
                      shape: .round,
                      color: .filled,
                      textStyle: typescaleTheme.titleMediumEmphasized
                          .toTextStyle(),
                    ),
                    onPressed: importInProgress || snapshot.data == null
                        ? null
                        : runObtainiumExport,
                    icon: const Icon(
                      Symbols.file_export_rounded,
                      fill: 1.0,
                      opticalSize: 24.0,
                    ),
                    label: Text(
                      tr('obtainiumExport'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasExportDir)
                    Flex.vertical(
                      children: [
                        const SizedBox(height: 16),
                        GeneratedForm(
                          items: [
                            [
                              GeneratedFormSwitch(
                                'autoExportOnChanges',
                                label: tr('autoExportOnChanges'),
                                defaultValue:
                                    settingsProvider.autoExportOnChanges,
                              ),
                            ],
                            [
                              GeneratedFormDropdown(
                                'exportSettings',
                                [
                                  MapEntry('0', tr('none')),
                                  MapEntry('1', tr('excludeSecrets')),
                                  MapEntry('2', tr('all')),
                                ],
                                label: tr('includeSettings'),
                                defaultValue: settingsProvider.exportSettings
                                    .toString(),
                              ),
                            ],
                          ],
                          onValueChanges: (value, valid, isBuilding) {
                            if (valid && !isBuilding) {
                              if (value['autoExportOnChanges'] != null) {
                                settingsProvider.autoExportOnChanges =
                                    value['autoExportOnChanges'] == true;
                              }
                              if (value['exportSettings'] != null) {
                                settingsProvider.exportSettings = int.parse(
                                  value['exportSettings'],
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              tr("obtainiumImport"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typescaleTheme.labelLarge.toTextStyle(
                color: colorTheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton.icon(
            style: LegacyThemeFactory.createButtonStyle(
              colorTheme: colorTheme,
              elevationTheme: elevationTheme,
              shapeTheme: shapeTheme,
              stateTheme: stateTheme,
              typescaleTheme: typescaleTheme,
              size: .medium,
              shape: .round,
              color: .filled,
              textStyle: typescaleTheme.titleMediumEmphasized.toTextStyle(),
            ),
            onPressed: importInProgress ? null : runObtainiumImport,
            icon: const Icon(
              Symbols.file_open_rounded,
              fill: 1.0,
              opticalSize: 24.0,
            ),
            label: Text(
              tr('obtainiumImport'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (importInProgress)
            const Flex.vertical(
              children: [
                SizedBox(height: 14),
                LinearProgressIndicator(value: null),
                SizedBox(height: 14),
              ],
            )
          else
            Flex.vertical(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8.0 - 4.0),
                FilledButton.icon(
                  style: otherImportButtonsStyle,
                  onPressed: importInProgress
                      ? null
                      : () async {
                          var searchSourceName =
                              await showDialog<List<String>?>(
                                context: context,
                                builder: (ctx) {
                                  return SelectionModal(
                                    title: tr(
                                      'selectX',
                                      args: [tr('source').toLowerCase()],
                                    ),
                                    entries: sourceStrings,
                                    selectedByDefault: false,
                                    onlyOneSelectionAllowed: true,
                                    titlesAreLinks: false,
                                  );
                                },
                              ) ??
                              [];
                          var searchSource = sourceProvider.sources
                              .where((e) => searchSourceName.contains(e.name))
                              .toList();
                          if (searchSource.isNotEmpty) {
                            runSourceSearch(searchSource[0]);
                          }
                        },
                  icon: const Icon(
                    Symbols.search_rounded,
                    fill: 1.0,
                    opticalSize: 20.0,
                  ),
                  label: Text(
                    tr('searchX', args: [lowerCaseIfEnglish(tr('source'))]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FilledButton.icon(
                  style: otherImportButtonsStyle,
                  onPressed: importInProgress ? null : urlListImport,
                  icon: const Icon(
                    Symbols.add_link_rounded,
                    fill: 1.0,
                    opticalSize: 20.0,
                  ),
                  label: Text(
                    tr('importFromURLList'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FilledButton.icon(
                  style: otherImportButtonsStyle,
                  onPressed: importInProgress ? null : runUrlImport,
                  icon: const Icon(
                    Symbols.dataset_linked_rounded,
                    fill: 1.0,
                    opticalSize: 20.0,
                  ),
                  label: Text(
                    tr('importFromURLsInFile'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ...sourceProvider.massUrlSources.map(
            (source) => Flex.vertical(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  style: otherImportButtonsStyle,
                  onPressed: importInProgress
                      ? null
                      : () {
                          runMassSourceImport(source);
                        },
                  icon: const Icon(
                    Symbols.star_rounded,
                    fill: 1.0,
                    opticalSize: 20.0,
                  ),
                  label: Text(
                    tr('importX', args: [source.name]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Text(
            tr('importedAppsIdDisclaimer'),
            textAlign: TextAlign.start,
            style: typescaleTheme.bodyMedium.toTextStyle(
              color: colorTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            getSliverAppBar(),
            getSliverList(),
            SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
          ],
        ),
      ),
    );
  }
}

class ImportErrorDialog extends StatefulWidget {
  const ImportErrorDialog({
    super.key,
    required this.urlsLength,
    required this.errors,
  });

  final int urlsLength;
  final List<List<String>> errors;

  @override
  State<ImportErrorDialog> createState() => _ImportErrorDialogState();
}

class _ImportErrorDialogState extends State<ImportErrorDialog> {
  @override
  Widget build(BuildContext context) {
    final typescaleTheme = TypescaleTheme.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(tr('importErrors')),
      content: Flex.vertical(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr(
              'importedXOfYApps',
              args: [
                (widget.urlsLength - widget.errors.length).toString(),
                widget.urlsLength.toString(),
              ],
            ),
            style: typescaleTheme.bodyLarge.toTextStyle(),
          ),
          const SizedBox(height: 16),
          Text(
            tr('followingURLsHadErrors'),
            style: typescaleTheme.bodyLarge.toTextStyle(),
          ),
          ...widget.errors.map((e) {
            return Flex.vertical(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(e[0]),
                Text(e[1], style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text(tr('ok')),
        ),
      ],
    );
  }
}

class SelectionModal extends StatefulWidget {
  const SelectionModal({
    super.key,
    required this.entries,
    this.selectedByDefault = true,
    this.onlyOneSelectionAllowed = false,
    this.titlesAreLinks = true,
    this.title,
    this.deselectThese = const [],
  });

  final String? title;
  final Map<String, List<String>> entries;
  final bool selectedByDefault;
  final List<String> deselectThese;
  final bool onlyOneSelectionAllowed;
  final bool titlesAreLinks;

  @override
  State<SelectionModal> createState() => _SelectionModalState();
}

class _SelectionModalState extends State<SelectionModal> {
  Map<MapEntry<String, List<String>>, bool> _entrySelections = {};
  String _filterRegex = '';

  @override
  void initState() {
    super.initState();
    for (final entry in widget.entries.entries) {
      _entrySelections.putIfAbsent(
        entry,
        () =>
            widget.selectedByDefault &&
            !widget.onlyOneSelectionAllowed &&
            !widget.deselectThese.contains(entry.key),
      );
    }
    if (widget.selectedByDefault && widget.onlyOneSelectionAllowed) {
      _selectOnlyOne(widget.entries.entries.first.key);
    }
  }

  void _selectOnlyOne(String url) {
    for (final entry in _entrySelections.keys) {
      _entrySelections[entry] = entry.key == url;
    }
  }

  void _selectEntry(MapEntry<String, List<String>> entry, bool? value) {
    setState(() {
      value ??= false;
      if (value! && widget.onlyOneSelectionAllowed) {
        _selectOnlyOne(entry.key);
      } else {
        _entrySelections[entry] = value!;
      }
    });
  }

  void _selectAll({bool deselect = false}) {
    for (final e in _entrySelections.keys) {
      _entrySelections[e] = !deselect;
    }
  }

  @override
  Widget build(BuildContext context) {
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final height = MediaQuery.heightOf(context);

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final filteredEntrySelections = <MapEntry<String, List<String>>, bool>{};
    _entrySelections.forEach((key, value) {
      final searchableText = key.value.isEmpty ? key.key : key.value[0];
      if (_filterRegex.isEmpty ||
          RegExp(_filterRegex).hasMatch(searchableText)) {
        filteredEntrySelections.putIfAbsent(key, () => value);
      }
    });
    if (_filterRegex.isNotEmpty && filteredEntrySelections.isEmpty) {
      _entrySelections.forEach((key, value) {
        final searchableText = key.value.isEmpty ? key.key : key.value[0];
        if (_filterRegex.isEmpty ||
            RegExp(
              _filterRegex,
              caseSensitive: false,
            ).hasMatch(searchableText)) {
          filteredEntrySelections.putIfAbsent(key, () => value);
        }
      });
    }

    Widget getSelectAllButton() {
      if (widget.onlyOneSelectionAllowed) {
        return const SizedBox.shrink();
      }
      final noneSelected = _entrySelections.values
          .where((v) => v == true)
          .isEmpty;
      return TextButton(
        style: LegacyThemeFactory.createButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          typescaleTheme: typescaleTheme,
          color: .text,
        ),
        onPressed: () {
          setState(() {
            _selectAll(deselect: !noneSelected);
          });
        },
        child: Text(
          noneSelected ? tr("selectAll") : tr("deselectX", args: [""]),
        ),
      );
    }

    final selectedEntries = _entrySelections.entries
        .where((e) => e.value)
        .toList();

    Widget content = ListItemTheme.merge(
      data: .from(
        overlineTextStyle: .all(typescaleTheme.labelSmall.toTextStyle()),
        headlineTextStyle: .all(
          typescaleTheme.bodyMediumEmphasized.toTextStyle(),
        ),
        supportingTextStyle: .all(typescaleTheme.bodySmall.toTextStyle()),
      ),
      child: Flex.vertical(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        spacing: 2.0,
        children: filteredEntrySelections.keys
            .mapIndexed((index, entry) {
              final isFirst = index == 0;
              final isLast = index == filteredEntrySelections.length - 1;
              final isSelected = _entrySelections[entry];

              return ListItemContainer(
                isFirst: isFirst,
                isLast: isLast,
                containerColor: const .all(Colors.transparent),
                child: ListItemInteraction(
                  onTap: () {
                    if (widget.onlyOneSelectionAllowed) {
                      setState(() {
                        _selectOnlyOne(entry.key);
                      });
                    } else {
                      _selectEntry(entry, !(isSelected ?? false));
                    }
                  },
                  child: ListItemLayout(
                    padding: .fromSTEB(
                      16.0 - 4.0,
                      0.0,
                      widget.titlesAreLinks ? 16.0 - 8.0 : 16.0,
                      0.0,
                    ),
                    leadingPadding: const .symmetric(
                      vertical: 10.0 - (48.0 - 40.0) / 2.0,
                    ),
                    trailingPadding: widget.titlesAreLinks
                        ? const .symmetric(vertical: 10.0 - (48.0 - 40.0) / 2.0)
                        : null,
                    leading: ExcludeFocus(
                      child: widget.onlyOneSelectionAllowed
                          ? RadioGroupButton<String>(value: entry.key)
                          : Checkbox.bistate(
                              checked: isSelected!,
                              onCheckedChanged: (value) =>
                                  _selectEntry(entry, value),
                            ),
                    ),
                    overline: widget.titlesAreLinks
                        ? Text(
                            Uri.parse(entry.key).host,
                            style: const TextStyle(),
                          )
                        : null,
                    headline: Text(
                      entry.value.isEmpty ? entry.key : entry.value[0],
                    ),
                    supportingText: entry.value.length > 1
                        ? Text(
                            entry.value[1].length > 128
                                ? "${entry.value[1].substring(0, 128)}..."
                                : entry.value[1],
                          )
                        : null,
                    trailing: widget.titlesAreLinks
                        ? IconButton(
                            style: LegacyThemeFactory.createIconButtonStyle(
                              colorTheme: colorTheme,
                              elevationTheme: elevationTheme,
                              shapeTheme: shapeTheme,
                              stateTheme: stateTheme,
                              color: .standard,
                              width: .narrow,
                              containerColor: colorTheme.surfaceContainer,
                            ),
                            onPressed: () {
                              launchUrlString(
                                entry.key,
                                mode: .externalApplication,
                              );
                            },
                            icon: const Icon(Symbols.link_rounded),
                          )
                        : null,
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );

    if (widget.onlyOneSelectionAllowed) {
      content = RadioButtonTheme.merge(
        data: CustomThemeFactory.createRadioButtonTheme(
          colorTheme: colorTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          color: .standard,
        ),
        child: RadioGroup<String>(
          groupValue: selectedEntries.isEmpty
              ? null
              : selectedEntries.first.key.key,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectOnlyOne(value);
            });
          },
          child: content,
        ),
      );
    } else {
      content = CheckboxTheme.merge(
        data: CustomThemeFactory.createCheckboxTheme(
          colorTheme: colorTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          color: .standard,
        ),
        child: content,
      );
    }

    return AlertDialog(
      scrollable: true,
      backgroundColor: useBlackTheme ? colorTheme.surfaceContainerLow : null,
      constraints: BoxConstraints(
        minWidth: 560.0,
        maxWidth: 560.0,
        minHeight: 280.0,
        maxHeight: height * 2.0 / 3.0,
      ),
      title: Text(widget.title ?? tr("pick")),
      titlePadding: const .fromSTEB(24.0, 24.0, 24.0, 16.0),
      contentPadding: const .symmetric(),
      content: Flex.vertical(
        children: [
          Padding(
            padding: const .symmetric(horizontal: 24.0),
            child: GeneratedForm(
              items: [
                [
                  GeneratedFormTextField(
                    "filter",
                    label: tr("filter"),
                    required: false,
                    additionalValidators: [
                      (value) {
                        return regExValidator(value);
                      },
                    ],
                  ),
                ],
              ],
              onValueChanges: (value, valid, isBuilding) {
                if (valid && !isBuilding) {
                  if (value["filter"] != null) {
                    setState(() {
                      _filterRegex = value["filter"];
                    });
                  }
                }
              },
              textFieldType: .outlined,
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(padding: const .symmetric(horizontal: 8.0), child: content),
        ],
      ),
      actionsPadding: const .symmetric(horizontal: 24.0, vertical: 24.0 - 4.0),
      actions: [
        getSelectAllButton(),
        TextButton(
          style: LegacyThemeFactory.createButtonStyle(
            colorTheme: colorTheme,
            elevationTheme: elevationTheme,
            shapeTheme: shapeTheme,
            stateTheme: stateTheme,
            typescaleTheme: typescaleTheme,
            color: .text,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(tr("cancel")),
        ),
        TextButton(
          style: LegacyThemeFactory.createButtonStyle(
            colorTheme: colorTheme,
            elevationTheme: elevationTheme,
            shapeTheme: shapeTheme,
            stateTheme: stateTheme,
            typescaleTheme: typescaleTheme,
            color: .text,
          ),
          onPressed: _entrySelections.values.where((b) => b).isEmpty
              ? null
              : () {
                  Navigator.of(context).pop(
                    _entrySelections.entries
                        .where((entry) => entry.value)
                        .map((e) => e.key.key)
                        .toList(),
                  );
                },
          child: Text(
            widget.onlyOneSelectionAllowed
                ? tr("pick")
                : tr(
                    "selectX",
                    args: [
                      _entrySelections.values.where((b) => b).length.toString(),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
