
# Roadmap

This section contains the list of projects that are planned to be implemented.

## Global changes

Changes affecting the project as a whole.

- [ ] Rebrand the project from Obtainium to Materium
  - [x] Rename GitHub repository
  - [x] Change internal package names
    - [x] `obtainium` -> `materium`
    - [x] `obtainium_fonts` -> `materium_fonts`
    - [x] `obtainium_i18n` -> `materium_i18n`
    - [x] `obtainium_tools` -> `materium_tools`
    - [x] Regenerate `flutter_gen` assets
  - [x] Change the name in Visual Studio Code launch configuration ([`.vscode/launch.json`](.vscode/launch.json))
  - [x] Rename platform-specific parts of the project
    - [x] [`android`](android)
  - [x] Change the name in [`README.md`](README.md)
  - [ ] Change the name in issue templates ([`.github/ISSUE_TEMPLATE`](.github/ISSUE_TEMPLATE))
  - [ ] Automatically change the name in translation files ([`assets/translations/*.json`](assets/translations)) to apply changes across the app
  - [x] Create new brand assets
    - [x] Change app icon

## User-facing changes

- [ ] Migrate to a new localization file structure
  - [ ] Develop a new localization file structure to use with [`slang`](https://pub.dev/packages/slang)
  - [ ] Create a Dart script which remaps [`easy_localization`](https://pub.dev/packages/easy_localization) files to the new localization structure (to preserve some of the existing translations)
  - [ ] Intermediate steps (TBA)
  - [ ] Start accepting localization contributions

## New features

- [ ] Add the ability to require biometric authentication upon opening the app via the [`local_auth`](https://pub.dev/packages/local_auth) package
- [ ] Cookie Manager - a way for users to obtain and store cookies for any website. The cookies will be used globally across the app for all web requests

## Material 3 Expressive

Many Material widgets used still come from Flutter's Material library. The long-standing goal of this project is to get rid of the dependency on Flutter's Material library. It is considered "legacy" in the scope of this repository (it's not actually deprecated).

Here's a list of widgets that are planned to have a custom implementation:

- [x] Switch (`Switch`)
  - [x] Support default style
  - [x] Support theming
- [x] Checkbox (`Checkbox`)
  - [x] Support default style
  - [x] Support theming
- [x] Radio button (`RadioButton`)
  - [x] Support default style
  - [x] Support theming
- [ ] Common buttons (`Button` and `ToggleButton`)
  - [x] Placeholder implementation with legacy theming
  - [ ] Support default style
  - [ ] Support theming
- [ ] Icon buttons (`IconButton` and `IconToggleButton`)
  - [x] Placeholder implementation with legacy theming
  - [ ] Support default style
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
- [x] Loading indicator (`LoadingIndicator`)
  - [x] Port `androidx.graphics.shapes` and `androidx.compose.material3.MaterialShapes` libraries
  - [x] Use a placeholder implementation
  - [x] Create a complete implementation
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

## Internal changes

These changes are expected to not affect the user experience. They include various architecural and structural changes to the project.

Here's a tree-like checklist of the changes expected to be implemented in the near future:

- [ ] Migrate from [`easy_localization`](https://pub.dev/packages/easy_localization) to [`slang`](https://pub.dev/packages/slang) localization solution
  - [x] Set up [`slang`](https://pub.dev/packages/slang)
  - [ ] Create a Dart script which migrates [`easy_localization`](https://pub.dev/packages/easy_localization) to [`slang`](https://pub.dev/packages/slang) localization files
  - [ ] Add tests for the migrated localizations
  - [ ] Migrate application code to use [`slang`](https://pub.dev/packages/slang) generated localizations
  - [ ] Completely remove the [`easy_localization`](https://pub.dev/packages/easy_localization) dependency
  - [ ] Clean up [`assets/translations`](./assets/translations) directory
- [ ] Migrate from [`http`](https://pub.dev/packages/http) to [`dio`](https://pub.dev/packages/dio) package

## Organization

The following list contains changes regarding the project's repository:

- [ ] Modernize issue temlates
- [ ] Create pull request templates
- [ ] Set up discussions
- [ ] Start accepting open-source contributions
- [x] ~~Consider choosing a different name for the app to further deviate from the original project~~
- [ ] Set up [**Renovate CLI**](https://github.com/renovatebot/renovate)
  - [ ] Install [**Renovate**](https://github.com/apps/renovate) GitHub app in this repository
- [ ] Start providing build APKs via CI
  - [ ] Set up GitHub actions
  - [ ] Set up a Telegram channel to act as the CI feed

## Miscellaneous

Features not directly related to the project or not urgently needed.

- [ ] Create a website for the app
  - [ ] Change website link in [`README.md`](README.md)
  - [ ] Change website link throughout the GitHub repository
  - [ ] Change website link inside of the app
