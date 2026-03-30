import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/custom_refresh_indicator.dart';
import 'package:materium/components/expressive_list_bullet.dart';
import 'package:materium/components/sliver_dynamic_header_basic.dart';
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

typedef _SegmentedListItemContainerBuilder =
    Widget Function(
      BuildContext context,
      bool isFirst,
      bool isLast,
      Widget child,
    );

extension type const _SegmentedListItemData._(
  ({
    Key? key,
    bool visible,
    _SegmentedListItemContainerBuilder? containerBuilder,
    Widget content,
  })
  _
) {
  const _SegmentedListItemData({
    Key? key,
    bool visible = true,
    _SegmentedListItemContainerBuilder? containerBuilder,
    required Widget content,
  }) : this._((
         key: key,
         visible: visible,
         containerBuilder: containerBuilder,
         content: content,
       ));

  Key? get key => _.key;

  bool get visible => _.visible;

  _SegmentedListItemContainerBuilder? get containerBuilder =>
      _.containerBuilder;

  Widget get content => _.content;
}

class _SegmentedList extends StatefulWidget {
  const _SegmentedList({
    super.key,
    this.spacing,
    this.builder = defaultBuilder,
    this.header,
    this.items = const [],
  });

  final double? spacing;
  final Widget Function(BuildContext context, List<Widget> children) builder;
  final _SegmentedListItemData? header;
  final List<_SegmentedListItemData> items;

  @override
  State<_SegmentedList> createState() => _SegmentedListState();

  static Widget defaultBuilder(BuildContext context, List<Widget> children) =>
      Flex.vertical(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: children,
      );
}

class _SegmentedListState extends State<_SegmentedList> {
  late int _visibleCount;
  int? _firstIndex;
  int? _lastIndex;

  void _updateIndices() {
    _visibleCount = 0;
    _firstIndex = null;
    _lastIndex = null;

    for (var index = 0; index < widget.items.length; index++) {
      final item = widget.items[index];
      if (item.visible) {
        _visibleCount++;
        _firstIndex ??= index;
        _lastIndex = index;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _updateIndices();
  }

  @override
  void didUpdateWidget(covariant _SegmentedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.items, oldWidget.items)) {
      _updateIndices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = widget.spacing ?? 2.0;
    final header = widget.header;
    final items = widget.items;

    final children = List<Widget>.filled(
      header != null ? items.length + 1 : items.length,
      const _NullWidget(),
    );

    if (header != null) {
      children[0] = _SegmentedListItem(
        key: header.key,
        isFirst: true,
        isLast: true,
        spacing: 0.0,
        isVisible: _visibleCount > 0,
        containerBuilder: header.containerBuilder,
        content: header.content,
      );
    }

    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final isFirst = index == _firstIndex;
      final isLast = index == _lastIndex;
      final childIndex = header != null ? index + 1 : index;
      children[childIndex] = _SegmentedListItem(
        key: item.key,
        isFirst: isFirst,
        isLast: isLast,
        spacing: spacing,
        isVisible: item.visible,
        containerBuilder: item.containerBuilder,
        content: item.content,
      );
    }

    return widget.builder(context, children);
  }
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}

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

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(tr("copiedToClipboard"))));
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

    final installedVersion = app?.app.installedVersion;
    final latestVersion = app?.app.latestVersion;
    final isInstalled = installedVersion != null;
    final isUpToDate = installedVersion == latestVersion;

    final apkUrls = app?.app.apkUrls ?? const [];
    final otherAssetUrls = app?.app.otherAssetUrls ?? const [];
    final apkText = apkUrls.isNotEmpty
        ? apkUrls.length == 1
              ? apkUrls.single.key
              : plural("apk", apkUrls.length)
        : null;

    final versionLines = [
      if (isInstalled) ...[
        "${app?.app.installedVersion} ${tr("installed")}${isUpToDate ? "/${tr("latest")}" : ""}",
        if (!isUpToDate) "${app?.app.latestVersion} ${tr("latest")}",
      ] else
        tr("notInstalled"),
    ].join("\n");

    final infoLines = [
      if (installedVersionIsEstimate) tr("pseudoVersionInUse"),
      if (trackOnly) tr("xIsTrackOnly", args: [tr("app")]),
      tr(
        "lastUpdateCheckX",
        args: [
          app?.app.lastUpdateCheck == null
              ? tr("never")
              : "${app?.app.lastUpdateCheck?.toLocal()}",
        ],
      ),
      if ((app?.app.apkUrls.length ?? 0) > 0)
        ?(app?.app.apkUrls.length == 1
            ? app?.app.apkUrls[0].key
            : plural("apk", app?.app.apkUrls.length ?? 0)),
    ].join("\n");

    final changeLogFn = app != null ? getChangeLogFn(context, app.app) : null;

    final Widget list = Padding(
      padding: const .symmetric(horizontal: 8.0),
      child: Skeletonizer(
        enabled: updating,
        effect: ShimmerEffect(
          baseColor: colorTheme.surfaceContainer,
          highlightColor: colorTheme.surfaceContainerHighest,
        ),
        child: ListItemTheme.merge(
          data: .from(
            containerColor: .all(colorTheme.surface),
            leadingIconTheme: .all(
              .from(
                color: useBlackTheme
                    ? colorTheme.primary
                    : colorTheme.onSurfaceVariant,
              ),
            ),
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
          child: Flex.vertical(
            crossAxisAlignment: .stretch,
            children: [
              _SegmentedList(
                items: [
                  _SegmentedListItemData(
                    visible: aboutText != null,
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: ListItemInteraction(
                            onLongPress: () => _copyText(aboutText ?? ""),
                            child: child,
                          ),
                        ),
                    content: ListItemLayout(
                      leading: const Icon(
                        Symbols.format_quote_rounded,
                        fill: 1.0,
                      ),
                      overline: Text(tr("about")),
                      // headline: Text(aboutText ?? ""),
                      headline: MarkdownBody(
                        data: aboutText ?? "",
                        styleSheet: MarkdownStyleSheet(
                          p: typescaleTheme.bodyLarge.toTextStyle(
                            color: colorTheme.onSurface,
                          ),
                          a: TextStyle(
                            color: colorTheme.tertiary,
                            decoration: .underline,
                            decorationColor: colorTheme.tertiary,
                          ),
                          strong: const TextStyle(fontWeight: .w700),
                          em: const TextStyle(fontStyle: .italic),
                          code: typescaleTheme.bodyLarge.toTextStyle().copyWith(
                            fontFamily: FontFamily.firaCode,
                            backgroundColor: colorTheme.surfaceContainer,
                          ),
                          codeblockDecoration: ShapeDecoration(
                            shape: CornersBorder.rounded(
                              corners: .all(shapeTheme.corner.medium),
                            ),
                            color: colorTheme.surfaceContainer,
                          ),
                        ),
                        onTapLink: (text, href, title) {
                          if (href != null) {
                            launchUrlString(href, mode: .externalApplication);
                          }
                        },
                        extensionSet: md.ExtensionSet.gitHubFlavored,
                      ),
                    ),
                  ),
                ],
              ),
              _SegmentedList(
                header: _SegmentedListItemData(
                  content: Skeleton.keep(
                    child: ListItemLayout(
                      minHeight: 0.0,
                      padding: const .fromLTRB(16.0, 20.0, 16.0, 8.0),
                      contentPadding: .zero,
                      headline: Text(
                        "Install status",
                        style: typescaleTheme.labelLarge.toTextStyle(
                          color: colorTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                items: [
                  _SegmentedListItemData(
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: ListItemInteraction(
                            onLongPress: isInstalled
                                ? () => _copyText(installedVersion)
                                : null,
                            child: child,
                          ),
                        ),
                    content: ListItemLayout(
                      leading: const Icon(Symbols.info_rounded, fill: 1.0),
                      overline: const Text("Installed version"),
                      headline: Text(
                        isInstalled ? installedVersion : tr("notInstalled"),
                      ),
                      trailing: isInstalled
                          ? SizedBox(
                              width: 40.0,
                              child: Align.center(
                                child: Skeleton.leaf(
                                  child: Tooltip(
                                    message: isUpToDate
                                        ? "Latest version installed"
                                        : "Newer version available",
                                    child: SizedBox(
                                      width: 32.0,
                                      height: 40.0,
                                      child: Material(
                                        clipBehavior: .antiAlias,
                                        shape: CornersBorder.rounded(
                                          corners: .all(shapeTheme.corner.full),
                                          // side: BorderSide(
                                          //   color: colorTheme.outlineVariant,
                                          // ),
                                        ),
                                        color: colorTheme.surfaceContainer,
                                        child: isUpToDate
                                            ? Icon(
                                                Symbols.check_rounded,
                                                color: colorTheme.secondary,
                                              )
                                            : Icon(
                                                Symbols.close_rounded,
                                                color: colorTheme.error,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  _SegmentedListItemData(
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: ListItemInteraction(
                            onLongPress: () => _copyText(latestVersion ?? ""),
                            child: child,
                          ),
                        ),
                    content: ListItemLayout(
                      padding: const .directional(start: 16.0, end: 16.0 - 4.0),
                      trailingPadding: const .symmetric(vertical: 10.0 - 4.0),
                      trailingSpace: 12.0 - 4.0,
                      leading: const Icon(
                        Symbols.release_alert_rounded,
                        fill: 1.0,
                      ),
                      overline: const Text("Latest version"),
                      headline: Text(latestVersion ?? ""),
                      supportingText:
                          changeLogFn != null || app?.app.releaseDate != null
                          ? Text(
                              app?.app.releaseDate == null
                                  ? tr("changes")
                                  : app!.app.releaseDate!.toLocal().toString(),
                            )
                          : null,
                      trailing: IconButton(
                        style: .from(
                          containerColor: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ =>
                                useBlackTheme
                                    ? colorTheme.primaryContainer
                                    : colorTheme.secondaryContainer,
                            },
                          ),
                          stateLayerColor: .all(
                            useBlackTheme
                                ? colorTheme.onPrimaryContainer
                                : colorTheme.onSecondaryContainer,
                          ),
                          iconTheme: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ => .from(
                                color: useBlackTheme
                                    ? colorTheme.onPrimaryContainer
                                    : colorTheme.onSecondaryContainer,
                              ),
                            },
                          ),
                        ),
                        settings: const .new(color: .tonal),
                        onTap:
                            changeLogFn != null || app?.app.releaseDate != null
                            ? changeLogFn
                            : null,
                        icon: const Icon(Symbols.update_rounded, fill: 0.0),
                      ),
                    ),
                  ),
                  _SegmentedListItemData(
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: ListItemInteraction(
                            onLongPress: app?.app.lastUpdateCheck != null
                                ? () => _copyText(
                                    "${app?.app.lastUpdateCheck?.toLocal()}",
                                  )
                                : null,
                            child: child,
                          ),
                        ),
                    content: ListItemLayout(
                      leading: const Icon(Symbols.schedule_rounded, fill: 1.0),
                      overline: const Text("Last update check"),
                      headline: Text(
                        app?.app.lastUpdateCheck == null
                            ? tr("never")
                            : "${app?.app.lastUpdateCheck?.toLocal()}",
                      ),
                    ),
                  ),
                ],
              ),
              _SegmentedList(
                header: _SegmentedListItemData(
                  content: Skeleton.keep(
                    child: ListItemLayout(
                      minHeight: 0.0,
                      padding: const .fromLTRB(16.0, 20.0, 16.0, 8.0),
                      contentPadding: .zero,
                      headline: Text(
                        "Metadata",
                        style: typescaleTheme.labelLarge.toTextStyle(
                          color: colorTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                items: [
                  _SegmentedListItemData(
                    visible: app?.app.url != null,
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: ListItemInteraction(
                            onLongPress: () => _copyText(app?.app.url ?? ""),
                            child: child,
                          ),
                        ),
                    content: ListItemLayout(
                      padding: const .directional(start: 16.0, end: 16.0 - 4.0),
                      trailingPadding: const .symmetric(vertical: 10.0 - 4.0),
                      trailingSpace: 12.0 - 4.0,
                      leading: const Icon(Symbols.link_2_rounded, fill: 1.0),
                      overline: const Text("Source URL"),
                      headline: Text(app?.app.url ?? ""),
                      trailing: IconButton(
                        style: .from(
                          containerColor: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ =>
                                useBlackTheme
                                    ? colorTheme.primaryContainer
                                    : colorTheme.secondaryContainer,
                            },
                          ),
                          stateLayerColor: .all(
                            useBlackTheme
                                ? colorTheme.onPrimaryContainer
                                : colorTheme.onSecondaryContainer,
                          ),
                          iconTheme: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ => .from(
                                color: useBlackTheme
                                    ? colorTheme.onPrimaryContainer
                                    : colorTheme.onSecondaryContainer,
                              ),
                            },
                          ),
                        ),
                        settings: const .new(color: .tonal),
                        onTap: () {
                          if (app?.app.url != null) {
                            launchUrlString(
                              app?.app.url ?? "",
                              mode: .externalApplication,
                            );
                          }
                        },
                        icon: const Icon(
                          Symbols.open_in_new_rounded,
                          fill: 0.0,
                        ),
                      ),
                    ),
                  ),
                  _SegmentedListItemData(
                    visible: app?.app.id != null,
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: ListItemInteraction(
                            onLongPress: () => _copyText(app?.app.id ?? ""),
                            child: child,
                          ),
                        ),
                    content: ListItemLayout(
                      leading: const Icon(Symbols.package_2_rounded, fill: 1.0),
                      overline: const Text("Package name"),
                      headline: Text(app?.app.id ?? ""),
                    ),
                  ),
                  _SegmentedListItemData(
                    visible:
                        apkUrls.isNotEmpty == true ||
                        app?.app.otherAssetUrls.isNotEmpty == true,
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: child,
                        ),
                    content: Flex.vertical(
                      mainAxisSize: .min,
                      crossAxisAlignment: .stretch,
                      children: [
                        ListItemLayout(
                          padding: const .directional(
                            start: 16.0,
                            end: 16.0 - 4.0,
                          ),
                          trailingPadding: const .symmetric(
                            vertical: 10.0 - 4.0,
                          ),
                          trailingSpace: 12.0 - 4.0,
                          leading: const Icon(
                            Symbols.android_rounded,
                            fill: 1.0,
                          ),
                          overline: const Text("Release assets"),
                          headline: Text(
                            <String>[
                              if (apkUrls.isNotEmpty)
                                <String>[
                                  "${apkUrls.length}",
                                  apkUrls.length > 1 ? "APKs" : "APK",
                                ].join(" "),
                              if (otherAssetUrls.isNotEmpty)
                                <String>[
                                  "${otherAssetUrls.length}",
                                  otherAssetUrls.length > 1
                                      ? "assets"
                                      : "asset",
                                ].join(" "),
                            ].join(" & "),
                          ),
                          trailing: Tooltip(
                            message: "Download release asset",
                            child: IconButton(
                              style: .from(
                                containerColor: .resolveWith(
                                  (states) => switch (states) {
                                    ButtonDisabledStates() => null,
                                    _ =>
                                      useBlackTheme
                                          ? colorTheme.primaryContainer
                                          : colorTheme.secondaryContainer,
                                  },
                                ),
                                stateLayerColor: .all(
                                  useBlackTheme
                                      ? colorTheme.onPrimaryContainer
                                      : colorTheme.onSecondaryContainer,
                                ),
                                iconTheme: .resolveWith(
                                  (states) => switch (states) {
                                    ButtonDisabledStates() => null,
                                    _ => .from(
                                      color: useBlackTheme
                                          ? colorTheme.onPrimaryContainer
                                          : colorTheme.onSecondaryContainer,
                                    ),
                                  },
                                ),
                              ),
                              settings: const .new(color: .tonal),
                              onTap:
                                  app?.app != null &&
                                      !updating &&
                                      (apkUrls.isNotEmpty ||
                                          otherAssetUrls.isNotEmpty)
                                  ? () async {
                                      try {
                                        await appsProvider.downloadAppAssets([
                                          app!.app.id,
                                        ], context);
                                      } catch (e) {
                                        if (context.mounted) {
                                          showError(e, context);
                                        }
                                      }
                                    }
                                  : null,
                              icon: const Icon(
                                Symbols.download_rounded,
                                fill: 0.0,
                              ),
                            ),
                          ),
                        ),
                        ...apkUrls
                            .followedBy(otherAssetUrls)
                            .take(3)
                            .mapIndexed(
                              (index, value) => ListItemInteraction(
                                stateLayerShape: .all(
                                  CornersBorder.rounded(
                                    corners: .all(shapeTheme.corner.none),
                                  ),
                                ),
                                onLongPress: () => _copyText(value.key),
                                child: ListItemLayout(
                                  alignment: .middle,
                                  leading: SizedBox(
                                    width: 24.0,
                                    height: 20.0,
                                    child: ExpressiveListBullet.indexed(
                                      index: index,
                                    ),
                                  ),
                                  headline: Text(
                                    value.key,
                                    style: typescaleTheme.bodyMediumEmphasized
                                        .mergeWith(
                                          font: const [FontFamily.firaCode],
                                        )
                                        .toTextStyle(),
                                  ),
                                ),
                              ),
                            ),
                        if (apkUrls
                            .followedBy(otherAssetUrls)
                            .skip(3)
                            .isNotEmpty)
                          ListItemLayout(
                            trailingPadding: const .symmetric(
                              vertical: 10.0 - 4.0,
                            ),
                            trailing: Button(
                              settings: const .new(size: .small, color: .text),
                              onTap: () async {
                                await Fluttertoast.cancel();
                                await Fluttertoast.showToast(
                                  msg: "Not yet implemented",
                                  toastLength: .LENGTH_SHORT,
                                );
                              },
                              label: const Text("View all"),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _SegmentedListItemData(
                    visible: app != null && app.certificateHashes.isNotEmpty,
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: child,
                        ),
                    content: Flex.vertical(
                      mainAxisSize: .min,
                      crossAxisAlignment: .stretch,
                      children: [
                        ListItemLayout(
                          leading: const Icon(
                            Symbols.verified_rounded,
                            fill: 1.0,
                          ),
                          headline: const Text("Certificate hashes"),
                          supportingText: (app?.hasMultipleSigners ?? false)
                              ? Text(tr("multipleSigners"))
                              : null,
                        ),
                        ...?app?.certificateHashes.mapIndexed(
                          (index, hash) => ListItemInteraction(
                            stateLayerShape: .all(
                              CornersBorder.rounded(
                                corners: .all(shapeTheme.corner.none),
                              ),
                            ),
                            onLongPress: () => _copyText(hash),
                            child: ListItemLayout(
                              alignment: .top,
                              leading: SizedBox(
                                width: 24.0,
                                // Keep in sync with line height
                                height: 20.0,
                                child: ExpressiveListBullet.indexed(
                                  index: index,
                                ),
                              ),
                              headline: Text(
                                hash,
                                style: typescaleTheme.bodyMediumEmphasized
                                    .mergeWith(
                                      font: const [FontFamily.firaCode],
                                    )
                                    .toTextStyle(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SegmentedListItemData(
                    visible: installedVersionIsEstimate,
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: child,
                        ),
                    content: ListItemLayout(
                      leading: const Icon(
                        Symbols.manufacturing_rounded,
                        fill: 1.0,
                      ),
                      headline: Text(tr("pseudoVersionInUse")),
                    ),
                  ),
                  _SegmentedListItemData(
                    visible: trackOnly,
                    containerBuilder: (context, isFirst, isLast, child) =>
                        ListItemContainer(
                          isFirst: isFirst,
                          isLast: isLast,
                          child: child,
                        ),
                    content: ListItemLayout(
                      leading: const Icon(
                        Symbols.notifications_active_rounded,
                        fill: 1.0,
                      ),
                      headline: Text(tr("xIsTrackOnly", args: [tr("app")])),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Skeleton.keep(
                child: ListItemLayout(
                  alignment: .top,
                  leading: const SizedBox(
                    width: 24.0,
                    child: Icon(
                      Symbols.lightbulb_2_rounded,
                      fill: 0.0,
                      opticalSize: 20.0,
                      size: 20.0,
                    ),
                  ),
                  supportingText: Text(
                    "Tap and hold an item to copy its contents as text.",
                    style: typescaleTheme.bodyMedium.toTextStyle(
                      color: colorTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget getFullInfoColumn({bool small = false}) => Flex.vertical(
      mainAxisAlignment: .center,
      crossAxisAlignment: .stretch,
      children: [
        list,
        Padding(
          padding: const .symmetric(horizontal: 8.0),
          child: Material(
            shape: CornersBorder.rounded(
              corners: .all(shapeTheme.corner.large),
            ),
            color: colorTheme.surface,
            child: Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 16.0 - 8.0),
              child: CategoryEditorSelector(
                showLabelWhenNotEmpty: false,
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
            ),
          ),
        ),
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
        mainAxisSize: .min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Flex.horizontal(
              mainAxisAlignment: .spaceEvenly,
              children: [
                if (source != null &&
                    source.combinedAppSpecificSettingFormItems.isNotEmpty)
                  IconButtonLegacy(
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
                  IconButtonLegacy(
                    onPressed: () {
                      appsProvider.openAppSettings(app.app.id);
                    },
                    icon: const Icon(Symbols.settings_rounded, fill: 1),
                    tooltip: tr('settings'),
                  ),
                // TODO: implement showAppWebpageFinal button in new toolbar
                if (app != null && showAppWebpageFinal)
                  IconButtonLegacy(
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
                  IconButtonLegacy(
                    onPressed: app?.downloadProgress != null || updating
                        ? null
                        : showMarkUpdatedDialog,
                    tooltip: tr('markUpdated'),
                    icon: const Icon(Symbols.done_rounded),
                  ),
                if ((!isVersionDetectionStandard || trackOnly) &&
                    app?.app.installedVersion != null &&
                    app?.app.installedVersion == app?.app.latestVersion)
                  IconButtonLegacy(
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
                IconButtonLegacy(
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

    final toolbarIconButtonStyle = ButtonStyleLegacy(
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
      final bottomPadding = padding.bottom;
      final showMarkUpdatedButton =
          app?.app.installedVersion != null &&
          app?.app.installedVersion != app?.app.latestVersion &&
          !isVersionDetectionStandard &&
          !trackOnly;
      final showResetInstallStatusButton =
          (!isVersionDetectionStandard || trackOnly) &&
          app?.app.installedVersion != null &&
          app?.app.installedVersion == app?.app.latestVersion;
      return Material(
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
                    child: Tooltip(
                      message: tr("remove"),
                      child: IconButton(
                        style: .from(
                          containerColor: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ => colorTheme.errorContainer,
                            },
                          ),
                          stateLayerColor: .all(colorTheme.onErrorContainer),
                          iconTheme: .resolveWith(
                            (states) => .from(
                              color: switch (states) {
                                ButtonDisabledStates() => null,
                                _ => colorTheme.onErrorContainer,
                              },
                            ),
                          ),
                        ),
                        settings: const .new(
                          size: .medium,
                          color: .tonal,
                          width: .narrow,
                        ),
                        onTap: app?.downloadProgress != null || updating
                            ? null
                            : () {
                                appsProvider
                                    .removeAppsWithModal(
                                      context,
                                      app != null ? [app.app] : [],
                                    )
                                    .then((value) {
                                      if (value && context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                              },
                        icon: const Icon(Symbols.delete_rounded, fill: 1.0),
                      ),
                    ),
                  ),
                  if (app != null && app.installedInfo != null)
                    Padding(
                      padding: const .directional(end: 8.0),
                      child: Tooltip(
                        message: tr("settings"),
                        child: IconButton(
                          style: .from(
                            containerColor: .resolveWith(
                              (states) => switch (states) {
                                ButtonDisabledStates() => null,
                                _ =>
                                  useBlackTheme
                                      ? colorTheme.surfaceContainer
                                      : colorTheme.surfaceContainerHighest,
                              },
                            ),
                            stateLayerColor: .all(
                              useBlackTheme
                                  ? colorTheme.primary
                                  : colorTheme.onSurfaceVariant,
                            ),
                            iconTheme: .resolveWith(
                              (states) => .from(
                                color: switch (states) {
                                  ButtonDisabledStates() => null,
                                  _ =>
                                    useBlackTheme
                                        ? colorTheme.primary
                                        : colorTheme.onSurfaceVariant,
                                },
                              ),
                            ),
                          ),
                          settings: const .new(
                            size: .medium,
                            color: .standard,
                            width: .narrow,
                          ),
                          onTap: app.downloadProgress != null || updating
                              ? null
                              : () {
                                  appsProvider.openAppSettings(app.app.id);
                                },
                          icon: const Icon(Symbols.settings_rounded, fill: 1.0),
                        ),
                      ),
                    ),
                  if (source != null &&
                      source.combinedAppSpecificSettingFormItems.isNotEmpty)
                    Padding(
                      padding: const .directional(end: 8.0),
                      child: Tooltip(
                        message: tr("additionalOptions"),
                        child: IconButton(
                          style: .from(
                            containerColor: .resolveWith(
                              (states) => switch (states) {
                                ButtonDisabledStates() => null,
                                _ =>
                                  useBlackTheme
                                      ? colorTheme.surfaceContainer
                                      : colorTheme.surfaceContainerHighest,
                              },
                            ),
                            stateLayerColor: .all(
                              useBlackTheme
                                  ? colorTheme.primary
                                  : colorTheme.onSurfaceVariant,
                            ),
                            iconTheme: .resolveWith(
                              (states) => .from(
                                color: switch (states) {
                                  ButtonDisabledStates() => null,
                                  _ =>
                                    useBlackTheme
                                        ? colorTheme.primary
                                        : colorTheme.onSurfaceVariant,
                                },
                              ),
                            ),
                          ),
                          settings: const .new(
                            size: .medium,
                            color: .standard,
                            width: .narrow,
                          ),
                          onTap: app?.downloadProgress != null || updating
                              ? null
                              : () async {
                                  handleAdditionalOptionChanges(
                                    await showAdditionalOptionsDialog(),
                                  );
                                },
                          icon: const Icon(Symbols.edit_rounded, fill: 1.0),
                        ),
                      ),
                    ),
                  if (showMarkUpdatedButton || showResetInstallStatusButton)
                    Padding(
                      padding: const .directional(end: 8.0),
                      child: IconButton(
                        style: .from(
                          containerColor: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ =>
                                showMarkUpdatedButton
                                    ? useBlackTheme
                                          ? colorTheme.primaryContainer
                                          : colorTheme.secondaryContainer
                                    : useBlackTheme
                                    ? colorTheme.surfaceContainer
                                    : colorTheme.surfaceContainerHighest,
                            },
                          ),
                          stateLayerColor: .all(
                            showMarkUpdatedButton
                                ? useBlackTheme
                                      ? colorTheme.onPrimaryContainer
                                      : colorTheme.onSecondaryContainer
                                : useBlackTheme
                                ? colorTheme.primary
                                : colorTheme.onSurfaceVariant,
                          ),
                          iconTheme: .resolveWith(
                            (states) => .from(
                              color: switch (states) {
                                ButtonDisabledStates() => null,
                                _ =>
                                  showMarkUpdatedButton
                                      ? useBlackTheme
                                            ? colorTheme.onPrimaryContainer
                                            : colorTheme.onSecondaryContainer
                                      : useBlackTheme
                                      ? colorTheme.primary
                                      : colorTheme.onSurfaceVariant,
                              },
                            ),
                          ),
                        ),
                        settings: .new(
                          size: .medium,
                          color: showMarkUpdatedButton ? .tonal : .standard,
                          width: showMarkUpdatedButton ? .normal : .narrow,
                        ),
                        onTap: app != null && !updating
                            ? showMarkUpdatedButton
                                  ? app.downloadProgress == null
                                        ? showMarkUpdatedDialog
                                        : null
                                  : () async {
                                      app.app.installedVersion = null;
                                      await appsProvider.saveApps([app.app]);
                                    }
                            : null,
                        icon: showMarkUpdatedButton
                            ? const Icon(
                                Symbols.check_circle_rounded,
                                fill: 1.0,
                              )
                            : const Icon(Symbols.restore_rounded, fill: 1.0),
                      ),
                    ),
                  Flexible.tight(
                    child: Button.custom(
                      style: .from(
                        containerColor: .resolveWith(
                          (states) => switch (states) {
                            ButtonDisabledStates() =>
                              showProgressIndicator ? Colors.transparent : null,
                            _ => null,
                          },
                        ),
                        containerOutline: .resolveWith(
                          (states) => switch (states.settings.color) {
                            .outlined when useBlackTheme => .from(
                              color: colorTheme.outline,
                            ),
                            _ => null,
                          },
                        ),
                        labelTextStyle: .all(
                          typescaleTheme.titleMediumEmphasized.toTextStyle(),
                        ),
                      ),
                      settings: .new(
                        size: .medium,
                        shape: showProgressIndicator ? .round : .square,
                        color: showProgressIndicator ? .outlined : .filled,
                      ),
                      onTap:
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
                      child: Stack(
                        alignment: .center,
                        children: [
                          Visibility.maintain(
                            visible: !showProgressIndicator,
                            child: ButtonContent(
                              label: Text(
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
                                  color: colorTheme.primary,
                                  backgroundColor: useBlackTheme
                                      ? colorTheme.primaryContainer
                                      : colorTheme.secondaryContainer,
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

    return Scaffold(
      extendBody: false,
      appBar: showAppWebpageFinal
          ? AppBar(
              backgroundColor: backgroundColor,
              toolbarHeight: 64.0,
              leadingWidth: 8.0 + 40.0 + 8.0,
              automaticallyImplyLeading: false,
              leading: showBackButton
                  ? const Align.center(child: DeveloperPageBackButton())
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
            // if (kDebugMode) {
            //   await Future.delayed(const Duration(seconds: 5));
            // }
            if (app != null) {
              return getUpdate(app.app.id);
            }
          },
          edgeOffset: padding.top,
          displacement: (96.0 - 48.0) / 2.0,
          child: showAppWebpageFinal
              ? getAppWebView()
              : CustomScrollView(
                  slivers: [
                    _AppPageAppBar(
                      collapsedPadding: const .symmetric(
                        horizontal: 24.0 - 4.0,
                      ),
                      expandedContainerColor: backgroundColor,
                      collapsedContainerColor: backgroundColor,
                      leading: const DeveloperPageBackButton(),
                      trailing: IconButton(
                        style: .from(
                          containerColor: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ =>
                                useBlackTheme
                                    ? colorTheme.surfaceContainer
                                    : colorTheme.surfaceContainerHighest,
                            },
                          ),
                          stateLayerColor: .all(
                            useBlackTheme
                                ? colorTheme.primary
                                : colorTheme.onSurfaceVariant,
                          ),
                          iconTheme: .resolveWith(
                            (states) => switch (states) {
                              ButtonDisabledStates() => null,
                              _ => .from(
                                color: useBlackTheme
                                    ? colorTheme.primary
                                    : colorTheme.onSurfaceVariant,
                              ),
                            },
                          ),
                        ),
                        settings: const .new(
                          size: .small,
                          shape: .round,
                          color: .standard,
                          width: .normal,
                        ),
                        onTap: app != null
                            ? () => pm.openApp(app.app.id)
                            : null,
                        icon: const Icon(Symbols.open_in_new_rounded),
                      ),
                      icon: FutureBuilder(
                        future: appsProvider
                            .updateAppIcon(app?.app.id, ignoreCache: true)
                            .then((_) => app?.icon),
                        builder: (context, snapshot) {
                          final isLoading = snapshot.connectionState != .done;
                          final bytes = snapshot.data;
                          final iconTheme = IconTheme.of(context);
                          final isCollapsed = iconTheme.size <= 48.0;
                          return Padding(
                            padding: const .symmetric(
                              horizontal: 24.0 + 40.0 + 24.0,
                            ),
                            child: Align.center(
                              child: SizedBox(
                                width: .infinity,
                                height: math.max(
                                  iconTheme.size,
                                  48.0 + 8.0 * 2.0,
                                ),
                                child: Tooltip(
                                  message: isCollapsed ? app?.name ?? "" : "",
                                  child: InkWell(
                                    customBorder: CornersBorder.rounded(
                                      corners: .all(shapeTheme.corner.full),
                                    ),
                                    overlayColor: WidgetStateLayerColor(
                                      color: WidgetStatePropertyAll(
                                        colorTheme.onSurface,
                                      ),
                                      opacity:
                                          stateTheme.asWidgetStateLayerOpacity,
                                    ),
                                    onTap: isCollapsed ? () {} : null,
                                    child: OverflowBox(
                                      alignment: .center,
                                      minWidth: iconTheme.size,
                                      maxWidth: iconTheme.size,
                                      minHeight: iconTheme.size,
                                      maxHeight: iconTheme.size,
                                      child: Skeletonizer(
                                        enabled: isLoading,
                                        effect: ShimmerEffect(
                                          baseColor:
                                              colorTheme.surfaceContainerHigh,
                                          highlightColor: colorTheme
                                              .surfaceContainerHighest,
                                        ),
                                        child: Skeleton.leaf(
                                          child: Material(
                                            clipBehavior: .antiAlias,
                                            shape: CornersBorder.rounded(
                                              corners: .all(
                                                shapeTheme.corner.full,
                                              ),
                                            ),
                                            color: !isLoading && bytes != null
                                                ? useBlackTheme
                                                      ? colorTheme
                                                            .surfaceContainerLow
                                                      : colorTheme
                                                            .surfaceContainerHighest
                                                : Colors.transparent,
                                            child: !isLoading
                                                ? bytes != null
                                                      ? Image.memory(
                                                          bytes,
                                                          fit: .cover,
                                                          gaplessPlayback: true,
                                                        )
                                                      : Icon(
                                                          Symbols
                                                              .broken_image_rounded,
                                                          // opticalSize:
                                                          //     48.0,
                                                          // size: 48.0,
                                                          color: colorTheme
                                                              .primary,
                                                        )
                                                : const SizedBox.shrink(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      headline: Text(app?.name ?? tr("app")),
                      supportingText: Text(
                        tr("byX", args: [app?.author ?? tr("unknown")]),
                      ),
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
    this.collapsedPadding,
    this.leading,
    required this.icon,
    required this.headline,
    required this.supportingText,
    this.trailing,
  });

  final Color? expandedContainerColor;
  final Color? collapsedContainerColor;
  final EdgeInsetsGeometry? collapsedPadding;

  final Widget? leading;
  final Widget icon;
  final Widget headline;
  final Widget supportingText;
  final Widget? trailing;

  @override
  State<_AppPageAppBar> createState() => _AppPageAppBarState();
}

class _AppPageAppBarState extends State<_AppPageAppBar> {
  @override
  Widget build(BuildContext context) {
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final padding = MediaQuery.paddingOf(context);

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

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
      builder: (context, layoutInfo) {
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
                height: currentExtent,
                child: Flex.vertical(
                  mainAxisSize: .min,
                  mainAxisAlignment: .end,
                  children: [
                    Padding(
                      padding: .only(top: iconAreaPadding),
                      child: SizedBox(
                        height: iconAreaHeight,
                        child: IconTheme.merge(
                          data: .from(opticalSize: iconSize, size: iconSize),
                          child: widget.icon,
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
              Positioned(
                left: padding.left,
                top: padding.top,
                right: padding.right,
                height: collapsedExtent,
                child: Padding(
                  padding:
                      widget.collapsedPadding ??
                      const .symmetric(horizontal: 24.0),
                  child: Flex.horizontal(
                    children: [
                      ?widget.leading,
                      const Flexible.space(),
                      ?widget.trailing,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const Curve _kFastOutLinearIn = Cubic(0.4, 0.0, 1.0, 1.0);
}

class _SegmentedListItem extends StatefulWidget {
  const _SegmentedListItem({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    this.spacing,
    this.isVisible = true,
    required this.containerBuilder,
    required this.content,
  });

  final bool isFirst;
  final bool isLast;
  final double? spacing;
  final bool isVisible;
  final _SegmentedListItemContainerBuilder? containerBuilder;
  final Widget content;

  @override
  State<_SegmentedListItem> createState() => _SegmentedListItemState();
}

class _SegmentedListItemState extends State<_SegmentedListItem>
    with SingleTickerProviderStateMixin {
  double get _spacing => widget.spacing ?? 2.0;

  double get _heightFactor => widget.isVisible ? 1.0 : 0.0;

  EdgeInsetsGeometry get _margin => widget.isVisible
      ? .only(
          top: widget.isFirst ? 0.0 : _spacing / 2.0,
          bottom: widget.isLast ? 0.0 : _spacing / 2.0,
        )
      : .zero;

  late AnimationController _controller;

  final Tween<double> _heightFactorTween = Tween<double>();
  late Animation<double> _heightFactorAnimation;

  final Tween<EdgeInsetsGeometry> _marginTween = EdgeInsetsGeometryTween();
  late Animation<EdgeInsetsGeometry> _marginAnimation;

  void _update({
    required double heightFactor,
    required EdgeInsetsGeometry margin,
  }) {
    if (heightFactor == _heightFactorTween.end && margin == _marginTween.end) {
      return;
    }

    _heightFactorTween.begin = _heightFactorAnimation.value;
    _heightFactorTween.end = heightFactor;

    _marginTween.begin = _marginAnimation.value;
    _marginTween.end = margin;

    if (_heightFactorTween.begin == _heightFactorTween.end &&
        _marginTween.begin == _marginTween.end) {
      return;
    }

    _controller.value = 0.0;
    _controller.animateTo(
      1.0,
      duration: const DurationThemeData.fallback().long2,
      curve: const EasingThemeData.fallback().standard,
    );
  }

  @override
  void initState() {
    super.initState();

    _heightFactorTween.begin = _heightFactorTween.end = _heightFactor;
    _marginTween.begin = _marginTween.end = _margin;

    _controller = AnimationController(vsync: this, value: 1.0);
    _heightFactorAnimation = _heightFactorTween.animate(_controller);
    _marginAnimation = _marginTween.animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _update(heightFactor: _heightFactor, margin: _margin);
    final Widget content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _heightFactorAnimation.value,
        child: Align.center(
          widthFactor: 1.0,
          heightFactor: _heightFactorAnimation.value,
          child: child!,
        ),
      ),
      child: widget.content,
    );
    final Widget container =
        widget.containerBuilder?.call(
          context,
          widget.isFirst,
          widget.isLast,
          content,
        ) ??
        content;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => IgnorePointer(
        ignoring: _heightFactor < 1.0,
        child: Padding(padding: _marginAnimation.value, child: child!),
      ),
      child: container,
    );
  }
}
