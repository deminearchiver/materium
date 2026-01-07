// import 'package:pub_semver/pub_semver.dart';

const upstreamMajor = 1;
const upstreamMinor = 2;
const upstreamPatch = 9;
const upstreamBuild = 2325;

const forkMajor = 2;
const forkMinor = 0;
const forkPatch = 0;

void main(List<String> arguments) async {
  final forkBuild =
      (upstreamMajor << 24) |
      (upstreamMinor << 16) |
      (upstreamPatch << 8) |
      (upstreamBuild);
  print("$forkMajor.$forkMinor.$forkPatch+$forkBuild");
}
