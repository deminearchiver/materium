import 'dart:convert';

import 'package:flutter/gestures.dart';

import 'package:markdown/markdown.dart' as md;

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

// ignore: implementation_imports
import 'package:flutter_markdown_plus/src/_functions_io.dart'
    if (dart.library.js_interop) 'package:flutter_markdown_plus/src/_functions_web.dart';

import 'package:materium/flutter.dart';

abstract class CustomMarkdownWidget extends StatefulWidget {
  const CustomMarkdownWidget({
    super.key,
    required this.nodes,
    this.selectable = false,
    this.styleSheet,
    this.styleSheetTheme = .material,
    this.syntaxHighlighter,
    this.onSelectionChanged,
    this.onTapLink,
    this.onTapText,
    this.imageDirectory,
    this.blockSyntaxes,
    this.inlineSyntaxes,
    this.extensionSet,
    this.imageBuilder,
    this.checkboxBuilder,
    this.bulletBuilder,
    this.builders = const <String, MarkdownElementBuilder>{},
    this.paddingBuilders = const <String, MarkdownPaddingBuilder>{},
    this.fitContent = false,
    this.listItemCrossAxisAlignment = .baseline,
    this.softLineBreak = false,
  });

  const factory CustomMarkdownWidget.builder({
    Key? key,
    required List<md.Node> nodes,
    bool selectable,
    MarkdownStyleSheet? styleSheet,
    MarkdownStyleSheetBaseTheme? styleSheetTheme,
    SyntaxHighlighter? syntaxHighlighter,
    MarkdownOnSelectionChangedCallback? onSelectionChanged,
    MarkdownTapLinkCallback? onTapLink,
    VoidCallback? onTapText,
    String? imageDirectory,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
    MarkdownImageBuilder? imageBuilder,
    MarkdownCheckboxBuilder? checkboxBuilder,
    MarkdownBulletBuilder? bulletBuilder,
    Map<String, MarkdownElementBuilder> builders,
    Map<String, MarkdownPaddingBuilder> paddingBuilders,
    MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment,
    bool softLineBreak,
    required Widget Function(BuildContext context, List<Widget>? children)
    builder,
  }) = _MarkdownWidgetBuilder;

  /// If true, the text is selectable.
  ///
  /// Defaults to false.
  final bool selectable;

  /// The styles to use when displaying the Markdown.
  ///
  /// If null, the styles are inferred from the current [Theme].
  final MarkdownStyleSheet? styleSheet;

  /// Setting to specify base theme for MarkdownStyleSheet
  ///
  /// Default to [MarkdownStyleSheetBaseTheme.material]
  final MarkdownStyleSheetBaseTheme? styleSheetTheme;

  /// The syntax highlighter used to color text in `pre` elements.
  ///
  /// If null, the [MarkdownStyleSheet.code] style is used for `pre` elements.
  final SyntaxHighlighter? syntaxHighlighter;

  /// Called when the user taps a link.
  final MarkdownTapLinkCallback? onTapLink;

  /// Called when the user changes selection when [selectable] is set to true.
  final MarkdownOnSelectionChangedCallback? onSelectionChanged;

  /// Default tap handler used when [selectable] is set to true
  final VoidCallback? onTapText;

  /// The base directory holding images referenced by Img tags with local or network file paths.
  final String? imageDirectory;

  /// Collection of custom block syntax types to be used parsing the Markdown data.
  final List<md.BlockSyntax>? blockSyntaxes;

  /// Collection of custom inline syntax types to be used parsing the Markdown data.
  final List<md.InlineSyntax>? inlineSyntaxes;

  /// Markdown syntax extension set
  ///
  /// Defaults to [md.ExtensionSet.gitHubFlavored]
  final md.ExtensionSet? extensionSet;

  /// Call when build an image widget.
  final MarkdownImageBuilder? imageBuilder;

  /// Call when build a checkbox widget.
  final MarkdownCheckboxBuilder? checkboxBuilder;

  /// Called when building a bullet
  final MarkdownBulletBuilder? bulletBuilder;

  /// Render certain tags, usually used with [extensionSet]
  ///
  /// For example, we will add support for `sub` tag:
  ///
  /// ```dart
  /// builders: {
  ///   'sub': SubscriptBuilder(),
  /// }
  /// ```
  ///
  /// The `SubscriptBuilder` is a subclass of [MarkdownElementBuilder].
  final Map<String, MarkdownElementBuilder> builders;

  /// Add padding for different tags (use only for block elements and img)
  ///
  /// For example, we will add padding for `img` tag:
  ///
  /// ```dart
  /// paddingBuilders: {
  ///   'img': ImgPaddingBuilder(),
  /// }
  /// ```
  ///
  /// The `ImgPaddingBuilder` is a subclass of [MarkdownPaddingBuilder].
  final Map<String, MarkdownPaddingBuilder> paddingBuilders;

  /// Whether to allow the widget to fit the child content.
  final bool fitContent;

  /// Controls the cross axis alignment for the bullet and list item content
  /// in lists.
  ///
  /// Defaults to [MarkdownListItemCrossAxisAlignment.baseline], which
  /// does not allow for intrinsic height measurements.
  final MarkdownListItemCrossAxisAlignment listItemCrossAxisAlignment;

  /// The soft line break is used to identify the spaces at the end of aline of
  /// text and the leading spaces in the immediately following the line of text.
  ///
  /// Default these spaces are removed in accordance with the Markdown
  /// specification on soft line breaks when lines of text are joined.
  final bool softLineBreak;

  final List<md.Node> nodes;

  /// Subclasses should override this function to display the given children,
  /// which are the parsed representation of [data].
  @protected
  Widget build(BuildContext context, List<Widget>? children);

  @override
  State<CustomMarkdownWidget> createState() => _CustomMarkdownWidgetState();

  static List<md.Node> parseFromString({
    required String data,
    List<md.BlockSyntax>? blockSyntaxes,
    List<md.InlineSyntax>? inlineSyntaxes,
    md.ExtensionSet? extensionSet,
  }) {
    final document = md.Document(
      blockSyntaxes: blockSyntaxes,
      inlineSyntaxes: inlineSyntaxes,
      extensionSet: extensionSet ?? md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    // Parse the source Markdown data into nodes of an Abstract Syntax Tree.
    final lines = const LineSplitter().convert(data);
    return document.parseLines(lines);
  }
}

class _CustomMarkdownWidgetState extends State<CustomMarkdownWidget>
    implements MarkdownBuilderDelegate {
  List<Widget>? _children;
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

  void _parseMarkdown() {
    final fallbackStyleSheet = kFallbackStyle(context, widget.styleSheetTheme);
    final styleSheet = fallbackStyleSheet.merge(widget.styleSheet);

    _disposeRecognizers();

    // Configure a Markdown widget builder to traverse the AST nodes and
    // create a widget tree based on the elements.
    _children = MarkdownBuilder(
      delegate: this,
      selectable: widget.selectable,
      styleSheet: styleSheet,
      imageDirectory: widget.imageDirectory,
      imageBuilder: widget.imageBuilder,
      checkboxBuilder: widget.checkboxBuilder,
      bulletBuilder: widget.bulletBuilder,
      builders: widget.builders,
      paddingBuilders: widget.paddingBuilders,
      fitContent: widget.fitContent,
      listItemCrossAxisAlignment: widget.listItemCrossAxisAlignment,
      onSelectionChanged: widget.onSelectionChanged,
      onTapText: widget.onTapText,
      softLineBreak: widget.softLineBreak,
    ).build(widget.nodes);
  }

  void _disposeRecognizers() {
    if (_recognizers.isEmpty) return;
    final localRecognizers = List<GestureRecognizer>.of(_recognizers);
    _recognizers.clear();
    for (final recognizer in localRecognizers) {
      recognizer.dispose();
    }
  }

  @override
  GestureRecognizer createLink(String text, String? href, String title) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () => widget.onTapLink?.call(text, href, title);
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) {
    code = code.replaceAll(RegExp(r"\n$"), "");
    return widget.syntaxHighlighter?.format(code) ??
        TextSpan(style: styleSheet.code, text: code);
  }

  @override
  void didChangeDependencies() {
    _parseMarkdown();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CustomMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nodes != oldWidget.nodes ||
        widget.styleSheet != oldWidget.styleSheet ||
        widget.syntaxHighlighter != oldWidget.syntaxHighlighter) {
      _parseMarkdown();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _children);
}

class _MarkdownWidgetBuilder extends CustomMarkdownWidget {
  const _MarkdownWidgetBuilder({
    super.key,
    required super.nodes,
    super.selectable,
    super.styleSheet,
    super.styleSheetTheme,
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
    required this.builder,
  });

  final Widget Function(BuildContext context, List<Widget>? children) builder;

  @override
  Widget build(BuildContext context, List<Widget>? children) =>
      builder(context, children);
}
