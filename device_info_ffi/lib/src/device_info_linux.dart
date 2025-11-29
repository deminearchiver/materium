import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';

/// Device information for a Linux system.
///
/// See:
/// - https://www.freedesktop.org/software/systemd/man/os-release.html
/// - https://www.freedesktop.org/software/systemd/man/machine-id.html
class LinuxDeviceInfo with Diagnosticable implements BaseDeviceInfo {
  /// Constructs a LinuxDeviceInfo.
  LinuxDeviceInfo({
    required this.name,
    this.version,
    required this.id,
    this.idLike,
    this.versionCodename,
    this.versionId,
    required this.prettyName,
    this.buildId,
    this.variant,
    this.variantId,
    required this.machineId,
  });

  /// A string identifying the operating system, without a version component,
  /// and suitable for presentation to the user.
  ///
  /// Examples: 'Fedora', 'Debian GNU/Linux'.
  ///
  /// If not set, defaults to 'Linux'.
  final String name;

  /// A string identifying the operating system version, excluding any OS name
  /// information, possibly including a release code name, and suitable for
  /// presentation to the user.
  ///
  /// Examples: '17', '17 (Beefy Miracle)'.
  ///
  /// This field is optional and may be null on some systems.
  final String? version;

  /// A lower-case string identifying the operating system, excluding any
  /// version information and suitable for processing by scripts or usage in
  /// generated filenames.
  ///
  /// The ID contains no spaces or other characters outside of 0–9, a–z, '.',
  /// '_' and '-'.
  ///
  /// Examples: 'fedora', 'debian'.
  ///
  /// If not set, defaults to 'linux'.
  final String id;

  /// A space-separated list of operating system identifiers in the same syntax
  /// as the [id] value. It lists identifiers of operating systems that are
  /// closely related to the local operating system in regards to packaging
  /// and programming interfaces, for example listing one or more OS identifiers
  /// the local OS is a derivative from.
  ///
  /// Examples: an operating system with [id] 'centos', would list 'rhel' and
  /// 'fedora', and an operating system with [id] 'ubuntu' would list 'debian'.
  ///
  /// This field is optional and may be null on some systems.
  final List<String>? idLike;

  /// A lower-case string identifying the operating system release code name,
  /// excluding any OS name information or release version, and suitable for
  /// processing by scripts or usage in generated filenames.
  ///
  /// The codename contains no spaces or other characters outside of 0–9, a–z,
  /// '.', '_' and '-'.
  ///
  /// Examples: 'buster', 'xenial'.
  ///
  /// This field is optional and may be null on some systems.
  final String? versionCodename;

  /// A lower-case string identifying the operating system version, excluding
  /// any OS name information or release code name, and suitable for processing
  /// by scripts or usage in generated filenames.
  ///
  /// The version is mostly numeric, and contains no spaces or other characters
  /// outside of 0–9, a–z, '.', '_' and '-'.
  ///
  /// Examples: '17', '11.04'.
  ///
  /// This field is optional and may be null on some systems.
  final String? versionId;

  /// A pretty operating system name in a format suitable for presentation to
  /// the user. May or may not contain a release code name or OS version of some
  /// kind, as suitable.
  ///
  /// Examples: 'Fedora 17 (Beefy Miracle)'.
  ///
  /// If not set, defaults to 'Linux'.
  final String prettyName;

  /// A string uniquely identifying the system image used as the origin for a
  /// distribution (it is not updated with system updates). The field can be
  /// identical between different [versionId]s as `buildId` is an only a unique
  /// identifier to a specific version.
  ///
  /// Examples: '2013-03-20.3', '201303203'.
  ///
  /// This field is optional and may be null on some systems.
  final String? buildId;

  /// A string identifying a specific variant or edition of the operating system
  /// suitable for presentation to the user. This field may be used to inform
  /// the user that the configuration of this system is subject to a specific
  /// divergent set of rules or default configuration settings.
  ///
  /// Examples: 'Server Edition', 'Smart Refrigerator Edition'.
  ///
  /// Note: this field is for display purposes only. The [variantId] field
  /// should be used for making programmatic decisions.
  ///
  /// This field is optional and may be null on some systems.
  final String? variant;

  /// A lower-case string identifying a specific variant or edition of the
  /// operating system. This may be interpreted in order to determine a
  /// divergent default configuration.
  ///
  /// The variant ID contains no spaces or other characters outside of 0–9, a–z,
  /// '.', '_' and '-'.
  ///
  /// Examples: 'server', 'embedded'.
  ///
  /// This field is optional and may be null on some systems.
  final String? variantId;

  /// A unique machine ID of the local system that is set during installation or
  /// boot. The machine ID is hexadecimal, 32-character, lowercase ID. When
  /// decoded from hexadecimal, this corresponds to a 16-byte/128-bit value.
  final String? machineId;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(StringProperty("name", name))
      ..add(StringProperty("version", version, defaultValue: null))
      ..add(StringProperty("id", id))
      ..add(IterableProperty("idLike", idLike, defaultValue: null))
      ..add(
        StringProperty("versionCodename", versionCodename, defaultValue: null),
      )
      ..add(StringProperty("versionId", versionId, defaultValue: null))
      ..add(StringProperty("prettyName", prettyName))
      ..add(StringProperty("buildId", buildId, defaultValue: null))
      ..add(StringProperty("variant", variant, defaultValue: null))
      ..add(StringProperty("variantId", variantId, defaultValue: null))
      ..add(StringProperty("machineId", machineId, defaultValue: null));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is LinuxDeviceInfo &&
          name == other.name &&
          version == other.version &&
          id == other.id &&
          listEquals(idLike, other.idLike) &&
          versionCodename == other.versionCodename &&
          versionId == other.versionId &&
          prettyName == other.prettyName &&
          buildId == other.buildId &&
          variant == other.variant &&
          variantId == other.variantId &&
          machineId == other.machineId;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    version,
    id,
    idLike != null ? Object.hashAll(idLike!) : null,
    versionCodename,
    versionId,
    prettyName,
    buildId,
    variant,
    variantId,
    machineId,
  );
}

class DeviceInfoLinux extends DeviceInfoPlatform {
  final FileSystem _fileSystem = const LocalFileSystem();

  LinuxDeviceInfo? _cachedLinuxDeviceInfo;

  LinuxDeviceInfo _getInfo() {
    final os = _getOsRelease() ?? const {};
    final lsb = _getLsbRelease() ?? const {};
    final machineId = _getMachineId();
    return LinuxDeviceInfo(
      name: os["NAME"] ?? "Linux",
      version: os["VERSION"] ?? lsb["LSB_VERSION"],
      id: os["ID"] ?? lsb["DISTRIB_ID"] ?? "linux",
      idLike: os["ID_LIKE"]?.split(" "),
      versionCodename: os["VERSION_CODENAME"] ?? lsb["DISTRIB_CODENAME"],
      versionId: os["VERSION_ID"] ?? lsb["DISTRIB_RELEASE"],
      prettyName: os["PRETTY_NAME"] ?? lsb["DISTRIB_DESCRIPTION"] ?? "Linux",
      buildId: os["BUILD_ID"],
      variant: os["VARIANT"],
      variantId: os["VARIANT_ID"],
      machineId: machineId,
    );
  }

  Map<String, String?>? _getOsRelease() =>
      _tryReadKeyValues("/etc/os-release") ??
      _tryReadKeyValues("/usr/lib/os-release");

  Map<String, String?>? _getLsbRelease() =>
      _tryReadKeyValues("/etc/lsb-release");

  String? _getMachineId() => _tryReadValue("/etc/machine-id");

  String? _tryReadValue(String path) {
    try {
      return _fileSystem.file(path).readAsStringSync().trim();
    } on Object catch (_) {
      return null;
    }
  }

  Map<String, String?>? _tryReadKeyValues(String path) {
    try {
      return _fileSystem.file(path).readAsLinesSync()._toKeyValues();
    } on Object catch (_) {
      return null;
    }
  }

  @override
  LinuxDeviceInfo deviceInfo() => _cachedLinuxDeviceInfo ??= _getInfo();

  static void registerWith() {
    DeviceInfoPlatform.instance = DeviceInfoLinux();
  }
}

extension on String {
  String _removePrefix(String prefix) =>
      startsWith(prefix) ? substring(prefix.length) : this;

  String _removeSuffix(String suffix) =>
      endsWith(suffix) ? substring(0, length - suffix.length) : this;

  String _unquote() => _removePrefix("\"")._removeSuffix("\"");
}

extension on List<String> {
  Map<String, String?> _toKeyValues() => Map.fromEntries(
    map((line) {
      final parts = line.split("=");
      if (parts.length != 2) return MapEntry(line, null);
      return MapEntry(parts.first, parts.last._unquote());
    }),
  );
}
