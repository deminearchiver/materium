import 'dart:io';

import 'package:materium/flutter.dart';
import 'package:android_package_installer/android_package_installer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/providers/logs_provider.dart';
import 'package:materium/providers/source_provider.dart';

class ObtainiumError {
  ObtainiumError(this.message, {this.unexpected = false});

  String message;
  bool unexpected;

  @override
  String toString() => message;
}

class RateLimitError extends ObtainiumError {
  RateLimitError(this.remainingMinutes)
    : super(plural("tooManyRequestsTryAgainInMinutes", remainingMinutes));

  int remainingMinutes;
}

class InvalidURLError extends ObtainiumError {
  InvalidURLError(String sourceName)
    : super(tr("invalidURLForSource", args: [sourceName]));
}

class CredsNeededError extends ObtainiumError {
  CredsNeededError(String sourceName)
    : super(tr("requiresCredentialsInSettings", args: [sourceName]));
}

class NoReleasesError extends ObtainiumError {
  NoReleasesError({String? note})
    : super(
        "${tr("noReleaseFound")}${note?.isNotEmpty == true ? "\n\n$note" : ""}",
      );
}

class NoAPKError extends ObtainiumError {
  NoAPKError() : super(tr("noAPKFound"));
}

class NoVersionError extends ObtainiumError {
  NoVersionError() : super(tr("noVersionFound"));
}

class UnsupportedURLError extends ObtainiumError {
  UnsupportedURLError() : super(tr("urlMatchesNoSource"));
}

class DowngradeError extends ObtainiumError {
  DowngradeError(int currentVersionCode, int newVersionCode)
    : super(
        "${tr("cantInstallOlderVersion")} (versionCode $currentVersionCode ➔ $newVersionCode)",
      );
}

class InstallError extends ObtainiumError {
  InstallError(int code)
    : super(PackageInstallerStatus.byCode(code).name.substring(7));
}

class IDChangedError extends ObtainiumError {
  IDChangedError(String newId) : super("${tr("appIdMismatch")} - $newId");
}

class NotImplementedError extends ObtainiumError {
  NotImplementedError() : super(tr("functionNotImplemented"));
}

class MultiAppMultiError extends ObtainiumError {
  MultiAppMultiError() : super(tr("placeholder"), unexpected: true);

  Map<String, Object?> rawErrors = {};
  Map<String, List<String>> idsByErrorString = {};
  Map<String, String> appIdNames = {};

  void add(String appId, Object? error, {String? appName}) {
    if (error is SocketException) {
      error = error.message;
    }
    rawErrors[appId] = error;
    final string = error.toString();
    // TODO: these braces can be safely removed
    final tempIds = (idsByErrorString.remove(string) ?? <String>[])..add(appId);
    idsByErrorString.putIfAbsent(string, () => tempIds);
    if (appName != null) {
      appIdNames[appId] = appName;
    }
  }

  String errorString(String appId, {bool includeIdsWithNames = false}) =>
      "${appIdNames.containsKey(appId) ? "${appIdNames[appId]}${includeIdsWithNames ? " ($appId)" : ""}" : appId}: ${rawErrors[appId].toString()}";

  String errorsAppsString(
    String errString,
    List<String> appIds, {
    bool includeIdsWithNames = false,
  }) =>
      "$errString [${list2FriendlyString(appIds.map((id) => appIdNames.containsKey(id) == true ? "${appIdNames[id]}${includeIdsWithNames ? " ($id)" : ""}" : id).toList())}]";

  @override
  String toString() => idsByErrorString.entries
      .map((e) => errorsAppsString(e.key, e.value))
      .join("\n\n");
}

void showMessage(Object? e, BuildContext context, {bool isError = false}) {
  LogsProvider.instance.add(
    e.toString(),
    level: isError ? LogLevels.error : LogLevels.info,
  );
  if (e is String || (e is ObtainiumError && !e.unexpected)) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
  } else {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          scrollable: true,
          title: Text(
            e is MultiAppMultiError
                ? tr(isError ? "someErrors" : "updates")
                : tr(isError ? "unexpectedError" : "unknown"),
          ),
          content: GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: e.toString()));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(tr("copiedToClipboard"))));
            },
            child: Text(e.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text(tr("ok")),
            ),
          ],
        );
      },
    );
  }
}

void showError(Object? e, BuildContext context) {
  showMessage(e, context, isError: true);
}

String list2FriendlyString(List<String> list) {
  final isUsingEnglish = isEnglish();
  return list.length == 2
      ? "${list[0]} ${tr("and")} ${list[1]}"
      : list
            .asMap()
            .entries
            .map(
              (e) =>
                  e.value +
                  (e.key == list.length - 1
                      ? ""
                      : e.key == list.length - 2
                      ? "${isUsingEnglish ? "," : ""} and "
                      : ", "),
            )
            .join("");
}
