///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element

class Translations with BaseTranslations<AppLocale, Translations> {
  /// Returns the current translations of the given [context].
  ///
  /// Usage:
  /// final t = Translations.of(context);
  static Translations of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, Translations>(context).translations;

  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  Translations({
    Map<String, Node>? overrides,
    PluralResolver? cardinalResolver,
    PluralResolver? ordinalResolver,
    TranslationMetadata<AppLocale, Translations>? meta,
  }) : assert(
         overrides == null,
         'Set "translation_overrides: true" in order to enable this feature.',
       ),
       $meta =
           meta ??
           TranslationMetadata(
             locale: AppLocale.en,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           );

  /// Metadata for the translations of <en>.
  @override
  final TranslationMetadata<AppLocale, Translations> $meta;

  late final Translations _root = this; // ignore: unused_field

  Translations $copyWith({
    TranslationMetadata<AppLocale, Translations>? meta,
  }) => Translations(meta: meta ?? this.$meta);

  // Translations

  /// en: 'Obtainum'
  String get obtainium => 'Obtainum';

  /// en: 'Materium'
  String get materium => 'Materium';

  late final Translations$licensesPage$en licensesPage =
      Translations$licensesPage$en.internal(_root);
  late final Translations$settingsPage$en settingsPage =
      Translations$settingsPage$en.internal(_root);
}

// Path: licensesPage
class Translations$licensesPage$en {
  Translations$licensesPage$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Open-source licenses'
  String get title => 'Open-source licenses';

  /// en: '(zero) {No licenses} (one) {$n license} (other) {$n licenses}'
  String licenseCount({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        zero: 'No licenses',
        one: '${n} license',
        other: '${n} licenses',
      );
}

// Path: settingsPage
class Translations$settingsPage$en {
  Translations$settingsPage$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$settingsPage$sections$en sections =
      Translations$settingsPage$sections$en.internal(_root);
  late final Translations$settingsPage$items$en items =
      Translations$settingsPage$items$en.internal(_root);
}

// Path: settingsPage.sections
class Translations$settingsPage$sections$en {
  Translations$settingsPage$sections$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$settingsPage$sections$other$en other =
      Translations$settingsPage$sections$other$en.internal(_root);
  late final Translations$settingsPage$sections$troubleshooting$en
  troubleshooting =
      Translations$settingsPage$sections$troubleshooting$en.internal(_root);
}

// Path: settingsPage.items
class Translations$settingsPage$items$en {
  Translations$settingsPage$items$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final Translations$settingsPage$items$licenses$en licenses =
      Translations$settingsPage$items$licenses$en.internal(_root);
  late final Translations$settingsPage$items$about$en about =
      Translations$settingsPage$items$about$en.internal(_root);
  late final Translations$settingsPage$items$help$en help =
      Translations$settingsPage$items$help$en.internal(_root);
  late final Translations$settingsPage$items$developerMode$en developerMode =
      Translations$settingsPage$items$developerMode$en.internal(_root);
}

// Path: settingsPage.sections.other
class Translations$settingsPage$sections$other$en {
  Translations$settingsPage$sections$other$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Other'
  String get label => 'Other';
}

// Path: settingsPage.sections.troubleshooting
class Translations$settingsPage$sections$troubleshooting$en {
  Translations$settingsPage$sections$troubleshooting$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Troubleshooting'
  String get label => 'Troubleshooting';
}

// Path: settingsPage.items.licenses
class Translations$settingsPage$items$licenses$en {
  Translations$settingsPage$items$licenses$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Open-source licenses'
  String get labelText => 'Open-source licenses';

  /// en: 'View licenses of open-source software'
  String get supportingText => 'View licenses of open-source software';
}

// Path: settingsPage.items.about
class Translations$settingsPage$items$about$en {
  Translations$settingsPage$items$about$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'About Materium'
  String get label => 'About Materium';

  /// en: 'Information, socials and contributors'
  String get description => 'Information, socials and contributors';
}

// Path: settingsPage.items.help
class Translations$settingsPage$items$help$en {
  Translations$settingsPage$items$help$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Help & support'
  String get label => 'Help & support';

  /// en: 'Get help, report a bug or request a feature'
  String get description => 'Get help, report a bug or request a feature';
}

// Path: settingsPage.items.developerMode
class Translations$settingsPage$items$developerMode$en {
  Translations$settingsPage$items$developerMode$en.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'For developers'
  String get label => 'For developers';

  /// en: 'If you know, you know'
  String get description => 'If you know, you know';

  /// en: 'Developer must be enabled'
  String get disabledTooltip => 'Developer must be enabled';
}
