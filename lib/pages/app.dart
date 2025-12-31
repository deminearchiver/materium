import 'package:easy_localization/easy_localization.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/custom_list.dart';
import 'package:materium/components/custom_refresh_indicator.dart';
import 'package:materium/flutter.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/apps.dart';
import 'package:materium/pages/settings.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:markdown/markdown.dart' as md;

class AppPage extends StatefulWidget {
  const AppPage({
    super.key,
    required this.appId,
    this.showOppositeOfPreferredView = false,
  });

  final String appId;
  final bool showOppositeOfPreferredView;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  late final WebViewController _webViewController;
  bool _wasWebViewOpened = false;
  AppInMemory? prevApp;
  bool updating = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              showError(
                ObtainiumError(error.description, unexpected: true),
                context,
              );
            }
          },
          onNavigationRequest: (request) =>
              !(request.url.startsWith("http://") ||
                  request.url.startsWith("https://") ||
                  request.url.startsWith("ftp://") ||
                  request.url.startsWith("ftps://"))
              ? NavigationDecision.prevent
              : NavigationDecision.navigate,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    var appsProvider = context.watch<AppsProvider>();
    var settingsProvider = context.watch<SettingsProvider>();

    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    var showAppWebpageFinal =
        (settingsProvider.showAppWebpage &&
            !widget.showOppositeOfPreferredView) ||
        (!settingsProvider.showAppWebpage &&
            widget.showOppositeOfPreferredView);
    Future<void> getUpdate(String id, {bool resetVersion = false}) async {
      try {
        setState(() {
          updating = true;
        });
        await appsProvider.checkUpdate(id);
        if (resetVersion) {
          appsProvider.apps[id]?.app.additionalSettings['versionDetection'] =
              true;
          if (appsProvider.apps[id]?.app.installedVersion != null) {
            appsProvider.apps[id]?.app.installedVersion =
                appsProvider.apps[id]?.app.latestVersion;
          }
          appsProvider.saveApps([appsProvider.apps[id]!.app]);
        }
      } catch (err) {
        // ignore: use_build_context_synchronously
        showError(err, context);
      } finally {
        if (context.mounted) {
          setState(() {
            updating = false;
          });
        }
      }
    }

    bool areDownloadsRunning = appsProvider.areDownloadsRunning();

    var sourceProvider = SourceProvider();
    AppInMemory? app = appsProvider.apps[widget.appId]?.deepCopy();
    var source = app != null
        ? sourceProvider.getSource(
            app.app.url,
            overrideSource: app.app.overrideSource,
          )
        : null;
    if (!areDownloadsRunning &&
        prevApp == null &&
        app != null &&
        settingsProvider.checkUpdateOnDetailPage) {
      prevApp = app;
      getUpdate(app.app.id);
    }
    var trackOnly = app?.app.additionalSettings['trackOnly'] == true;

    bool isVersionDetectionStandard =
        app?.app.additionalSettings['versionDetection'] == true;

    bool installedVersionIsEstimate = app?.app != null
        ? isVersionPseudo(app!.app)
        : false;

    if (app != null && !_wasWebViewOpened) {
      _wasWebViewOpened = true;
      _webViewController.loadRequest(Uri.parse(app.app.url));
    }

    Widget getInfoColumn() {
      String versionLines = '';
      bool installed = app?.app.installedVersion != null;
      bool upToDate = app?.app.installedVersion == app?.app.latestVersion;
      if (installed) {
        versionLines = '${app?.app.installedVersion} ${tr('installed')}';
        if (upToDate) {
          versionLines += '/${tr('latest')}';
        }
      } else {
        versionLines = tr('notInstalled');
      }
      if (!upToDate) {
        versionLines += '\n${app?.app.latestVersion} ${tr('latest')}';
      }
      String infoLines = tr(
        'lastUpdateCheckX',
        args: [
          app?.app.lastUpdateCheck == null
              ? tr('never')
              : '${app?.app.lastUpdateCheck?.toLocal()}',
        ],
      );
      if (trackOnly) {
        infoLines = '${tr('xIsTrackOnly', args: [tr('app')])}\n$infoLines';
      }
      if (installedVersionIsEstimate) {
        infoLines = '${tr('pseudoVersionInUse')}\n$infoLines';
      }
      if ((app?.app.apkUrls.length ?? 0) > 0) {
        infoLines =
            '$infoLines\n${app?.app.apkUrls.length == 1 ? app?.app.apkUrls[0].key : plural('apk', app?.app.apkUrls.length ?? 0)}';
      }
      var changeLogFn = app != null ? getChangeLogFn(context, app.app) : null;
      return Flex.vertical(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            child: Flex.vertical(
              children: [
                const SizedBox(height: 8),
                Text(
                  versionLines,
                  textAlign: TextAlign.start,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                changeLogFn != null || app?.app.releaseDate != null
                    ? GestureDetector(
                        onTap: changeLogFn,
                        child: Text(
                          app?.app.releaseDate == null
                              ? tr('changes')
                              : app!.app.releaseDate!.toLocal().toString(),
                          textAlign: TextAlign.center,
                          style: typescaleTheme.labelSmall
                              .toTextStyle()
                              .copyWith(
                                decoration: changeLogFn != null
                                    ? TextDecoration.underline
                                    : null,
                                fontStyle: changeLogFn != null
                                    ? FontStyle.italic
                                    : null,
                              ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Text(
            infoLines,
            textAlign: TextAlign.center,
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
          ),
          if (app?.app.apkUrls.isNotEmpty == true ||
              app?.app.otherAssetUrls.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align.center(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48.0,
                    minHeight: 32.0,
                  ),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    shape: CornersBorder.rounded(
                      corners: Corners.all(shapeTheme.corner.medium),
                    ),
                    color: colorTheme.surfaceContainer,
                    child: InkWell(
                      onTap: app?.app == null || updating
                          ? null
                          : () async {
                              try {
                                await appsProvider.downloadAppAssets([
                                  app!.app.id,
                                ], context);
                              } catch (e) {
                                if (context.mounted) {
                                  showError(e, context);
                                }
                              }
                            },
                      overlayColor: WidgetStateLayerColor(
                        color: WidgetStatePropertyAll(
                          colorTheme.onSurfaceVariant,
                        ),
                        opacity: stateTheme.stateLayerOpacity,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        child: Flex.horizontal(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible.loose(
                              child: Text(
                                tr(
                                  'downloadX',
                                  args: [
                                    lowerCaseIfEnglish(tr('releaseAsset')),
                                  ],
                                ),
                                style: typescaleTheme.labelLarge.toTextStyle(
                                  color: colorTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 48),
          CategoryEditorSelector(
            alignment: WrapAlignment.center,
            preselected: app?.app.categories != null
                ? app!.app.categories.toSet()
                : {},
            onSelected: (categories) {
              if (app != null) {
                app.app.categories = categories;
                appsProvider.saveApps([app.app]);
              }
            },
          ),
          if (app?.app.additionalSettings['about'] is String &&
              app?.app.additionalSettings['about'].isNotEmpty)
            Flex.vertical(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 48),
                GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: app?.app.additionalSettings['about'] ?? '',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('copiedToClipboard'))),
                    );
                  },
                  child: Markdown(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    styleSheet: MarkdownStyleSheet(
                      blockquoteDecoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      textAlign: WrapAlignment.center,
                    ),
                    data: app?.app.additionalSettings['about'],
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrlString(
                          href,
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
                ),
              ],
            ),
        ],
      );
    }

    Widget getFullInfoColumn({bool small = false}) => Flex.vertical(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: small ? 5 : 20),
        FutureBuilder(
          future: appsProvider.updateAppIcon(app?.app.id, ignoreCache: true),
          builder: (ctx, val) {
            return app?.icon != null
                ? Flex.horizontal(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: app == null
                            ? null
                            : () => pm.openApp(app.app.id),
                        child: Image.memory(
                          app!.icon!,
                          height: small ? 70 : 150,
                          gaplessPlayback: true,
                        ),
                      ),
                    ],
                  )
                : Container();
          },
        ),
        SizedBox(height: small ? 10 : 25),
        Text(
          app?.name ?? tr('app'),
          textAlign: TextAlign.center,
          style: small
              ? typescaleTheme.headlineSmallEmphasized.toTextStyle(
                  color: colorTheme.onSurface,
                )
              : typescaleTheme.displaySmallEmphasized.toTextStyle(
                  color: colorTheme.onSurface,
                ),
        ),
        Text(
          tr('byX', args: [app?.author ?? tr('unknown')]),
          textAlign: TextAlign.center,
          style: small
              ? typescaleTheme.labelLarge.toTextStyle(
                  color: colorTheme.onSurfaceVariant,
                )
              : typescaleTheme.titleMedium.toTextStyle(
                  color: colorTheme.onSurfaceVariant,
                ),
        ),
        const SizedBox(height: 24),
        if (kDebugMode) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListItemContainer(
              isFirst: true,
              child: ListItemInteraction(
                onTap: () {
                  if (app?.app.url != null) {
                    launchUrlString(
                      app?.app.url ?? "",
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: app?.app.url ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr("copiedToClipboard"))),
                  );
                },
                child: ListItemLayout(
                  leading: SizedBox.square(
                    dimension: 40.0,
                    child: Material(
                      clipBehavior: Clip.antiAlias,
                      shape: CornersBorder.rounded(
                        corners: Corners.all(shapeTheme.corner.full),
                      ),
                      color: colorTheme.primaryFixedDim,
                      child: Icon(
                        Symbols.link_rounded,
                        color: colorTheme.onPrimaryFixedVariant,
                      ),
                    ),
                  ),
                  headline: Text(app?.app.url ?? "", maxLines: 3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListItemContainer(
              child: ListItemLayout(
                leading: SizedBox.square(
                  dimension: 40.0,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    shape: CornersBorder.rounded(
                      corners: Corners.all(shapeTheme.corner.full),
                    ),
                    color: colorTheme.secondaryFixedDim,
                    child: Icon(
                      Symbols.package_2_rounded,
                      fill: 1.0,
                      color: colorTheme.onSecondaryFixedVariant,
                    ),
                  ),
                ),
                headline: Text(app?.app.id ?? "", maxLines: 3),
              ),
            ),
          ),
        ],
        GestureDetector(
          onTap: () {
            if (app?.app.url != null) {
              launchUrlString(
                app?.app.url ?? '',
                mode: LaunchMode.externalApplication,
              );
            }
          },
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: app?.app.url ?? ''));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(tr('copiedToClipboard'))));
          },
          child: Text(
            app?.app.url ?? '',
            textAlign: TextAlign.center,
            style: typescaleTheme.labelSmall
                .toTextStyle(color: colorTheme.primary)
                .copyWith(decoration: TextDecoration.underline),
          ),
        ),
        Text(
          app?.app.id ?? '',
          textAlign: TextAlign.center,
          style: typescaleTheme.labelSmall.toTextStyle(),
        ),
        getInfoColumn(),
        const SizedBox(height: 16.0),
      ],
    );

    Widget getAppWebView() => app != null
        ? WebViewWidget(
            key: ObjectKey(_webViewController),
            controller: _webViewController
              ..setBackgroundColor(colorTheme.surface),
          )
        : Container();

    Future<void> showMarkUpdatedDialog() {
      return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(tr('alreadyUpToDateQuestion')),
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
                  var updatedApp = app?.app;
                  if (updatedApp != null) {
                    updatedApp.installedVersion = updatedApp.latestVersion;
                    appsProvider.saveApps([updatedApp]);
                  }
                  Navigator.of(context).pop();
                },
                child: Text(tr('yesMarkUpdated')),
              ),
            ],
          );
        },
      );
    }

    Future<Map<String, dynamic>?>? showAdditionalOptionsDialog() async {
      return await showDialog<Map<String, dynamic>?>(
        context: context,
        builder: (ctx) {
          var items = (source?.combinedAppSpecificSettingFormItems ?? []).map((
            row,
          ) {
            row = row.map((e) {
              if (app?.app.additionalSettings[e.key] != null) {
                e.defaultValue = app?.app.additionalSettings[e.key];
              }
              return e;
            }).toList();
            return row;
          }).toList();

          return GeneratedFormModal(
            title: tr('additionalOptions'),
            items: items,
          );
        },
      );
    }

    void handleAdditionalOptionChanges(Map<String, dynamic>? values) {
      if (app != null && values != null) {
        Map<String, dynamic> originalSettings = app.app.additionalSettings;
        app.app.additionalSettings = values;
        if (source?.enforceTrackOnly == true) {
          app.app.additionalSettings['trackOnly'] = true;
          // ignore: use_build_context_synchronously
          showMessage(tr('appsFromSourceAreTrackOnly'), context);
        }
        var versionDetectionEnabled =
            app.app.additionalSettings['versionDetection'] == true &&
            originalSettings['versionDetection'] != true;
        var releaseDateVersionEnabled =
            app.app.additionalSettings['releaseDateAsVersion'] == true &&
            originalSettings['releaseDateAsVersion'] != true;
        var releaseDateVersionDisabled =
            app.app.additionalSettings['releaseDateAsVersion'] != true &&
            originalSettings['releaseDateAsVersion'] == true;
        if (releaseDateVersionEnabled) {
          if (app.app.releaseDate != null) {
            bool isUpdated = app.app.installedVersion == app.app.latestVersion;
            app.app.latestVersion = app.app.releaseDate!.microsecondsSinceEpoch
                .toString();
            if (isUpdated) {
              app.app.installedVersion = app.app.latestVersion;
            }
          }
        } else if (releaseDateVersionDisabled) {
          app.app.installedVersion =
              app.installedInfo?.versionName ?? app.app.installedVersion;
        }
        if (versionDetectionEnabled) {
          app.app.additionalSettings['versionDetection'] = true;
          app.app.additionalSettings['releaseDateAsVersion'] = false;
        }
        appsProvider.saveApps([app.app]).then((value) {
          getUpdate(app.app.id, resetVersion: versionDetectionEnabled);
        });
      }
    }

    Widget getInstallOrUpdateButton() => TextButton(
      onPressed:
          !updating &&
              (app?.app.installedVersion == null ||
                  app?.app.installedVersion != app?.app.latestVersion) &&
              !areDownloadsRunning
          ? () async {
              try {
                var successMessage = app?.app.installedVersion == null
                    ? tr('installed')
                    : tr('appsUpdated');
                HapticFeedback.heavyImpact();
                var res = await appsProvider.downloadAndInstallLatestApps(
                  app?.app.id != null ? [app!.app.id] : [],
                  globalNavigatorKey.currentContext,
                );
                if (res.isNotEmpty && !trackOnly) {
                  // ignore: use_build_context_synchronously
                  showMessage(successMessage, context);
                }
                if (res.isNotEmpty && context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                // ignore: use_build_context_synchronously
                showError(e, context);
              }
            }
          : null,
      child: Text(
        app?.app.installedVersion == null
            ? !trackOnly
                  ? tr('install')
                  : tr('markInstalled')
            : !trackOnly
            ? tr('update')
            : tr('markUpdated'),
      ),
    );

    Widget getBottomSheetMenu() => Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        MediaQuery.of(context).padding.bottom,
      ),
      child: Flex.vertical(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Flex.horizontal(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (source != null &&
                    source.combinedAppSpecificSettingFormItems.isNotEmpty)
                  IconButton(
                    onPressed: app?.downloadProgress != null || updating
                        ? null
                        : () async {
                            var values = await showAdditionalOptionsDialog();
                            handleAdditionalOptionChanges(values);
                          },
                    tooltip: tr('additionalOptions'),
                    icon: const IconLegacy(Symbols.edit_rounded, fill: 1),
                  ),
                if (app != null && app.installedInfo != null)
                  IconButton(
                    onPressed: () {
                      appsProvider.openAppSettings(app.app.id);
                    },
                    icon: const IconLegacy(Symbols.settings_rounded, fill: 1),
                    tooltip: tr('settings'),
                  ),
                // TODO: implement showAppWebpageFinal button in new toolbar
                if (app != null && showAppWebpageFinal)
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            scrollable: true,
                            content: getFullInfoColumn(small: true),
                            title: Text(app.name),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(tr('continue')),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const IconLegacy(Symbols.more_horiz_rounded),
                    tooltip: tr('more'),
                  ),
                if (app?.app.installedVersion != null &&
                    app?.app.installedVersion != app?.app.latestVersion &&
                    !isVersionDetectionStandard &&
                    !trackOnly)
                  IconButton(
                    onPressed: app?.downloadProgress != null || updating
                        ? null
                        : showMarkUpdatedDialog,
                    tooltip: tr('markUpdated'),
                    icon: const IconLegacy(Symbols.done_rounded),
                  ),
                if ((!isVersionDetectionStandard || trackOnly) &&
                    app?.app.installedVersion != null &&
                    app?.app.installedVersion == app?.app.latestVersion)
                  IconButton(
                    onPressed: app?.app == null || updating
                        ? null
                        : () {
                            app!.app.installedVersion = null;
                            appsProvider.saveApps([app.app]);
                          },
                    icon: const IconLegacy(Symbols.restore_rounded),
                    tooltip: tr('resetInstallStatus'),
                  ),
                const SizedBox(width: 16.0),
                Flexible.tight(child: getInstallOrUpdateButton()),
                const SizedBox(width: 16.0),
                IconButton(
                  onPressed: app?.downloadProgress != null || updating
                      ? null
                      : () {
                          appsProvider
                              .removeAppsWithModal(
                                context,
                                app != null ? [app.app] : [],
                              )
                              .then((value) {
                                if (value == true && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              });
                        },
                  tooltip: tr('remove'),
                  icon: const IconLegacy(Symbols.delete_rounded, fill: 0),
                ),
              ],
            ),
          ),
          if (app?.downloadProgress != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: LinearProgressIndicator(
                value: app!.downloadProgress! >= 0
                    ? app.downloadProgress! / 100
                    : null,
              ),
            ),
        ],
      ),
    );

    final toolbarIconButtonStyle = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0.0),
      shadowColor: WidgetStateColor.transparent,
      minimumSize: const WidgetStatePropertyAll(Size.zero),
      fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
      maximumSize: const WidgetStatePropertyAll(Size.infinite),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      iconSize: const WidgetStatePropertyAll(24.0),
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
            : Colors.transparent,
      ),
      iconColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colorTheme.onSurface.withValues(alpha: 0.38)
            : colorTheme.onSurfaceVariant,
      ),
    );

    final showProgressIndicator = app?.downloadProgress != null;

    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      extendBody: false,
      appBar: showAppWebpageFinal
          ? AppBar(backgroundColor: colorTheme.surfaceContainer)
          : null,
      backgroundColor: colorTheme.surfaceContainer,
      // TODO: replace with a Loading indicator
      body: CustomRefreshIndicator(
        onRefresh: () async {
          if (kDebugMode) {
            await Future.delayed(const Duration(seconds: 5));
          }
          if (app != null) {
            return getUpdate(app.app.id);
          }
        },
        edgeOffset: padding.top + 64.0,
        displacement: 80.0,
        child: showAppWebpageFinal
            ? getAppWebView()
            : CustomScrollView(
                slivers: [
                  CustomAppBar(
                    type: CustomAppBarType.small,
                    behavior: CustomAppBarBehavior.duplicate,
                    expandedContainerColor: colorTheme.surfaceContainer,
                    collapsedContainerColor: colorTheme.surfaceContainer,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 16.0 - 4.0),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0.0),
                          shadowColor: WidgetStateColor.transparent,
                          minimumSize: const WidgetStatePropertyAll(Size.zero),
                          fixedSize: const WidgetStatePropertyAll(
                            Size(40.0, 40.0),
                          ),
                          maximumSize: const WidgetStatePropertyAll(
                            Size.infinite,
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.zero,
                          ),
                          iconSize: const WidgetStatePropertyAll(24.0),
                          shape: WidgetStatePropertyAll(
                            CornersBorder.rounded(
                              corners: Corners.all(shapeTheme.corner.full),
                            ),
                          ),
                          overlayColor: WidgetStateLayerColor(
                            color: WidgetStatePropertyAll(
                              colorTheme.onSurfaceVariant,
                            ),
                            opacity: stateTheme.stateLayerOpacity,
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? colorTheme.onSurface.withValues(alpha: 0.1)
                                : colorTheme.surfaceContainerHighest,
                          ),
                          iconColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled)
                                ? colorTheme.onSurface.withValues(alpha: 0.38)
                                : colorTheme.onSurfaceVariant,
                          ),
                        ),
                        icon: const IconLegacy(Symbols.arrow_back_rounded),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Flex.vertical(children: [getFullInfoColumn()]),
                  ),
                ],
              ),
      ),
      // bottomSheet: kDebugMode ? getBottomSheetMenu() : null,
      bottomNavigationBar: Align.bottomCenter(
        heightFactor: 1.0,
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: CornersBorder.rounded(
            corners: Corners.all(shapeTheme.corner.none),
          ),
          color: colorTheme.surfaceContainerHigh,
          child: Padding(
            padding: EdgeInsets.only(bottom: padding.bottom),
            child: SizedBox(
              width: double.infinity,
              height: 64.0,
              child: Flex.horizontal(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16.0 - 4.0),
                  Flexible.tight(
                    child: Flex.horizontal(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (source != null &&
                            source
                                .combinedAppSpecificSettingFormItems
                                .isNotEmpty)
                          IconButton(
                            onPressed: app?.downloadProgress != null || updating
                                ? null
                                : () async {
                                    var values =
                                        await showAdditionalOptionsDialog();
                                    handleAdditionalOptionChanges(values);
                                  },
                            style: toolbarIconButtonStyle,
                            icon: const IconLegacy(
                              Symbols.edit_rounded,
                              fill: 1.0,
                            ),
                            tooltip: tr("additionalOptions"),
                          ),
                        if (app != null && app.installedInfo != null) ...[
                          const SizedBox(width: 12.0 - 4.0 - 4.0),
                          IconButton(
                            onPressed: () {
                              appsProvider.openAppSettings(app.app.id);
                            },
                            style: toolbarIconButtonStyle,
                            icon: const IconLegacy(
                              Symbols.settings_rounded,
                              fill: 1.0,
                            ),
                            tooltip: tr("settings"),
                          ),
                        ],
                        if (app?.app.installedVersion != null &&
                            app?.app.installedVersion !=
                                app?.app.latestVersion &&
                            !isVersionDetectionStandard &&
                            !trackOnly) ...[
                          const SizedBox(width: 12.0 - 4.0 - 4.0),
                          IconButton(
                            onPressed: app?.downloadProgress != null || updating
                                ? null
                                : showMarkUpdatedDialog,
                            style: toolbarIconButtonStyle,
                            icon: const IconLegacy(Symbols.done_rounded),
                            tooltip: tr("markUpdated"),
                          ),
                        ],
                        if ((!isVersionDetectionStandard || trackOnly) &&
                            app?.app.installedVersion != null &&
                            app?.app.installedVersion ==
                                app?.app.latestVersion) ...[
                          const SizedBox(width: 12.0 - 4.0 - 4.0),
                          IconButton(
                            onPressed: app?.app == null || updating
                                ? null
                                : () {
                                    app!.app.installedVersion = null;
                                    appsProvider.saveApps([app.app]);
                                  },
                            style: toolbarIconButtonStyle,
                            icon: const IconLegacy(Symbols.restore_rounded),
                            tooltip: tr("resetInstallStatus"),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // TODO: the amount of buttons on the left and on the right should be the same
                  const SizedBox(width: 12.0 - 4.0),
                  FilledButton(
                    onPressed:
                        !updating &&
                            (app?.app.installedVersion == null ||
                                app?.app.installedVersion !=
                                    app?.app.latestVersion) &&
                            !areDownloadsRunning
                        ? () async {
                            try {
                              var successMessage =
                                  app?.app.installedVersion == null
                                  ? tr('installed')
                                  : tr('appsUpdated');
                              HapticFeedback.heavyImpact();
                              var res = await appsProvider
                                  .downloadAndInstallLatestApps(
                                    app?.app.id != null ? [app!.app.id] : [],
                                    globalNavigatorKey.currentContext,
                                  );
                              if (res.isNotEmpty && !trackOnly) {
                                // ignore: use_build_context_synchronously
                                showMessage(successMessage, context);
                              }
                              if (res.isNotEmpty && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              // ignore: use_build_context_synchronously
                              showError(e, context);
                            }
                          }
                        : null,
                    style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(0.0),
                      shadowColor: WidgetStateColor.transparent,
                      minimumSize: const WidgetStatePropertyAll(
                        Size(48.0, 40.0),
                      ),
                      fixedSize: const WidgetStatePropertyAll(null),
                      maximumSize: const WidgetStatePropertyAll(Size.infinite),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                      iconSize: const WidgetStatePropertyAll(20.0),
                      shape: WidgetStatePropertyAll(
                        CornersBorder.rounded(
                          corners: Corners.all(shapeTheme.corner.full),
                        ),
                      ),
                      overlayColor: showProgressIndicator
                          ? WidgetStateColor.transparent
                          : WidgetStateLayerColor(
                              color: WidgetStatePropertyAll(
                                colorTheme.onPrimary,
                              ),
                              opacity: stateTheme.stateLayerOpacity,
                            ),
                      backgroundColor: showProgressIndicator
                          ? WidgetStatePropertyAll(colorTheme.surface)
                          : WidgetStateProperty.resolveWith(
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
                                    ? typescaleTheme.labelLarge
                                    : typescaleTheme.labelLargeEmphasized)
                                .toTextStyle(),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Visibility.maintain(
                          visible: !showProgressIndicator,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            child: Align.center(
                              widthFactor: null,
                              heightFactor: 1.0,
                              child: Text(
                                app?.app.installedVersion == null
                                    ? !trackOnly
                                          ? tr('install')
                                          : tr('markInstalled')
                                    : !trackOnly
                                    ? tr('update')
                                    : tr('markUpdated'),
                              ),
                            ),
                          ),
                        ),
                        if (showProgressIndicator)
                          Positioned.fill(
                            child: Align.center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: LinearProgressIndicator(
                                  stopIndicatorColor: Colors.transparent,
                                  value:
                                      !kDebugMode && app!.downloadProgress! >= 0
                                      ? clampDouble(
                                          app.downloadProgress! / 100,
                                          0.0,
                                          1.0,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0 - 4.0),
                  Flexible.tight(
                    child: Flex.horizontal(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: app?.downloadProgress != null || updating
                              ? null
                              : () {
                                  appsProvider
                                      .removeAppsWithModal(
                                        context,
                                        app != null ? [app.app] : [],
                                      )
                                      .then((value) {
                                        if (value == true && context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      });
                                },
                          style: toolbarIconButtonStyle,

                          icon: const IconLegacy(
                            Symbols.delete_rounded,
                            fill: 1.0,
                          ),
                          tooltip: tr("remove"),
                        ),
                        // ignore: dead_code
                        if (false) ...[
                          const SizedBox(width: 12.0 - 4.0 - 4.0),
                          MenuButtonTheme(
                            data: MenuButtonThemeData(
                              style: ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                                textStyle: WidgetStatePropertyAll(
                                  typescaleTheme.labelLarge.toTextStyle(),
                                ),
                              ),
                            ),
                            child: MenuAnchor(
                              consumeOutsideTap: true,
                              crossAxisUnconstrained: false,
                              style: const MenuStyle(
                                minimumSize: WidgetStatePropertyAll(
                                  Size(112.0, 0.0),
                                ),
                                maximumSize: WidgetStatePropertyAll(
                                  Size(280.0, double.infinity),
                                ),
                              ),
                              menuChildren: [
                                MenuItemButton(
                                  onPressed: () {},
                                  child: Text("AAA"),
                                ),
                              ],
                              builder: (context, controller, child) =>
                                  IconButton(
                                    onPressed: () {
                                      if (!kDebugMode) return;
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    style: toolbarIconButtonStyle,
                                    icon: const IconLegacy(Symbols.more_vert),
                                    tooltip: tr("more"),
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0 - 4.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
