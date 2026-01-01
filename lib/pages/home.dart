import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/flutter.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/pages/add_app.dart';
import 'package:materium/pages/apps.dart';
import 'package:materium/pages/import_export.dart';
import 'package:materium/pages/settings.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/theme/legacy.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

extension type const NavigationPageItem._(
  ({NavigationDestination destination, Widget widget}) _
) {
  const NavigationPageItem(NavigationDestination destination, Widget widget)
    : this._((destination: destination, widget: widget));

  NavigationDestination get destination => _.destination;
  Widget get widget => _.widget;
}

class _HomePageState extends State<HomePage> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isLinkActivity = false;

  final List<int> _selectedIndexHistory = <int>[];
  int _prevAppCount = -1;
  bool _prevIsLoading = true;

  List<NavigationPageItem> pages = [
    NavigationPageItem(
      NavigationDestination(
        icon: const IconLegacy(Symbols.apps_rounded, fill: 0.0),
        selectedIcon: const IconLegacy(Symbols.apps_rounded, fill: 1.0),
        label: tr("appsString"),
      ),
      AppsPage(key: GlobalKey<AppsPageState>()),
    ),
    NavigationPageItem(
      NavigationDestination(
        icon: const IconLegacy(Symbols.add_rounded, fill: 0.0),
        selectedIcon: const IconLegacy(Symbols.add_rounded, fill: 1.0),
        label: tr("addApp"),
      ),
      AddAppPage(key: GlobalKey<AddAppPageState>()),
    ),
    NavigationPageItem(
      NavigationDestination(
        icon: const IconLegacy(Symbols.swap_vert_rounded, fill: 0.0),
        selectedIcon: const IconLegacy(Symbols.swap_vert_rounded, fill: 1.0),
        label: tr("importExport"),
      ),
      const ImportExportPage(),
    ),
    NavigationPageItem(
      NavigationDestination(
        icon: const IconLegacy(Symbols.settings_rounded, fill: 0.0),
        selectedIcon: const IconLegacy(Symbols.settings_rounded, fill: 1.0),
        label: tr("settings"),
      ),
      const SettingsPage(),
    ),
  ];

  Future<void> _initDeepLinks() async {
    Future<void> goToAddApp(String data) async {
      _switchToPage(1);
      while ((pages[1].widget.key as GlobalKey<AddAppPageState>?)
              ?.currentState ==
          null) {
        await Future.delayed(const Duration(microseconds: 1));
      }
      (pages[1].widget.key as GlobalKey<AddAppPageState>?)?.currentState
          ?.linkFn(data);
    }

    Future<void> interpretLink(Uri uri) async {
      _isLinkActivity = true;
      final action = uri.host;
      final data = uri.path.length > 1 ? uri.path.substring(1) : "";
      try {
        if (action == 'add') {
          await goToAddApp(data);
        } else if (action == 'app' || action == 'apps') {
          final dataStr = Uri.decodeComponent(data);
          if (await showDialog(
                context: context,
                builder: (ctx) {
                  return GeneratedFormModal(
                    title: tr(
                      'importX',
                      args: [
                        (action == 'app' ? tr('app') : tr('appsString'))
                            .toLowerCase(),
                      ],
                    ),
                    items: const [],
                    additionalWidgets: [
                      ExpansionTile(
                        title: const Text('Raw JSON'),
                        children: [
                          Text(
                            dataStr,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ) !=
              null) {
            if (!mounted) return;
            final appsProvider = context.read<AppsProvider>();
            final result = await appsProvider.import(
              action == 'app'
                  ? '{ "apps": [$dataStr] }'
                  : '{ "apps": $dataStr }',
            );

            if (!mounted) return;
            showMessage(
              tr(
                'importedX',
                args: [plural('apps', result.key.length).toLowerCase()],
              ),
              context,
            );
          }
        } else {
          throw ObtainiumError(tr('unknown'));
        }
      } catch (e) {
        if (!mounted) return;
        showError(e, context);
      }
    }

    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialLink();
    var initLinked = false;
    if (appLink != null) {
      await interpretLink(appLink);
      initLinked = true;
    }
    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      if (!initLinked) {
        await interpretLink(uri);
      } else {
        initLinked = false;
      }
    });
  }

  Future<void> _switchToPage(int index) async {
    if (index == 0) {
      while ((pages[0].widget.key as GlobalKey<AppsPageState>).currentState !=
          null) {
        // Avoid duplicate GlobalKey error
        await Future.delayed(const Duration(microseconds: 1));
      }
      setState(() {
        _selectedIndexHistory.clear();
      });
    } else if (_selectedIndexHistory.isEmpty ||
        (_selectedIndexHistory.isNotEmpty &&
            _selectedIndexHistory.last != index)) {
      setState(() {
        final existingInd = _selectedIndexHistory.indexOf(index);
        if (existingInd >= 0) {
          _selectedIndexHistory.removeAt(existingInd);
        }
        _selectedIndexHistory.add(index);
      });
    }
  }

  // TODO: migrate to use PopScope for top-level navigation history handling

  // The tricky part is that onPopInvokedWithResult gets called AFTER a pop
  // has NOT been prevented, so the logic of the previous onWillPop callback
  // becomes useless. A suggestion is to use either ModalRoute.registerPopEntry
  // or ModalRoute.addLocalHistoryEntry in this scenario. Until this gets
  // implemented, top-level navigation history is unsupported, attempting to
  // pop a top-level route pops the whole application.

  // Future<bool> _onWillPop() async {
  //   if (isLinkActivity &&
  //       selectedIndexHistory.length == 1 &&
  //       selectedIndexHistory.last == 1) {
  //     return true;
  //   }
  //   setIsReversing(
  //     selectedIndexHistory.length >= 2
  //         ? selectedIndexHistory.reversed.toList()[1]
  //         : 0,
  //   );
  //   if (selectedIndexHistory.isNotEmpty) {
  //     setState(() {
  //       selectedIndexHistory.removeLast();
  //     });
  //     return false;
  //   }
  //   return !(pages[0].widget.key as GlobalKey<AppsPageState>).currentState!
  //       .clearSelected();
  // }

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final sp = context.read<SettingsProvider>();
      if (!sp.welcomeShown) {
        await showDialog(
          context: context,
          builder: (ctx) {
            final colorTheme = ColorTheme.of(ctx);
            final elevationTheme = ElevationTheme.of(ctx);
            final shapeTheme = ShapeTheme.of(ctx);
            final stateTheme = StateTheme.of(ctx);
            final typescaleTheme = TypescaleTheme.of(ctx);
            return AlertDialog(
              title: Text(tr('welcome')),
              content: Flex.vertical(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  Text(tr('documentationLinksNote')),
                  GestureDetector(
                    onTap: () {
                      launchUrlString(
                        'https://github.com/deminearchiver/materium/blob/main/README.md',
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: const Text(
                      'https://github.com/deminearchiver/materium/blob/main/README.md',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: LegacyThemeFactory.createButtonStyle(
                    colorTheme: colorTheme,
                    elevationTheme: elevationTheme,
                    shapeTheme: shapeTheme,
                    stateTheme: stateTheme,
                    typescaleTheme: typescaleTheme,
                    size: .small,
                    shape: .round,
                    color: .text,
                  ),
                  onPressed: () {
                    sp.welcomeShown = true;
                    Navigator.of(context).pop(null);
                  },
                  child: Text(tr('ok')),
                ),
              ],
            );
          },
        );
      }
      if (!sp.googleVerificationWarningShown &&
          DateTime.now().year >=
              2026 /* Gives some time to translators between now and Jan */ ) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) {
            final colorTheme = ColorTheme.of(ctx);
            final elevationTheme = ElevationTheme.of(ctx);
            final shapeTheme = ShapeTheme.of(ctx);
            final stateTheme = StateTheme.of(ctx);
            final typescaleTheme = TypescaleTheme.of(ctx);
            return AlertDialog(
              title: Text(tr('note')),
              scrollable: true,
              content: Flex.vertical(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  Text(tr('googleVerificationWarningP1')),
                  GestureDetector(
                    onTap: () {
                      launchUrlString(
                        'https://keepandroidopen.org/',
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Text(
                      tr('googleVerificationWarningP2'),
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(tr('googleVerificationWarningP3')),
                ],
              ),
              actions: [
                TextButton(
                  style: LegacyThemeFactory.createButtonStyle(
                    colorTheme: colorTheme,
                    elevationTheme: elevationTheme,
                    shapeTheme: shapeTheme,
                    stateTheme: stateTheme,
                    typescaleTheme: typescaleTheme,
                    size: .small,
                    shape: .round,
                    color: .text,
                  ),
                  onPressed: () {
                    sp.googleVerificationWarningShown = true;
                    Navigator.of(context).pop(null);
                  },
                  child: Text(tr('ok')),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsService>();
    final appsProvider = context.watch<AppsProvider>();

    final isRedesignEnabled = context.select<SettingsService, bool>(
      (settings) => settings.developerMode.value,
    );

    if (!_prevIsLoading &&
        _prevAppCount >= 0 &&
        appsProvider.apps.length > _prevAppCount &&
        _selectedIndexHistory.isNotEmpty &&
        _selectedIndexHistory.last == 1 &&
        !_isLinkActivity) {
      _switchToPage(0);
    }

    final colorTheme = ColorTheme.of(context);

    _prevAppCount = appsProvider.apps.length;
    _prevIsLoading = appsProvider.loadingApps;

    final selectedIndex = _selectedIndexHistory.isEmpty
        ? 0
        : _selectedIndexHistory.last;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        backgroundColor: colorTheme.surfaceContainer,
        body: pages
            .elementAt(
              _selectedIndexHistory.isEmpty ? 0 : _selectedIndexHistory.last,
            )
            .widget,
        bottomNavigationBar: NavigationBar(
          backgroundColor: isRedesignEnabled
              ? colorTheme.surfaceContainer
              : colorTheme.surfaceContainerHigh,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            _switchToPage(index);
          },
          selectedIndex: selectedIndex,
          destinations: pages.map((e) => e.destination).toList(),
        ),
      ),
    );
  }
}
