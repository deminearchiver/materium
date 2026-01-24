import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/scheduler.dart';
import 'package:materium/flutter.dart';
import 'package:materium/components/generated_form_modal.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/pages/add_app.dart';
import 'package:materium/pages/app.dart';
import 'package:materium/pages/apps.dart';
import 'package:materium/providers/apps_provider.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:materium/providers/settings_provider.dart';
import 'package:materium/providers/source_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void _goToAddApp(String data) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => AddAppPage(input: data)),
    );
  }

  void _goToExistingApp(String appId) {
    if (!mounted) return;

    final appsProvider = context.read<AppsProvider>();

    final app = appsProvider.apps[appId];
    if (app == null) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => AppPage(appId: app.app.id)),
    );
  }

  Future<void> _interpretLink(Uri uri) async {
    final action = uri.host;
    final data = uri.path.length > 1 ? uri.path.substring(1) : "";
    try {
      if (action == "add") {
        // Ensure apps are loaded
        final appsProvider = context.read<AppsProvider>();
        while (appsProvider.loadingApps) {
          await Future.delayed(const Duration(milliseconds: 10));
        }

        // See if we already have this app
        final standardizedUrl = SourceProvider()
            .getSource(data)
            .standardizeUrl(data);

        final existingApp = appsProvider.apps.values
            .where((a) => a.app.url == standardizedUrl)
            .firstOrNull;

        if (existingApp != null) {
          _goToExistingApp(existingApp.app.id);
        } else {
          _goToAddApp(data);
        }
      } else if (action == "app" || action == "apps") {
        final dataStr = Uri.decodeComponent(data);
        if (await showDialog(
              context: context,
              builder: (ctx) {
                return GeneratedFormModal(
                  title: tr(
                    "importX",
                    args: [
                      (action == "app" ? tr("app") : tr("appsString"))
                          .toLowerCase(),
                    ],
                  ),
                  items: const [],
                  additionalWidgets: [
                    ExpansionTile(
                      title: const Text("Raw JSON"),
                      children: [
                        Text(
                          dataStr,
                          style: const TextStyle(fontFamily: "monospace"),
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
            action == "app"
                ? "{ \"apps\": [$dataStr] }"
                : "{ \"apps\": $dataStr }",
          );

          if (!mounted) return;
          showMessage(
            tr(
              "importedX",
              args: [plural("apps", result.key.length).toLowerCase()],
            ),
            context,
          );
        }
      } else {
        throw ObtainiumError(tr("unknown"));
      }
    } catch (e) {
      if (!mounted) return;
      showError(e, context);
    }
  }

  Future<void> _initDeepLinks() async {
    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialLink();
    var initLinked = false;
    if (appLink != null) {
      await _interpretLink(appLink);
      initLinked = true;
    }
    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      if (!initLinked) {
        await _interpretLink(uri);
      } else {
        initLinked = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _initDeepLinks();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final settingsProvider = context.read<SettingsProvider>();

      if (!settingsProvider.welcomeShown) {
        await showDialog(
          context: context,
          builder: (context) => const _WelcomeDialog(),
        );
      }

      if (mounted &&
          !settingsProvider.googleVerificationWarningShown &&
          DateTime.now().year == 2026) {
        await showDialog(
          context: context,
          builder: (context) => const _GoogleVerificationWarningDialog(),
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
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );
    final colorTheme = ColorTheme.of(context);
    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: AppsPage(key: GlobalObjectKey(this)),
    );
  }
}

class _WelcomeDialog extends StatelessWidget {
  const _WelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return AlertDialog(
      title: Text(tr("welcome")),
      content: Flex.vertical(
        mainAxisSize: MainAxisSize.min,
        spacing: 20.0,
        children: [
          Text(tr("documentationLinksNote")),
          GestureDetector(
            onTap: () {
              launchUrlString(
                "https://github.com/deminearchiver/materium/blob/main/README.md",
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text(
              "https://github.com/deminearchiver/materium/blob/main/README.md",
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
            settingsProvider.welcomeShown = true;
            Navigator.of(context).pop(null);
          },
          child: Text(tr("ok")),
        ),
      ],
    );
  }
}

class _GoogleVerificationWarningDialog extends StatelessWidget {
  const _GoogleVerificationWarningDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return AlertDialog(
      title: Text(tr("note")),
      scrollable: true,
      content: Flex.vertical(
        mainAxisSize: .min,
        spacing: 20.0,
        children: [
          Text(tr("googleVerificationWarningP1")),
          GestureDetector(
            onTap: () {
              launchUrlString(
                "https://keepandroidopen.org/",
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text(
              tr("googleVerificationWarningP2"),
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(tr("googleVerificationWarningP3")),
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
            settingsProvider.googleVerificationWarningShown = true;
            Navigator.of(context).pop(null);
          },
          child: Text(tr("ok")),
        ),
      ],
    );
  }
}
