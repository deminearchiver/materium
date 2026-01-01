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

  late final TranslationsLicensesPageEn licensesPage =
      TranslationsLicensesPageEn.internal(_root);
  late final TranslationsSettingsPageEn settingsPage =
      TranslationsSettingsPageEn.internal(_root);
}

// Path: licensesPage
class TranslationsLicensesPageEn {
  TranslationsLicensesPageEn.internal(this._root);

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
class TranslationsSettingsPageEn {
  TranslationsSettingsPageEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final TranslationsSettingsPageSectionsEn sections =
      TranslationsSettingsPageSectionsEn.internal(_root);
  late final TranslationsSettingsPageItemsEn items =
      TranslationsSettingsPageItemsEn.internal(_root);
}

// Path: settingsPage.sections
class TranslationsSettingsPageSectionsEn {
  TranslationsSettingsPageSectionsEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final TranslationsSettingsPageSectionsOtherEn other =
      TranslationsSettingsPageSectionsOtherEn.internal(_root);
  late final TranslationsSettingsPageSectionsTroubleshootingEn troubleshooting =
      TranslationsSettingsPageSectionsTroubleshootingEn.internal(_root);
}

// Path: settingsPage.items
class TranslationsSettingsPageItemsEn {
  TranslationsSettingsPageItemsEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations
  late final TranslationsSettingsPageItemsLicensesEn licenses =
      TranslationsSettingsPageItemsLicensesEn.internal(_root);
  late final TranslationsSettingsPageItemsAboutEn about =
      TranslationsSettingsPageItemsAboutEn.internal(_root);
  late final TranslationsSettingsPageItemsHelpEn help =
      TranslationsSettingsPageItemsHelpEn.internal(_root);
  late final TranslationsSettingsPageItemsDeveloperModeEn developerMode =
      TranslationsSettingsPageItemsDeveloperModeEn.internal(_root);
}

// Path: settingsPage.sections.other
class TranslationsSettingsPageSectionsOtherEn {
  TranslationsSettingsPageSectionsOtherEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Other'
  String get label => 'Other';
}

// Path: settingsPage.sections.troubleshooting
class TranslationsSettingsPageSectionsTroubleshootingEn {
  TranslationsSettingsPageSectionsTroubleshootingEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Troubleshooting'
  String get label => 'Troubleshooting';
}

// Path: settingsPage.items.licenses
class TranslationsSettingsPageItemsLicensesEn {
  TranslationsSettingsPageItemsLicensesEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Open-source licenses'
  String get labelText => 'Open-source licenses';

  /// en: 'View licenses of open-source software'
  String get supportingText => 'View licenses of open-source software';
}

// Path: settingsPage.items.about
class TranslationsSettingsPageItemsAboutEn {
  TranslationsSettingsPageItemsAboutEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'About Materium'
  String get label => 'About Materium';

  /// en: 'Information, socials and contributors'
  String get description => 'Information, socials and contributors';
}

// Path: settingsPage.items.help
class TranslationsSettingsPageItemsHelpEn {
  TranslationsSettingsPageItemsHelpEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'Help & support'
  String get label => 'Help & support';

  /// en: 'Get help, report a bug or request a feature'
  String get description => 'Get help, report a bug or request a feature';
}

// Path: settingsPage.items.developerMode
class TranslationsSettingsPageItemsDeveloperModeEn {
  TranslationsSettingsPageItemsDeveloperModeEn.internal(this._root);

  final Translations _root; // ignore: unused_field

  // Translations

  /// en: 'For developers'
  String get label => 'For developers';

  /// en: 'If you know, you know'
  String get description => 'If you know, you know';

  /// en: 'Developer must be enabled'
  String get disabledTooltip => 'Developer must be enabled';
}
