// ignore_for_file: invalid_use_of_internal_member

import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material/material_shapes.dart';
import 'package:materium/components/custom_app_bar.dart';
import 'package:materium/components/custom_markdown.dart';
import 'package:materium/components/custom_refresh_indicator.dart';
import 'package:materium/components/overflow_eager.dart';
import 'package:materium/flutter.dart' hide Cubic;
import 'package:markdown/markdown.dart' as md;
import 'package:materium/pages/settings.dart';
import 'package:materium/providers/settings_new.dart';
import 'package:provider/provider.dart';
import 'package:screen_corners_ffi/screen_corners_ffi.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_editor/super_editor.dart';

// ignore: implementation_imports
import 'package:material/src/material_shapes/material_shapes.dart'
    show RoundedPolygonInternalExtension;
import 'package:super_keyboard/super_keyboard.dart';

import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeveloperPageBackButton extends StatelessWidget {
  const DeveloperPageBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final materialLocalization = MaterialLocalizations.of(context);

    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);

    return IconButton(
      style: LegacyThemeFactory.createIconButtonStyle(
        colorTheme: colorTheme,
        elevationTheme: elevationTheme,
        shapeTheme: shapeTheme,
        stateTheme: stateTheme,
        color: .standard,
        containerColor: useBlackTheme
            ? colorTheme.surfaceContainer
            : colorTheme.surfaceContainerHighest,
        iconColor: useBlackTheme
            ? colorTheme.primary
            : colorTheme.onSurfaceVariant,
      ),
      onPressed: () => navigator.pop(),
      icon: const Icon(Symbols.arrow_back_rounded),
      tooltip: materialLocalization.backButtonTooltip,
    );
  }
}

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final staticColors = StaticColors.of(context);

    const defaultPairing = ExtendedColorPairing.variantOnFixed;

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CustomAppBar(
              type: .small,
              expandedContainerColor: colorTheme.surfaceContainer,
              collapsedContainerColor: colorTheme.surfaceContainer,
              collapsedPadding: const .fromSTEB(
                8.0 + 40.0 + 8.0,
                0.0,
                16.0,
                0.0,
              ),
              leading: const Padding(
                padding: .fromSTEB(8.0 - 4.0, 0.0, 8.0 - 4.0, 0.0),
                child: DeveloperPageBackButton(),
              ),
              title: const Text("Developer Options"),
            ),
            ListItemTheme.merge(
              data: CustomThemeFactory.createListItemTheme(
                colorTheme: colorTheme,
                elevationTheme: elevationTheme,
                shapeTheme: shapeTheme,
                stateTheme: stateTheme,
                typescaleTheme: typescaleTheme,
                color: .settings,
              ),
              child: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Flex.vertical(
                    crossAxisAlignment: .stretch,
                    spacing: 2.0,
                    children: [
                      ListItemContainer(
                        isFirst: true,
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const DeveloperMarkdown1Page(),
                              ),
                            ),
                            child: ListItemLayout(
                              leading: CustomListItemLeading.fromExtendedColor(
                                extendedColor: staticColors.cyan,
                                pairing: defaultPairing,
                                containerShape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.slanted,
                                ),
                                child: const Icon(
                                  Symbols.markdown_rounded,
                                  fill: 1.0,
                                ),
                              ),
                              headline: const Text("Markdown Demo 1"),
                              supportingText: const Text(
                                "Uses flutter_markdown_plus",
                              ),
                              trailing: const Icon(
                                Symbols.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListItemContainer(
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const DeveloperMarkdown2Page(),
                              ),
                            ),
                            child: ListItemLayout(
                              leading: CustomListItemLeading.fromExtendedColor(
                                extendedColor: staticColors.cyan,
                                pairing: defaultPairing,
                                containerShape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.slanted,
                                ),
                                child: const Icon(
                                  Symbols.markdown_rounded,
                                  fill: 1.0,
                                ),
                              ),
                              headline: const Text("Markdown Demo 2"),
                              supportingText: const Text("Uses super_editor"),
                              trailing: const Icon(
                                Symbols.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListItemContainer(
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const _MaterialDemoView(),
                              ),
                            ),
                            child: ListItemLayout(
                              leading: CustomListItemLeading.fromExtendedColor(
                                extendedColor: staticColors.purple,
                                pairing: defaultPairing,
                                containerShape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.pill,
                                ),
                                child: const Icon(
                                  Symbols.magic_button_rounded,
                                  fill: 1.0,
                                ),
                              ),
                              headline: const Text("Material 3 Expressive"),
                              supportingText: const Text(
                                "Demo of the new design system",
                              ),
                              trailing: const Icon(
                                Symbols.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListItemContainer(
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const Settings2View(),
                              ),
                            ),
                            child: ListItemLayout(
                              leading: CustomListItemLeading.fromExtendedColor(
                                extendedColor: staticColors.pink,
                                pairing: defaultPairing,
                                containerShape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.cookie12Sided,
                                ),
                                child: const Icon(
                                  Symbols.settings_rounded,
                                  fill: 1.0,
                                ),
                              ),
                              headline: const Text("New settings experience"),
                              supportingText: const Text(
                                "Try out new design for settings",
                              ),
                              trailing: const Icon(
                                Symbols.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListItemContainer(
                        isLast: true,
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const _ExperimentsPage(),
                              ),
                            ),
                            child: ListItemLayout(
                              leading: CustomListItemLeading.fromExtendedColor(
                                extendedColor: staticColors.red,
                                pairing: defaultPairing,
                                containerShape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.cookie7Sided,
                                ),
                                child: const Icon(
                                  Symbols.experiment_rounded,
                                  fill: 1.0,
                                ),
                              ),
                              headline: const Text("Experiments"),
                              supportingText: const Text(
                                "May cause the app to crash",
                              ),
                              trailing: const Icon(
                                Symbols.keyboard_arrow_right_rounded,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.paddingOf(context).bottom),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperimentsPage extends StatefulWidget {
  const _ExperimentsPage({super.key});

  @override
  State<_ExperimentsPage> createState() => _ExperimentsPageState();
}

class _ExperimentsPageState extends State<_ExperimentsPage> {
  double _widthFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final height = MediaQuery.heightOf(context);
    final padding = MediaQuery.paddingOf(context);

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final staticColors = StaticColors.of(context);

    final showBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    const length = 25;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
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
                "Experiments",
                textAlign: !showBackButton ? .center : .start,
              ),
            ),
            SliverList.list(
              children: [
                Padding(
                  padding: .symmetric(horizontal: 24.0),
                  child: Slider(
                    value: _widthFactor,
                    onChanged: (value) => setState(() => _widthFactor = value),
                  ),
                ),
                Padding(
                  padding: .symmetric(horizontal: 8.0),
                  child: FractionallySizedBox(
                    widthFactor: _widthFactor,
                    child: ColoredBox(
                      color: colorTheme.errorContainer,
                      child: Align.center(
                        child: Material(
                          shape: CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                          color: colorTheme.primaryContainer,
                          child: Padding(
                            padding: .all(12.0 - 4.0),
                            child: Overflow(
                              direction: .horizontal,
                              overflowIndicator: OverflowItemBuilder(
                                builder: (context, layoutInfo, child) {
                                  // print(layoutInfo);
                                  return Padding(
                                    padding: .symmetric(
                                      // horizontal: 12.0 - 4.0 - 4.0,
                                    ),
                                    child: IconButton(
                                      style:
                                          LegacyThemeFactory.createIconButtonStyle(
                                            colorTheme: colorTheme,
                                            elevationTheme: elevationTheme,
                                            shapeTheme: shapeTheme,
                                            stateTheme: stateTheme,
                                            color: .standard,
                                            width: .normal,
                                            containerColor:
                                                colorTheme.primaryContainer,
                                            iconColor:
                                                colorTheme.onPrimaryContainer,
                                          ),
                                      onPressed: () async {
                                        await Fluttertoast.cancel();
                                        await Fluttertoast.showToast(
                                          msg: "Overflow button clicked!",
                                          toastLength: .LENGTH_SHORT,
                                        );
                                      },
                                      icon: const Icon(
                                        Symbols.more_vert_rounded,
                                      ),
                                      tooltip:
                                          "${layoutInfo.overflowChildCount}",
                                    ),
                                  );
                                },
                              ),
                              children: List.generate(
                                length,
                                (index) => OverflowItemBuilder(
                                  builder: (context, layoutInfo, _) {
                                    return Padding(
                                      padding: .directional(
                                        end: 12.0 - 4.0 - 4.0,
                                      ),
                                      child: IconButton(
                                        style:
                                            LegacyThemeFactory.createIconButtonStyle(
                                              colorTheme: colorTheme,
                                              elevationTheme: elevationTheme,
                                              shapeTheme: shapeTheme,
                                              stateTheme: stateTheme,
                                              color: .standard,
                                              width: .normal,
                                              containerColor:
                                                  layoutInfo.isVisible
                                                  ? colorTheme.surfaceContainer
                                                  : colorTheme.primaryContainer,
                                              iconColor: layoutInfo.isVisible
                                                  ? colorTheme.onSurface
                                                  : colorTheme
                                                        .onPrimaryContainer,
                                            ),
                                        onPressed: () async {
                                          await Fluttertoast.cancel();
                                          await Fluttertoast.showToast(
                                            msg: "Button ${index + 1} clicked!",
                                            toastLength: .LENGTH_SHORT,
                                          );
                                        },
                                        icon: const Icon(
                                          Symbols.add_rounded,
                                          fill: 1.0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
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
      ),
    );
  }
}

class DeveloperMarkdown1Page extends StatefulWidget {
  const DeveloperMarkdown1Page({super.key});

  @override
  State<DeveloperMarkdown1Page> createState() => _DeveloperMarkdown1PageState();
}

List<md.Node> _parseMarkdown(
  ({String data, md.ExtensionSet extensionSet}) message,
) => CustomMarkdownWidget.parseFromString(
  data: message.data,
  extensionSet: message.extensionSet,
);

class _DeveloperMarkdown1PageState extends State<DeveloperMarkdown1Page> {
  static final md.ExtensionSet _extensionSet = md.ExtensionSet(
    [...md.ExtensionSet.gitHubWeb.blockSyntaxes],
    [...md.ExtensionSet.gitHubWeb.inlineSyntaxes],
  );

  late ScrollController _scrollController;

  late Future<HighlighterTheme> _highlighterTheme;
  late Future<List<md.Node>> _nodes;

  void _loadHighlighterTheme(Brightness brightness) {
    final highlighterInitialized = Highlighter.initialize(["dart"]);
    final highlighterTheme = HighlighterTheme.loadForBrightness(brightness);
    _highlighterTheme = (
      highlighterInitialized,
      highlighterTheme,
    ).wait.then((value) => value.$2);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _nodes = compute(_parseMarkdown, (
      data: _custom * 50,
      extensionSet: _extensionSet,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.brightnessOf(context);
    _loadHighlighterTheme(brightness);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          CustomAppBar(
            leading: const Padding(
              padding: EdgeInsets.only(left: 8.0 - 4.0),
              child: DeveloperPageBackButton(),
            ),
            type: CustomAppBarType.largeFlexible,
            expandedContainerColor: colorTheme.surfaceContainer,
            collapsedContainerColor: colorTheme.surfaceContainer,
            collapsedPadding: const EdgeInsets.fromLTRB(
              8.0 + 40.0 + 8.0,
              0.0,
              16.0,
              8.0 + 40.0 + 8.0,
            ),
            title: Text("Markdown"),
            subtitle: Text("flutter_markdown_plus"),
            trailing: Padding(
              padding: EdgeInsets.only(right: 8.0 - 4.0),
              child: IconButton.filledTonal(
                onPressed: () => _scrollController.animateTo(
                  0.0,
                  duration: const DurationThemeData.fallback().extraLong4,
                  curve: const EasingThemeData.fallback().emphasized,
                ),
                icon: Icon(
                  Symbols.arrow_upward_rounded,
                  color: colorTheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            sliver: FutureBuilder(
              future: _nodes,
              builder: (context, nodesSnapshot) {
                final nodes = nodesSnapshot.data;
                if (nodes == null || nodes.isEmpty) {
                  return const SliverFillRemaining(
                    fillOverscroll: false,
                    hasScrollBody: false,
                    child: Flex.vertical(
                      crossAxisAlignment: .center,
                      children: [
                        Flexible.space(flex: 1.0),
                        SizedBox.square(
                          dimension: 160.0,
                          child: IndeterminateLoadingIndicator(contained: true),
                        ),
                        Flexible.space(flex: 3.0),
                      ],
                    ),
                  );
                }
                return FutureBuilder(
                  future: _highlighterTheme,
                  builder: (context, highlighterThemeSnapshot) {
                    final highlighterTheme = highlighterThemeSnapshot.data;
                    return CustomMarkdownWidget.builder(
                      nodes: nodes,
                      selectable: true,
                      checkboxBuilder: (value) => Icon(
                        value
                            ? Symbols.check_box_rounded
                            : Symbols.check_box_outline_blank_rounded,
                        fill: value ? 1.0 : 0.0,
                        color: value
                            ? colorTheme.primary
                            : colorTheme.onSurfaceVariant,
                      ),
                      extensionSet: _extensionSet,
                      syntaxHighlighter: highlighterTheme != null
                          ? _SyntaxHighlighter(
                              language: "dart",
                              theme: highlighterTheme,
                              style: typescaleTheme.bodyMedium
                                  .toTextStyle()
                                  .copyWith(
                                    fontFamily: FontFamily.firaCode,
                                    fontWeight: FontWeight.w400,
                                    fontVariations: const [
                                      FontVariation.weight(400.0),
                                    ],
                                  ),
                            )
                          : null,
                      onTapLink: (text, href, title) async {
                        if (href == null) return;
                        final url = Uri.tryParse(href);
                        if (url == null) return;
                        await launchUrl(url);
                      },
                      styleSheet: MarkdownStyleSheet(
                        p: typescaleTheme.bodyMedium.toTextStyle(
                          color: colorTheme.onSurface,
                        ),
                        a: TextStyle(
                          color: colorTheme.tertiary,
                          decoration: TextDecoration.underline,
                          decorationColor: colorTheme.tertiary,
                          decorationStyle: TextDecorationStyle.dotted,
                        ),
                        h1: typescaleTheme.displayMediumEmphasized
                            .toTextStyle(),
                        h1Padding: EdgeInsets.zero,
                        h2: typescaleTheme.displaySmallEmphasized.toTextStyle(),
                        h2Padding: EdgeInsets.zero,
                        h3: typescaleTheme.headlineSmallEmphasized
                            .toTextStyle(),
                        h3Padding: EdgeInsets.zero,
                        code: const TextStyle(
                          inherit: true,
                          fontFamily: FontFamily.firaCode,
                          fontWeight: FontWeight.w500,
                          fontVariations: [FontVariation.weight(500.0)],
                        ),
                        codeblockDecoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(16.0),
                            side: BorderSide(color: colorTheme.outlineVariant),
                          ),
                          color: colorTheme.surfaceContainerLow,
                        ),
                        codeblockPadding: const EdgeInsets.all(16.0),
                      ),
                      builder: (context, children) => SliverList.list(
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        children: children ?? const [],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SyntaxHighlighter implements SyntaxHighlighter {
  _SyntaxHighlighter({required this.language, required this.theme, this.style})
    : _highlighter = Highlighter(language: language, theme: theme);

  final String language;
  final HighlighterTheme theme;
  final TextStyle? style;

  final Highlighter _highlighter;

  @override
  TextSpan format(String source) {
    final result = _highlighter.highlight(source);
    if (style == null) return result;
    return TextSpan(style: style, children: [result]);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is _SyntaxHighlighter &&
            language == other.language &&
            theme == other.theme &&
            style == other.style;
  }

  @override
  int get hashCode => Object.hash(runtimeType, language, theme, style);
}

class DeveloperMarkdown2Page extends StatefulWidget {
  const DeveloperMarkdown2Page({super.key});

  @override
  State<DeveloperMarkdown2Page> createState() => _DeveloperMarkdown2PageState();
}

class _DeveloperMarkdown2PageState extends State<DeveloperMarkdown2Page> {
  late Editor _editor;

  @override
  void initState() {
    super.initState();
    _editor = createDefaultDocumentEditor(
      document: deserializeMarkdownToDocument(_custom),
      composer: MutableDocumentComposer(),
    );
  }

  @override
  void dispose() {
    _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            leading: const Padding(
              padding: EdgeInsets.only(left: 8.0 - 4.0),
              child: DeveloperPageBackButton(),
            ),
            type: CustomAppBarType.largeFlexible,
            expandedContainerColor: colorTheme.surfaceContainer,
            collapsedContainerColor: colorTheme.surfaceContainer,
            collapsedPadding: const EdgeInsets.fromLTRB(
              8.0 + 40.0 + 8.0,
              0.0,
              16.0,
              0.0,
            ),
            title: Text("Markdown"),
            subtitle: Text("super_editor"),
          ),
          SuperReader(
            editor: _editor,
            androidHandleColor: colorTheme.primary,
            selectionStyle: SelectionStyles(
              selectionColor: colorTheme.primary.withValues(alpha: 0.3),
            ),
            componentBuilders: [
              const BlockquoteComponentBuilder(),
              const ParagraphComponentBuilder(),
              const ListItemComponentBuilder(),
              const ImageComponentBuilder(),
              const HorizontalRuleComponentBuilder(),
              const ReadOnlyCheckboxComponentBuilder(),
              const MarkdownTableComponentBuilder(),
            ],
            stylesheet: readOnlyDefaultStylesheet.copyWith(
              addRulesAfter: [
                StyleRule(BlockSelector.all, (doc, docNode) {
                  return {
                    Styles.maxWidth: 760.0,
                    Styles.padding: const CascadingPadding.symmetric(
                      horizontal: 16.0,
                    ),
                    Styles.textStyle: typescaleTheme.bodyMedium.toTextStyle(
                      color: colorTheme.onSurface,
                    ),
                  };
                }),
                StyleRule(const BlockSelector("header1"), (doc, docNode) {
                  return {
                    Styles.padding: const CascadingPadding.only(top: 40),
                    Styles.textStyle: typescaleTheme.displayMediumEmphasized
                        .toTextStyle(),
                  };
                }),
                StyleRule(const BlockSelector("header2"), (doc, docNode) {
                  return {
                    Styles.padding: const CascadingPadding.only(top: 80),
                    Styles.textStyle: typescaleTheme.displaySmallEmphasized
                        .toTextStyle(),
                  };
                }),
                StyleRule(const BlockSelector("header3"), (doc, docNode) {
                  return {
                    Styles.padding: const CascadingPadding.only(
                      top: 56.0,
                      bottom: 16.0,
                    ),
                    Styles.textStyle: typescaleTheme.headlineSmallEmphasized
                        .toTextStyle(),
                  };
                }),
                StyleRule(const BlockSelector("paragraph"), (doc, docNode) {
                  return {
                    Styles.padding: CascadingPadding.only(
                      top: typescaleTheme.bodyMedium.size,
                      bottom: typescaleTheme.bodyMedium.size,
                    ),
                  };
                }),
                StyleRule(const BlockSelector("paragraph").after("header2"), (
                  doc,
                  docNode,
                ) {
                  return {Styles.padding: CascadingPadding.only(top: 24.0)};
                }),
                StyleRule(const BlockSelector("code"), (doc, docNode) {
                  return {
                    Styles.borderRadius: BorderRadius.circular(28),
                    Styles.textStyle: typescaleTheme.bodyMedium
                        .toTextStyle()
                        .copyWith(
                          color: colorTheme.onSurface,
                          fontFamily: FontFamily.firaCode,
                        ),
                  };
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SliverMarkdown extends MarkdownWidget {
  /// Creates a scrolling widget that parses and displays Markdown.
  const SliverMarkdown({
    super.key,
    required super.data,
    super.selectable,
    super.styleSheet,
    super.styleSheetTheme = null,
    super.syntaxHighlighter,
    super.onSelectionChanged,
    super.onTapLink,
    super.onTapText,
    super.imageDirectory,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.extensionSet,
    super.imageBuilder,
    super.checkboxBuilder,
    super.bulletBuilder,
    super.builders,
    super.paddingBuilders,
    super.listItemCrossAxisAlignment,
    super.softLineBreak,
  });

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    return SliverList.list(children: children ?? const []);
  }
}

const String _custom = r"""
- [ ] A
- [ ] B
- [x] C
- [ ] D
- [ ] E

# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

The app uses Markdown to display certain rich text messages, namely changelogs for tracked apps.

While not a part of the Material Design spec, a refresh of the default Markdown styles is urgently needed.

The priority of this change is low, because Markdown is rarely encountered throughout the app normally.

No significant changes were made to Markdown stylesheets yet, because the update is at the design stage.

## Roadmap

This section contains the list of projects that are planned to be implemented.

### User-facing changes

- [ ] Migrate to a new localization file structure
  - [ ] Develop a new localization file structure to use with [`slang`](https://pub.dev/packages/slang)
  - [ ] Create a Dart script which remaps [`easy_localization`](https://pub.dev/packages/easy_localization) files to the new localization structure (to preserve some of the existing translations)
  - [ ] Intermediate steps (TBA)
  - [ ] Start accepting localization contributions

### New features

- [ ] Add the ability to require biometric authentication upon opening the app via the [`local_auth`](https://pub.dev/packages/local_auth) package
- [ ] Cookie Manager - a way for users to obtain and store cookies for any website. The cookies will be used globally across the app for all web requests

### Material 3 Expressive

Many Material widgets used still come from Flutter's Material library. The long-standing goal of this project is to get rid of the dependency on Flutter's Material library. It is considered "legacy" in the scope of this repository (it's not actually deprecated).

Here's a list of widgets that are planned to have a custom implementation:
- [ ] Switch (`Switch`)
  - [x] Support default style
  - [ ] Support theming
- [ ] Checkbox (`Checkbox`)
  - [x] Support default style
  - [ ] Support theming
- [ ] Radio button (`RadioButton`)
  - [x] Support default style
  - [ ] Support theming
- [ ] Common buttons (`Button` and `ToggleButton`)
  - [x] Support default style
  - [ ] Support theming
- [ ] Icon buttons (`IconButton` and `IconToggleButton`)
  - [x] Support default style
  - [ ] Support theming
- [ ] Standard button group (`StandardButtonGroup`)
  - One of the most complex widgets to implement, will probably require a custom render object. In that case children will be required to support dry layout.
- [ ] Connected button group (`ConnectedButtonGroup`)
- [ ] FAB (`FloatingActionButton`)
- [ ] FAB menu (`FloatingActionButtonMenu`)
- [ ] App bar (`AppBar`)
  - [x] Implement using existing `SliverAppBar`
  - [ ] Improve title layout to account for actions
  - [ ] Fully custom implementation (must use `SliverPersistentHeader` under the hood)
- [ ] Loading indicator (`LoadingIndicator`)
  - [x] Port `androidx.graphics.shapes` and `androidx.compose.material3.MaterialShapes` libraries
  - [x] Use a placeholder implementation
  - [ ] Create a complete implementation
- [ ] Progress indicators
  - [ ] Linear progress indicator (`LinearProgressIndicator`)
    - [x] Use a placeholder implementation
    - [ ] Flat shape (`LinearProgressIndicator`)
    - [ ] Wavy shape (`LinearWavyProgressIndicator`)
    - [ ] Implement complex transition logic (`LinearProgressIndicatorController`)
  - [ ] Circular progress indicator
    - [x] Use a placeholder implementation
    - [ ] Flat shape (`CircularProgressIndicator`)
    - [ ] Wavy shape (`CircularWavyProgressIndicator`)
    - [ ] Implement complex transition logic (`CircularProgressIndicatorController`)

### Internal changes

These changes are expected to not affect the user experience. They include various architecural and structural changes to the project.

Here's a tree-like checklist of the changes expected to be implemented in the near future:

- [ ] Migrate from [`easy_localization`](https://pub.dev/packages/easy_localization) to [`slang`](https://pub.dev/packages/slang) localization solution
  - [x] Create workspace [`obtainium_i18n`](./obtainium_i18n) package
  - [x] Set up [`slang`](https://pub.dev/packages/slang) in the workspace package
  - [ ] Create a Dart script which migrates [`easy_localization`](https://pub.dev/packages/easy_localization) to [`slang`](https://pub.dev/packages/slang) localization files
  - [ ] Add tests for the migrated localizations
  - [ ] Migrate application code to use [`slang`](https://pub.dev/packages/slang) generated localizations
  - [ ] Completely remove the [`easy_localization`](https://pub.dev/packages/easy_localization) dependency
  - [ ] Clean up [`assets/translations`](./assets/translations) directory
- [ ] Migrate from [`http`](https://pub.dev/packages/http) to [`dio`](https://pub.dev/packages/dio) package

### Organization

The following list contains changes regarding the project's repository:

- [ ] Modernize issue temlates
- [ ] Create pull request templates
- [ ] Set up discussions
- [ ] Start accepting open-source contributions
- [ ] Consider choosing a different name for the app to further deviate from the original project
- [ ] Set up [**Renovate CLI**](https://github.com/renovatebot/renovate)
  - [ ] Install [**Renovate**](https://github.com/apps/renovate) GitHub app in this repository
### Miscellaneous

- [ ] Create a website for the app

| a | b | c |
| - | - | - |
| 1 | 2 | 3 |

```dart
class SliverMarkdown extends MarkdownWidget {
  /// Creates a scrolling widget that parses and displays Markdown.
  const SliverMarkdown({
    super.key,
    required super.data,
    super.selectable,
    super.styleSheet,
    super.styleSheetTheme = null,
    super.syntaxHighlighter,
    super.onSelectionChanged,
    super.onTapLink,
    super.onTapText,
    super.imageDirectory,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.extensionSet,
    super.imageBuilder,
    super.checkboxBuilder,
    super.bulletBuilder,
    super.builders,
    super.paddingBuilders,
    super.listItemCrossAxisAlignment,
    super.softLineBreak,
  });

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    return SliverList.list(children: children!);
  }
}
```
""";

const String _markdownIt = r"""---
__Advertisement :)__

- __[pica](https://nodeca.github.io/pica/demo/)__ - high quality and fast image
  resize in browser.
- __[babelfish](https://github.com/nodeca/babelfish/)__ - developer friendly
  i18n with plurals support and easy syntax.

You will like those projects!

---

# h1 Heading 8-)
## h2 Heading
### h3 Heading
#### h4 Heading
##### h5 Heading
###### h6 Heading


## Horizontal Rules

___

---

***


## Typographic replacements

Enable typographer option to see result.

(c) (C) (r) (R) (tm) (TM) (p) (P) +-

test.. test... test..... test?..... test!....

!!!!!! ???? ,,  -- ---

"Smartypants, double quotes" and 'single quotes'


## Emphasis

**This is bold text**

__This is bold text__

*This is italic text*

_This is italic text_

~~Strikethrough~~


## Blockquotes


> Blockquotes can also be nested...
>> ...by using additional greater-than signs right next to each other...
> > > ...or with spaces between arrows.


## Lists

Unordered

+ Create a list by starting a line with `+`, `-`, or `*`
+ Sub-lists are made by indenting 2 spaces:
  - Marker character change forces new list start:
    * Ac tristique libero volutpat at
    + Facilisis in pretium nisl aliquet
    - Nulla volutpat aliquam velit
+ Very easy!

Ordered

1. Lorem ipsum dolor sit amet
2. Consectetur adipiscing elit
3. Integer molestie lorem at massa


1. You can use sequential numbers...
1. ...or keep all the numbers as `1.`

Start numbering with offset:

57. foo
1. bar


## Code

Inline `code`

Indented code

    // Some comments
    line 1 of code
    line 2 of code
    line 3 of code


Block code "fences"

```
Sample text here...
```

Syntax highlighting

``` js
var foo = function (bar) {
  return bar++;
};

console.log(foo(5));
```

## Tables

| Option | Description |
| ------ | ----------- |
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |

Right aligned columns

| Option | Description |
| ------:| -----------:|
| data   | path to data files to supply the data that will be passed into templates. |
| engine | engine to be used for processing templates. Handlebars is the default. |
| ext    | extension to be used for dest files. |


## Links

[link text](http://dev.nodeca.com)

[link with title](http://nodeca.github.io/pica/demo/ "title text!")

Autoconverted link https://github.com/nodeca/pica (enable linkify to see)


## Images

![Minion](https://octodex.github.com/images/minion.png)
![Stormtroopocat](https://octodex.github.com/images/stormtroopocat.jpg "The Stormtroopocat")

Like links, Images also have a footnote style syntax

![Alt text][id]

With a reference later in the document defining the URL location:

[id]: https://octodex.github.com/images/dojocat.jpg  "The Dojocat"


## Plugins

The killer feature of `markdown-it` is very effective support of
[syntax plugins](https://www.npmjs.org/browse/keyword/markdown-it-plugin).


### [Emojies](https://github.com/markdown-it/markdown-it-emoji)

> Classic markup: :wink: :cry: :laughing: :yum:
>
> Shortcuts (emoticons): :-) :-( 8-) ;)

see [how to change output](https://github.com/markdown-it/markdown-it-emoji#change-output) with twemoji.


### [Subscript](https://github.com/markdown-it/markdown-it-sub) / [Superscript](https://github.com/markdown-it/markdown-it-sup)

- 19^th^
- H~2~O


### [\<ins>](https://github.com/markdown-it/markdown-it-ins)

++Inserted text++


### [\<mark>](https://github.com/markdown-it/markdown-it-mark)

==Marked text==


### [Footnotes](https://github.com/markdown-it/markdown-it-footnote)

Footnote 1 link[^first].

Footnote 2 link[^second].

Inline footnote^[Text of inline footnote] definition.

Duplicated footnote reference[^second].

[^first]: Footnote **can have markup**

    and multiple paragraphs.

[^second]: Footnote text.


### [Definition lists](https://github.com/markdown-it/markdown-it-deflist)

Term 1

:   Definition 1
with lazy continuation.

Term 2 with *inline markup*

:   Definition 2

        { some code, part of Definition 2 }

    Third paragraph of definition 2.

_Compact style:_

Term 1
  ~ Definition 1

Term 2
  ~ Definition 2a
  ~ Definition 2b


### [Abbreviations](https://github.com/markdown-it/markdown-it-abbr)

This is HTML abbreviation example.

It converts "HTML", but keep intact partial entries like "xxxHTMLyyy" and so on.

*[HTML]: Hyper Text Markup Language

### [Custom containers](https://github.com/markdown-it/markdown-it-container)

::: warning
*here be dragons*
:::""";

class ReadOnlyCheckboxComponentBuilder implements ComponentBuilder {
  const ReadOnlyCheckboxComponentBuilder();

  @override
  TaskComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    if (node is! TaskNode) {
      return null;
    }

    final textDirection = getParagraphDirection(node.text.toPlainText());

    return TaskComponentViewModel(
      nodeId: node.id,
      createdAt: node.metadata[NodeMetadata.createdAt],
      padding: EdgeInsets.zero,
      indent: node.indent,
      isComplete: node.isComplete,
      setComplete: null,
      text: node.text,
      textDirection: textDirection,
      textAlignment: textDirection == TextDirection.ltr
          ? TextAlign.left
          : TextAlign.right,
      textStyleBuilder: noStyleBuilder,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! TaskComponentViewModel) {
      return null;
    }
    return CheckboxComponent(
      key: componentContext.componentKey,
      viewModel: componentViewModel,
    );
  }
}

class CheckboxComponent extends StatefulWidget {
  const CheckboxComponent({
    super.key,
    required this.viewModel,
    this.showDebugPaint = false,
  });

  final TaskComponentViewModel viewModel;
  final bool showDebugPaint;

  @override
  State<CheckboxComponent> createState() => _CheckboxComponentState();
}

class _CheckboxComponentState extends State<CheckboxComponent>
    with ProxyDocumentComponent<CheckboxComponent>, ProxyTextComposable {
  final _textKey = GlobalKey();

  @override
  GlobalKey<State<StatefulWidget>> get childDocumentComponentKey => _textKey;

  @override
  TextComposable get childTextComposable =>
      childDocumentComponentKey.currentState as TextComposable;

  /// Computes the [TextStyle] for this task's inner [TextComponent].
  TextStyle _computeStyles(Set<Attribution> attributions) {
    // Show a strikethrough across the entire task if it's complete.
    final style = widget.viewModel.textStyleBuilder(attributions);
    return widget.viewModel.isComplete
        ? style.copyWith(
            decoration: style.decoration == null
                ? TextDecoration.lineThrough
                : TextDecoration.combine([
                    TextDecoration.lineThrough,
                    style.decoration!,
                  ]),
          )
        : style;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.viewModel.textDirection,
      child: Flex.horizontal(
        crossAxisAlignment: .start,
        children: [
          SizedBox(
            width: widget.viewModel.indentCalculator(
              widget.viewModel.textStyleBuilder({}),
              widget.viewModel.indent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: IgnorePointer(
              ignoring: widget.viewModel.setComplete == null,
              child: Checkbox.bistate(
                checked: widget.viewModel.isComplete,
                onCheckedChanged: (value) {
                  widget.viewModel.setComplete?.call(value);
                },
              ),
            ),
          ),
          Flexible.tight(
            child: TextComponent(
              key: _textKey,
              text: widget.viewModel.text,
              textDirection: widget.viewModel.textDirection,
              textAlign: widget.viewModel.textAlignment,
              textStyleBuilder: _computeStyles,
              inlineWidgetBuilders: widget.viewModel.inlineWidgetBuilders,
              textSelection: widget.viewModel.selection,
              selectionColor: widget.viewModel.selectionColor,
              highlightWhenEmpty: widget.viewModel.highlightWhenEmpty,
              underlines: widget.viewModel.createUnderlines(),
              showDebugPaint: widget.showDebugPaint,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsAppBar extends StatefulWidget {
  const SettingsAppBar({super.key});

  @override
  State<SettingsAppBar> createState() => _SettingsAppBarState();
}

class _SettingsAppBarState extends State<SettingsAppBar> {
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _textKey = GlobalKey();

  _SettingsAppBarRoute? _route;

  Future<void> _openView() async {
    final navigator = Navigator.of(context);
    final route = _SettingsAppBarRoute<void>(
      containerKey: _containerKey,
      textKey: _textKey,
    );
    _route = route;
    navigator.push(route);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    final height = 64.0;
    final extent = padding.top + height;

    return SliverHeader(
      minExtent: extent,
      maxExtent: extent,
      pinned: true,
      builder: (context, shrinkOffset, overlapsContent) => SizedBox(
        width: double.infinity,
        height: extent,
        child: Material(
          color: colorTheme.surfaceContainer,
          child: Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: Flex.horizontal(
              children: [
                const SizedBox(width: 8.0 - 4.0),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0.0),
                    shadowColor: WidgetStateColor.transparent,
                    minimumSize: const WidgetStatePropertyAll(Size.zero),
                    fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
                    maximumSize: const WidgetStatePropertyAll(Size.infinite),
                    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
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
                          : colorTheme.onSurface,
                    ),
                  ),
                  icon: const Icon(Symbols.arrow_back_rounded),
                ),
                const SizedBox(width: 8.0 - 4.0),
                Flexible.tight(
                  child: KeyedSubtree(
                    key: _containerKey,
                    child: SizedBox(
                      height: 56.0,
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        color: colorTheme.surfaceBright,
                        shape: CornersBorder.rounded(
                          corners: Corners.all(shapeTheme.corner.full),
                        ),
                        child: InkWell(
                          overlayColor: WidgetStateLayerColor(
                            color: WidgetStatePropertyAll(colorTheme.onSurface),
                            opacity: stateTheme.asWidgetStateLayerOpacity,
                          ),
                          onTap: _openView,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              24.0,
                              0.0,
                              24.0,
                              0.0,
                            ),
                            child: Flex.horizontal(
                              children: [
                                Flexible.tight(
                                  child: Align.center(
                                    child: Text(
                                      "Search Settings",
                                      key: _textKey,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: typescaleTheme.bodyLarge
                                          .toTextStyle(
                                            color: colorTheme.onSurfaceVariant,
                                          ),
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
                const SizedBox(width: 8.0 - 4.0),
                MenuAnchor(
                  consumeOutsideTap: true,
                  crossAxisUnconstrained: false,
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () {},
                      leadingIcon: const Icon(Symbols.reset_settings_rounded),
                      child: const Text("Reset settings"),
                    ),
                  ],
                  builder: (context, controller, child) => IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(0.0),
                      shadowColor: WidgetStateColor.transparent,
                      minimumSize: const WidgetStatePropertyAll(Size.zero),
                      fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
                      maximumSize: const WidgetStatePropertyAll(Size.infinite),
                      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
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
                    ),
                    icon: const Icon(Symbols.more_vert_rounded),
                  ),
                ),
                const SizedBox(width: 8.0 - 4.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsAppBarRoute<T extends Object?> extends PopupRoute<T> {
  _SettingsAppBarRoute({
    required this.containerKey,
    required this.textKey,
    super.directionalTraversalEdgeBehavior,
    super.filter,
    super.requestFocus,
    super.settings,
    super.traversalEdgeBehavior,
  });

  final GlobalKey containerKey;
  final GlobalKey textKey;

  final GlobalKey _viewKey = GlobalKey();
  final GlobalKey _textFieldKey = GlobalKey();

  final Tween<double> _exitOpacityTween = Tween<double>(begin: 1.0, end: 0.0);

  final Tween<double> _enterOpacityTween = Tween<double>(begin: 0.0, end: 1.0);

  CurvedAnimation _linearExitAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: const EasingThemeData.fallback().linear,
  );
  CurvedAnimation _linearEnterAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: const EasingThemeData.fallback().linear,
  );
  CurvedAnimation _curvedExitAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: const EasingThemeData.fallback().linear,
  );
  CurvedAnimation _curvedEnterAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: const EasingThemeData.fallback().linear,
  );
  CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: const EasingThemeData.fallback().linear,
  );

  final Tween<Rect?> _containerRectTween = RectTween();
  final Tween<Rect?> _textRectTween = RectTween();

  bool _sharedElementVisible = false;

  void _didChangeState({required Animation<double> linearAnimation}) {
    final easingTheme = const EasingThemeData.fallback();
    final linearExitInterval = Interval(0.0, 0.25, curve: easingTheme.linear);
    final linearEnterInterval = Interval(0.25, 0.75, curve: easingTheme.linear);
    final reverseLinearExitInterval = Interval(
      1.0 - linearEnterInterval.end,
      1.0 - linearEnterInterval.begin,
      curve: linearEnterInterval.curve,
    );
    final reverseLinearEnterInterval = Interval(
      1.0 - linearExitInterval.end,
      1.0 - linearExitInterval.begin,
      curve: linearEnterInterval.curve,
    );
    final curvedExitInterval = linearExitInterval.copyWith(
      curve: easingTheme.emphasizedAccelerate,
    );
    final curvedEnterInterval = linearEnterInterval.copyWith(
      curve: easingTheme.emphasizedDecelerate,
    );
    final reverseCurvedExitInterval = reverseLinearExitInterval.copyWith(
      curve: easingTheme.emphasizedDecelerate.flipped,
    );
    final reverseCurvedEnterInterval = reverseLinearEnterInterval.copyWith(
      curve: easingTheme.emphasizedAccelerate.flipped,
    );
    if (_linearExitAnimation.parent != linearAnimation) {
      _linearExitAnimation.dispose();
      _linearExitAnimation = CurvedAnimation(
        parent: linearAnimation,
        curve: linearExitInterval,
        reverseCurve: reverseLinearExitInterval,
      );
    }
    if (_linearEnterAnimation.parent != linearAnimation) {
      _linearEnterAnimation.dispose();
      _linearEnterAnimation = CurvedAnimation(
        parent: linearAnimation,
        curve: linearEnterInterval,
        reverseCurve: reverseLinearEnterInterval,
      );
    }
    if (_curvedExitAnimation.parent != linearAnimation) {
      _curvedExitAnimation.dispose();
      _curvedExitAnimation = CurvedAnimation(
        parent: linearAnimation,
        curve: curvedExitInterval,
        reverseCurve: reverseCurvedExitInterval,
      );
    }
    if (_curvedEnterAnimation.parent != linearAnimation) {
      _curvedEnterAnimation.dispose();
      _curvedEnterAnimation = CurvedAnimation(
        parent: linearAnimation,
        curve: curvedEnterInterval,
        reverseCurve: reverseCurvedEnterInterval,
      );
    }
    if (_curvedAnimation.parent != linearAnimation) {
      _curvedAnimation.dispose();
      final curve = easingTheme.emphasized;
      _curvedAnimation = CurvedAnimation(
        parent: linearAnimation,
        curve: curve,
        reverseCurve: curve.flipped,
      );
    }
  }

  void _animationListener() {
    assert(this.animation != null);
    final animation = this.animation!;
    final sharedElementVisible = !offstage && !animation.isDismissed;
    setState(() => _sharedElementVisible = sharedElementVisible);
  }

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => kDebugMode
      ? const DurationThemeData.fallback().extraLong4
      : const DurationThemeData.fallback().long2;

  @override
  Duration get reverseTransitionDuration => kDebugMode
      ? const DurationThemeData.fallback().extraLong4
      : const DurationThemeData.fallback().medium2;

  @override
  void install() {
    super.install();
    animation?.addListener(_animationListener);
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _curvedEnterAnimation.dispose();
    _curvedExitAnimation.dispose();
    _linearEnterAnimation.dispose();
    _linearExitAnimation.dispose();
    animation?.removeListener(_animationListener);
    super.dispose();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    _didChangeState(linearAnimation: animation);

    final screenCorners = ScreenCorners.of(context);

    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final scrimColor = Color.lerp(
      colorTheme.scrim.withAlpha(0),
      colorTheme.scrim.withValues(alpha: 0.32),
      animation.value,
    )!;

    final containerColor = Color.lerp(
      colorTheme.surfaceBright,
      colorTheme.surfaceContainerHigh,
      _curvedAnimation.value,
    )!;

    final padding = MediaQuery.paddingOf(context);

    final extent = padding.top + 72.0;
    // padding.top + lerpDouble(56.0, 72.0, _curvedAnimation.value)!;

    // Positioned.fill(
    //   child: ColoredBox(
    //     color: Color.lerp(
    //       colorTheme.surfaceContainerHigh.withValues(alpha: 0.0),
    //       colorTheme.surfaceContainerHigh,
    //       _curvedAnimation.value,
    //     )!,
    //   ),
    // ),

    final viewShape = CornersBorder.rounded(
      corners: animation.isCompleted ? Corners.none : screenCorners.toCorners(),
    );

    return AbsorbPointer(
      absorbing: !animation.isForwardOrCompleted,
      child: ColoredBox(
        color: scrimColor,
        child: LayoutBuilder(
          key: _viewKey,
          builder: (context, constraints) {
            Rect? beginContainerRect;
            final containerBox = switch (containerKey.currentContext) {
              final containerContext? when containerContext.mounted =>
                containerContext.findRenderObject() as RenderBox?,
              _ => null,
            };
            if (containerBox != null && containerBox.hasSize) {
              try {
                beginContainerRect =
                    containerBox.localToGlobal(Offset.zero) & containerBox.size;
              } on Object catch (_) {
                beginContainerRect = _containerRectTween.begin;
              }
            }

            Rect? endContainerRect;
            if (constraints.hasTightWidth && constraints.hasTightHeight) {
              try {
                endContainerRect = Offset.zero & constraints.biggest;
              } on Object catch (_) {
                endContainerRect = _containerRectTween.end;
              }
            }

            Rect? containerRect;
            if (beginContainerRect != null) {
              _containerRectTween.begin = beginContainerRect;
            }
            if (endContainerRect != null) {
              _containerRectTween.end = endContainerRect;
            }
            if (_containerRectTween.begin != null &&
                _containerRectTween.end != null) {
              containerRect = _containerRectTween.evaluate(_curvedAnimation)!;
            }
            beginContainerRect ??= _containerRectTween.begin ?? Rect.zero;
            endContainerRect ??= _containerRectTween.end ?? Rect.zero;

            // final showSharedElement =
            //     containerRect != null && !animation.isCompleted;

            containerRect ??= animation.isDismissed
                ? beginContainerRect
                : endContainerRect;

            Rect? beginTextRect;
            final textBox = switch (textKey.currentContext) {
              final textContext? when textContext.mounted =>
                textContext.findRenderObject() as RenderBox?,
              _ => null,
            };

            if (textBox != null && textBox.hasSize) {
              try {
                beginTextRect =
                    textBox.localToGlobal(Offset.zero) & textBox.size;
              } on Object catch (_) {
                beginTextRect = _textRectTween.begin;
              }
            }

            Rect? endTextRect;
            final textFieldBox = switch (_textFieldKey.currentContext) {
              final textFieldContext? when textFieldContext.mounted =>
                textFieldContext.findRenderObject() as RenderBox?,
              _ => null,
            };
            if (textFieldBox != null && textFieldBox.hasSize) {
              try {
                endTextRect =
                    textFieldBox.localToGlobal(Offset.zero) & textFieldBox.size;
              } on Object catch (_) {
                endTextRect = _textRectTween.end;
              }
            }

            Rect? textRect;
            if (beginTextRect != null) {
              _textRectTween.begin = beginTextRect;
            }
            if (endTextRect != null) {
              _textRectTween.end = endTextRect;
            }
            if (_textRectTween.begin != null && _textRectTween.end != null) {
              textRect = _textRectTween.evaluate(_curvedAnimation)!;
            }
            beginTextRect ??= _textRectTween.begin ?? Rect.zero;
            endTextRect ??= _textRectTween.end ?? Rect.zero;

            // final showSharedElement =
            //     textRect != null && !animation.isCompleted;
            final showSharedElement =
                textRect != null && !offstage && !animation.isCompleted;

            textRect ??= animation.isDismissed ? beginTextRect : endTextRect;

            final shape = ShapeBorder.lerp(
              CornersBorder.rounded(
                corners: Corners.all(
                  Corner.circular(beginContainerRect.shortestSide / 2.0),
                ),
              ),
              viewShape,
              _curvedAnimation.value,
            )!;

            final backIconButton = IconButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(0.0),
                shadowColor: WidgetStateColor.transparent,
                minimumSize: const WidgetStatePropertyAll(Size.zero),
                fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
                maximumSize: const WidgetStatePropertyAll(Size.infinite),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                iconSize: const WidgetStatePropertyAll(24.0),
                shape: WidgetStatePropertyAll(
                  CornersBorder.rounded(
                    corners: Corners.all(shapeTheme.corner.full),
                  ),
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
                      : colorTheme.onSurface,
                ),
              ),
              icon: const Icon(Symbols.arrow_back_rounded),
            );

            final clearIconButton = IconButton(
              onPressed: () {},
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(0.0),
                shadowColor: WidgetStateColor.transparent,
                minimumSize: const WidgetStatePropertyAll(Size.zero),
                fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
                maximumSize: const WidgetStatePropertyAll(Size.infinite),
                padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                iconSize: const WidgetStatePropertyAll(24.0),
                shape: WidgetStatePropertyAll(
                  CornersBorder.rounded(
                    corners: Corners.all(shapeTheme.corner.full),
                  ),
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
              ),
              icon: const Icon(Symbols.close_rounded),
            );

            return Align.topLeft(
              child: Transform.translate(
                offset: containerRect.topLeft,
                child: SizedBox(
                  width: containerRect.width,
                  height: containerRect.height,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: containerColor,
                    shape: shape,
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: containerRect.width,
                      maxWidth: containerRect.width,
                      minHeight: endContainerRect.height,
                      maxHeight: endContainerRect.height,
                      child: Transform.translate(
                        // offset: viewRect.topLeft - rect.topLeft,
                        offset: Offset(
                          0.0,
                          lerpDouble(
                            -(padding.top + (72.0 - 56.0) / 2.0),
                            0.0,
                            _curvedAnimation.value,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomScrollView(
                              slivers: [
                                SliverHeader(
                                  minExtent: extent,
                                  maxExtent: extent,
                                  pinned: true,
                                  builder:
                                      (
                                        context,
                                        shrinkOffset,
                                        overlapsContent,
                                      ) => Material(
                                        clipBehavior: Clip.antiAlias,
                                        color: containerColor,
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: extent,
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                              0.0,
                                              padding.top,
                                              0.0,
                                              0.0,
                                            ),
                                            child: KeyedSubtree(
                                              child: Flex.horizontal(
                                                children: [
                                                  const SizedBox(
                                                    width: 8.0 - 4.0,
                                                  ),
                                                  Opacity(
                                                    opacity: _enterOpacityTween
                                                        .evaluate(
                                                          _linearEnterAnimation,
                                                        ),
                                                    child: backIconButton,
                                                  ),
                                                  const SizedBox(
                                                    width: 8.0 - 4.0,
                                                  ),
                                                  Flexible.tight(
                                                    child: Visibility.maintain(
                                                      visible:
                                                          !showSharedElement,
                                                      child: TextField(
                                                        key: _textFieldKey,
                                                        autofocus: false,
                                                        style: typescaleTheme
                                                            .bodyLarge
                                                            .toTextStyle(
                                                              color: colorTheme
                                                                  .onSurface,
                                                            ),
                                                        decoration: InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText:
                                                              "Search Settings",
                                                          hintStyle: typescaleTheme
                                                              .bodyLarge
                                                              .toTextStyle(
                                                                color: colorTheme
                                                                    .onSurfaceVariant,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    width: 8.0 - 4.0,
                                                  ),
                                                  Opacity(
                                                    opacity: _enterOpacityTween
                                                        .evaluate(
                                                          _linearEnterAnimation,
                                                        ),
                                                    child: clearIconButton,
                                                  ),
                                                  const SizedBox(
                                                    width: 8.0 - 4.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8.0,
                                    0.0,
                                    8.0,
                                    16.0,
                                  ),
                                  sliver: SliverOpacity(
                                    opacity: _enterOpacityTween.evaluate(
                                      _linearEnterAnimation,
                                    ),
                                    sliver: SliverList.separated(
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 2.0),
                                      itemBuilder: (context, index) =>
                                          ListItemContainer(
                                            isFirst: index == 0,
                                            opticalCenterEnabled: false,
                                            containerColor: .all(
                                              colorTheme.surfaceContainerLow,
                                            ),
                                            child: ListItemInteraction(
                                              onTap: () => navigator?.pop(),

                                              child: ListItemLayout(
                                                leading: const Icon(
                                                  Symbols.search_rounded,
                                                ),
                                                headline: Text(
                                                  "Search suggestion ${index + 1}",
                                                ),
                                              ),
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (showSharedElement)
                              Positioned(
                                top:
                                    padding.top +
                                    (72.0 - beginTextRect.height) / 2.0,
                                left: textRect.left - containerRect.left,
                                child: Text(
                                  "Search Settings",
                                  textAlign: TextAlign.start,
                                  style: typescaleTheme.bodyLarge.toTextStyle(
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
            );
          },
        ),
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const Placeholder();
  }
}

class _SettingsAppBarView extends StatefulWidget {
  const _SettingsAppBarView({super.key});

  @override
  State<_SettingsAppBarView> createState() => _SettingsAppBarViewState();
}

class _SettingsAppBarViewState extends State<_SettingsAppBarView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_SettingsAppBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Settings2View extends StatefulWidget {
  const Settings2View({super.key});

  @override
  State<Settings2View> createState() => _Settings2ViewState();
}

class _Settings2ViewState extends State<Settings2View> {
  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final staticColors = StaticColors.of(context);

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomScrollView(
        slivers: [
          // CustomAppBar(
          //   leading: const Padding(
          //     padding: EdgeInsets.only(left: 8.0 - 4.0),
          //     child: DeveloperPageBackButton(),
          //   ),
          //   type: CustomAppBarType.largeFlexible,
          //   expandedContainerColor: colorTheme.surfaceContainer,
          //   collapsedContainerColor: colorTheme.surfaceContainer,
          //   collapsedPadding: const EdgeInsets.fromLTRB(
          //     8.0 + 40.0 + 8.0,
          //     0.0,
          //     16.0,
          //     0.0,
          //   ),
          //   title: Text("Settings"),
          // ),
          const SettingsAppBar(),
          ListItemTheme.merge(
            data: CustomThemeFactory.createListItemTheme(
              colorTheme: colorTheme,
              elevationTheme: elevationTheme,
              shapeTheme: shapeTheme,
              stateTheme: stateTheme,
              typescaleTheme: typescaleTheme,
              color: .settings,
            ),
            child: SliverList.list(
              children: [
                const SizedBox(height: 16 - 4.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListItemContainer(
                    isFirst: true,
                    child: ListItemInteraction(
                      onTap: () {},
                      child: ListItemLayout(
                        leading: SizedBox.square(
                          dimension: 40.0,
                          child: Material(
                            clipBehavior: Clip.antiAlias,
                            color: staticColors.blue.colorFixed,
                            shape: CornersBorder.rounded(
                              corners: Corners.all(shapeTheme.corner.full),
                            ),
                            child: Align.center(
                              child: Icon(
                                Symbols.tune_rounded,
                                fill: 1.0,
                                color: staticColors.blue.onColorFixedVariant,
                              ),
                            ),
                          ),
                        ),
                        headline: Text("General"),
                        supportingText: Text("Behavioral options"),
                        trailing: const Icon(
                          Symbols.keyboard_arrow_right_rounded,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListItemContainer(
                    child: ListItemInteraction(
                      onTap: () {},
                      child: ListItemLayout(
                        leading: SizedBox.square(
                          dimension: 40.0,
                          child: Material(
                            clipBehavior: Clip.antiAlias,
                            color: staticColors.yellow.colorFixed,
                            shape: CornersBorder.rounded(
                              corners: Corners.all(shapeTheme.corner.full),
                            ),
                            child: Align.center(
                              child: Icon(
                                Symbols.palette_rounded,
                                fill: 1.0,
                                color: staticColors.yellow.onColorFixedVariant,
                              ),
                            ),
                          ),
                        ),
                        headline: Text("Appearance"),
                        supportingText: Text("App theme and language"),
                        trailing: const Icon(
                          Symbols.keyboard_arrow_right_rounded,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListItemContainer(
                    isLast: true,
                    child: MergeSemantics(
                      child: ListItemInteraction(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const AboutPage(),
                          ),
                        ),
                        child: ListItemLayout(
                          leading: SizedBox.square(
                            dimension: 40.0,
                            child: Material(
                              clipBehavior: Clip.antiAlias,
                              color: staticColors.pink.colorFixed,
                              shape: const StadiumBorder(),
                              child: Align.center(
                                child: Icon(
                                  Symbols.info_rounded,
                                  fill: 1.0,
                                  color: staticColors.pink.onColorFixedVariant,
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
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.heightOf(context)),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  final Tween<double> _rotationTween = Tween<double>(
    begin: 0.0,
    end: 2.0 * math.pi,
  );
  late Animation<double> _rotationAnimation;
  final Matrix4 _rotationMatrix = Matrix4.zero();

  @override
  void initState() {
    super.initState();
    _rotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 30))
          ..addListener(() {
            _rotationMatrix
              ..setIdentity()
              ..translateByDouble(0.5, 0.5, 0.0, 1.0)
              ..rotateZ(_rotationAnimation.value)
              ..translateByDouble(-0.5, -0.5, 0.0, 1.0);
          })
          ..repeat();
    _rotationAnimation = _rotationTween.animate(_rotationController);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);
    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            leading: const Padding(
              padding: EdgeInsets.only(left: 8.0 - 4.0),
              child: DeveloperPageBackButton(),
            ),
            type: CustomAppBarType.small,
            expandedContainerColor: colorTheme.surfaceContainer,
            collapsedContainerColor: colorTheme.surfaceContainer,
            collapsedPadding: const EdgeInsets.fromLTRB(
              8.0 + 40.0 + 8.0,
              0.0,
              16.0,
              0.0,
            ),
            title: Text("About"),
          ),
          SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Flex.vertical(
                  crossAxisAlignment: .stretch,
                  children: [
                    SizedBox.square(
                      dimension: 192.0,
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Material(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedPolygonBorder(
                              polygon: MaterialShapes.cookie12Sided
                                  .transformedWithMatrix(_rotationMatrix),
                            ),
                            color: colorTheme.surface,
                            child: child!,
                          );
                        },
                        child: InkWell(
                          overlayColor: WidgetStateLayerColor(
                            color: WidgetStatePropertyAll(colorTheme.primary),
                            opacity: stateTheme.asWidgetStateLayerOpacity,
                          ),
                          onTap: () {},
                          child: Assets.icLauncher.foregroundInner.svg(),
                        ),
                      ),
                    ),
                    SelectableText(
                      "Materium",
                      textAlign: TextAlign.center,
                      style: typescaleTheme.displaySmallEmphasized
                          .toTextStyle()
                          .copyWith(
                            color: colorTheme.primary,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    SelectableText(
                      "Get Android app updates straight from the source",
                      textAlign: TextAlign.center,
                      style: typescaleTheme.bodyLarge.toTextStyle().copyWith(
                        color: colorTheme.onSurface,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // const SizedBox(height: 16.0),
                    // ListItemContainer(
                    //   isFirst: true,
                    //   child: ListItemInteraction(
                    //     child: ListItemLayout(headline: Text("Contributors")),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaterialDemoView extends StatefulWidget {
  const _MaterialDemoView({super.key});

  @override
  State<_MaterialDemoView> createState() => _MaterialDemoViewState();
}

class _MaterialDemoViewState extends State<_MaterialDemoView> {
  static const List<double> _speedValues = [
    0.1,
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  double get _speed => _speedValues[_speedIndex];
  int _speedIndex = _speedValues.indexOf(1.0);

  void _setSpeedIndex(int value) {
    final speed = _speedValues.elementAtOrNull(value);
    if (speed == null) return;
    setState(() {
      _speedIndex = value;
      timeDilation = 1.0 / speed;
    });
  }

  final _enabled = ValueNotifier<bool>(true);
  final _selected = ValueNotifier<bool>(false);
  final _progress = ValueNotifier<double>(0.0);

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    final useBlackTheme = context.select<SettingsService, bool>(
      (settings) => settings.useBlackTheme.value,
    );

    final colorTheme = ColorTheme.of(context);
    final elevationTheme = ElevationTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final staticColors = StaticColors.of(context);

    final backgroundColor = useBlackTheme
        ? colorTheme.surface
        : colorTheme.surfaceContainer;

    final ExtendedColorPairing defaultPairing = useBlackTheme
        ? .container
        : .variantOnFixed;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomRefreshIndicator(
        onRefresh: () async {
          await Fluttertoast.showToast(msg: "Pull-to-refresh demo triggered");
          await Future.delayed(const Duration(seconds: 5));
        },
        edgeOffset: padding.top + 152.0,
        displacement: 80.0,
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              CustomAppBar(
                type: .small,
                expandedContainerColor: backgroundColor,
                collapsedContainerColor: backgroundColor,
                collapsedPadding: const .fromSTEB(
                  8.0 + 40.0 + 8.0,
                  0.0,
                  16.0,
                  0.0,
                ),
                leading: const Padding(
                  padding: .fromSTEB(8.0 - 4.0, 0.0, 8.0 - 4.0, 0.0),
                  child: DeveloperPageBackButton(),
                ),
                title: const Text("Material 3 Expressive"),
              ),
              SliverPadding(
                padding: const .symmetric(horizontal: 8.0),
                sliver: ListItemTheme.merge(
                  data:
                      CustomThemeFactory.createListItemTheme(
                        colorTheme: colorTheme,
                        elevationTheme: elevationTheme,
                        shapeTheme: shapeTheme,
                        stateTheme: stateTheme,
                        typescaleTheme: typescaleTheme,
                        color: .settings,
                      ).copyWith(
                        containerColor: .all(
                          useBlackTheme
                              ? colorTheme.surface
                              : colorTheme.surfaceBright,
                        ),
                      ),
                  child: SliverList.list(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          16.0,
                          8.0,
                        ),
                        child: Text(
                          "Shape",
                          style: typescaleTheme.labelLarge.toTextStyle(
                            color: colorTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ListItemContainer(
                        isFirst: true,
                        child: ListItemInteraction(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const _ShapeLibraryView(),
                            ),
                          ),
                          onLongPress: () async {
                            await launchUrlString(
                              "https://m3.material.io/styles/shape/overview-principles#579dd4ba-39f3-4e60-bd9b-1d97ed6ef1bf",
                            );
                          },
                          child: ListItemLayout(
                            leading: CustomListItemLeading.fromExtendedColor(
                              extendedColor: staticColors.yellow,
                              pairing: defaultPairing,
                              containerShape: RoundedPolygonBorder(
                                polygon: MaterialShapes.pill,
                              ),
                              child: const Icon(
                                Symbols.interests_rounded,
                                fill: 1.0,
                              ),
                            ),
                            headline: const Text("Shape library"),
                            supportingText: const Text(
                              "Material 3 Expressive has 35 shapes.\n"
                              "Long press to view docs",
                            ),
                            trailing: const Icon(
                              Symbols.keyboard_arrow_right_rounded,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        isLast: true,
                        child: ListItemInteraction(
                          onTap: () async {
                            await Fluttertoast.showToast(
                              msg: "Not yet implemented!",
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          },
                          onLongPress: () async {
                            await launchUrlString(
                              "https://m3.material.io/styles/shape/shape-morph",
                            );
                          },
                          child: ListItemLayout(
                            leading: CustomListItemLeading.fromExtendedColor(
                              extendedColor: staticColors.yellow,
                              pairing: defaultPairing,
                              containerShape: RoundedPolygonBorder(
                                polygon: MaterialShapes.clover4Leaf,
                              ),
                              child: const Icon(
                                Symbols.draw_abstract_rounded,
                                fill: 1.0,
                              ),
                            ),
                            headline: const Text("Shape morph"),
                            supportingText: const Text(
                              "Long press to view docs",
                            ),
                            trailing: const Icon(
                              Symbols.keyboard_arrow_right_rounded,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0,
                          8.0,
                        ),
                        child: Text(
                          "Motion",
                          style: typescaleTheme.labelLarge.toTextStyle(
                            color: colorTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ListItemContainer(
                        isFirst: true,
                        isLast: true,
                        child: Flex.vertical(
                          crossAxisAlignment: .stretch,
                          children: [
                            ListItemInteraction(
                              onLongPress: timeDilation != 1.0
                                  ? () {
                                      setState(() {
                                        timeDilation = 1.0;
                                      });
                                      Fluttertoast.showToast(
                                        msg: "Animation time scale set to 1.0x",
                                      );
                                    }
                                  : null,
                              child: ListItemLayout(
                                leading:
                                    CustomListItemLeading.fromExtendedColor(
                                      extendedColor: staticColors.cyan,
                                      pairing: defaultPairing,
                                      containerShape: RoundedPolygonBorder(
                                        polygon: MaterialShapes.cookie9Sided,
                                      ),
                                      child: Icon(switch (_speed) {
                                        < 1.0 =>
                                          Symbols.timer_arrow_down_rounded,
                                        > 1.0 => Symbols.timer_arrow_up_rounded,
                                        _ => Symbols.timer_rounded,
                                      }, fill: 1.0),
                                    ),
                                headline: const Text("Animation time scale"),
                                supportingText: _speed != 1.0
                                    ? const Text("Long press to reset")
                                    : const Text(
                                        "Control the speed of animations",
                                      ),
                                trailing: Text(
                                  "${(_speed).toStringAsFixed(2)}x",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                8.0,
                                16.0,
                                16.0,
                              ),
                              child: Slider(
                                padding: EdgeInsets.zero,
                                value: _speedIndex.toDouble(),
                                min: 0.0,
                                max: (_speedValues.length - 1).toDouble(),
                                divisions: _speedValues.length - 1,
                                onChanged: (value) =>
                                    _setSpeedIndex(value.toInt()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListItemLayout(
                        alignment: .top,
                        leading: const Icon(Symbols.info_rounded, fill: 0.0),
                        supportingText: Text(
                          "Try slowing down animations and look at the loading indicators below "
                          "to see shape morphing in all its beauty.",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0,
                          8.0,
                        ),
                        child: Text(
                          "Basic input",
                          style: typescaleTheme.labelLarge.toTextStyle(
                            color: colorTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ListItemContainer(
                        isFirst: true,
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => _enabled.value = !_enabled.value,
                            child: ListItemLayout(
                              padding: const .fromLTRB(
                                16.0,
                                0.0,
                                16.0 - 8.0,
                                0.0,
                              ),
                              trailingPadding: const .symmetric(
                                vertical: (32.0 + 2 * 10.0 - 48.0) / 2.0,
                              ),
                              leading: CustomListItemLeading.fromExtendedColor(
                                extendedColor: staticColors.red,
                                pairing: defaultPairing,
                                containerShape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.cookie4Sided,
                                ),
                                child: const Icon(
                                  Symbols.ads_click_rounded,
                                  fill: 1.0,
                                ),
                              ),
                              headline: const Text("Enable basic input"),
                              trailing: ExcludeFocus(
                                child: ListenableBuilder(
                                  listenable: _enabled,
                                  builder: (context, _) => Switch(
                                    onCheckedChanged: (value) =>
                                        _enabled.value = value,
                                    checked: _enabled.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        isLast: true,
                        child: Flex.vertical(
                          crossAxisAlignment: .stretch,
                          children: [
                            ListItemLayout(
                              leading: CustomListItemLeading.fromExtendedColor(
                                extendedColor: staticColors.red,
                                pairing: defaultPairing,
                                containerShape: RoundedPolygonBorder(
                                  polygon: MaterialShapes.square,
                                ),
                                child: const Icon(
                                  Symbols.check_box_rounded,
                                  fill: 1.0,
                                ),
                              ),
                              headline: const Text("Basic input"),
                              supportingText: const Text(
                                "Switch · Checkbox · Radio button",
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                0.0,
                                16.0,
                                0.0,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 160.0,
                                ),
                                child: ListenableBuilder(
                                  listenable: Listenable.merge([
                                    _enabled,
                                    _selected,
                                  ]),
                                  builder: (context, _) => Material(
                                    shape: CornersBorder.rounded(
                                      corners: .all(shapeTheme.corner.full),
                                    ),
                                    color: colorTheme.surface,
                                    child: Flex.horizontal(
                                      spacing: 16.0,
                                      children: [
                                        Flexible.tight(
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: SizedBox(
                                              width: 72.0,
                                              height: 48.0,
                                              child: Switch(
                                                onCheckedChanged: _enabled.value
                                                    ? (value) =>
                                                          _selected.value =
                                                              value
                                                    : null,
                                                checked: _selected.value,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible.tight(
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: SizedBox(
                                              width: 72.0,
                                              height: 48.0,
                                              child: Checkbox.bistate(
                                                onCheckedChanged: _enabled.value
                                                    ? (value) =>
                                                          _selected.value =
                                                              value
                                                    : null,
                                                checked: _selected.value,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible.tight(
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: SizedBox(
                                              width: 72.0,
                                              height: 48.0,
                                              child: RadioButton(
                                                onTap: _enabled.value
                                                    ? () => _selected.value =
                                                          !_selected.value
                                                    : null,
                                                selected: _selected.value,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                0.0,
                                16.0,
                                0.0,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 160.0,
                                ),
                                child: CheckboxTheme.merge(
                                  data: CustomThemeFactory.createCheckboxTheme(
                                    colorTheme: colorTheme,
                                    shapeTheme: shapeTheme,
                                    stateTheme: stateTheme,
                                    color: .listItemPhone,
                                  ),
                                  child: RadioButtonTheme.merge(
                                    data:
                                        CustomThemeFactory.createRadioButtonTheme(
                                          colorTheme: colorTheme,
                                          shapeTheme: shapeTheme,
                                          stateTheme: stateTheme,
                                          color: .listItemPhone,
                                        ),
                                    child: SwitchTheme.merge(
                                      data:
                                          CustomThemeFactory.createSwitchTheme(
                                            colorTheme: colorTheme,
                                            shapeTheme: shapeTheme,
                                            stateTheme: stateTheme,
                                            color: .listItemPhone,
                                          ),
                                      child: ListenableBuilder(
                                        listenable: Listenable.merge([
                                          _enabled,
                                          _selected,
                                        ]),
                                        builder: (context, _) => Material(
                                          shape: CornersBorder.rounded(
                                            corners: .all(
                                              _selected.value
                                                  ? shapeTheme
                                                        .corner
                                                        .largeIncreased
                                                  : shapeTheme.corner.full,
                                            ),
                                          ),
                                          color:
                                              _selected.value && _enabled.value
                                              ? colorTheme.secondaryContainer
                                              : colorTheme.surface,
                                          child: Flex.horizontal(
                                            spacing: 16.0,
                                            children: [
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: Switch(
                                                      onCheckedChanged:
                                                          _enabled.value
                                                          ? (value) =>
                                                                _selected
                                                                        .value =
                                                                    value
                                                          : null,
                                                      checked: _selected.value,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: Checkbox.bistate(
                                                      onCheckedChanged:
                                                          _enabled.value
                                                          ? (value) =>
                                                                _selected
                                                                        .value =
                                                                    value
                                                          : null,
                                                      checked: _selected.value,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: RadioButton(
                                                      onTap: _enabled.value
                                                          ? () =>
                                                                _selected
                                                                        .value =
                                                                    !_selected
                                                                        .value
                                                          : null,
                                                      selected: _selected.value,
                                                    ),
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
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                0.0,
                                16.0,
                                0.0,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 160.0,
                                ),
                                child: CheckboxTheme.merge(
                                  data: CustomThemeFactory.createCheckboxTheme(
                                    colorTheme: colorTheme,
                                    shapeTheme: shapeTheme,
                                    stateTheme: stateTheme,
                                    color: .listItemWatch,
                                  ),
                                  child: RadioButtonTheme.merge(
                                    data:
                                        CustomThemeFactory.createRadioButtonTheme(
                                          colorTheme: colorTheme,
                                          shapeTheme: shapeTheme,
                                          stateTheme: stateTheme,
                                          color: .listItemWatch,
                                        ),
                                    child: SwitchTheme.merge(
                                      data:
                                          CustomThemeFactory.createSwitchTheme(
                                            colorTheme: colorTheme,
                                            shapeTheme: shapeTheme,
                                            stateTheme: stateTheme,
                                            color: .listItemWatch,
                                          ),
                                      child: ListenableBuilder(
                                        listenable: Listenable.merge([
                                          _enabled,
                                          _selected,
                                        ]),
                                        builder: (context, _) => Material(
                                          shape: CornersBorder.rounded(
                                            corners: .all(
                                              shapeTheme.corner.full,
                                            ),
                                          ),
                                          color:
                                              _selected.value && _enabled.value
                                              ? colorTheme.primaryContainer
                                              : colorTheme.surfaceContainer,
                                          child: Flex.horizontal(
                                            spacing: 16.0,
                                            children: [
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: Switch(
                                                      onCheckedChanged:
                                                          _enabled.value
                                                          ? (value) =>
                                                                _selected
                                                                        .value =
                                                                    value
                                                          : null,
                                                      checked: _selected.value,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: Checkbox.bistate(
                                                      onCheckedChanged:
                                                          _enabled.value
                                                          ? (value) =>
                                                                _selected
                                                                        .value =
                                                                    value
                                                          : null,
                                                      checked: _selected.value,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: RadioButton(
                                                      onTap: _enabled.value
                                                          ? () =>
                                                                _selected
                                                                        .value =
                                                                    !_selected
                                                                        .value
                                                          : null,
                                                      selected: _selected.value,
                                                    ),
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
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                0.0,
                                16.0,
                                0.0,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 160.0,
                                ),
                                child: CheckboxTheme.merge(
                                  data: CustomThemeFactory.createCheckboxTheme(
                                    colorTheme: colorTheme,
                                    shapeTheme: shapeTheme,
                                    stateTheme: stateTheme,
                                    color: .black,
                                  ),
                                  child: RadioButtonTheme.merge(
                                    data:
                                        CustomThemeFactory.createRadioButtonTheme(
                                          colorTheme: colorTheme,
                                          shapeTheme: shapeTheme,
                                          stateTheme: stateTheme,
                                          color: .black,
                                        ),
                                    child: SwitchTheme.merge(
                                      data:
                                          CustomThemeFactory.createSwitchTheme(
                                            colorTheme: colorTheme,
                                            shapeTheme: shapeTheme,
                                            stateTheme: stateTheme,
                                            size: .black,
                                            color: .black,
                                          ),
                                      child: ListenableBuilder(
                                        listenable: Listenable.merge([
                                          _enabled,
                                          _selected,
                                        ]),
                                        builder: (context, _) => Material(
                                          shape: CornersBorder.rounded(
                                            corners: .all(
                                              shapeTheme.corner.full,
                                            ),
                                          ),
                                          color:
                                              _selected.value && _enabled.value
                                              ? colorTheme.primaryContainer
                                              : colorTheme.surface,
                                          child: Flex.horizontal(
                                            spacing: 16.0,
                                            children: [
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: Switch(
                                                      onCheckedChanged:
                                                          _enabled.value
                                                          ? (value) =>
                                                                _selected
                                                                        .value =
                                                                    value
                                                          : null,
                                                      checked: _selected.value,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: Checkbox.bistate(
                                                      onCheckedChanged:
                                                          _enabled.value
                                                          ? (value) =>
                                                                _selected
                                                                        .value =
                                                                    value
                                                          : null,
                                                      checked: _selected.value,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible.tight(
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: SizedBox(
                                                    width: 72.0,
                                                    height: 48.0,
                                                    child: RadioButton(
                                                      onTap: _enabled.value
                                                          ? () =>
                                                                _selected
                                                                        .value =
                                                                    !_selected
                                                                        .value
                                                          : null,
                                                      selected: _selected.value,
                                                    ),
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
                            ),
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                0.0,
                                16.0,
                                0.0,
                              ),
                              child: SizedBox(
                                width: .infinity,
                                height: 64.0,
                                child: SpringTheme(
                                  data: const .standard(),
                                  child: SwitchTheme.merge(
                                    data: CustomThemeFactory.createSwitchTheme(
                                      colorTheme: colorTheme,
                                      shapeTheme: shapeTheme,
                                      stateTheme: stateTheme,
                                      size: .nowInAndroid,
                                      color: .nowInAndroid,
                                    ),
                                    child: ListenableBuilder(
                                      listenable: Listenable.merge([
                                        _enabled,
                                        _selected,
                                      ]),
                                      builder: (context, _) => Material(
                                        clipBehavior: .antiAlias,
                                        shape: const CornersBorder.rounded(
                                          corners: .all(.circular(24.0)),
                                        ),
                                        color: _selected.value && _enabled.value
                                            ? colorTheme.primaryContainer
                                            : colorTheme
                                                  .surfaceContainerHighest,
                                        child: InkWell(
                                          overlayColor: WidgetStateLayerColor(
                                            color: WidgetStatePropertyAll(
                                              _selected.value && _enabled.value
                                                  ? colorTheme.onPrimary
                                                  : colorTheme.onSurface,
                                            ),
                                            opacity: stateTheme
                                                .asWidgetStateLayerOpacity,
                                          ),
                                          onTap: () => _selected.value =
                                              !_selected.value,
                                          child: Padding(
                                            padding: const .fromSTEB(
                                              20.0,
                                              0.0,
                                              20.0 - 12.0,
                                              0.0,
                                            ),
                                            child: Flex.horizontal(
                                              spacing: 12.0 - 12.0,
                                              children: [
                                                Flexible.tight(
                                                  child: Text(
                                                    "Switch from \"Now in Android\"",
                                                    style: typescaleTheme
                                                        .labelLarge
                                                        .copyWith(
                                                          grad:
                                                              _enabled.value &&
                                                                  _selected
                                                                      .value
                                                              ? 100.0
                                                              : 0.0,
                                                        )
                                                        .toTextStyle(
                                                          color:
                                                              _selected.value &&
                                                                  _enabled.value
                                                              ? colorTheme
                                                                    .onPrimaryContainer
                                                              : colorTheme
                                                                    .onSurface,
                                                        ),
                                                  ),
                                                ),
                                                Switch(
                                                  onCheckedChanged:
                                                      _enabled.value
                                                      ? (value) =>
                                                            _selected.value =
                                                                value
                                                      : null,
                                                  checked: _selected.value,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0,
                          8.0,
                        ),
                        child: Text(
                          "Loading indicator",
                          style: typescaleTheme.labelLarge.toTextStyle(
                            color: colorTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ListItemContainer(
                        isFirst: true,
                        child: Flex.vertical(
                          crossAxisAlignment: .stretch,
                          children: [
                            ListItemInteraction(
                              onTap: () async {
                                await Fluttertoast.showToast(
                                  msg: "Not yet implemented!",
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              },
                              child: ListItemLayout(
                                leading:
                                    CustomListItemLeading.fromExtendedColor(
                                      extendedColor: staticColors.blue,
                                      pairing: defaultPairing,
                                      containerShape: RoundedPolygonBorder(
                                        polygon: MaterialShapes.cookie9Sided,
                                      ),
                                      child: const Icon(
                                        Symbols.progress_activity_rounded,
                                        fill: 1.0,
                                      ),
                                    ),
                                headline: const Text(
                                  "Loading indicator (indeterminate)",
                                ),
                                supportingText: const Text(
                                  "Used to display loading states",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                12.0,
                                16.0,
                                16.0,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 96.0,
                                ),
                                child: const Flex.horizontal(
                                  spacing: 16.0,
                                  children: [
                                    const Flexible.tight(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: IndeterminateLoadingIndicator(
                                          contained: false,
                                        ),
                                      ),
                                    ),
                                    const Flexible.tight(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: IndeterminateLoadingIndicator(
                                          contained: true,
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
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        child: Flex.vertical(
                          crossAxisAlignment: .stretch,
                          children: [
                            ListItemInteraction(
                              onTap: () async {
                                await Fluttertoast.showToast(
                                  msg: "Not yet implemented!",
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              },
                              child: ListItemLayout(
                                leading:
                                    CustomListItemLeading.fromExtendedColor(
                                      extendedColor: staticColors.blue,
                                      pairing: defaultPairing,
                                      containerShape: RoundedPolygonBorder(
                                        polygon: MaterialShapes.pill,
                                      ),
                                      child: const Icon(
                                        Symbols.refresh_rounded,
                                        fill: 1.0,
                                      ),
                                    ),
                                headline: const Text(
                                  "Loading indicator (determinate)",
                                ),
                                supportingText: const Text(
                                  "Typically used within a pull-to-refresh",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                12.0,
                                16.0,
                                16.0,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 96.0,
                                ),
                                child: ValueListenableBuilder(
                                  valueListenable: _progress,
                                  builder: (context, progress, _) =>
                                      Flex.horizontal(
                                        spacing: 16.0,
                                        children: [
                                          Flexible.tight(
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child:
                                                  DeterminateLoadingIndicator(
                                                    progress: progress,
                                                    contained: false,
                                                  ),
                                            ),
                                          ),
                                          Flexible.tight(
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child:
                                                  DeterminateLoadingIndicator(
                                                    progress: progress,
                                                    contained: true,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      ListItemContainer(
                        isLast: true,
                        child: Flex.vertical(
                          crossAxisAlignment: .stretch,
                          children: [
                            ListItemInteraction(
                              onTap: () async {
                                await Fluttertoast.showToast(
                                  msg: "Not yet implemented!",
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              },
                              child: ListItemLayout(
                                leading:
                                    CustomListItemLeading.fromExtendedColor(
                                      extendedColor: staticColors.blue,
                                      pairing: defaultPairing,
                                      containerShape: RoundedPolygonBorder(
                                        polygon: MaterialShapes.square,
                                      ),
                                      child: const Icon(
                                        Symbols.clock_loader_60_rounded,
                                        fill: 1.0,
                                      ),
                                    ),
                                headline: const Text("Progress"),
                                supportingText: const Text(
                                  "Determinate loading indicator progress",
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                8.0,
                                16.0,
                                16.0,
                              ),
                              child: ListenableBuilder(
                                listenable: _progress,
                                builder: (context, _) => Slider(
                                  padding: EdgeInsets.zero,
                                  value: _progress.value,
                                  onChanged: (value) => _progress.value = value,
                                  label: (_progress.value * 100.0)
                                      .toStringAsFixed(0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          12.0,
                          16.0,
                          8.0,
                        ),
                        child: Text(
                          "Android Design",
                          style: typescaleTheme.labelLarge.toTextStyle(
                            color: colorTheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ListItemContainer(
                        isFirst: true,
                        isLast: true,
                        containerShape: .all(
                          CornersBorder.rounded(
                            corners: .all(shapeTheme.corner.full),
                          ),
                        ),
                        containerColor: .all(colorTheme.primaryContainer),
                        child: MergeSemantics(
                          child: ListItemInteraction(
                            onTap: () => _selected.value = !_selected.value,
                            stateLayerColor: .all(
                              colorTheme.onPrimaryContainer,
                            ),
                            child: ListItemLayout(
                              minHeight: 72.0,
                              maxHeight: 72.0,
                              padding: const EdgeInsets.fromLTRB(
                                32.0,
                                0.0,
                                20.0 - 8.0,
                                0.0,
                              ),
                              headline: Text(
                                "Android 16 Switch",
                                style: typescaleTheme.bodyLargeEmphasized
                                    .toTextStyle(
                                      color: colorTheme.onPrimaryContainer,
                                    ),
                              ),
                              trailing: ListenableBuilder(
                                listenable: _selected,
                                builder: (context, _) => ExcludeFocus(
                                  child: Switch(
                                    onCheckedChanged: (value) =>
                                        _selected.value = value,
                                    checked: _selected.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Builder(
                      //   builder: (context) {
                      //     final startCorners = Corners.horizontal(
                      //       left: shapeTheme.corner.full,
                      //       right: shapeTheme.corner.extraSmall,
                      //     );
                      //     return Flex.horizontal(
                      //       spacing: 2.0,
                      //       children: [
                      //         SizedBox(
                      //           height: 40.0,
                      //           child: Material(
                      //             clipBehavior: .antiAlias,
                      //             shape: CornersBorder.rounded(
                      //               corners: startCorners,
                      //             ),
                      //             color: colorTheme.secondaryContainer,
                      //             child: CenterOptically(
                      //               corners: startCorners,
                      //               maxOffsets: EdgeInsets.all(double.infinity),
                      //               child: Padding(
                      //                 padding: EdgeInsets.symmetric(
                      //                   horizontal: 16.0,
                      //                   vertical: 10.0,
                      //                 ),
                      //                 child: Text(
                      //                   "Hello world!",
                      //                   style: typescaleTheme.labelLarge
                      //                       .toTextStyle(
                      //                         color:
                      //                             colorTheme.onSecondaryContainer,
                      //                       ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
            ],
          ),
        ),
      ),
    );
  }
}

extension type const _Shape._(({RoundedPolygon polygon, String name}) _) {
  const _Shape({required RoundedPolygon polygon, required String name})
    : this._((polygon: polygon, name: name));

  RoundedPolygon get polygon => _.polygon;

  String get name => _.name;
}

class _ShapeLibraryView extends StatefulWidget {
  const _ShapeLibraryView({super.key});

  @override
  State<_ShapeLibraryView> createState() => _ShapeLibraryViewState();
}

class _ShapeLibraryViewState extends State<_ShapeLibraryView> {
  static final Map<String, RoundedPolygon> _shapes = UnmodifiableMapView({
    "Circle": MaterialShapes.circle,
    "Square": MaterialShapes.square,
    "Slanted": MaterialShapes.slanted,
    "Arch": MaterialShapes.arch,
    "Fan": MaterialShapes.fan,
    "Arrow": MaterialShapes.arrow,
    "Semicircle": MaterialShapes.semiCircle,
    "Oval": MaterialShapes.oval,
    "Pill": MaterialShapes.pill,
    "Triangle": MaterialShapes.triangle,
    "Diamond": MaterialShapes.diamond,
    "Clamshell": MaterialShapes.clamShell,
    "Pentagon": MaterialShapes.pentagon,
    "Gem": MaterialShapes.gem,
    "Very sunny": MaterialShapes.verySunny,
    "Sunny": MaterialShapes.sunny,
    "4-sided cookie": MaterialShapes.cookie4Sided,
    "6-sided cookie": MaterialShapes.cookie6Sided,
    "7-sided cookie": MaterialShapes.cookie7Sided,
    "9-sided cookie": MaterialShapes.cookie9Sided,
    "12-sided cookie": MaterialShapes.cookie12Sided,
    "Ghost-ish": MaterialShapes.ghostish,
    "4-leaf clover": MaterialShapes.clover4Leaf,
    "8-leaf clover": MaterialShapes.clover8Leaf,
    "Burst": MaterialShapes.burst,
    "Soft burst": MaterialShapes.softBurst,
    "Boom": MaterialShapes.boom,
    "Soft boom": MaterialShapes.softBoom,
    "Flower": MaterialShapes.flower,
    "Puffy": MaterialShapes.puffy,
    "Puffy diamond": MaterialShapes.puffyDiamond,
    "Pixel circle": MaterialShapes.pixelCircle,
    "Pixel triangle": MaterialShapes.pixelTriangle,
    "Bun": MaterialShapes.bun,
    "Heart": MaterialShapes.heart,
  });

  static final List<MapEntry<String, RoundedPolygon>> _shapesEntries =
      UnmodifiableListView(_shapes.entries.toList());

  List<MapEntry<String, RoundedPolygon>> _filteredShapesEntries =
      _shapesEntries;

  late TextEditingController _controller;
  late FocusNode _focusNode;

  void _listener() {
    final query = _controller.text.trim().toLowerCase();
    final filteredShapesEntries = query.isNotEmpty
        ? _shapesEntries
              .where((entry) => entry.key.toLowerCase().contains(query))
              .toList()
        : _shapesEntries;

    setState(() {
      _filteredShapesEntries = filteredShapesEntries;
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredShapesEntries = _shapes.entries.toList();
    _controller = TextEditingController()..addListener(_listener);
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    final colorTheme = ColorTheme.of(context);
    final shapeTheme = ShapeTheme.of(context);
    final stateTheme = StateTheme.of(context);
    final typescaleTheme = TypescaleTheme.of(context);

    final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    final crossAxisCount = switch (windowWidthSizeClass) {
      >= WindowWidthSizeClass.expanded => 7,
      _ => 5,
    };

    final labelTextStyle = switch (windowWidthSizeClass) {
      >= WindowWidthSizeClass.expanded => typescaleTheme.labelLarge,
      >= WindowWidthSizeClass.medium => typescaleTheme.labelMedium,
      _ => typescaleTheme.labelSmall,
    }.toTextStyle(color: colorTheme.onSurface);

    final supportingTypeStyle = typescaleTheme.bodyLarge;
    final supportingTextStyle = supportingTypeStyle.toTextStyle(
      color: colorTheme.onSurfaceVariant,
    );
    final inputTextStyle = typescaleTheme.bodyLarge.toTextStyle(
      color: colorTheme.onSurface,
    );

    final searchBar = SizedBox(
      width: double.infinity,
      height: 56.0,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: CornersBorder.rounded(
          corners: Corners.all(shapeTheme.corner.full),
        ),
        color: colorTheme.surfaceBright,
        child: InkWell(
          onTap: () => _focusNode.requestFocus(),
          overlayColor: WidgetStateLayerColor(
            color: WidgetStatePropertyAll(colorTheme.onSurface),
            opacity: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return 0.0;
              }
              if (states.contains(WidgetState.focused)) {
                return 0.0;
              }
              if (states.contains(WidgetState.pressed)) {
                return stateTheme.pressedStateLayerOpacity;
              }
              if (states.contains(WidgetState.hovered)) {
                return stateTheme.hoverStateLayerOpacity;
              }
              return 0.0;
            }),
          ),
          child: Flex.horizontal(
            children: [
              const SizedBox(width: 16.0),
              Icon(Symbols.search_rounded, color: colorTheme.onSurface),
              const SizedBox(width: 12.0),
              Flexible.tight(
                child: TapRegion(
                  onTapOutside: (_) => _focusNode.unfocus(),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: inputTextStyle,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: false,
                      constraints: const BoxConstraints(
                        minHeight: 56.0,
                        maxHeight: 56.0,
                      ),
                      hintText: "Search ${_shapesEntries.length} shapes",
                      contentPadding: EdgeInsets.symmetric(
                        vertical: (56.0 - supportingTypeStyle.lineHeight) / 2.0,
                      ),
                      hintStyle: supportingTextStyle,
                    ),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  style: ButtonStyle(
                    elevation: const WidgetStatePropertyAll(0.0),
                    shadowColor: WidgetStateColor.transparent,
                    minimumSize: const WidgetStatePropertyAll(Size.zero),
                    fixedSize: const WidgetStatePropertyAll(Size(40.0, 40.0)),
                    maximumSize: const WidgetStatePropertyAll(Size.infinite),
                    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
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
                  ),
                  onPressed: () => _controller.clear(),
                  icon: const Icon(Symbols.close_rounded),
                ),
              const SizedBox(width: 4.0),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: colorTheme.surfaceContainer,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            CustomAppBar(
              leading: const Padding(
                padding: EdgeInsets.only(left: 8.0 - 4.0),
                child: DeveloperPageBackButton(),
              ),
              type: CustomAppBarType.small,
              expandedContainerColor: colorTheme.surfaceContainer,
              collapsedContainerColor: colorTheme.surfaceContainer,
              collapsedPadding: const EdgeInsets.fromLTRB(
                8.0 + 40.0 + 8.0,
                0.0,
                16.0,
                0.0,
              ),
              title: const Text("Shape library"),
            ),
            SliverHeader(
              minExtent: 4.0 + 56.0 + 16.0,
              maxExtent: 4.0 + 56.0 + 16.0,
              pinned: true,
              builder: (context, shrinkOffset, overlapsContent) => Material(
                clipBehavior: Clip.none,
                color: colorTheme.surfaceContainer,
                shape: CornersBorder.rounded(
                  corners: Corners.all(shapeTheme.corner.none),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const minWidth = 312.0;

                      assert(constraints.hasTightWidth);
                      final maxWidth = constraints.maxWidth;

                      final resolvedWidth = clampDouble(
                        maxWidth / 2.0,
                        minWidth,
                        maxWidth,
                      );

                      return Align.center(
                        child: SizedBox(width: resolvedWidth, child: searchBar),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Material(
                  clipBehavior: Clip.antiAlias,
                  shape: CornersBorder.rounded(
                    corners: Corners.all(shapeTheme.corner.full),
                  ),
                  color: colorTheme.surfaceContainerLow,
                  child: InkWell(
                    onTap: () => _controller.clear(),
                    overlayColor: WidgetStateLayerColor(
                      color: WidgetStatePropertyAll(colorTheme.error),
                      opacity: stateTheme.asWidgetStateLayerOpacity,
                    ),
                    child: AnimatedAlign(
                      duration: const DurationThemeData.fallback().medium4,
                      curve: const EasingThemeData.fallback().standard,
                      alignment: Alignment.center,
                      widthFactor: 1.0,
                      heightFactor: _filteredShapesEntries.isEmpty ? 1.0 : 0.0,
                      child: AnimatedOpacity(
                        duration: const DurationThemeData.fallback().medium4,
                        curve: const EasingThemeData.fallback().standard,
                        opacity: _filteredShapesEntries.isEmpty ? 1.0 : 0.0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            24.0,
                            24.0,
                            24.0,
                            24.0,
                          ),
                          child: Flex.vertical(
                            crossAxisAlignment: .stretch,
                            children: [
                              Align.center(
                                child: Icon(
                                  Symbols.search_off_rounded,
                                  size: 48.0,
                                  opticalSize: 48.0,
                                  color: colorTheme.error,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                "No results",
                                textAlign: TextAlign.center,
                                style: typescaleTheme.titleLargeEmphasized
                                    .toTextStyle(color: colorTheme.error),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                "Tap to clear search query",
                                textAlign: TextAlign.center,
                                style: typescaleTheme.bodySmall.toTextStyle(
                                  color: colorTheme.onSurfaceVariant,
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
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              sliver: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  end: _filteredShapesEntries.isNotEmpty ? 1.0 : 0.0,
                ),
                duration: const DurationThemeData.fallback().medium4,
                curve: const EasingThemeData.fallback().standard,
                builder: (context, value, child) => SliverOpacity(
                  opacity: value,
                  sliver: SliverTransform.scale(
                    scale: lerpDouble(0.75, 1.0, value),
                    sliver: child,
                  ),
                ),
                child: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.0 / 1.5,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                  ),
                  itemCount: _filteredShapesEntries.length,
                  itemBuilder: (context, index) {
                    final MapEntry(key: name, value: polygon) =
                        _filteredShapesEntries[index];
                    final shape = RoundedPolygonBorder(polygon: polygon);
                    return Flex.vertical(
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Material(
                            clipBehavior: Clip.antiAlias,
                            shape: shape,
                            color: colorTheme.primary,
                            child: InkWell(
                              mouseCursor: WidgetStateMouseCursor.clickable,
                              overlayColor: WidgetStateLayerColor(
                                color: WidgetStatePropertyAll(
                                  colorTheme.onPrimary,
                                ),
                                opacity: stateTheme.asWidgetStateLayerOpacity,
                              ),
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) {
                                  final size = MediaQuery.sizeOf(context);

                                  final colorTheme = ColorTheme.of(context);
                                  final typescaleTheme = TypescaleTheme.of(
                                    context,
                                  );

                                  final materialLocalizations =
                                      MaterialLocalizations.of(context);

                                  return AlertDialog(
                                    constraints: BoxConstraints(
                                      minWidth: 280.0,
                                      maxWidth: 560.0,
                                      minHeight: 240.0,
                                      maxHeight: size.height * 2 / 3,
                                    ),
                                    title: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: typescaleTheme
                                          .headlineSmallEmphasized
                                          .toTextStyle(
                                            color: colorTheme.onSurface,
                                          ),
                                    ),
                                    content: Flex.vertical(
                                      mainAxisSize: .min,
                                      crossAxisAlignment: .stretch,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1.0,
                                          child: Material(
                                            clipBehavior: Clip.antiAlias,
                                            shape: shape,
                                            color: colorTheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          final pathData = _pathFromCubics(
                                            repeatPath: false,
                                            closePath: true,
                                            cubics: polygon.cubics,
                                            rotationPivotX: 0.5,
                                            rotationPivotY: 0.5,
                                          );
                                          await SharePlus.instance.share(
                                            ShareParams(
                                              title: name,
                                              text: pathData,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          materialLocalizations
                                              .shareButtonLabel,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          materialLocalizations
                                              .closeButtonLabel,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: labelTextStyle,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: padding.bottom)),
          ],
        ),
      ),
    );
  }
}

String _pathFromCubics({
  required bool repeatPath,
  required bool closePath,
  required List<Cubic> cubics,
  required double rotationPivotX,
  required double rotationPivotY,
}) {
  final buffer = StringBuffer();

  var first = true;

  for (int i = 0; i < cubics.length; i++) {
    final it = cubics[i];

    if (first) {
      buffer.write("M${it.anchor0X} ${it.anchor0Y}");
      first = false;
    }

    buffer.write(
      "C${it.control0X} ${it.control0Y} "
      "${it.control1X} ${it.control1Y} "
      "${it.anchor1X} ${it.anchor1Y}",
    );
  }

  if (repeatPath) {
    var firstInRepeat = true;

    for (int i = 0; i < cubics.length; i++) {
      final it = cubics[i];

      if (firstInRepeat) {
        buffer.write("L${it.anchor0X} ${it.anchor0Y}");
        firstInRepeat = false;
      }

      buffer.write(
        "C${it.control0X} ${it.control0Y} "
        "${it.control1X} ${it.control1Y} "
        "${it.anchor1X} ${it.anchor1Y}",
      );
    }
  }

  if (closePath) {
    buffer.write("Z");
  }

  return buffer.toString();
}
