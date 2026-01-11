import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/components/custom_refresh_indicator.dart';
import 'package:materium/components/custom_sliver_scrollbar.dart';
import 'package:materium/flutter.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/generated_form.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/add_app.dart';
import 'package:materium/pages/app.dart';
import 'package:materium/pages/settings.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/settings_new.dart';
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

void Function()? getChangeLogFn(BuildContext context, App app) {
  final appSource = SourceProvider().getSource(
    app.url,
    overrideSource: app.overrideSource,
  );
  var changesUrl = appSource.changeLogPageFromStandardUrl(app.url);
  var changeLog = app.changeLog;
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
  final _progressIndicatorKey = GlobalKey();
  double? _progressIndicatorValueCache;

  var filter = AppsFilter();

  final neutralFilter = AppsFilter();

  var updatesOnlyFilter = AppsFilter(
    includeUptodate: false,
    includeNonInstalled: false,
  );

  var selectedAppIds = <String>{};

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

  final sourceProvider = SourceProvider();

  @override
  Widget build(BuildContext context) {
    final appsProvider = context.watch<AppsProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    var listedApps = appsProvider.getAppValues().toList();
    final hasApps = appsProvider.apps.isNotEmpty;

    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final padding = MediaQuery.paddingOf(context);
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final listItemDuration = const DurationThemeData.fallback().medium2;
    final listItemEasing = const EasingThemeData.fallback().standard;

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
        .where((id) => listedApps.map((item) => item.app.id).contains(id))
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
            final nameTokens = filter.nameFilter
                .split(" ")
                .where((element) => element.trim().isNotEmpty)
                .toList();
            final authorTokens = filter.authorFilter
                .split(" ")
                .where((element) => element.trim().isNotEmpty)
                .toList();

            for (final t in nameTokens) {
              if (!app.name.toLowerCase().contains(t.toLowerCase())) {
                return false;
              }
            }
            for (final t in authorTokens) {
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
          switch (settingsProvider.sortColumn) {
            case .authorName:
              result = ((a.author + a.name).toLowerCase()).compareTo(
                (b.author + b.name).toLowerCase(),
              );
            case .nameAuthor:
              result = ((a.name + a.author).toLowerCase()).compareTo(
                (b.name + b.author).toLowerCase(),
              );
            case .releaseDate:
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
            default:
          }
          return result;
        });

    if (settingsProvider.sortOrder == .descending) {
      listedApps = listedApps.reversed.toList();
    }

    final existingUpdates = appsProvider.findExistingUpdates(
      installedOnly: true,
    );

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

    final trackOnlyUpdateIdsAllOrSelected = <String>[];

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
      final temp = [];
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

    final unpinnedApps = <AppInMemory>[];
    final pinnedApps = <AppInMemory>[];
    for (final item in listedApps) {
      if (item.app.pinned) {
        pinnedApps.add(item);
      } else {
        unpinnedApps.add(item);
      }
    }
    listedApps = [...pinnedApps, ...unpinnedApps];

    List<String?> getListedCategories() {
      final temp = listedApps.map(
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

    final selectedApps = listedApps
        .map((e) => e.app)
        .where((a) => selectedAppIds.contains(a.id))
        .toSet();

    final hasPinnedSelection = selectedApps.any((element) => element.pinned);

    Widget buildLinearProgressIndicator(
      Widget Function(BuildContext context, Size preferredSize, Widget child)
      builder,
    ) {
      final isVisible = refreshingSince != null || appsProvider.loadingApps;
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(end: isVisible ? 1.0 : 0.0),
        duration: const DurationThemeData.fallback().medium2,
        curve: const EasingThemeData.fallback().standard,
        builder: (context, heightFactor, _) {
          if (heightFactor == 0.0) {
            _progressIndicatorValueCache = 0.0;
          }
          final size = Size(.infinity, lerpDouble(0.0, 8.0, heightFactor));
          final oldValue = _progressIndicatorValueCache;
          final newValue = isVisible
              ? !appsProvider.loadingApps
                    ? appsProvider
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
                              : 1.0)
                    : null
              : oldValue;
          _progressIndicatorValueCache = newValue;
          final Widget child = SizedBox.fromSize(
            size: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: newValue ?? 0.0),
              duration: const DurationThemeData.fallback().short4,
              curve: const EasingThemeData.fallback().standard,
              builder: (context, value, _) {
                return size.height > 0.0
                    ? LinearProgressIndicator(
                        value: newValue != null ? value : null,
                        borderRadius: .circular(size.height / 2.0),
                        trackGap: 4.0,
                        stopIndicatorRadius: 2.0,
                        backgroundColor: useBlackTheme
                            ? colorTheme.surfaceContainer
                            : colorTheme.secondaryContainer,
                        color: colorTheme.primary,
                        minHeight: size.height,
                      )
                    : const SizedBox.shrink();
              },
            ),
          );
          return builder(context, size, child);
        },
      );
    }

    Widget getAppIcon(int appIndex) {
      return GestureDetector(
        behavior: .opaque,
        onDoubleTap: () {
          pm.openApp(listedApps[appIndex].app.id);
        },
        onLongPress: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => AppPage(
                appId: listedApps[appIndex].app.id,
                showOppositeOfPreferredView: true,
              ),
            ),
          );
        },
        child: FutureBuilder(
          future: appsProvider.updateAppIcon(listedApps[appIndex].app.id),
          builder: (ctx, val) => listedApps[appIndex].icon != null
              ? Image.memory(
                  listedApps[appIndex].icon!,
                  gaplessPlayback: true,
                  opacity: AlwaysStoppedAnimation(
                    listedApps[appIndex].installedInfo == null ? 0.6 : 1,
                  ),
                )
              : Align.center(
                  child: SizedBox.square(
                    dimension: 40.0,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(0.31),
                      child: Assets.graphics.iconSmall.image(
                        color: colorTheme.brightness == .dark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.3),
                        colorBlendMode: .modulate,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
        ),
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
      final showChangesFn = getChangeLogFn(context, listedApps[index].app);

      final isInstalled = listedApps[index].app.installedVersion != null;
      final hasUpdate =
          listedApps[index].app.installedVersion != null &&
          listedApps[index].app.installedVersion !=
              listedApps[index].app.latestVersion;
      final hasChanges = showChangesFn != null;
      final isSelected = selectedAppIds.contains(listedApps[index].app.id);

      final versionTextColor = isSelected
          ? colorTheme.onSecondaryContainer
          : isInstalled
          ? colorTheme.onSurface
          : colorTheme.onSurfaceVariant;
      final changesTextColor = isSelected
          ? colorTheme.onSecondaryContainer
          : isInstalled && hasChanges
          ? colorTheme.onSurface
          : colorTheme.onSurfaceVariant;

      final Widget trailingRow = Flex.horizontal(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        crossAxisAlignment: .stretch,
        spacing: 8.0,
        children: [
          if (hasUpdate)
            IconButton(
              style: LegacyThemeFactory.createIconButtonStyle(
                colorTheme: colorTheme,
                elevationTheme: elevationTheme,
                shapeTheme: shapeTheme,
                stateTheme: stateTheme,
                size: .medium,
                shape: .round,
                width: .narrow,
                isSelected: isSelected,
                unselectedContainerColor: colorTheme.secondaryContainer,
                unselectedIconColor: colorTheme.onSecondaryContainer,
                selectedContainerColor: colorTheme.primary,
                selectedIconColor: colorTheme.onPrimary,
                tapTargetSize: .shrinkWrap,
              ),
              onPressed: appsProvider.areDownloadsRunning()
                  ? null
                  : () {
                      appsProvider
                          .downloadAndInstallLatestApps([
                            listedApps[index].app.id,
                          ], globalNavigatorKey.currentContext)
                          .catchError((e) {
                            if (context.mounted) {
                              showError(e, context);
                            }
                            return <String>[];
                          });
                    },
              icon:
                  listedApps[index].app.additionalSettings["trackOnly"] == true
                  ? const Icon(Symbols.check_circle_rounded, fill: 1.0)
                  : const Icon(Symbols.install_mobile, fill: 1.0),
              tooltip:
                  listedApps[index].app.additionalSettings["trackOnly"] == true
                  ? tr("markUpdated")
                  : tr("update"),
            ),
          SizedBox(
            height: 56.0,
            child: Material(
              clipBehavior: .antiAlias,
              shape: CornersBorder.rounded(
                corners: Corners.all(shapeTheme.corner.large),
                // side: isSelected
                //     ? BorderSide(color: colorTheme.onSecondaryContainer)
                //     : BorderSide.none,
              ),
              color: isSelected
                  ? colorTheme.secondaryContainer
                  : isInstalled
                  ? colorTheme.surfaceContainerHighest
                  : colorTheme.surfaceContainerHigh,
              child: InkWell(
                onTap: showChangesFn,
                overlayColor: WidgetStateLayerColor(
                  color: WidgetStatePropertyAll(
                    isSelected
                        ? colorTheme.onSecondaryContainer
                        : colorTheme.onSurface,
                  ),
                  opacity: stateTheme.asWidgetStateLayerOpacity,
                ),
                child: Padding(
                  padding: const .symmetric(horizontal: 12.0),
                  child: IntrinsicWidth(
                    child: Flex.vertical(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(
                          getVersionText(index),
                          textAlign: .end,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style:
                              (isInstalled
                                      ? typescaleTheme.labelSmallEmphasized
                                      : typescaleTheme.labelSmall)
                                  .toTextStyle(color: versionTextColor)
                                  .copyWith(
                                    fontStyle:
                                        isVersionPseudo(listedApps[index].app)
                                        ? .italic
                                        : .normal,
                                  ),
                        ),
                        Text(
                          getChangesButtonString(index, showChangesFn != null),
                          textAlign: .end,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style:
                              (isInstalled && hasChanges
                                      ? typescaleTheme.labelSmallEmphasized
                                      : typescaleTheme.labelSmall)
                                  .toTextStyle(color: changesTextColor)
                                  .copyWith(
                                    fontStyle: .normal,
                                    decorationColor: changesTextColor,
                                    decorationStyle: .solid,
                                    decoration: hasChanges
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

      final transparent = colorTheme.surface.withAlpha(0).toARGB32();

      final stops = <double>[
        ...listedApps[index].app.categories.asMap().entries.map(
          (e) =>
              ((e.key / (listedApps[index].app.categories.length - 1)) -
              0.0001),
        ),
        1.0,
      ];
      if (stops.length == 2) {
        stops[0] = 0.9999;
      }
      return DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: stops,
            begin: const Alignment(-1.0, 0.0),
            end: const Alignment(-0.97, 0.0),
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
          leading: SizedBox.square(dimension: 56.0, child: getAppIcon(index)),
          title: Text(
            listedApps[index].name,
            maxLines: 1,
            overflow: .ellipsis,
            softWrap: false,
            style:
                (isInstalled
                        ? typescaleTheme.bodyLargeEmphasized
                        : typescaleTheme.bodyLarge)
                    .toTextStyle(
                      color: isSelected
                          ? colorTheme.onSecondaryContainer
                          : colorTheme.onSurface,
                    ),
          ),
          subtitle: Text(
            tr("byX", args: [listedApps[index].author]),
            maxLines: 1,
            overflow: .ellipsis,
            softWrap: false,
            style: typescaleTheme.bodyMedium.toTextStyle(
              color: isSelected
                  ? colorTheme.onSecondaryContainer
                  : colorTheme.onSurfaceVariant,
            ),
          ),
          trailing: listedApps[index].downloadProgress != null
              ? SizedBox(
                  child: Text(
                    listedApps[index].downloadProgress! >= 0
                        ? tr(
                            "percentProgress",
                            args: [
                              listedApps[index].downloadProgress!
                                  .toInt()
                                  .toString(),
                            ],
                          )
                        : tr("installing"),
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
                MaterialPageRoute<void>(
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
      final pinStatus = !hasPinnedSelection;
      appsProvider.saveApps(
        selectedApps.map((e) {
          e.pinned = pinStatus;
          return e;
        }).toList(),
      );
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
          final padding = MediaQuery.paddingOf(context);
          final colorTheme = ColorTheme.of(context);
          return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              scrollDirection: .vertical,
              child: Padding(
                padding: .fromLTRB(8.0, 0.0, 8.0, 16.0 + padding.bottom),
                child: ListItemTheme.merge(
                  data: .from(
                    containerColor: .all(colorTheme.surfaceContainerLow),
                  ),
                  child: Flex.vertical(
                    mainAxisSize: .min,
                    crossAxisAlignment: .stretch,
                    spacing: 2.0,
                    children: [
                      // for (var i = 0; i < 50; i++)
                      //   ListItemContainer(
                      //     isFirst: true,
                      //     child: ListItemInteraction(
                      //       onTap: pinSelectedApps,
                      //       child: ListItemLayout(
                      //         leading:
                      //             selectedApps
                      //                 .where((element) => element.pinned)
                      //                 .isEmpty
                      //             ? Icon(
                      //                 Symbols.keep_rounded,
                      //                 fill: 1.0,
                      //                 color: colorTheme.onSurfaceVariant,
                      //               )
                      //             : Icon(
                      //                 Symbols.keep_off_rounded,
                      //                 fill: 1.0,
                      //                 color: colorTheme.onSurfaceVariant,
                      //               ),

                      //         headline: Text(
                      //           selectedApps
                      //                   .where((element) => element.pinned)
                      //                   .isEmpty
                      //               ? tr("pinToTop")
                      //               : tr("unpinFromTop"),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      ListItemContainer(
                        isFirst: true,
                        child: ListItemInteraction(
                          onTap: () {
                            pinSelectedApps();
                            Navigator.pop(context);
                          },
                          child: ListItemLayout(
                            leading:
                                selectedApps
                                    .where((element) => element.pinned)
                                    .isEmpty
                                ? Icon(
                                    Symbols.keep_rounded,
                                    fill: 1.0,
                                    color: colorTheme.onSurfaceVariant,
                                  )
                                : Icon(
                                    Symbols.keep_off_rounded,
                                    fill: 1.0,
                                    color: colorTheme.onSurfaceVariant,
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
                      ListItemContainer(
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
                            leading: Icon(
                              Symbols.share_rounded,
                              fill: 1.0,
                              color: colorTheme.onSurfaceVariant,
                            ),

                            headline: Text(tr("shareSelectedAppURLs")),
                          ),
                        ),
                      ),
                      if (selectedApps.isNotEmpty) ...[
                        ListItemContainer(
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
                              leading: Icon(
                                Symbols.share_rounded,
                                fill: 1.0,
                                color: colorTheme.onSurfaceVariant,
                              ),

                              headline: Text(tr("shareAppConfigLinks")),
                            ),
                          ),
                        ),
                        ListItemContainer(
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
                              leading: Icon(
                                Symbols.share_rounded,
                                fill: 1.0,
                                color: colorTheme.onSurfaceVariant,
                              ),
                              headline: Text(
                                "${tr("share")} - ${tr("obtainiumExport")}",
                              ),
                            ),
                          ),
                        ),
                      ],
                      ListItemContainer(
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
                            leading: Icon(
                              Symbols.download_rounded,
                              fill: 1.0,
                              color: colorTheme.onSurfaceVariant,
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
                      ListItemContainer(
                        isLast: true,
                        child: ListItemInteraction(
                          onTap: () {
                            if (!appsProvider.areDownloadsRunning()) {
                              showMassMarkDialog();
                            }
                          },
                          child: ListItemLayout(
                            leading: Icon(
                              Symbols.done_all_rounded,
                              fill: 1.0,
                              color: colorTheme.onSurfaceVariant,
                            ),
                            headline: Text(tr("markSelectedAppsUpdated")),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    Future<void> showFilterDialog() async {
      var values = await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (ctx) {
          final vals = filter.toFormValuesMap();
          return GeneratedFormModal(
            initValid: true,
            title: tr('filterApps'),
            items: [
              [
                GeneratedFormTextField(
                  'appName',
                  label: tr('appName'),
                  required: false,
                  defaultValue: vals['appName']! as String,
                ),
                GeneratedFormTextField(
                  'author',
                  label: tr('author'),
                  required: false,
                  defaultValue: vals['author']! as String,
                ),
              ],
              [
                GeneratedFormTextField(
                  'appId',
                  label: tr('appId'),
                  required: false,
                  defaultValue: vals['appId']! as String,
                ),
              ],
              [
                GeneratedFormSwitch(
                  'upToDateApps',
                  label: tr('upToDateApps'),
                  defaultValue: vals['upToDateApps']! as bool,
                ),
              ],
              [
                GeneratedFormSwitch(
                  'nonInstalledApps',
                  label: tr('nonInstalledApps'),
                  defaultValue: vals['nonInstalledApps']! as bool,
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

    Widget buildSliverList(List<AppInMemory> apps) {
      const spacing = 2.0;
      return ListItemTheme.merge(
        data: .from(
          containerColor: .all(
            useBlackTheme ? colorTheme.surface : colorTheme.surface,
          ),
          headlineTextStyle: .all(
            typescaleTheme.bodyLargeEmphasized.toTextStyle(),
          ),
        ),
        child: CheckboxTheme.merge(
          data: CustomThemeFactory.createCheckboxTheme(
            colorTheme: colorTheme,
            shapeTheme: shapeTheme,
            stateTheme: stateTheme,
            color: useBlackTheme ? .black : .listItemPhone,
          ),
          child: SliverList.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final isLast = index == apps.length - 1;

              final item = apps[index];

              final showChanges = getChangeLogFn(context, item.app);

              final installedVersion = item.app.installedVersion;
              final progress = item.downloadProgress;

              final isInstalled = installedVersion != null;
              final hasUpdate =
                  isInstalled && installedVersion != item.app.latestVersion;
              final isSelected = selectedAppIds.contains(item.app.id);

              final Widget updateButton = IconButton(
                style: LegacyThemeFactory.createIconButtonStyle(
                  colorTheme: colorTheme,
                  elevationTheme: elevationTheme,
                  shapeTheme: shapeTheme,
                  stateTheme: stateTheme,
                  size: .small,
                  shape: .round,
                  color: .tonal,
                  width: .wide,
                  containerColor: useBlackTheme
                      ? colorTheme.primaryContainer
                      : null,
                  iconColor: useBlackTheme
                      ? colorTheme.onPrimaryContainer
                      : null,
                ),
                onPressed: !appsProvider.areDownloadsRunning()
                    ? () {
                        appsProvider
                            .downloadAndInstallLatestApps([
                              item.app.id,
                            ], globalNavigatorKey.currentContext)
                            .catchError((e) {
                              if (context.mounted) {
                                showError(e, context);
                              }
                              return <String>[];
                            });
                      }
                    : null,
                icon: item.app.additionalSettings["trackOnly"] == true
                    ? const Icon(Symbols.check_circle_rounded, fill: 1.0)
                    : const Icon(Symbols.install_mobile, fill: 1.0),
                tooltip: item.app.additionalSettings["trackOnly"] == true
                    ? tr("markUpdated")
                    : tr("update"),
              );

              final LegacyMenuVariant menuVariant = useBlackTheme
                  ? .standard
                  : .standard;

              final Widget overflowButton = MenuAnchor(
                consumeOutsideTap: true,
                crossAxisUnconstrained: false,
                style: LegacyThemeFactory.createMenuStyle(
                  colorTheme: colorTheme,
                  elevationTheme: elevationTheme,
                  shapeTheme: shapeTheme,
                  variant: menuVariant,
                ),
                menuChildren: [
                  MenuItemButton(
                    style: LegacyThemeFactory.createMenuButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      variant: menuVariant,
                      isFirst: true,
                      isLast: false,
                      isSelected: isSelected,
                    ),
                    // closeOnActivate:
                    //     (!isSelected && selectedAppIds.isEmpty) ||
                    //     (isSelected && selectedAppIds.length == 1),
                    onPressed: () => toggleAppSelected(item.app),
                    leadingIcon: const Icon(Symbols.check_rounded, fill: 1.0),
                    child: isSelected
                        ? const Text("Selected")
                        : const Text("Select"),
                  ),
                  if (hasUpdate && selectedAppIds.isNotEmpty)
                    MenuItemButton(
                      style: LegacyThemeFactory.createMenuButtonStyle(
                        colorTheme: colorTheme,
                        elevationTheme: elevationTheme,
                        shapeTheme: shapeTheme,
                        stateTheme: stateTheme,
                        typescaleTheme: typescaleTheme,
                        variant: menuVariant,
                        isFirst: false,
                        isLast: false,
                      ),
                      onPressed: !appsProvider.areDownloadsRunning()
                          ? () {
                              appsProvider
                                  .downloadAndInstallLatestApps([
                                    item.app.id,
                                  ], globalNavigatorKey.currentContext)
                                  .catchError((e) {
                                    if (context.mounted) {
                                      showError(e, context);
                                    }
                                    return <String>[];
                                  });
                            }
                          : null,
                      leadingIcon:
                          item.app.additionalSettings["trackOnly"] == true
                          ? const Icon(Symbols.check_circle_rounded, fill: 1.0)
                          : const Icon(Symbols.install_mobile, fill: 1.0),
                      child: Text(
                        item.app.additionalSettings["trackOnly"] == true
                            ? tr("markUpdated")
                            : tr("update"),
                      ),
                    ),
                  MenuItemButton(
                    style: LegacyThemeFactory.createMenuButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      variant: menuVariant,
                      isFirst: false,
                      isLast: false,
                    ),
                    onPressed: showChanges,
                    leadingIcon: const Icon(
                      Symbols.menu_book_rounded,
                      fill: 1.0,
                    ),
                    child: const Text("View changelog"),
                  ),
                  if (selectedAppIds.isNotEmpty)
                    MenuItemButton(
                      style: LegacyThemeFactory.createMenuButtonStyle(
                        colorTheme: colorTheme,
                        elevationTheme: elevationTheme,
                        shapeTheme: shapeTheme,
                        stateTheme: stateTheme,
                        typescaleTheme: typescaleTheme,
                        variant: menuVariant,
                        isFirst: false,
                        isLast: false,
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => AppPage(appId: item.app.id),
                        ),
                      ),
                      leadingIcon: const Icon(Symbols.edit_rounded, fill: 1.0),
                      child: const Text("Edit"),
                    ),
                  MenuItemButton(
                    style: LegacyThemeFactory.createMenuButtonStyle(
                      colorTheme: colorTheme,
                      elevationTheme: elevationTheme,
                      shapeTheme: shapeTheme,
                      stateTheme: stateTheme,
                      typescaleTheme: typescaleTheme,
                      variant: menuVariant,
                      isFirst: false,
                      isLast: true,
                    ),
                    onPressed: () =>
                        appsProvider.removeAppsWithModal(context, [item.app]),
                    leadingIcon: const Icon(Symbols.delete_rounded, fill: 1.0),
                    child: Text(tr("remove")),
                  ),
                ],
                builder: (context, controller, child) => IconButton(
                  style: LegacyThemeFactory.createIconButtonStyle(
                    colorTheme: colorTheme,
                    elevationTheme: elevationTheme,
                    shapeTheme: shapeTheme,
                    stateTheme: stateTheme,
                    size: .small,
                    shape: .round,
                    color: .standard,
                    width: .narrow,
                    containerColor: isSelected || useBlackTheme
                        ? Colors.transparent
                        : colorTheme.surfaceContainer,
                    iconColor: isSelected
                        ? useBlackTheme
                              ? colorTheme.onPrimaryContainer
                              : colorTheme.onSecondaryContainer
                        : useBlackTheme
                        ? colorTheme.onSurface
                        : colorTheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  icon: const Icon(Symbols.more_vert_rounded),
                ),
              );

              final Widget checkbox = Checkbox.bistate(
                onCheckedChanged: (value) => toggleAppSelected(item.app),
                checked: isSelected,
              );

              return KeyedSubtree(
                key: ValueKey(item.app.id),
                child: Padding(
                  padding: .only(
                    top: isFirst ? 0.0 : spacing / 2.0,
                    bottom: isLast ? 0.0 : spacing / 2.0,
                  ),
                  child: ListItemContainer(
                    isFirst: isFirst,
                    isLast: isLast,
                    containerShape: .all(
                      isSelected
                          ? CornersBorder.rounded(
                              corners: Corners.all(shapeTheme.corner.large),
                            )
                          : null,
                    ),
                    containerColor: .all(
                      isSelected
                          ? useBlackTheme
                                ? colorTheme.primaryContainer
                                : colorTheme.secondaryContainer
                          : null,
                    ),
                    child: ListItemInteraction(
                      stateLayerColor: .all(
                        isSelected
                            ? useBlackTheme
                                  ? colorTheme.onPrimaryContainer
                                  : colorTheme.onSecondaryContainer
                            : useBlackTheme
                            ? colorTheme.onPrimaryContainer
                            : colorTheme.onSurface,
                      ),
                      onTap: () {
                        if (selectedAppIds.isNotEmpty) {
                          toggleAppSelected(item.app);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => AppPage(appId: item.app.id),
                            ),
                          );
                        }
                      },
                      onLongPress: () => toggleAppSelected(item.app),
                      child: ListItemLayout(
                        padding: const .directional(start: 16.0, end: 0.0),
                        leading: ExcludeFocus(
                          child: SizedBox.square(
                            dimension: 56.0,
                            child: FutureBuilder(
                              future: appsProvider
                                  .updateAppIcon(item.app.id)
                                  .then((_) => item.icon),
                              builder: (context, snapshot) {
                                final bytes = snapshot.data;
                                return TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    end: progress != null ? 1.0 : 0.0,
                                  ),
                                  duration: listItemDuration,
                                  curve: listItemEasing,
                                  builder: (context, value, child) => Material(
                                    clipBehavior: .antiAlias,
                                    shape: ShapeBorder.lerp(
                                      CornersBorder.rounded(
                                        corners: .all(shapeTheme.corner.small),
                                      ),
                                      CornersBorder.rounded(
                                        corners: .all(shapeTheme.corner.full),
                                      ),
                                      value,
                                    )!,
                                    color: isSelected
                                        ? bytes != null
                                              ? useBlackTheme
                                                    ? colorTheme
                                                          .primaryContainer
                                                    : colorTheme
                                                          .secondaryContainer
                                              : Colors.transparent
                                        : useBlackTheme
                                        ? colorTheme.surface
                                        : colorTheme.surfaceContainer,
                                    child: child!,
                                  ),
                                  child: Stack(
                                    fit: .expand,
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          end: progress != null ? 1.0 : 0.0,
                                        ),
                                        duration: listItemDuration,
                                        curve: listItemEasing,
                                        builder: (context, value, _) {
                                          final size = lerpDouble(
                                            40.0,
                                            28.0,
                                            value,
                                          );
                                          return Align.center(
                                            child: bytes != null
                                                ? SizedBox.square(
                                                    dimension: size,
                                                    child: Image.memory(
                                                      bytes,
                                                      gaplessPlayback: true,
                                                      fit: .contain,
                                                    ),
                                                  )
                                                : Icon(
                                                    Symbols
                                                        .broken_image_rounded,
                                                    opticalSize: size,
                                                    size: size,
                                                    color: isSelected
                                                        ? useBlackTheme
                                                              ? colorTheme
                                                                    .onPrimaryContainer
                                                              : colorTheme
                                                                    .onSecondaryContainer
                                                        : useBlackTheme
                                                        ? colorTheme.primary
                                                        : colorTheme
                                                              .onSurfaceVariant,
                                                  ),
                                          );
                                        },
                                      ),
                                      InkWell(
                                        overlayColor: WidgetStateLayerColor(
                                          color: WidgetStatePropertyAll(
                                            isSelected
                                                ? useBlackTheme
                                                      ? colorTheme
                                                            .onPrimaryContainer
                                                      : colorTheme
                                                            .onSecondaryContainer
                                                : useBlackTheme
                                                ? colorTheme.primary
                                                : colorTheme.onSurface,
                                          ),
                                          opacity: stateTheme
                                              .asWidgetStateLayerOpacity,
                                        ),
                                        onTap: () {
                                          toggleAppSelected(item.app);
                                        },
                                        onDoubleTap: () {
                                          pm.openApp(item.app.id);
                                        },
                                        onLongPress: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (context) => AppPage(
                                                appId: item.app.id,
                                                showOppositeOfPreferredView:
                                                    true,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          end: progress != null ? 1.0 : 0.0,
                                        ),
                                        duration: listItemDuration,
                                        curve: listItemEasing,
                                        builder: (context, value, _) =>
                                            value > 0.0
                                            ? CircularProgressIndicator(
                                                padding: const .all(0.0),
                                                strokeWidth: lerpDouble(
                                                  0.0,
                                                  4.0,
                                                  value,
                                                ),
                                                value:
                                                    progress != null &&
                                                        progress >= 0.0
                                                    ? clampDouble(
                                                        progress / 100.0,
                                                        0.0,
                                                        1.0,
                                                      )
                                                    : null,
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        overline: Text(
                          tr("byX", args: [item.author]),
                          maxLines: 1,
                          overflow: .ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: isSelected
                                ? useBlackTheme
                                      ? colorTheme.onPrimaryContainer
                                            .withValues(alpha: 0.9)
                                      : colorTheme.onSecondaryContainer
                                : useBlackTheme
                                ? colorTheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        headline: Text(
                          item.name,
                          maxLines: 1,
                          overflow: .ellipsis,
                          softWrap: false,
                          style:
                              (isInstalled
                                      ? typescaleTheme.bodyLargeEmphasized
                                      : typescaleTheme.bodyLarge)
                                  .toTextStyle(
                                    color: isSelected
                                        ? useBlackTheme
                                              ? colorTheme.onPrimaryContainer
                                              : colorTheme.onSecondaryContainer
                                        : colorTheme.onSurface,
                                  ),
                        ),
                        supportingText: Text(
                          installedVersion != null
                              ? hasUpdate
                                    ? "$installedVersion → ${item.app.latestVersion}"
                                    : installedVersion
                              : tr("notInstalled"),
                          style: typescaleTheme.bodySmall
                              .toTextStyle()
                              .copyWith(
                                fontFamily: installedVersion != null
                                    ? FontFamily.googleSansCode
                                    : null,
                                color: isSelected
                                    ? useBlackTheme
                                          ? colorTheme.onPrimaryContainer
                                                .withValues(alpha: 0.9)
                                          : colorTheme.onSecondaryContainer
                                    : hasUpdate
                                    ? colorTheme.onSurface
                                    : colorTheme.onSurfaceVariant,
                              ),
                        ),
                        trailing: Flex.horizontal(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                end: hasUpdate && selectedAppIds.isEmpty
                                    ? 1.0
                                    : 0.0,
                              ),
                              duration: listItemDuration,
                              curve: listItemEasing,
                              builder: (context, value, child) => Visibility(
                                visible: value > 0.0,
                                child: Opacity(
                                  opacity: value,
                                  child: Align.centerEnd(
                                    widthFactor: value,
                                    child: Transform.scale(
                                      scale: value,
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: child!,
                                    ),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const .directional(end: 12.0 - 8.0),
                                child: updateButton,
                              ),
                            ),
                            overflowButton,
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                end: selectedAppIds.isNotEmpty ? 1.0 : 0.0,
                              ),
                              duration: listItemDuration,
                              curve: listItemEasing,
                              builder: (context, value, child) => Visibility(
                                visible: value > 0.0,
                                child: Opacity(
                                  opacity: value,
                                  child: Align.centerStart(
                                    widthFactor: value,
                                    child: child!,
                                  ),
                                ),
                              ),

                              child: checkbox,
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                end: selectedAppIds.isNotEmpty ? 1.0 : 0.0,
                              ),
                              duration: listItemDuration,
                              curve: listItemEasing,
                              builder: (context, value, _) => SizedBox(
                                width: lerpDouble(
                                  16.0 - 8.0,
                                  16.0 - 4.0,
                                  value,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
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

      return SliverPadding(
        padding: const .symmetric(horizontal: 8.0),
        sliver: SliverMainAxisGroup(
          slivers: [
            if (pinnedApps.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const .fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Text(
                    "Pinned apps",
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              buildSliverList(pinnedApps),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const .fromLTRB(16.0, 20.0, 16.0, 8.0),
                  child: Text(
                    "Non-pinned apps",
                    style: typescaleTheme.labelLarge.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
            buildSliverList(unpinnedApps),
          ],
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

    PreferredSizeWidget getDockedOrFloatingToolbar() {
      const height = 64.0;
      final elevation = useBlackTheme
          ? elevationTheme.level0
          : elevationTheme.level3;

      final margin = EdgeInsets.fromLTRB(
        padding.left + 16.0,
        16.0,
        padding.right + 16.0,
        padding.bottom + 16.0,
      );

      final unselectedContainerColor = Colors.transparent;

      final selectedContainerColor = useBlackTheme
          ? colorTheme.primaryContainer
          : hasSelection
          ? colorTheme.surfaceContainer
          : colorTheme.secondaryContainer;

      final unselectedContentColor = hasSelection
          ? useBlackTheme
                ? colorTheme.primary
                : colorTheme.onPrimaryContainer
          : useBlackTheme
          ? colorTheme.onSurface
          : colorTheme.onSurfaceVariant;

      final selectedContentColor = useBlackTheme
          ? colorTheme.onPrimaryContainer
          : hasSelection
          ? colorTheme.onSurface
          : colorTheme.onSecondaryContainer;

      final unselectedDisabledContainerColor = Colors.transparent;

      final selectedDisabledContainerColor =
          (useBlackTheme || !hasSelection
                  ? colorTheme.onSurface
                  : colorTheme.surface)
              .withValues(alpha: useBlackTheme ? 0.12 : 0.1);

      final unselectedDisabledContentColor =
          (useBlackTheme || !hasSelection
                  ? colorTheme.onSurface
                  : colorTheme.surface)
              .withValues(alpha: 0.38);

      final selectedDisabledContentColor = unselectedDisabledContentColor;

      final Widget selectButton = IconButton(
        style: LegacyThemeFactory.createIconButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          size: .small,
          color: .filled,
          width: .normal,
          isSelected: hasSelection,
          unselectedShape: .round,
          selectedShape: .round,
          unselectedContainerColor: unselectedContainerColor,
          unselectedDisabledContainerColor: unselectedDisabledContainerColor,
          unselectedIconColor: unselectedContentColor,
          unselectedDisabledIconColor: unselectedDisabledContentColor,
          selectedContainerColor: selectedContainerColor,
          selectedDisabledContainerColor: selectedDisabledContainerColor,
          selectedIconColor: selectedContentColor,
          selectedDisabledIconColor: selectedDisabledContentColor,
        ),
        onPressed: () => hasSelection
            ? clearSelected()
            : selectThese(listedApps.map((e) => e.app).toList()),
        icon: hasSelection
            ? const Icon(Symbols.deselect_rounded)
            : const Icon(Symbols.select_all_rounded),
        tooltip: hasSelection
            ? selectedAppIds.length.toString()
            : listedApps.length.toString(),
      );

      final Widget downloadButton = IconButton(
        style: LegacyThemeFactory.createIconButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          size: .small,
          color: .filled,
          width: .wide,
          isSelected: hasSelection,
          unselectedShape: .round,
          selectedShape: .round,
          unselectedContainerColor: useBlackTheme
              ? colorTheme.primaryDim
              : colorTheme.secondaryContainer,
          unselectedIconColor: useBlackTheme
              ? colorTheme.onPrimary
              : colorTheme.onSecondaryContainer,
          selectedContainerColor: useBlackTheme
              ? colorTheme.onPrimaryContainer
              : colorTheme.surfaceContainer,
          selectedDisabledContainerColor: selectedDisabledContainerColor,
          selectedIconColor: useBlackTheme
              ? colorTheme.primaryContainer
              : colorTheme.onSurface,
          selectedDisabledIconColor: unselectedDisabledContentColor,
        ),
        onPressed: getMassObtainFunction(),
        icon: const Icon(Symbols.download_rounded),
        tooltip: hasSelection
            ? tr("installUpdateSelectedApps")
            : tr("installUpdateApps"),
      );

      final Widget removeButton = IconButton(
        style: LegacyThemeFactory.createIconButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          size: .small,
          color: .standard,
          width: .normal,
          isSelected: false,
          unselectedShape: .round,
          selectedShape: .round,
          unselectedContainerColor: unselectedContainerColor,
          unselectedDisabledContainerColor: unselectedDisabledContainerColor,
          unselectedIconColor: unselectedContentColor,
          unselectedDisabledIconColor: unselectedDisabledContentColor,
          selectedContainerColor: selectedContainerColor,
          selectedDisabledContainerColor: selectedDisabledContainerColor,
          selectedIconColor: selectedContentColor,
          selectedDisabledIconColor: selectedDisabledContentColor,
        ),
        onPressed: hasSelection
            ? () {
                appsProvider.removeAppsWithModal(
                  context,
                  selectedApps.toList(),
                );
              }
            : null,

        icon: const Icon(Symbols.delete_rounded, fill: 1.0),
        tooltip: tr("removeSelectedApps"),
      );

      final Widget categorizeButton = IconButton(
        style: LegacyThemeFactory.createIconButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          size: .small,
          color: .standard,
          width: .normal,
          isSelected: false,
          unselectedShape: .round,
          selectedShape: .round,
          unselectedContainerColor: unselectedContainerColor,
          unselectedDisabledContainerColor: unselectedDisabledContainerColor,
          unselectedIconColor: unselectedContentColor,
          unselectedDisabledIconColor: unselectedDisabledContentColor,
          selectedContainerColor: selectedContainerColor,
          selectedDisabledContainerColor: selectedDisabledContainerColor,
          selectedIconColor: selectedContentColor,
          selectedDisabledIconColor: selectedDisabledContentColor,
        ),
        onPressed: hasSelection ? launchCategorizeDialog() : null,
        icon: const Icon(Symbols.category_rounded, fill: 1.0),
        tooltip: tr("categorize"),
      );

      final Widget pinButton = IconButton(
        style: LegacyThemeFactory.createIconButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          size: .small,
          color: .standard,
          width: .normal,
          isSelected: hasPinnedSelection,
          unselectedShape: .round,
          selectedShape: .round,
          unselectedContainerColor: unselectedContainerColor,
          unselectedDisabledContainerColor: unselectedDisabledContainerColor,
          unselectedIconColor: unselectedContentColor,
          unselectedDisabledIconColor: unselectedDisabledContentColor,
          selectedContainerColor: selectedContainerColor,
          selectedDisabledContainerColor: selectedDisabledContainerColor,
          selectedIconColor: selectedContentColor,
          selectedDisabledIconColor: selectedDisabledContentColor,
        ),
        onPressed: hasSelection ? pinSelectedApps : null,
        icon: hasPinnedSelection
            ? const Icon(Symbols.keep_off_rounded, fill: 1.0)
            : const Icon(Symbols.keep_rounded, fill: 1.0),
        tooltip: hasPinnedSelection ? tr("unpinFromTop") : tr("pinToTop"),
      );

      final Widget moreButton = IconButton(
        style: LegacyThemeFactory.createIconButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          size: .small,
          color: .standard,
          width: .normal,
          isSelected: false,
          unselectedShape: .round,
          selectedShape: .round,
          unselectedContainerColor: unselectedContainerColor,
          unselectedDisabledContainerColor: unselectedDisabledContainerColor,
          unselectedIconColor: unselectedContentColor,
          unselectedDisabledIconColor: unselectedDisabledContentColor,
          selectedContainerColor: selectedContainerColor,
          selectedDisabledContainerColor: selectedDisabledContainerColor,
          selectedIconColor: selectedContentColor,
          selectedDisabledIconColor: selectedDisabledContentColor,
        ),
        onPressed: hasSelection ? showMoreOptionsDialog : null,
        icon: const Icon(Symbols.more_horiz_rounded),
        tooltip: tr("more"),
      );

      final Widget floatingActionButton = IconButton(
        style: LegacyThemeFactory.createIconButtonStyle(
          colorTheme: colorTheme,
          elevationTheme: elevationTheme,
          shapeTheme: shapeTheme,
          stateTheme: stateTheme,
          size: hasApps ? .medium : .large,
          shape: .square,
          color: .tonal,
          width: .normal,
          containerColor: !hasApps || useBlackTheme
              ? colorTheme.primary
              : colorTheme.primaryContainer,
          iconColor: !hasApps || useBlackTheme
              ? colorTheme.onPrimary
              : colorTheme.onPrimaryContainer,
          containerElevation: elevation,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => const AddAppPage()),
        ),
        icon: const Icon(Symbols.add_rounded),
        tooltip: tr("addApp"),
      );

      final Widget toolbar = SizedBox(
        height: height,
        child: Material(
          clipBehavior: .antiAlias,
          color: useBlackTheme
              ? colorTheme.surfaceContainer
              : hasSelection
              ? colorTheme.primaryContainer
              : colorTheme.surfaceContainerHighest,
          shape: CornersBorder.rounded(corners: .all(shapeTheme.corner.full)),
          elevation: elevation,
          child: Flex.horizontal(
            mainAxisSize: .min,
            children: [
              const SizedBox(width: 12.0),
              downloadButton,
              const SizedBox(width: 12.0 - 4.0),
              selectButton,
              const SizedBox(width: 12.0 - 4.0 - 4.0),
              removeButton,
              const SizedBox(width: 12.0 - 4.0 - 4.0),
              categorizeButton,
              const SizedBox(width: 12.0 - 4.0 - 4.0),
              pinButton,
              const SizedBox(width: 12.0 - 4.0 - 4.0),
              moreButton,
              const SizedBox(width: 12.0 - 4.0),
            ],
          ),
        ),
      );

      return PreferredSize(
        preferredSize: Size(.infinity, margin.vertical + height),
        child: Align.bottomCenter(
          heightFactor: 1.0,
          child: Padding(
            padding: margin,
            child: Flex.horizontal(
              mainAxisSize: .max,
              mainAxisAlignment: hasApps ? .center : .end,
              crossAxisAlignment: .center,
              children: hasApps
                  ? [
                      toolbar,
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          end: selectedAppIds.isEmpty ? 1.0 : 0.0,
                        ),
                        duration: const DurationThemeData.fallback().long2,
                        curve: const EasingThemeData.fallback().emphasized,
                        builder: (context, value, child) => Visibility(
                          visible: value > 0.0,
                          child: Opacity(
                            opacity: value,
                            child: Align.center(
                              widthFactor: value,
                              heightFactor: 1.0,
                              child: Transform.scale(
                                scale: value,
                                alignment: AlignmentDirectional.center,
                                child: child!,
                              ),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const .directional(start: 8.0),
                          child: floatingActionButton,
                        ),
                      ),
                    ]
                  : [floatingActionButton],
            ),
          ),
        ),
      );
    }

    final toolbar = getDockedOrFloatingToolbar();

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomRefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            // if (kDebugMode) {
            //   await Future.delayed(const Duration(seconds: 5));
            // }
            if (context.mounted) {
              await refresh();
            }
          },
          edgeOffset: padding.top + 64.0,
          displacement: 80.0,
          child: Scrollbar(
            controller: scrollController,
            interactive: true,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              slivers: <Widget>[
                buildLinearProgressIndicator(
                  (context, preferredSize, child) => CustomAppBar(
                    type: .small,
                    expandedContainerColor: backgroundColor,
                    collapsedContainerColor: backgroundColor,
                    collapsedTitleTextStyle: typescaleTheme.titleLargeEmphasized
                        .toTextStyle(),
                    collapsedPadding: const .symmetric(
                      horizontal: 8.0 + 52.0 + 8.0,
                    ),
                    leading: Padding(
                      padding: const .fromSTEB(8.0, 0.0, 8.0, 0.0),
                      child: IconButton(
                        style: LegacyThemeFactory.createIconButtonStyle(
                          colorTheme: colorTheme,
                          elevationTheme: elevationTheme,
                          shapeTheme: shapeTheme,
                          stateTheme: stateTheme,
                          color: .standard,
                          width: .wide,
                          isSelected: !isFilterOff,
                          unselectedContainerColor: useBlackTheme
                              ? colorTheme.surfaceContainer
                              : colorTheme.surfaceContainerHighest,
                          unselectedIconColor: useBlackTheme
                              ? colorTheme.primary
                              : colorTheme.onSurfaceVariant,
                          selectedContainerColor: useBlackTheme
                              ? colorTheme.primaryContainer
                              : colorTheme.tertiaryContainer,
                          selectedIconColor: useBlackTheme
                              ? colorTheme.onPrimaryContainer
                              : colorTheme.onTertiaryContainer,
                        ),
                        onPressed: isFilterOff
                            ? showFilterDialog
                            : () {
                                setState(() {
                                  filter = AppsFilter();
                                });
                              },
                        icon: Icon(
                          isFilterOff
                              ? Symbols.search_rounded
                              : Symbols.search_off_rounded,
                        ),
                        tooltip: isFilterOff
                            ? tr('filterApps')
                            : '${tr('filter')} - ${tr('remove')}',
                      ),
                    ),
                    title: const Text(
                      "Materium",
                      textAlign: .center,
                      maxLines: 1,
                      overflow: .ellipsis,
                      softWrap: false,
                    ),
                    trailing: Padding(
                      padding: const .fromSTEB(8.0, 0.0, 8.0, 0.0),
                      child: IconButton(
                        style: LegacyThemeFactory.createIconButtonStyle(
                          colorTheme: colorTheme,
                          elevationTheme: elevationTheme,
                          shapeTheme: shapeTheme,
                          stateTheme: stateTheme,
                          color: .standard,
                          width: .wide,
                          containerColor: useBlackTheme
                              ? colorTheme.surfaceContainer
                              : colorTheme.surfaceContainerHighest,
                          iconColor: useBlackTheme
                              ? colorTheme.primary
                              : colorTheme.onSurfaceVariant,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const SettingsPage(),
                          ),
                        ),
                        icon: const Icon(Symbols.settings_rounded, fill: 1.0),
                        tooltip: tr("settings"),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: preferredSize,
                      child: Padding(
                        padding: const .symmetric(horizontal: 4.0),
                        child: KeyedSubtree(
                          key: _progressIndicatorKey,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
                getDisplayedList(),
                if (listedApps.isEmpty)
                  SliverFillRemaining(
                    fillOverscroll: false,
                    hasScrollBody: false,
                    child: Align.center(
                      child: Text(
                        !hasApps
                            ? appsProvider.loadingApps
                                  ? tr("pleaseWait")
                                  : tr("noApps")
                            : tr("noAppsForFilter"),
                        style: typescaleTheme.headlineMedium.toTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (hasApps)
                  SliverToBoxAdapter(
                    child: SizedBox(height: toolbar.preferredSize.height),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: toolbar,
    );
  }
}

class AppsFilter {
  AppsFilter({
    this.nameFilter = "",
    this.authorFilter = "",
    this.idFilter = "",
    this.includeUptodate = true,
    this.includeNonInstalled = true,
    this.categoryFilter = const {},
    this.sourceFilter = "",
  });

  String nameFilter;
  String authorFilter;
  String idFilter;
  bool includeUptodate;
  bool includeNonInstalled;
  Set<String> categoryFilter;
  String sourceFilter;

  Map<String, Object?> toFormValuesMap() => {
    "appName": nameFilter,
    "author": authorFilter,
    "appId": idFilter,
    "upToDateApps": includeUptodate,
    "nonInstalledApps": includeNonInstalled,
    "sourceFilter": sourceFilter,
  };

  void setFormValuesFromMap(Map<String, Object?> values) {
    nameFilter = values["appName"]! as String;
    authorFilter = values["author"]! as String;
    idFilter = values["appId"]! as String;
    includeUptodate = values["upToDateApps"] as bool;
    includeNonInstalled = values["nonInstalledApps"] as bool;
    sourceFilter = values["sourceFilter"] as String;
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
