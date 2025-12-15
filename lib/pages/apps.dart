import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/assets/assets.gen.dart';
import 'package:materium/components/custom_decorated_sliver.dart';
import 'package:materium/components/custom_list.dart';
import 'package:materium/components/custom_refresh_indicator.dart';
import 'package:materium/components/custom_sliver_scrollbar.dart';
import 'package:materium/flutter.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/generated_form.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/app.dart';
import 'package:materium/pages/settings.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:markdown/markdown.dart' as md;

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => AppsPageState();
}

void showChangeLogDialog(
  BuildContext context,
  App app,
  String? changesUrl,
  AppSource appSource,
  String changeLog,
) {
  showDialog(
    context: context,
    builder: (context) {
      // TODO: completely redesign this dialog, turning it into a bottom sheet
      return GeneratedFormModal(
        title: tr('changes'),
        items: const [],
        message: app.latestVersion,
        additionalWidgets: [
          changesUrl != null
              ? GestureDetector(
                  child: Text(
                    changesUrl,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    launchUrlString(
                      changesUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                )
              : const SizedBox.shrink(),
          changesUrl != null
              ? const SizedBox(height: 16)
              : const SizedBox.shrink(),
          appSource.changeLogIfAnyIsMarkDown
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 350,
                  // TODO: create markdown styles for M3E
                  child: Markdown(
                    styleSheet: MarkdownStyleSheet(
                      blockquoteDecoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                    data: changeLog,
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrlString(
                          href.startsWith('http://') ||
                                  href.startsWith('https://')
                              ? href
                              : '${Uri.parse(app.url).origin}/$href',
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                      [
                        md.EmojiSyntax(),
                        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                      ],
                    ),
                  ),
                )
              : Text(changeLog),
        ],
        singleNullReturnButton: tr('ok'),
      );
    },
  );
}

Null Function()? getChangeLogFn(BuildContext context, App app) {
  AppSource appSource = SourceProvider().getSource(
    app.url,
    overrideSource: app.overrideSource,
  );
  String? changesUrl = appSource.changeLogPageFromStandardUrl(app.url);
  String? changeLog = app.changeLog;
  if (changeLog?.split('\n').length == 1) {
    if (RegExp(
      '(http|ftp|https)://([\\w_-]+(?:(?:\\.[\\w_-]+)+))([\\w.,@?^=%&:/~+#-]*[\\w@?^=%&/~+#-])?',
    ).hasMatch(changeLog!)) {
      if (changesUrl == null) {
        changesUrl = changeLog;
        changeLog = null;
      }
    }
  }
  return (changeLog == null && changesUrl == null)
      ? null
      : () {
          if (changeLog != null) {
            showChangeLogDialog(context, app, changesUrl, appSource, changeLog);
          } else {
            launchUrlString(changesUrl!, mode: LaunchMode.externalApplication);
          }
        };
}

class AppsPageState extends State<AppsPage> with TickerProviderStateMixin {
  AppsFilter filter = AppsFilter();
  final AppsFilter neutralFilter = AppsFilter();
  var updatesOnlyFilter = AppsFilter(
    includeUptodate: false,
    includeNonInstalled: false,
  );
  Set<String> selectedAppIds = {};
  DateTime? refreshingSince;

  bool clearSelected() {
    if (selectedAppIds.isNotEmpty) {
      setState(() {
        selectedAppIds.clear();
      });
      return true;
    }
    return false;
  }

  void selectThese(List<App> apps) {
    if (selectedAppIds.isEmpty) {
      setState(() {
        for (var a in apps) {
          selectedAppIds.add(a.id);
        }
      });
    }
  }

  final GlobalKey<CustomRefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<CustomRefreshIndicatorState>();

  late final ScrollController scrollController = ScrollController();

  var sourceProvider = SourceProvider();

  @override
  Widget build(BuildContext context) {
    var appsProvider = context.watch<AppsProvider>();
    var settingsProvider = context.watch<SettingsProvider>();
    var listedApps = appsProvider.getAppValues().toList();

    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    Future<List<App>> refresh() {
      HapticFeedback.lightImpact();
      setState(() {
        refreshingSince = DateTime.now();
      });
      return appsProvider
          .checkUpdates()
          .catchError((e) {
            showError(e is Map ? e['errors'] : e, context);
            return <App>[];
          })
          .whenComplete(() {
            setState(() {
              refreshingSince = null;
            });
          });
    }

    if (!appsProvider.loadingApps &&
        appsProvider.apps.isNotEmpty &&
        settingsProvider.checkJustStarted() &&
        settingsProvider.checkOnStart) {
      _refreshIndicatorKey.currentState?.show();
    }

    selectedAppIds = selectedAppIds
        .where((element) => listedApps.map((e) => e.app.id).contains(element))
        .toSet();

    void toggleAppSelected(App app) {
      setState(() {
        if (selectedAppIds.map((e) => e).contains(app.id)) {
          selectedAppIds.removeWhere((a) => a == app.id);
        } else {
          selectedAppIds.add(app.id);
        }
      });
    }

    listedApps =
        listedApps.where((app) {
          if (app.app.installedVersion == app.app.latestVersion &&
              !(filter.includeUptodate)) {
            return false;
          }
          if (app.app.installedVersion == null &&
              !(filter.includeNonInstalled)) {
            return false;
          }
          if (filter.nameFilter.isNotEmpty || filter.authorFilter.isNotEmpty) {
            List<String> nameTokens = filter.nameFilter
                .split(' ')
                .where((element) => element.trim().isNotEmpty)
                .toList();
            List<String> authorTokens = filter.authorFilter
                .split(' ')
                .where((element) => element.trim().isNotEmpty)
                .toList();

            for (var t in nameTokens) {
              if (!app.name.toLowerCase().contains(t.toLowerCase())) {
                return false;
              }
            }
            for (var t in authorTokens) {
              if (!app.author.toLowerCase().contains(t.toLowerCase())) {
                return false;
              }
            }
          }
          if (filter.idFilter.isNotEmpty) {
            if (!app.app.id.contains(filter.idFilter)) {
              return false;
            }
          }
          if (filter.categoryFilter.isNotEmpty &&
              filter.categoryFilter
                  .intersection(app.app.categories.toSet())
                  .isEmpty) {
            return false;
          }
          if (filter.sourceFilter.isNotEmpty &&
              sourceProvider
                      .getSource(
                        app.app.url,
                        overrideSource: app.app.overrideSource,
                      )
                      .runtimeType
                      .toString() !=
                  filter.sourceFilter) {
            return false;
          }
          return true;
        }).toList()..sort((a, b) {
          var result = 0;
          if (settingsProvider.sortColumn == SortColumnSettings.authorName) {
            result = ((a.author + a.name).toLowerCase()).compareTo(
              (b.author + b.name).toLowerCase(),
            );
          } else if (settingsProvider.sortColumn ==
              SortColumnSettings.nameAuthor) {
            result = ((a.name + a.author).toLowerCase()).compareTo(
              (b.name + b.author).toLowerCase(),
            );
          } else if (settingsProvider.sortColumn ==
              SortColumnSettings.releaseDate) {
            // Handle null dates: apps with unknown release dates are grouped at the end
            final aDate = a.app.releaseDate;
            final bDate = b.app.releaseDate;
            if (aDate == null && bDate == null) {
              // Both null: sort by name for consistency
              result = ((a.name + a.author).toLowerCase()).compareTo(
                (b.name + b.author).toLowerCase(),
              );
            } else if (aDate == null) {
              // a has no date, push to end (ascending) or beginning (will be reversed for descending)
              result = 1;
            } else if (bDate == null) {
              // b has no date, push to end
              result = -1;
            } else {
              result = aDate.compareTo(bDate);
            }
          }
          return result;
        });

    if (settingsProvider.sortOrder == SortOrderSettings.descending) {
      listedApps = listedApps.reversed.toList();
    }

    var existingUpdates = appsProvider.findExistingUpdates(installedOnly: true);

    var existingUpdateIdsAllOrSelected = existingUpdates
        .where(
          (element) => selectedAppIds.isEmpty
              ? listedApps.where((a) => a.app.id == element).isNotEmpty
              : selectedAppIds.map((e) => e).contains(element),
        )
        .toList();
    var newInstallIdsAllOrSelected = appsProvider
        .findExistingUpdates(nonInstalledOnly: true)
        .where(
          (element) => selectedAppIds.isEmpty
              ? listedApps.where((a) => a.app.id == element).isNotEmpty
              : selectedAppIds.map((e) => e).contains(element),
        )
        .toList();

    List<String> trackOnlyUpdateIdsAllOrSelected = [];
    existingUpdateIdsAllOrSelected = existingUpdateIdsAllOrSelected.where((id) {
      if (appsProvider.apps[id]!.app.additionalSettings['trackOnly'] == true) {
        trackOnlyUpdateIdsAllOrSelected.add(id);
        return false;
      }
      return true;
    }).toList();
    newInstallIdsAllOrSelected = newInstallIdsAllOrSelected.where((id) {
      if (appsProvider.apps[id]!.app.additionalSettings['trackOnly'] == true) {
        trackOnlyUpdateIdsAllOrSelected.add(id);
        return false;
      }
      return true;
    }).toList();

    if (settingsProvider.pinUpdates) {
      var temp = [];
      listedApps = listedApps.where((sa) {
        if (existingUpdates.contains(sa.app.id)) {
          temp.add(sa);
          return false;
        }
        return true;
      }).toList();
      listedApps = [...temp, ...listedApps];
    }

    if (settingsProvider.buryNonInstalled) {
      var temp = [];
      listedApps = listedApps.where((sa) {
        if (sa.app.installedVersion == null) {
          temp.add(sa);
          return false;
        }
        return true;
      }).toList();
      listedApps = [...listedApps, ...temp];
    }

    var tempPinned = [];
    var tempNotPinned = [];
    for (var a in listedApps) {
      if (a.app.pinned) {
        tempPinned.add(a);
      } else {
        tempNotPinned.add(a);
      }
    }
    listedApps = [...tempPinned, ...tempNotPinned];

    List<String?> getListedCategories() {
      var temp = listedApps.map(
        (e) => e.app.categories.isNotEmpty ? e.app.categories : [null],
      );
      return temp.isNotEmpty
          ? {
              ...temp.reduce((v, e) => [...v, ...e]),
            }.toList()
          : [];
    }

    final listedCategories = getListedCategories()
      ..sort((a, b) {
        return a != null && b != null
            ? a.toLowerCase().compareTo(b.toLowerCase())
            : a == null
            ? 1
            : -1;
      });

    Set<App> selectedApps = listedApps
        .map((e) => e.app)
        .where((a) => selectedAppIds.contains(a.id))
        .toSet();

    List<Widget> getLoadingWidgets() {
      return [
        if (listedApps.isEmpty)
          SliverFillRemaining(
            child: Align.center(
              child: Text(
                appsProvider.apps.isEmpty
                    ? appsProvider.loadingApps
                          ? tr('pleaseWait')
                          : tr('noApps')
                    : tr('noAppsForFilter'),
                style: typescaleTheme.headlineMedium.toTextStyle(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (refreshingSince != null || appsProvider.loadingApps)
          SliverToBoxAdapter(
            child: LinearProgressIndicator(
              value: appsProvider.loadingApps
                  ? null
                  : appsProvider
                            .getAppValues()
                            .where(
                              (element) =>
                                  !(element.app.lastUpdateCheck?.isBefore(
                                        refreshingSince!,
                                      ) ??
                                      true),
                            )
                            .length /
                        (appsProvider.apps.isNotEmpty
                            ? appsProvider.apps.length
                            : 1),
            ),
          ),
      ];
    }

    Widget getUpdateButton(int appIndex) {
      return IconButton(
        visualDensity: VisualDensity.compact,
        color: colorTheme.primary,
        tooltip:
            listedApps[appIndex].app.additionalSettings['trackOnly'] == true
            ? tr('markUpdated')
            : tr('update'),
        onPressed: appsProvider.areDownloadsRunning()
            ? null
            : () {
                appsProvider
                    .downloadAndInstallLatestApps([
                      listedApps[appIndex].app.id,
                    ], globalNavigatorKey.currentContext)
                    .catchError((e) {
                      showError(e, context);
                      return <String>[];
                    });
              },
        icon: listedApps[appIndex].app.additionalSettings['trackOnly'] == true
            ? const IconLegacy(Symbols.check_circle_rounded, fill: 0)
            : const IconLegacy(Symbols.install_mobile, fill: 0),
      );
    }

    Widget getAppIcon(int appIndex) {
      return GestureDetector(
        child: FutureBuilder(
          future: appsProvider.updateAppIcon(listedApps[appIndex].app.id),
          builder: (ctx, val) {
            return listedApps[appIndex].icon != null
                ? Image.memory(
                    listedApps[appIndex].icon!,
                    gaplessPlayback: true,
                    opacity: AlwaysStoppedAnimation(
                      listedApps[appIndex].installedInfo == null ? 0.6 : 1,
                    ),
                  )
                : Flex.horizontal(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationZ(0.31),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Assets.graphics.iconSmall.image(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.3),
                            colorBlendMode: BlendMode.modulate,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
        onDoubleTap: () {
          pm.openApp(listedApps[appIndex].app.id);
        },
        onLongPress: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AppPage(
                appId: listedApps[appIndex].app.id,
                showOppositeOfPreferredView: true,
              ),
            ),
          );
        },
      );
    }

    String getVersionText(int appIndex) {
      return listedApps[appIndex].app.installedVersion ?? tr('notInstalled');
    }

    String getChangesButtonString(int appIndex, bool hasChangeLogFn) {
      return listedApps[appIndex].app.releaseDate == null
          ? hasChangeLogFn
                ? tr('changes')
                : ''
          : DateFormat(
              'yyyy-MM-dd',
            ).format(listedApps[appIndex].app.releaseDate!.toLocal());
    }

    Widget getSingleAppHorizTile(int index) {
      var showChangesFn = getChangeLogFn(context, listedApps[index].app);
      var hasUpdate =
          listedApps[index].app.installedVersion != null &&
          listedApps[index].app.installedVersion !=
              listedApps[index].app.latestVersion;
      final isSelected = selectedAppIds
          .map((e) => e)
          .contains(listedApps[index].app.id);
      Widget trailingRow = Flex.horizontal(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hasUpdate ? getUpdateButton(index) : const SizedBox.shrink(),
          hasUpdate ? const SizedBox(width: 5) : const SizedBox.shrink(),
          Material(
            animationDuration: Duration.zero,
            type: MaterialType.card,
            clipBehavior: Clip.antiAlias,
            shape: CornersBorder.rounded(
              corners: Corners.all(shapeTheme.corner.medium),
            ),
            color: Colors.transparent,
            child: InkWell(
              onTap: showChangesFn,
              overlayColor: WidgetStateLayerColor(
                color: WidgetStatePropertyAll(
                  isSelected
                      ? colorTheme.onSecondaryContainer
                      : colorTheme.onSurface,
                ),
                opacity: stateTheme.stateLayerOpacity,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Flex.vertical(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flex.horizontal(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width / 4,
                          ),
                          child: Text(
                            getVersionText(index),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: isVersionPseudo(listedApps[index].app)
                                ? const TextStyle(fontStyle: FontStyle.italic)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    Flex.horizontal(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getChangesButtonString(index, showChangesFn != null),
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            decoration: showChangesFn != null
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

      var transparent = Theme.of(
        context,
      ).colorScheme.surface.withAlpha(0).toARGB32();
      List<double> stops = [
        ...listedApps[index].app.categories.asMap().entries.map(
          (e) =>
              ((e.key / (listedApps[index].app.categories.length - 1)) -
              0.0001),
        ),
        1,
      ];
      if (stops.length == 2) {
        stops[0] = 0.9999;
      }
      return DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: stops,
            begin: const Alignment(-1, 0),
            end: const Alignment(-0.97, 0),
            colors: [
              ...listedApps[index].app.categories.map(
                (e) => Color(
                  settingsProvider.categories[e] ?? transparent,
                ).withAlpha(255),
              ),
              Color(transparent),
            ],
          ),
        ),
        child: ListTile(
          minTileHeight: 72.0,
          tileColor: listedApps[index].app.pinned
              ? colorTheme.surfaceContainerHighest
              : Colors.transparent,
          selectedTileColor: colorTheme.secondaryContainer,
          selected: isSelected,
          onLongPress: () {
            toggleAppSelected(listedApps[index].app);
          },
          leading: getAppIcon(index),

          title: Text(
            maxLines: 1,
            listedApps[index].name,
            style: typescaleTheme.titleMediumEmphasized
                .toTextStyle(
                  color: isSelected
                      ? colorTheme.onSecondaryContainer
                      : colorTheme.onSurface,
                )
                .copyWith(overflow: TextOverflow.ellipsis),
          ),
          subtitle: Text(
            tr('byX', args: [listedApps[index].author]),
            maxLines: 1,
            style: typescaleTheme.bodyMedium
                .toTextStyle(
                  color: isSelected
                      ? colorTheme.onSecondaryContainer
                      : colorTheme.onSurfaceVariant,
                )
                .copyWith(overflow: TextOverflow.ellipsis),
          ),
          trailing: listedApps[index].downloadProgress != null
              ? SizedBox(
                  child: Text(
                    listedApps[index].downloadProgress! >= 0
                        ? tr(
                            'percentProgress',
                            args: [
                              listedApps[index].downloadProgress!
                                  .toInt()
                                  .toString(),
                            ],
                          )
                        : tr('installing'),
                    textAlign: (listedApps[index].downloadProgress! >= 0)
                        ? TextAlign.start
                        : TextAlign.end,
                  ),
                )
              : trailingRow,
          onTap: () {
            if (selectedAppIds.isNotEmpty) {
              toggleAppSelected(listedApps[index].app);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      AppPage(appId: listedApps[index].app.id),
                ),
              );
            }
          },
        ),
      );
    }

    Widget getCategoryCollapsibleTile(int index) {
      var tiles = listedApps
          .asMap()
          .entries
          .where(
            (e) =>
                e.value.app.categories.contains(listedCategories[index]) ||
                e.value.app.categories.isEmpty &&
                    listedCategories[index] == null,
          )
          .map((e) => getSingleAppHorizTile(e.key))
          .toList();

      String capFirstChar(String str) =>
          str[0].toUpperCase() + str.substring(1);
      return ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          capFirstChar(listedCategories[index] ?? tr('noCategory')),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        trailing: Text(tiles.length.toString()),
        children: tiles,
      );
    }

    void Function()? getMassObtainFunction() {
      return appsProvider.areDownloadsRunning() ||
              (existingUpdateIdsAllOrSelected.isEmpty &&
                  newInstallIdsAllOrSelected.isEmpty &&
                  trackOnlyUpdateIdsAllOrSelected.isEmpty)
          ? null
          : () {
              HapticFeedback.heavyImpact();
              List<GeneratedFormItem> formItems = [];
              if (existingUpdateIdsAllOrSelected.isNotEmpty) {
                formItems.add(
                  GeneratedFormSwitch(
                    'updates',
                    label: tr(
                      'updateX',
                      args: [
                        plural(
                          'apps',
                          existingUpdateIdsAllOrSelected.length,
                        ).toLowerCase(),
                      ],
                    ),
                    defaultValue: true,
                  ),
                );
              }
              if (newInstallIdsAllOrSelected.isNotEmpty) {
                formItems.add(
                  GeneratedFormSwitch(
                    'installs',
                    label: tr(
                      'installX',
                      args: [
                        plural(
                          'apps',
                          newInstallIdsAllOrSelected.length,
                        ).toLowerCase(),
                      ],
                    ),
                    defaultValue: existingUpdateIdsAllOrSelected.isEmpty,
                  ),
                );
              }
              if (trackOnlyUpdateIdsAllOrSelected.isNotEmpty) {
                formItems.add(
                  GeneratedFormSwitch(
                    'trackonlies',
                    label: tr(
                      'markXTrackOnlyAsUpdated',
                      args: [
                        plural('apps', trackOnlyUpdateIdsAllOrSelected.length),
                      ],
                    ),
                    defaultValue:
                        existingUpdateIdsAllOrSelected.isEmpty &&
                        newInstallIdsAllOrSelected.isEmpty,
                  ),
                );
              }
              showDialog<Map<String, dynamic>?>(
                context: context,
                builder: (ctx) {
                  var totalApps =
                      existingUpdateIdsAllOrSelected.length +
                      newInstallIdsAllOrSelected.length +
                      trackOnlyUpdateIdsAllOrSelected.length;
                  return GeneratedFormModal(
                    title: tr(
                      'changeX',
                      args: [plural('apps', totalApps).toLowerCase()],
                    ),
                    items: formItems.map((e) => [e]).toList(),
                    initValid: true,
                  );
                },
              ).then((values) async {
                if (values != null) {
                  if (values.isEmpty) {
                    values = getDefaultValuesFromFormItems([formItems]);
                  }
                  bool shouldInstallUpdates = values['updates'] == true;
                  bool shouldInstallNew = values['installs'] == true;
                  bool shouldMarkTrackOnlies = values['trackonlies'] == true;
                  List<String> toInstall = [];
                  if (shouldInstallUpdates) {
                    toInstall.addAll(existingUpdateIdsAllOrSelected);
                  }
                  if (shouldInstallNew) {
                    toInstall.addAll(newInstallIdsAllOrSelected);
                  }
                  if (shouldMarkTrackOnlies) {
                    toInstall.addAll(trackOnlyUpdateIdsAllOrSelected);
                  }
                  appsProvider
                      .downloadAndInstallLatestApps(
                        toInstall,
                        globalNavigatorKey.currentContext,
                      )
                      .catchError((e) {
                        showError(e, context);
                        return <String>[];
                      })
                      .then((value) {
                        if (value.isNotEmpty && shouldInstallUpdates) {
                          showMessage(tr('appsUpdated'), context);
                        }
                      });
                }
              });
            };
    }

    Future<void> Function() launchCategorizeDialog() {
      return () async {
        try {
          Set<String>? preselected;
          var showPrompt = false;
          for (var element in selectedApps) {
            var currentCats = element.categories.toSet();
            if (preselected == null) {
              preselected = currentCats;
            } else {
              if (!settingsProvider.setEqual(currentCats, preselected)) {
                showPrompt = true;
                break;
              }
            }
          }
          var cont = true;
          if (showPrompt) {
            cont =
                await showDialog<Map<String, dynamic>?>(
                  context: context,
                  builder: (ctx) {
                    return GeneratedFormModal(
                      title: tr('categorize'),
                      items: const [],
                      initValid: true,
                      message: tr('selectedCategorizeWarning'),
                    );
                  },
                ) !=
                null;
          }
          if (cont) {
            await showDialog<Map<String, dynamic>?>(
              context: context,
              builder: (ctx) {
                return GeneratedFormModal(
                  title: tr('categorize'),
                  items: const [],
                  initValid: true,
                  singleNullReturnButton: tr('continue'),
                  additionalWidgets: [
                    CategoryEditorSelector(
                      preselected: !showPrompt ? preselected ?? {} : {},
                      showLabelWhenNotEmpty: false,
                      onSelected: (categories) {
                        appsProvider.saveApps(
                          selectedApps.map((e) {
                            e.categories = categories;
                            return e;
                          }).toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        } catch (err) {
          showError(err, context);
        }
      };
    }

    Future<void> showMassMarkDialog() {
      return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              tr(
                'markXSelectedAppsAsUpdated',
                args: [selectedAppIds.length.toString()],
              ),
            ),
            content: Text(
              tr('onlyWorksWithNonVersionDetectApps'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(tr('no')),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  appsProvider.saveApps(
                    selectedApps.map((a) {
                      if (a.installedVersion != null &&
                          !appsProvider.isVersionDetectionPossible(
                            appsProvider.apps[a.id],
                          )) {
                        a.installedVersion = a.latestVersion;
                      }
                      return a;
                    }).toList(),
                  );

                  Navigator.of(context).pop();
                },
                child: Text(tr('yes')),
              ),
            ],
          );
        },
      ).whenComplete(() {
        Navigator.of(context).pop();
      });
    }

    void pinSelectedApps() {
      var pinStatus = selectedApps.where((element) => element.pinned).isEmpty;
      appsProvider.saveApps(
        selectedApps.map((e) {
          e.pinned = pinStatus;
          return e;
        }).toList(),
      );
      Navigator.of(context).pop();
    }

    Future<void> showMoreOptionsDialog() {
      return showModalBottomSheet(
        context: context,
        barrierColor: colorTheme.scrim.withValues(alpha: 0.32),
        useRootNavigator: true,
        isDismissible: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          final colorTheme = ColorTheme.of(context);
          final listItemContainerColor = colorTheme.surfaceContainerHigh;
          final iconContainerColor = colorTheme.surfaceContainerLow;
          final iconColor = colorTheme.onSurfaceVariant;
          final windowHeightSizeClass = WindowHeightSizeClass.of(context);
          return DraggableScrollableSheet(
            expand: false,
            shouldCloseOnMinExtent: true,
            initialChildSize: switch (windowHeightSizeClass) {
              WindowHeightSizeClass.compact => 1.0,
              WindowHeightSizeClass.medium => 0.75,
              WindowHeightSizeClass.expanded => 0.55,
            },
            maxChildSize: 1.0,
            builder: (context, scrollController) => CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  sliver: SliverList.list(
                    children: [
                      ListItemContainer(
                        isFirst: true,
                        containerColor: .all(listItemContainerColor),
                        child: ListItemInteraction(
                          onTap: pinSelectedApps,
                          child: ListItemLayout(
                            leading: SizedBox.square(
                              dimension: 40.0,
                              child: Material(
                                animationDuration: Duration.zero,
                                type: MaterialType.card,
                                clipBehavior: Clip.antiAlias,
                                color: iconContainerColor,
                                shape: const StadiumBorder(),
                                child: Align.center(
                                  child:
                                      selectedApps
                                          .where((element) => element.pinned)
                                          .isEmpty
                                      ? IconLegacy(
                                          Symbols.keep_rounded,
                                          fill: 1.0,
                                          color: colorTheme.onSurfaceVariant,
                                        )
                                      : IconLegacy(
                                          Symbols.keep_off_rounded,
                                          fill: 1.0,
                                          color: colorTheme.onSurfaceVariant,
                                        ),
                                ),
                              ),
                            ),
                            headline: Text(
                              selectedApps
                                      .where((element) => element.pinned)
                                      .isEmpty
                                  ? tr("pinToTop")
                                  : tr("unpinFromTop"),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        containerColor: .all(listItemContainerColor),
                        child: ListItemInteraction(
                          onTap: () {
                            String urls = "";
                            for (var a in selectedApps) {
                              urls += "${a.url}\n";
                            }
                            urls = urls.substring(0, urls.length - 1);
                            SharePlus.instance.share(
                              ShareParams(
                                text: urls,
                                subject: "Materium - ${tr("appsString")}",
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: ListItemLayout(
                            leading: SizedBox.square(
                              dimension: 40.0,
                              child: Material(
                                animationDuration: Duration.zero,
                                type: MaterialType.card,
                                clipBehavior: Clip.antiAlias,
                                color: iconContainerColor,
                                shape: const StadiumBorder(),
                                child: Align.center(
                                  child: IconLegacy(
                                    Symbols.share_rounded,
                                    fill: 1.0,
                                    color: colorTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            headline: Text(tr("shareSelectedAppURLs")),
                          ),
                        ),
                      ),
                      if (selectedApps.isNotEmpty) ...[
                        const SizedBox(height: 2.0),
                        ListItemContainer(
                          containerColor: .all(listItemContainerColor),
                          child: ListItemInteraction(
                            onTap: () {
                              String urls = "";
                              for (var a in selectedApps) {
                                urls +=
                                    "https://apps.obtainium.imranr.dev/redirect?r=obtainium://app/${Uri.encodeComponent(jsonEncode({"id": a.id, "url": a.url, "author": a.author, "name": a.name, "preferredApkIndex": a.preferredApkIndex, "additionalSettings": jsonEncode(a.additionalSettings), "overrideSource": a.overrideSource}))}\n\n";
                              }
                              SharePlus.instance.share(
                                ShareParams(
                                  text: urls,
                                  subject: "Materium - ${tr("appsString")}",
                                ),
                              );
                            },
                            child: ListItemLayout(
                              leading: SizedBox.square(
                                dimension: 40.0,
                                child: Material(
                                  animationDuration: Duration.zero,
                                  type: MaterialType.card,
                                  clipBehavior: Clip.antiAlias,
                                  color: iconContainerColor,
                                  shape: const StadiumBorder(),
                                  child: Align.center(
                                    child: IconLegacy(
                                      Symbols.share_rounded,
                                      fill: 1.0,
                                      color: colorTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              headline: Text(tr("shareAppConfigLinks")),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        ListItemContainer(
                          containerColor: .all(listItemContainerColor),
                          child: ListItemInteraction(
                            onTap: () {
                              var encoder = const JsonEncoder.withIndent(
                                "    ",
                              );
                              var exportJSON = encoder.convert(
                                appsProvider.generateExportJSON(
                                  appIds: selectedApps
                                      .map((e) => e.id)
                                      .toList(),
                                  overrideExportSettings: 0,
                                ),
                              );
                              String fn =
                                  "${tr("obtainiumExportHyphenatedLowercase")}-${DateTime.now().toIso8601String().replaceAll(":", "-")}-count-${selectedApps.length}";
                              XFile f = XFile.fromData(
                                Uint8List.fromList(utf8.encode(exportJSON)),
                                mimeType: "application/json",
                                name: fn,
                              );
                              SharePlus.instance.share(
                                ShareParams(
                                  files: [f],
                                  fileNameOverrides: ["$fn.json"],
                                ),
                              );
                            },
                            child: ListItemLayout(
                              leading: SizedBox.square(
                                dimension: 40.0,
                                child: Material(
                                  animationDuration: Duration.zero,
                                  type: MaterialType.card,
                                  clipBehavior: Clip.antiAlias,
                                  color: iconContainerColor,
                                  shape: const StadiumBorder(),
                                  child: Align.center(
                                    child: IconLegacy(
                                      Symbols.share_rounded,
                                      fill: 1.0,
                                      color: colorTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              headline: Text(
                                "${tr("share")} - ${tr("obtainiumExport")}",
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        containerColor: .all(listItemContainerColor),
                        child: ListItemInteraction(
                          onTap: () {
                            appsProvider
                                .downloadAppAssets(
                                  selectedApps.map((e) => e.id).toList(),
                                  globalNavigatorKey.currentContext ?? context,
                                )
                                .catchError(
                                  // ignore: invalid_return_type_for_catch_error
                                  (e) => showError(
                                    e,
                                    globalNavigatorKey.currentContext ??
                                        context,
                                  ),
                                );
                            Navigator.of(context).pop();
                          },
                          child: ListItemLayout(
                            leading: SizedBox.square(
                              dimension: 40.0,
                              child: Material(
                                animationDuration: Duration.zero,
                                type: MaterialType.card,
                                clipBehavior: Clip.antiAlias,
                                color: iconContainerColor,
                                shape: const StadiumBorder(),
                                child: Align.center(
                                  child: IconLegacy(
                                    Symbols.download_rounded,
                                    fill: 1.0,
                                    color: colorTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            headline: Text(
                              tr(
                                "downloadX",
                                args: [lowerCaseIfEnglish(tr("releaseAsset"))],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        isLast: true,
                        containerColor: .all(listItemContainerColor),
                        child: ListItemInteraction(
                          onTap: () {
                            if (!appsProvider.areDownloadsRunning()) {
                              showMassMarkDialog();
                            }
                          },
                          child: ListItemLayout(
                            leading: SizedBox.square(
                              dimension: 40.0,
                              child: Material(
                                animationDuration: Duration.zero,
                                type: MaterialType.card,
                                clipBehavior: Clip.antiAlias,
                                color: iconContainerColor,
                                shape: const StadiumBorder(),
                                child: Align.center(
                                  child: IconLegacy(
                                    Symbols.done_all_rounded,
                                    fill: 1.0,
                                    color: colorTheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            headline: Text(tr("markSelectedAppsUpdated")),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> showFilterDialog() async {
      var values = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (ctx) {
          var vals = filter.toFormValuesMap();
          return GeneratedFormModal(
            initValid: true,
            title: tr('filterApps'),
            items: [
              [
                GeneratedFormTextField(
                  'appName',
                  label: tr('appName'),
                  required: false,
                  defaultValue: vals['appName'],
                ),
                GeneratedFormTextField(
                  'author',
                  label: tr('author'),
                  required: false,
                  defaultValue: vals['author'],
                ),
              ],
              [
                GeneratedFormTextField(
                  'appId',
                  label: tr('appId'),
                  required: false,
                  defaultValue: vals['appId'],
                ),
              ],
              [
                GeneratedFormSwitch(
                  'upToDateApps',
                  label: tr('upToDateApps'),
                  defaultValue: vals['upToDateApps'],
                ),
              ],
              [
                GeneratedFormSwitch(
                  'nonInstalledApps',
                  label: tr('nonInstalledApps'),
                  defaultValue: vals['nonInstalledApps'],
                ),
              ],
              [
                GeneratedFormDropdown(
                  'sourceFilter',
                  label: tr('appSource'),
                  defaultValue: filter.sourceFilter,
                  [
                    MapEntry('', tr('none')),
                    ...sourceProvider.sources.map(
                      (e) => MapEntry(e.runtimeType.toString(), e.name),
                    ),
                  ],
                ),
              ],
            ],
            additionalWidgets: [
              const SizedBox(height: 16),
              CategoryEditorSelector(
                preselected: filter.categoryFilter,
                onSelected: (categories) {
                  filter.categoryFilter = categories.toSet();
                },
              ),
            ],
          );
        },
      );
      if (values != null) {
        setState(() {
          filter.setFormValuesFromMap(values);
        });
      }
    }

    Widget getDisplayedList() {
      if (settingsProvider.groupByCategory &&
          !(listedCategories.isEmpty ||
              (listedCategories.length == 1 && listedCategories[0] == null))) {
        return SliverList.builder(
          itemCount: listedCategories.length,
          itemBuilder: (context, index) => getCategoryCollapsibleTile(index),
        );
      }
      // ignore: dead_code
      if (kDebugMode) {
        final pinnedApps = listedApps;
        // final pinnedApps = listedApps
        //     .where((element) => element.app.pinned)
        //     .toList(growable: false);
        // final unpinnedApps = listedApps
        //     .whereNot((element) => element.app.pinned)
        //     .toList(growable: false);
        const double spacing = 2.0;
        return SliverList.list(
          children: [
            const SizedBox(height: 16.0),
            ...pinnedApps.mapIndexed((index, e) {
              final isSelected = selectedAppIds.contains(e.app.id);
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  index > 0 ? spacing / 2.0 : 0.0,
                  16.0,
                  index < pinnedApps.length - 1 ? spacing / 2.0 : 0.0,
                ),
                child: ListItemContainer(
                  isFirst: index == 0,
                  isLast: index == pinnedApps.length - 1,
                  containerShape: .all(
                    isSelected
                        ? CornersBorder.rounded(
                            corners: Corners.all(
                              shapeTheme.corner.largeIncreased,
                            ),
                          )
                        : null,
                  ),
                  containerColor: .all(
                    isSelected
                        ? colorTheme.secondaryContainer
                        : colorTheme.surfaceBright,
                  ),
                  child: ListItemInteraction(
                    stateLayerColor: .all(
                      isSelected
                          ? colorTheme.onSecondaryContainer
                          : colorTheme.onSurface,
                    ),
                    onTap: () {
                      if (selectedAppIds.isNotEmpty) {
                        toggleAppSelected(e.app);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AppPage(appId: e.app.id),
                          ),
                        );
                      }
                    },
                    onLongPress: () => toggleAppSelected(e.app),
                    child: ListItemLayout(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        12.0,
                        16.0,
                        12.0,
                      ),
                      leading: SizedBox.square(
                        dimension: 40.0,
                        child: getAppIcon(index),
                      ),
                      headline: Text(
                        e.name,
                        maxLines: 1,
                        style: TextStyle(
                          color: isSelected
                              ? colorTheme.onSecondaryContainer
                              : null,
                        ),
                      ),
                      supportingText: Text(
                        tr("byX", args: [e.author]),
                        maxLines: 1,
                        style: TextStyle(
                          color: isSelected
                              ? colorTheme.onSecondaryContainer
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16.0),
          ],
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        sliver: SliverList.builder(
          itemCount: listedApps.length,
          itemBuilder: (context, index) => Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: getSingleAppHorizTile(index),
          ),
        ),
      );
    }

    const bool kDebugCustomScrollbar = false;
    const bool kCustomScrollbarVisible = kDebugMode && kDebugCustomScrollbar;
    final isFilterOff = filter.isIdenticalTo(neutralFilter, settingsProvider);
    final hasSelection = selectedAppIds.isNotEmpty;

    // TODO: uncomment when needed
    // final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    // final isCompact = windowWidthSizeClass <= WindowWidthSizeClass.compact;

    Widget getDockedToolbar() {
      final Widget filterButton = IconButton(
        onPressed: isFilterOff
            ? showFilterDialog
            : () {
                setState(() {
                  filter = AppsFilter();
                });
              },
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          fixedSize: const WidgetStatePropertyAll(Size(52.0, 40.0)),
          shape: WidgetStatePropertyAll(
            CornersBorder.rounded(corners: Corners.all(shapeTheme.corner.full)),
          ),
          overlayColor: WidgetStateLayerColor(
            color: WidgetStatePropertyAll(colorTheme.onSurfaceVariant),
            opacity: stateTheme.stateLayerOpacity,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) && !hasSelection
                ? colorTheme.onSurface.withValues(alpha: 0.1)
                : colorTheme.surfaceBright,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? colorTheme.onSurface.withValues(alpha: 0.38)
                : colorTheme.onSurfaceVariant,
          ),
        ),
        icon: IconLegacy(
          isFilterOff ? Symbols.search_rounded : Symbols.search_off_rounded,
        ),
        tooltip: isFilterOff
            ? tr('filterApps')
            : '${tr('filter')} - ${tr('remove')}',
      );
      final Widget selectButton = IconButton(
        onPressed: () => hasSelection
            ? clearSelected()
            : selectThese(listedApps.map((e) => e.app).toList()),
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          fixedSize: const WidgetStatePropertyAll(Size(52.0, 40.0)),
          shape: WidgetStatePropertyAll(
            CornersBorder.rounded(
              corners: Corners.all(
                hasSelection
                    ? shapeTheme.corner.medium
                    : shapeTheme.corner.full,
              ),
            ),
          ),
          overlayColor: WidgetStateLayerColor(
            color: WidgetStatePropertyAll(
              hasSelection ? colorTheme.primary : colorTheme.onSurfaceVariant,
            ),
            opacity: stateTheme.stateLayerOpacity,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => hasSelection
                ? states.contains(WidgetState.disabled) && !hasSelection
                      ? colorTheme.onSurface.withValues(alpha: 0.1)
                      : colorTheme.surfaceBright
                : Colors.transparent,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? colorTheme.onSurface.withValues(alpha: 0.38)
                : hasSelection
                ? colorTheme.primary
                : colorTheme.onSurfaceVariant,
          ),
        ),
        icon: hasSelection
            ? const IconLegacy(Symbols.deselect_rounded)
            : const IconLegacy(Symbols.select_all_rounded),
        tooltip: hasSelection
            ? selectedAppIds.length.toString()
            : listedApps.length.toString(),
      );
      final Widget downloadButton = IconButton(
        onPressed: getMassObtainFunction(),
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          // TODO: decide which style to use
          // fixedSize: const WidgetStatePropertyAll(
          //   Size(48.0, 48.0),
          // ),
          // shape: WidgetStatePropertyAll(
          //   CornersBorder.rounded(
          //     corners: Corners.all(
          //       shapeTheme.corner.large,
          //     ),
          //   ),
          // ),
          fixedSize: const WidgetStatePropertyAll(Size(52.0, 40.0)),
          shape: WidgetStatePropertyAll(
            CornersBorder.rounded(corners: Corners.all(shapeTheme.corner.full)),
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
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? colorTheme.onSurface.withValues(alpha: 0.38)
                : colorTheme.onPrimary,
          ),
        ),
        icon: const IconLegacy(Symbols.download_rounded),
        tooltip: hasSelection
            ? tr('installUpdateSelectedApps')
            : tr('installUpdateApps'),
      );
      final removeButton = IconButton(
        onPressed: hasSelection
            ? () {
                appsProvider.removeAppsWithModal(
                  context,
                  selectedApps.toList(),
                );
              }
            : null,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
          shape: WidgetStatePropertyAll(
            CornersBorder.rounded(
              corners: Corners.all(shapeTheme.corner.medium),
            ),
          ),
          overlayColor: WidgetStateLayerColor(
            color: WidgetStatePropertyAll(
              hasSelection ? colorTheme.error : colorTheme.onSurfaceVariant,
            ),
            opacity: stateTheme.stateLayerOpacity,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => hasSelection
                ? states.contains(WidgetState.disabled) && !hasSelection
                      ? colorTheme.onSurface.withValues(alpha: 0.1)
                      : colorTheme.surfaceBright
                : Colors.transparent,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? colorTheme.onSurface.withValues(alpha: 0.38)
                : hasSelection
                ? colorTheme.error
                : colorTheme.onSurfaceVariant,
          ),
        ),
        icon: const IconLegacy(Symbols.delete_rounded, fill: 0.0),
        tooltip: tr('removeSelectedApps'),
      );
      final Widget categorizeButton = IconButton(
        onPressed: hasSelection ? launchCategorizeDialog() : null,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
          shape: WidgetStatePropertyAll(
            CornersBorder.rounded(
              corners: Corners.all(shapeTheme.corner.medium),
            ),
          ),
          overlayColor: WidgetStateLayerColor(
            color: WidgetStatePropertyAll(colorTheme.onSurfaceVariant),
            opacity: stateTheme.stateLayerOpacity,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => hasSelection
                ? states.contains(WidgetState.disabled) && !hasSelection
                      ? colorTheme.onSurface.withValues(alpha: 0.1)
                      : colorTheme.surfaceBright
                : Colors.transparent,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? colorTheme.onSurface.withValues(alpha: 0.38)
                : colorTheme.onSurfaceVariant,
          ),
        ),
        icon: const IconLegacy(Symbols.category_rounded, fill: 1.0),
        tooltip: tr('categorize'),
      );
      final Widget moreButton = IconButton(
        onPressed: hasSelection ? showMoreOptionsDialog : null,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: const WidgetStatePropertyAll(Size.zero),
          maximumSize: const WidgetStatePropertyAll(Size.infinite),
          fixedSize: const WidgetStatePropertyAll(Size(32.0, 40.0)),
          shape: WidgetStatePropertyAll(
            CornersBorder.rounded(corners: Corners.all(shapeTheme.corner.full)),
          ),
          overlayColor: WidgetStateLayerColor(
            color: WidgetStatePropertyAll(colorTheme.onSurfaceVariant),
            opacity: stateTheme.stateLayerOpacity,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => hasSelection
                ? states.contains(WidgetState.disabled) && !hasSelection
                      ? colorTheme.onSurface.withValues(alpha: 0.1)
                      : colorTheme.surfaceBright
                : Colors.transparent,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? colorTheme.onSurface.withValues(alpha: 0.38)
                : colorTheme.onSurfaceVariant,
          ),
        ),
        icon: const IconLegacy(Symbols.more_vert_rounded),
        tooltip: tr('more'),
      );
      return Align.bottomCenter(
        heightFactor: 1.0,
        child: SizedBox(
          width: double.infinity,
          height: 64.0,
          child: Material(
            animationDuration: Duration.zero,
            type: MaterialType.card,
            clipBehavior: Clip.antiAlias,
            color: colorTheme.surfaceContainerHigh,
            shape: CornersBorder.rounded(
              corners: Corners.vertical(
                // TODO: consider the following design choice:
                // top: shapeTheme.corner.extraLarge,
                top: shapeTheme.corner.none,
                bottom: shapeTheme.corner.none,
              ),
            ),
            // TODO: improve compact layout (it's not production ready)
            child: false
                // ignore: dead_code
                ? Flex.horizontal(
                    children: [
                      Flexible.tight(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Flex.horizontal(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              filterButton,
                              const Flexible.space(),
                              selectButton,
                            ],
                          ),
                        ),
                      ),
                      Flexible.tight(
                        flex: 3,
                        child: Align.center(child: downloadButton),
                      ),
                      Flexible.tight(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0 - 8.0),
                          child: Flex.horizontal(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              removeButton,
                              const Flexible.space(),
                              categorizeButton,
                              const Flexible.space(),
                              moreButton,
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Flex.horizontal(
                    children: [
                      Flexible.tight(
                        child: Flex.horizontal(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16.0),
                            filterButton,
                            const SizedBox(width: 12.0),
                            selectButton,
                            const SizedBox(width: 12.0),
                          ],
                        ),
                      ),
                      downloadButton,
                      Flexible.tight(
                        child: Flex.horizontal(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(width: 12.0 - 4.0),
                            removeButton,
                            const SizedBox(width: 12.0 - 4.0 - 4.0),
                            categorizeButton,
                            const SizedBox(width: 12.0 - 8.0 - 4.0),
                            moreButton,
                            const SizedBox(width: 16.0 - 8.0),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomRefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          if (kDebugMode) {
            await Future.delayed(const Duration(seconds: 5));
          }
          if (context.mounted) {
            await refresh();
          }
        },
        edgeOffset: padding.top + 120.0,
        displacement: 80.0,
        child: Scrollbar(
          controller: scrollController,
          interactive: true,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            slivers: <Widget>[
              // if (!kDebugMode)
              CustomAppBar(
                type: CustomAppBarType.largeFlexible,
                behavior: CustomAppBarBehavior.duplicate,
                expandedContainerColor: colorTheme.surfaceContainer,
                collapsedContainerColor: colorTheme.surfaceContainer,
                title: Text(tr("appsString")),
              ),
              // TODO: either finish CustomScrollbar3 or use nested_scroll_view_plus
              // ignore: dead_code
              if (kCustomScrollbarVisible) ...[
                SliverScrollbar(
                  sliver: SliverMainAxisGroup(
                    // slivers: [...getLoadingWidgets(), getDisplayedList()],
                    slivers: [
                      SliverList.builder(
                        itemCount: 100,
                        itemBuilder: (context, index) =>
                            ListTile(title: Text("Item ${index + 1}")),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.green,
                    width: double.infinity,
                    height: 128.0,
                    child: Align.center(child: Text("Another one")),
                  ),
                ),
              ] else ...[
                ...getLoadingWidgets(),
                getDisplayedList(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: appsProvider.apps.isNotEmpty
          ? getDockedToolbar()
          : null,
    );
  }
}

class AppsFilter {
  late String nameFilter;
  late String authorFilter;
  late String idFilter;
  late bool includeUptodate;
  late bool includeNonInstalled;
  late Set<String> categoryFilter;
  late String sourceFilter;

  AppsFilter({
    this.nameFilter = '',
    this.authorFilter = '',
    this.idFilter = '',
    this.includeUptodate = true,
    this.includeNonInstalled = true,
    this.categoryFilter = const {},
    this.sourceFilter = '',
  });

  Map<String, dynamic> toFormValuesMap() {
    return {
      'appName': nameFilter,
      'author': authorFilter,
      'appId': idFilter,
      'upToDateApps': includeUptodate,
      'nonInstalledApps': includeNonInstalled,
      'sourceFilter': sourceFilter,
    };
  }

  void setFormValuesFromMap(Map<String, dynamic> values) {
    nameFilter = values['appName']!;
    authorFilter = values['author']!;
    idFilter = values['appId']!;
    includeUptodate = values['upToDateApps'];
    includeNonInstalled = values['nonInstalledApps'];
    sourceFilter = values['sourceFilter'];
  }

  bool isIdenticalTo(AppsFilter other, SettingsProvider settingsProvider) =>
      authorFilter.trim() == other.authorFilter.trim() &&
      nameFilter.trim() == other.nameFilter.trim() &&
      idFilter.trim() == other.idFilter.trim() &&
      includeUptodate == other.includeUptodate &&
      includeNonInstalled == other.includeNonInstalled &&
      settingsProvider.setEqual(categoryFilter, other.categoryFilter) &&
      sourceFilter.trim() == other.sourceFilter.trim();
}
