import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/custom_refresh_indicator.dart';
import 'package:materium/components/sliver_dynamic_header.dart';
import 'package:materium/flutter.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/main.dart';
import 'package:materium/pages/apps.dart';
import 'package:materium/pages/developer.dart';
import 'package:materium/pages/settings.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:android_package_manager/android_package_manager.dart'
    hide LaunchMode;

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
  bool hasMultipleSigners = false;
  List<String> certificateHashes = [];

  Future<void> _loadAppHashes() async {
    final pm = AndroidPackageManager();

    final packageInfo = await pm.getPackageInfo(
      packageName: prevApp?.app.id as String,
      flags: PackageInfoFlags(const {.getSigningCertificates}),
    );

    final multipleSigners =
        packageInfo?.signingInfo?.hasMultipleSigners ?? false;

    // https://developer.android.com/reference/android/content/pm/SigningInfo#getApkContentsSigners()
    final signatures = hasMultipleSigners
        ? packageInfo?.signingInfo?.apkContentSigners
        : packageInfo?.signingInfo?.signingCertificateHistory;

    final hashes =
        signatures?.map((signature) {
          final digest = sha256.convert(signature);
          return digest.bytes
              .map((b) => b.toRadixString(16).padLeft(2, "0").toUpperCase())
              .join(":");
        }).toList() ??
        <String>[];

    if (!mounted) return;

    setState(() {
      hasMultipleSigners = multipleSigners;
      certificateHashes = hashes;
    });
  }

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
    final appsProvider = context.watch<AppsProvider>();

    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final showBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final staticColors = StaticColors.of(context);

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    final developerMode = context.select<SettingsService, bool>(
      (settings) => settings.developerMode.value,
    );

    final showAppWebpage = context.select<SettingsProvider, bool>(
      (settingsProvider) => settingsProvider.showAppWebpage,
    );

    final checkUpdateOnDetailPage = context.select<SettingsProvider, bool>(
      (settingsProvider) => settingsProvider.checkUpdateOnDetailPage,
    );

    final showAppWebpageFinal =
        (showAppWebpage && !widget.showOppositeOfPreferredView) ||
        (!showAppWebpage && widget.showOppositeOfPreferredView);

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
        if (context.mounted) {
          showError(err, context);
        }
      } finally {
        if (context.mounted) {
          setState(() {
            updating = false;
          });
        }
      }
    }

    final areDownloadsRunning = appsProvider.areDownloadsRunning();

    final sourceProvider = SourceProvider();
    final app = appsProvider.apps[widget.appId]?.deepCopy();
    final source = app != null
        ? sourceProvider.getSource(
            app.app.url,
            overrideSource: app.app.overrideSource,
          )
        : null;
    if (!areDownloadsRunning &&
        prevApp == null &&
        app != null &&
        checkUpdateOnDetailPage) {
      prevApp = app;
      _loadAppHashes();
      getUpdate(app.app.id);
    }
    final trackOnly = app?.app.additionalSettings['trackOnly'] == true;

    final isVersionDetectionStandard =
        app?.app.additionalSettings['versionDetection'] == true;

    final installedVersionIsEstimate = app?.app != null
        ? isVersionPseudo(app!.app)
        : false;

    if (app != null && !_wasWebViewOpened) {
      _wasWebViewOpened = true;
      _webViewController.loadRequest(Uri.parse(app.app.url));
    }

    final aboutText = app != null
        ? switch (app.app.additionalSettings["about"]) {
            final String value when value.isNotEmpty => value,
            _ => null,
          }
        : null;

    Widget getInfoColumn() {
      var versionLines = '';
      final installed = app?.app.installedVersion != null;
      final upToDate = app?.app.installedVersion == app?.app.latestVersion;
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
      final changeLogFn = app != null ? getChangeLogFn(context, app.app) : null;
      return Flex.vertical(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
            child: Flex.vertical(
              children: [
                const SizedBox(height: 32.0),
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
                const SizedBox(height: 40.0),
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
              padding: const EdgeInsets.only(top: 4.0),
              child: Align.center(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48.0,
                    minHeight: 32.0,
                  ),
                  child: Material(
                    clipBehavior: .antiAlias,
                    shape: CornersBorder.rounded(
                      corners: .all(shapeTheme.corner.medium),
                    ),
                    color: colorTheme.surfaceContainerHighest,
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
                        opacity: stateTheme.asWidgetStateLayerOpacity,
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
          /* Certificate Hashes */
          if (installed && certificateHashes.isNotEmpty)
            Flex.vertical(
              mainAxisSize: .min,
              children: [
                const SizedBox(height: 40),
                Text(
                  "${plural("certificateHash", certificateHashes.length)}"
                  "${hasMultipleSigners ? " (${tr("multipleSigners")})" : ""}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                Flex.vertical(
                  mainAxisSize: .min,
                  children: certificateHashes.map((hash) {
                    return GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: hash));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("copiedToClipboard"))),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 0,
                        ),
                        child: Text(
                          hash,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          const SizedBox(height: 40.0),
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
              (app?.app.additionalSettings['about']! as String).isNotEmpty)
            Flex.vertical(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32.0),
                GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            app.app.additionalSettings['about'] as String? ??
                            '',
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
                    data: app!.app.additionalSettings['about']! as String,
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
        if (!developerMode) ...[
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
          SizedBox(height: small ? 10.0 : 24.0),
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
          Padding(
            padding: const .fromLTRB(16.0, 4.0, 16.0, 4.0),
            child: Align.center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 32.0,
                ),
                child: Material(
                  clipBehavior: .antiAlias,
                  shape: CornersBorder.rounded(
                    corners: .all(shapeTheme.corner.medium),
                  ),
                  color: colorTheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: () {
                      if (app?.app.url != null) {
                        launchUrlString(
                          app?.app.url ?? "",
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    onLongPress: () {
                      Clipboard.setData(
                        ClipboardData(text: app?.app.url ?? ""),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr("copiedToClipboard"))),
                      );
                    },
                    child: Padding(
                      padding: const .symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      child: Text(
                        app?.app.url ?? "",
                        textAlign: .center,
                        overflow: .ellipsis,
                        maxLines: 2,
                        style: typescaleTheme.labelLarge.toTextStyle(
                          color: colorTheme.tertiary,
                          decoration: .underline,
                          decorationColor: colorTheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(
            app?.app.id ?? '',
            textAlign: TextAlign.center,
            style: typescaleTheme.labelLarge.toTextStyle(
              color: colorTheme.onSurfaceVariant,
            ),
          ),
        ],
        if (developerMode)
          Padding(
            padding: const .symmetric(horizontal: 24.0),
            child: ListItemTheme.merge(
              data: .from(
                containerColor: .all(colorTheme.surface),
                overlineTextStyle: .all(
                  typescaleTheme.labelMedium.toTextStyle(
                    color: colorTheme.onSurface,
                  ),
                ),
                headlineTextStyle: .all(
                  typescaleTheme.bodyLargeEmphasized.toTextStyle(
                    color: colorTheme.primary,
                  ),
                ),
                supportingTextStyle: .all(
                  typescaleTheme.bodyMedium.toTextStyle(
                    color: colorTheme.onSurfaceVariant,
                  ),
                ),
              ),
              child: Flex.vertical(
                children: [
                  if (aboutText != null)
                    ListItemContainer(
                      isFirst: true,
                      child: ListItemInteraction(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: aboutText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr("copiedToClipboard"))),
                          );
                        },
                        child: ListItemLayout(
                          leading: CustomListItemLeading.fromExtendedColor(
                            extendedColor: staticColors.cyan,
                            pairing: .variantOnFixed,
                            child: const Icon(Symbols.info_rounded, fill: 1.0),
                          ),
                          overline: Text("About"),
                          headline: Text(aboutText),
                          supportingText: Text("Hold to copy"),
                        ),
                      ),
                    ),
                  const SizedBox(height: 2.0),
                  ListItemContainer(
                    isFirst: aboutText == null,
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
                        Clipboard.setData(
                          ClipboardData(text: app?.app.url ?? ""),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("copiedToClipboard"))),
                        );
                      },
                      child: ListItemLayout(
                        leading: CustomListItemLeading.fromExtendedColor(
                          extendedColor: staticColors.blue,
                          pairing: .variantOnFixed,
                          child: const Icon(Symbols.link_rounded, fill: 1.0),
                        ),
                        overline: Text("App source URL"),
                        headline: Text(
                          app?.app.url ?? "",
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                        supportingText: Text("Click to open, hold to copy"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  ListItemContainer(
                    isLast: true,
                    child: ListItemInteraction(
                      onLongPress: () {
                        Clipboard.setData(
                          ClipboardData(text: app?.app.id ?? ""),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("copiedToClipboard"))),
                        );
                      },
                      child: ListItemLayout(
                        leading: CustomListItemLeading.fromExtendedColor(
                          extendedColor: staticColors.green,
                          pairing: .variantOnFixed,
                          child: const Icon(
                            Symbols.package_2_rounded,
                            fill: 1.0,
                          ),
                        ),
                        overline: Text("App package name"),
                        headline: Text(
                          app?.app.id ?? "",
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                        supportingText: Text("Hold to copy"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        getInfoColumn(),
        const SizedBox(height: 16.0),
      ],
    );

    Widget getAppWebView() => app != null
        ? WebViewWidget(
            key: ObjectKey(_webViewController),
            controller: _webViewController..setBackgroundColor(backgroundColor),
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

    Future<Map<String, Object?>?>? showAdditionalOptionsDialog() async {
      return await showDialog<Map<String, Object?>?>(
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
          if (context.mounted) {
            showMessage(tr('appsFromSourceAreTrackOnly'), context);
          }
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
                  if (context.mounted) {
                    showMessage(successMessage, context);
                  }
                }
                if (res.isNotEmpty && context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  showError(e, context);
                }
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
                    icon: const Icon(Symbols.edit_rounded, fill: 1),
                  ),
                if (app != null && app.installedInfo != null)
                  IconButton(
                    onPressed: () {
                      appsProvider.openAppSettings(app.app.id);
                    },
                    icon: const Icon(Symbols.settings_rounded, fill: 1),
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
                    icon: const Icon(Symbols.more_horiz_rounded),
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
                    icon: const Icon(Symbols.done_rounded),
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
                    icon: const Icon(Symbols.restore_rounded),
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
                  icon: const Icon(Symbols.delete_rounded, fill: 0),
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
        opacity: stateTheme.asWidgetStateLayerOpacity,
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

    Widget buildFooter() {
      Widget? oldFooter;
      if (!developerMode) {
        oldFooter = Material(
          clipBehavior: .antiAlias,
          shape: CornersBorder.rounded(corners: .all(shapeTheme.corner.none)),
          color: useBlackTheme
              ? backgroundColor
              : colorTheme.surfaceContainerHigh,
          child: Padding(
            padding: .fromLTRB(
              padding.left,
              0.0,
              padding.right,
              padding.bottom,
            ),
            child: SizedBox(
              width: .infinity,
              height: 64.0,
              child: Flex.horizontal(
                mainAxisAlignment: .center,
                children: [
                  const SizedBox(width: 16.0 - 4.0),
                  Flexible.tight(
                    child: Flex.horizontal(
                      mainAxisAlignment: .start,
                      children: [
                        if (source != null &&
                            source
                                .combinedAppSpecificSettingFormItems
                                .isNotEmpty)
                          IconButton(
                            style: toolbarIconButtonStyle,
                            onPressed: app?.downloadProgress != null || updating
                                ? null
                                : () async {
                                    handleAdditionalOptionChanges(
                                      await showAdditionalOptionsDialog(),
                                    );
                                  },
                            icon: const Icon(Symbols.edit_rounded, fill: 1.0),
                            tooltip: tr("additionalOptions"),
                          ),
                        if (app != null && app.installedInfo != null) ...[
                          const SizedBox(width: 12.0 - 4.0 - 4.0),
                          IconButton(
                            style: toolbarIconButtonStyle,
                            onPressed: () {
                              appsProvider.openAppSettings(app.app.id);
                            },
                            icon: const Icon(
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
                            icon: const Icon(Symbols.done_rounded),
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
                            icon: const Icon(Symbols.restore_rounded),
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
                                if (context.mounted) {
                                  showMessage(successMessage, context);
                                }
                              }
                              if (res.isNotEmpty && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showError(e, context);
                              }
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
                              opacity: stateTheme.asWidgetStateLayerOpacity,
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
                                  value: app!.downloadProgress! >= 0
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

                          icon: const Icon(Symbols.delete_rounded, fill: 1.0),
                          tooltip: tr("remove"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0 - 4.0),
                ],
              ),
            ),
          ),
        );
      }

      Widget? newFooter;
      if (oldFooter == null || developerMode) {
        final bottomPadding = oldFooter == null ? padding.bottom : 0.0;
        newFooter = Material(
          clipBehavior: .antiAlias,
          shape: CornersBorder.rounded(corners: .all(shapeTheme.corner.none)),
          color: backgroundColor,
          child: Padding(
            padding: .fromLTRB(padding.left, 0.0, padding.right, bottomPadding),
            child: SizedBox(
              width: .infinity,
              height: 56.0 + 16.0 * 2.0,
              child: Padding(
                padding: const .all(16.0),
                child: Flex.horizontal(
                  children: [
                    Padding(
                      padding: const .directional(end: 8.0),
                      child: IconButton(
                        style: LegacyThemeFactory.createIconButtonStyle(
                          colorTheme: colorTheme,
                          elevationTheme: elevationTheme,
                          shapeTheme: shapeTheme,
                          stateTheme: stateTheme,
                          size: .medium,
                          color: .tonal,
                          width: .narrow,
                          containerColor: colorTheme.errorContainer,
                          iconColor: colorTheme.onErrorContainer,
                        ),
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
                        icon: const Icon(Symbols.delete_rounded, fill: 1.0),
                        tooltip: tr("remove"),
                      ),
                    ),
                    if (app != null && app.installedInfo != null)
                      Padding(
                        padding: const .directional(end: 8.0),
                        child: IconButton(
                          style: LegacyThemeFactory.createIconButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            size: .medium,
                            color: .standard,
                            width: .narrow,
                            containerColor: useBlackTheme
                                ? colorTheme.surfaceContainer
                                : colorTheme.surfaceContainerHighest,
                            iconColor: useBlackTheme
                                ? colorTheme.primary
                                : colorTheme.onSurfaceVariant,
                          ),
                          onPressed: app.downloadProgress != null || updating
                              ? null
                              : () {
                                  appsProvider.openAppSettings(app.app.id);
                                },
                          icon: const Icon(Symbols.settings_rounded, fill: 1.0),
                          tooltip: tr("settings"),
                        ),
                      ),
                    if (source != null &&
                        source.combinedAppSpecificSettingFormItems.isNotEmpty)
                      Padding(
                        padding: const .directional(end: 8.0),
                        child: IconButton(
                          style: LegacyThemeFactory.createIconButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            size: .medium,
                            color: .standard,
                            width: .narrow,
                            containerColor: useBlackTheme
                                ? colorTheme.surfaceContainer
                                : colorTheme.surfaceContainerHighest,
                            iconColor: useBlackTheme
                                ? colorTheme.primary
                                : colorTheme.onSurfaceVariant,
                          ),
                          onPressed: app?.downloadProgress != null || updating
                              ? null
                              : () async {
                                  handleAdditionalOptionChanges(
                                    await showAdditionalOptionsDialog(),
                                  );
                                },
                          icon: const Icon(Symbols.edit_rounded, fill: 1.0),
                          tooltip: tr("additionalOptions"),
                        ),
                      ),
                    if ((!isVersionDetectionStandard || trackOnly) &&
                        app?.app.installedVersion != null &&
                        app?.app.installedVersion == app?.app.latestVersion)
                      Padding(
                        padding: const .directional(end: 8.0),
                        child: IconButton(
                          style: LegacyThemeFactory.createIconButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            size: .medium,
                            color: .standard,
                            width: .narrow,
                            containerColor: useBlackTheme
                                ? colorTheme.surfaceContainer
                                : colorTheme.surfaceContainerHighest,
                            iconColor: useBlackTheme
                                ? colorTheme.primary
                                : colorTheme.onSurfaceVariant,
                          ),
                          onPressed: app?.app == null || updating
                              ? null
                              : () {
                                  app!.app.installedVersion = null;
                                  appsProvider.saveApps([app.app]);
                                },
                          icon: const Icon(Symbols.restore_rounded, fill: 1.0),
                          tooltip: tr("resetInstallStatus"),
                        ),
                      ),
                    if (app?.app.installedVersion != null &&
                        app?.app.installedVersion != app?.app.latestVersion &&
                        !isVersionDetectionStandard &&
                        !trackOnly)
                      Padding(
                        padding: const .directional(end: 8.0),
                        child: IconButton(
                          style: LegacyThemeFactory.createIconButtonStyle(
                            colorTheme: colorTheme,
                            elevationTheme: elevationTheme,
                            shapeTheme: shapeTheme,
                            stateTheme: stateTheme,
                            size: .medium,
                            color: .tonal,
                            width: .normal,
                            containerColor: useBlackTheme
                                ? colorTheme.primaryContainer
                                : colorTheme.secondaryContainer,
                            iconColor: useBlackTheme
                                ? colorTheme.onPrimaryContainer
                                : colorTheme.onSecondaryContainer,
                          ),
                          onPressed: app?.downloadProgress != null || updating
                              ? null
                              : showMarkUpdatedDialog,
                          icon: const Icon(
                            Symbols.check_circle_rounded,
                            fill: 1.0,
                          ),
                          tooltip: tr("markUpdated"),
                        ),
                      ),
                    Flexible.tight(
                      child: FilledButton(
                        style: LegacyThemeFactory.createButtonStyle(
                          colorTheme: colorTheme,
                          elevationTheme: elevationTheme,
                          shapeTheme: shapeTheme,
                          stateTheme: stateTheme,
                          typescaleTheme: typescaleTheme,
                          size: .medium,
                          color: .filled,
                          textStyle: typescaleTheme.titleMediumEmphasized
                              .toTextStyle(),
                          disabledContainerColor: showProgressIndicator
                              ? useBlackTheme
                                    ? colorTheme.primaryContainer
                                    : colorTheme.surfaceContainerHighest
                              : null,
                          padding: .zero,
                        ),
                        onPressed:
                            !updating &&
                                (app?.app.installedVersion == null ||
                                    app?.app.installedVersion !=
                                        app?.app.latestVersion) &&
                                !areDownloadsRunning
                            ? () async {
                                try {
                                  final successMessage =
                                      app?.app.installedVersion == null
                                      ? tr("installed")
                                      : tr("appsUpdated");
                                  HapticFeedback.heavyImpact();
                                  final res = await appsProvider
                                      .downloadAndInstallLatestApps(
                                        app?.app.id != null
                                            ? [app!.app.id]
                                            : [],
                                        globalNavigatorKey.currentContext,
                                      );
                                  if (res.isNotEmpty && !trackOnly) {
                                    if (context.mounted) {
                                      showMessage(successMessage, context);
                                    }
                                  }
                                  if (res.isNotEmpty && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    showError(e, context);
                                  }
                                }
                              }
                            : null,
                        child: Stack(
                          alignment: .center,
                          children: [
                            Visibility.maintain(
                              visible: !showProgressIndicator,
                              child: Padding(
                                padding: const .symmetric(
                                  horizontal: 24.0,
                                  vertical: 16.0,
                                ),
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
                            Visibility.maintain(
                              visible: showProgressIndicator,
                              child: Padding(
                                padding: const .symmetric(
                                  horizontal: 8.0,
                                  vertical: 8.0,
                                ),
                                child: SizedBox.square(
                                  dimension: 40.0,
                                  child: CircularProgressIndicator(
                                    value: showProgressIndicator
                                        ? app!.downloadProgress! >= 0
                                              ? clampDouble(
                                                  app.downloadProgress! / 100,
                                                  0.0,
                                                  1.0,
                                                )
                                              : null
                                        : 0.0,
                                    padding: .zero,
                                    color: useBlackTheme
                                        ? colorTheme.onPrimaryContainer
                                        : colorTheme.primary,
                                    backgroundColor:
                                        colorTheme.surfaceContainer,
                                  ),
                                ),
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
        );
      }
      return Flex.vertical(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [?newFooter, ?oldFooter],
      );
    }

    return Scaffold(
      extendBody: false,
      appBar: showAppWebpageFinal
          ? AppBar(
              backgroundColor: backgroundColor,
              toolbarHeight: 64.0,
              leadingWidth: 8.0 + 40.0 + 8.0,
              automaticallyImplyLeading: false,
              leading: showBackButton
                  ? Align.center(child: const DeveloperPageBackButton())
                  : null,
            )
          : null,
      backgroundColor: backgroundColor,
      // TODO: replace with a Loading indicator
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomRefreshIndicator(
          onRefresh: () async {
            if (kDebugMode) {
              await Future.delayed(const Duration(seconds: 5));
            }
            if (app != null) {
              return getUpdate(app.app.id);
            }
          },
          edgeOffset: developerMode ? padding.top : padding.top + 64.0,
          displacement: developerMode ? (96.0 - 48.0) / 2.0 : 80.0,
          child: showAppWebpageFinal
              ? getAppWebView()
              : CustomScrollView(
                  slivers: [
                    developerMode
                        ? _AppPageAppBar(
                            expandedContainerColor: backgroundColor,
                            collapsedContainerColor: backgroundColor,
                            icon: Tooltip(
                              message: app?.name ?? "",
                              child: FutureBuilder(
                                future: appsProvider
                                    .updateAppIcon(
                                      app?.app.id,
                                      ignoreCache: true,
                                    )
                                    .then((_) => app?.icon),
                                builder: (context, snapshot) {
                                  final bytes = snapshot.data;
                                  final iconTheme = IconTheme.of(context);

                                  return Skeletonizer(
                                    enabled: bytes == null,
                                    effect: ShimmerEffect(
                                      baseColor:
                                          colorTheme.surfaceContainerHigh,
                                      highlightColor:
                                          colorTheme.surfaceContainerHighest,
                                    ),
                                    child: SizedBox.square(
                                      dimension: iconTheme.size,
                                      child: Skeleton.leaf(
                                        child: Material(
                                          clipBehavior: .antiAlias,
                                          shape: CornersBorder.rounded(
                                            corners: .all(
                                              shapeTheme.corner.full,
                                            ),
                                          ),
                                          color: colorTheme
                                              .surfaceContainerHighest,
                                          child: bytes != null
                                              ? Image.memory(
                                                  bytes,
                                                  fit: .cover,
                                                  gaplessPlayback: true,
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            headline: Text(app?.name ?? tr("app")),
                            supportingText: Text(
                              tr("byX", args: [app?.author ?? tr("unknown")]),
                            ),
                          )
                        : CustomAppBar(
                            type: .small,
                            expandedContainerColor: backgroundColor,
                            collapsedContainerColor: backgroundColor,
                            collapsedPadding: showBackButton
                                ? const .fromSTEB(
                                    8.0 + 40.0 + 8.0,
                                    0.0,
                                    16.0,
                                    0.0,
                                  )
                                : null,
                            leading: showBackButton
                                ? const Padding(
                                    padding: .fromSTEB(
                                      8.0 - 4.0,
                                      0.0,
                                      8.0 - 4.0,
                                      0.0,
                                    ),
                                    child: DeveloperPageBackButton(),
                                  )
                                : null,
                          ),
                    SliverToBoxAdapter(
                      child: Flex.vertical(children: [getFullInfoColumn()]),
                    ),
                    // if (kDebugMode)
                    //   SliverToBoxAdapter(
                    //     child: SizedBox(height: MediaQuery.heightOf(context)),
                    //   ),
                  ],
                ),
        ),
      ),
      // bottomSheet: kDebugMode ? getBottomSheetMenu() : null,
      bottomNavigationBar: Align.bottomCenter(
        heightFactor: 1.0,
        child: buildFooter(),
      ),
    );
  }
}

class _AppPageAppBar extends StatefulWidget {
  const _AppPageAppBar({
    super.key,
    this.expandedContainerColor,
    this.collapsedContainerColor,
    required this.icon,
    required this.headline,
    required this.supportingText,
  });

  final Color? expandedContainerColor;
  final Color? collapsedContainerColor;

  final Widget icon;
  final Widget headline;
  final Widget supportingText;

  @override
  State<_AppPageAppBar> createState() => _AppPageAppBarState();
}

class _AppPageAppBarState extends State<_AppPageAppBar> {
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final showBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final expandedContainerColor =
        widget.expandedContainerColor ?? colorTheme.surface;
    final collapsedContainerColor =
        widget.collapsedContainerColor ?? colorTheme.surfaceContainer;

    const collapsedContainerHeight = 96.0;
    const collapsedIconSize = 48.0;
    const expandedIconSize = 108.0;

    final Widget headline = DefaultTextStyle.merge(
      textAlign: .center,
      maxLines: 2,
      overflow: .ellipsis,
      style: typescaleTheme.displaySmallEmphasized.toTextStyle(
        color: colorTheme.onSurface,
      ),
      child: widget.headline,
    );

    final Widget supportingText = DefaultTextStyle.merge(
      textAlign: .center,
      maxLines: 2,
      overflow: .ellipsis,
      style: typescaleTheme.titleMedium.toTextStyle(
        color: colorTheme.onSurfaceVariant,
      ),
      child: widget.supportingText,
    );

    final Widget header = Flex.vertical(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        const SizedBox(height: 16.0),
        headline,
        const SizedBox(height: 8.0),
        supportingText,
        const SizedBox(height: 12.0),
      ],
    );

    return SliverDynamicHeader(
      minExtentPrototype: Padding(
        padding: .only(top: padding.top),
        child: const SizedBox(height: collapsedContainerHeight),
      ),
      maxExtentPrototype: Padding(
        padding: .fromLTRB(
          padding.left + 16.0,
          padding.top,
          padding.right + 16.0,
          0.0,
        ),
        child: Flex.vertical(
          children: [
            const SizedBox(height: collapsedContainerHeight),
            const SizedBox(height: expandedIconSize),
            header,
          ],
        ),
      ),
      builder: (context, layoutInfo, child) {
        final minExtent = layoutInfo.minExtent - padding.top;
        final maxExtent = layoutInfo.maxExtent - padding.top;
        final currentExtent = layoutInfo.currentExtent - padding.top;
        final shrinkOffset = layoutInfo.shrinkOffset;

        const minShrinkOffset = 0.0;
        final maxShrinkOffset = maxExtent - minExtent;

        final collapsedExtent = minExtent;

        final expandedExtent = currentExtent - minExtent;

        final collapsedFraction = clampDouble(
          (shrinkOffset - minShrinkOffset) /
              (maxShrinkOffset - minShrinkOffset),
          0.0,
          1.0,
        );
        final containerColorFraction = _kFastOutLinearIn.transform(
          collapsedFraction,
        );

        final collapsedIconFraction = clampDouble(
          (shrinkOffset - minShrinkOffset) /
              (expandedIconSize - minShrinkOffset),
          0.0,
          1.0,
        );

        final collapsedHeaderFraction = clampDouble(
          (shrinkOffset - expandedIconSize - minShrinkOffset) /
              (maxShrinkOffset - expandedIconSize - minShrinkOffset),
          0.0,
          1.0,
        );

        final color = Color.lerp(
          expandedContainerColor,
          collapsedContainerColor,
          containerColorFraction,
        )!;

        final iconSize = lerpDouble(
          expandedIconSize,
          collapsedIconSize,
          collapsedIconFraction,
        );

        final headerOpacity = lerpDouble(1.0, 0.0, collapsedHeaderFraction);

        final iconAreaPadding = lerpDouble(
          minExtent,
          0.0,
          collapsedIconFraction,
        );

        final iconAreaHeight = lerpDouble(
          expandedIconSize,
          minExtent,
          collapsedIconFraction,
        );

        return Material(
          clipBehavior: .antiAlias,
          shape: CornersBorder.rounded(corners: .all(shapeTheme.corner.none)),
          color: color,
          child: Stack(
            alignment: .topCenter,
            children: [
              Positioned(
                left: padding.left,
                top: padding.top,
                right: padding.right,
                height: collapsedExtent,
                child: Flex.horizontal(
                  children: [
                    const SizedBox(width: 24.0 - 4.0),
                    DeveloperPageBackButton(),
                  ],
                ),
              ),
              Positioned(
                left: padding.left,
                top: padding.top,
                right: padding.right,
                height: currentExtent,
                child: Flex.vertical(
                  mainAxisAlignment: .end,
                  children: [
                    Padding(
                      padding: .only(top: iconAreaPadding),
                      child: SizedBox(
                        height: iconAreaHeight,
                        child: OverflowBox(
                          alignment: .center,
                          minWidth: iconSize,
                          maxWidth: iconSize,
                          minHeight: iconSize,
                          maxHeight: iconSize,
                          child: IconTheme.merge(
                            data: .from(size: iconSize),
                            child: widget.icon,
                          ),
                        ),
                      ),
                    ),
                    Flexible.tight(
                      child: ClipRect(
                        child: Opacity(
                          opacity: headerOpacity,
                          child: OverflowBox(
                            alignment: .bottomCenter,
                            minHeight: 0.0,
                            maxHeight: maxShrinkOffset,
                            child: Padding(
                              padding: const .fromLTRB(
                                16.0,
                                expandedIconSize,
                                16.0,
                                0.0,
                              ),
                              child: header,
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
        );
      },
    );
    // return SliverHeader(minExtent: minExtent, maxExtent: maxExtent, builder: builder);
  }
}

const Curve _kFastOutLinearIn = Cubic(0.4, 0.0, 1.0, 1.0);
