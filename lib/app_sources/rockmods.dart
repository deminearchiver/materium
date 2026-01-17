import 'package:easy_localization/easy_localization.dart';
import 'package:html/parser.dart';
import 'package:materium/custom_errors.dart';
import 'package:materium/providers/source_provider.dart';

class RockMods extends AppSource {
  RockMods() {
    name = "RockMods";
    hosts = ["rockmods.net"];
  }

  @override
  String sourceSpecificStandardizeURL(String url, {bool forSelection = false}) {
    final standardUrlRegEx = RegExp(
      "^https?://${getSourceRegex(hosts)}/[^/]+/[^/]+",
      caseSensitive: false,
    );
    final match = standardUrlRegEx.firstMatch(url);
    if (match == null) {
      throw InvalidURLError(name);
    }
    return match.group(0)!;
  }

  @override
  Future<APKDetails> getLatestAPKDetails(
    String standardUrl,
    Map<String, dynamic> additionalSettings,
  ) async {
    try {
      final res = await sourceRequest(standardUrl, additionalSettings);
      if (res.statusCode != 200) {
        throw getObtainiumHttpError(res);
      }
      final html = parse(res.body);

      final nameElement = html.querySelector("h1");
      final appName = nameElement?.text ?? standardUrl.split("/").last;
      final appInfoElements = nameElement?.nextElementSibling?.children;
      final appVersion = ((appInfoElements?.length ?? 0) >= 1)
          ? appInfoElements![0].text
          : null;
      final appAuthor = ((appInfoElements?.length ?? 0) >= 2)
          ? appInfoElements![1].text
          : name;
      final releaseDateString = ((appInfoElements?.length ?? 0) >= 3)
          ? appInfoElements![2].text
          : null;
      if (appVersion == null) {
        throw NoVersionError();
      }

      final slugRegex = RegExp(
        "^https?://bot.${getSourceRegex(hosts)}/[^/]+/download.php\\?slug=[^/]+",
        caseSensitive: false,
      );
      final intermediateRegex = RegExp(
        "^https?://download.${getSourceRegex(hosts)}/[^/]+\$",
        caseSensitive: false,
      );

      final slugs = html
          .querySelectorAll("a")
          .where((e) => slugRegex.hasMatch(e.attributes["href"] ?? ""))
          .map((e) => e.attributes["href"]!)
          .toList();

      if (slugs.isEmpty) {
        final intermediatePages = html
            .querySelectorAll("a")
            .where(
              (e) => intermediateRegex.hasMatch(e.attributes["href"] ?? ""),
            )
            .toList();

        if (intermediatePages.isNotEmpty) {
          final intermediateFutures = intermediatePages.map((
            intermediatePage,
          ) async {
            final resIntermediate = await sourceRequest(
              intermediatePage.attributes["href"]!,
              additionalSettings,
            );
            if (resIntermediate.statusCode != 200) {
              throw getObtainiumHttpError(resIntermediate);
            }
            return parse(resIntermediate.body);
          }).toList();
          final intermediateResults = await Future.wait(intermediateFutures);
          for (final htmlIntermediate in intermediateResults) {
            slugs.addAll(
              htmlIntermediate
                  .querySelectorAll("a")
                  .where((e) => slugRegex.hasMatch(e.attributes["href"] ?? ""))
                  .map((e) => e.attributes["href"]!),
            );
          }
        }
      }

      if (slugs.isEmpty) {
        throw NoReleasesError();
      }

      final slugFutures = slugs.map((slugUrl) async {
        final resSlug = await sourceRequest(slugUrl, additionalSettings);
        if (resSlug.statusCode != 200) {
          throw getObtainiumHttpError(resSlug);
        }
        return MapEntry(slugUrl, parse(resSlug.body));
      });
      final slugResults = await Future.wait(slugFutures);

      final apkUrls = <MapEntry<String, String>>[];

      for (final entry in slugResults) {
        final slugUrl = entry.key;
        final htmlSlug = entry.value;

        final fnPs = htmlSlug.querySelectorAll("p").where((e) {
          return e.text == "File Name";
        });

        final apkName =
            (fnPs.isNotEmpty ? fnPs.first.nextElementSibling?.text : null) ??
            ("${slugUrl.split("=").last}.apk");

        final dlLink = htmlSlug
            .querySelector("#download-button")
            ?.attributes["href"];

        if (dlLink != null) {
          apkUrls.add(
            MapEntry(
              apkName.trim(),
              Uri.parse(dlLink.trim()).replace(query: "").toString(),
            ),
          );
        }
      }

      if (apkUrls.isEmpty) {
        throw NoAPKError();
      }

      return APKDetails(
        appVersion.trim(),
        apkUrls,
        AppNames("${name.trim()} (${appAuthor.trim()})", appName.trim()),
        releaseDate: releaseDateString != null
            ? DateFormat("MMMM dd, yyyy").tryParse(releaseDateString.trim())
            : null,
      );
    } catch (e) {
      if (e is ObtainiumError) rethrow;
      throw ObtainiumError("RockMods Error: $e");
    }
  }
}
