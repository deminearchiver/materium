import 'package:flutter/foundation.dart';
import 'package:jni/jni.dart';
import 'package:device_info_ffi/device_info_ffi_platform_interface.dart';

import 'jni_bindings.dart' as jb;

/// Information derived from `android.os.Build`.
///
/// See: https://developer.android.com/reference/android/os/Build.html
class AndroidDeviceInfo with Diagnosticable implements BaseDeviceInfo {
  AndroidDeviceInfo({
    required this.version,
    required this.board,
    required this.bootloader,
    required this.brand,
    required this.device,
    required this.display,
    required this.fingerprint,
    required this.hardware,
    required this.host,
    required this.id,
    required this.manufacturer,
    required this.model,
    required this.product,
    required this.name,
    required List<String> supported32BitAbis,
    required List<String> supported64BitAbis,
    required List<String> supportedAbis,
    required this.tags,
    required this.type,
    required this.isPhysicalDevice,
    required this.freeDiskSize,
    required this.totalDiskSize,
    required List<String> systemFeatures,
    required this.isLowRamDevice,
    required this.physicalRamSize,
    required this.availableRamSize,
  }) : supported32BitAbis = List<String>.unmodifiable(supported32BitAbis),
       supported64BitAbis = List<String>.unmodifiable(supported64BitAbis),
       supportedAbis = List<String>.unmodifiable(supportedAbis),
       systemFeatures = List<String>.unmodifiable(systemFeatures);

  /// Android operating system version values derived from `android.os.Build.VERSION`.
  final AndroidBuildVersion version;

  /// The name of the underlying board, like "goldfish".
  /// https://developer.android.com/reference/android/os/Build#BOARD
  final String board;

  /// The system bootloader version number.
  /// https://developer.android.com/reference/android/os/Build#BOOTLOADER
  final String bootloader;

  /// The consumer-visible brand with which the product/hardware will be associated, if any.
  /// https://developer.android.com/reference/android/os/Build#BRAND
  final String brand;

  /// The name of the industrial design.
  /// https://developer.android.com/reference/android/os/Build#DEVICE
  final String device;

  /// A build ID string meant for displaying to the user.
  /// https://developer.android.com/reference/android/os/Build#DISPLAY
  final String display;

  /// A string that uniquely identifies this build.
  /// https://developer.android.com/reference/android/os/Build#FINGERPRINT
  final String fingerprint;

  /// The name of the hardware (from the kernel command line or /proc).
  /// https://developer.android.com/reference/android/os/Build#HARDWARE
  final String hardware;

  /// Hostname.
  /// https://developer.android.com/reference/android/os/Build#HOST
  final String host;

  /// Either a changelist number, or a label like "M4-rc20".
  /// https://developer.android.com/reference/android/os/Build#ID
  final String id;

  /// The manufacturer of the product/hardware.
  /// https://developer.android.com/reference/android/os/Build#MANUFACTURER
  final String manufacturer;

  /// The end-user-visible name for the end product.
  /// https://developer.android.com/reference/android/os/Build#MODEL
  final String model;

  /// The name of the overall product.
  /// https://developer.android.com/reference/android/os/Build#PRODUCT
  final String product;

  /// The name of the device.
  /// https://developer.android.com/reference/android/provider/Settings.Global#DEVICE_NAME
  final String name;

  /// An ordered list of 32 bit ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_32_BIT_ABIS
  final List<String> supported32BitAbis;

  /// An ordered list of 64 bit ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_64_BIT_ABIS
  final List<String> supported64BitAbis;

  /// An ordered list of ABIs supported by this device.
  /// Available only on Android L (API 21) and newer
  /// https://developer.android.com/reference/android/os/Build#SUPPORTED_ABIS
  final List<String> supportedAbis;

  /// Comma-separated tags describing the build, like "unsigned,debug".
  /// https://developer.android.com/reference/android/os/Build#TAGS
  final String tags;

  /// The type of build, like "user" or "eng".
  /// https://developer.android.com/reference/android/os/Build#TYPE
  final String type;

  /// `false` if the application is running in an emulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// Available disk size in bytes
  ///
  /// https://developer.android.com/reference/android/os/StatFs#getFreeBytes()
  final int freeDiskSize;

  /// Total disk size in bytes
  ///
  /// https://developer.android.com/reference/android/os/StatFs#getTotalBytes()
  final int totalDiskSize;

  /// Describes what features are available on the current device.
  ///
  /// This can be used to check if the device has, for example, a front-facing
  /// camera, or a touchscreen. However, in many cases this is not the best
  /// API to use. For example, if you are interested in bluetooth, this API
  /// can tell you if the device has a bluetooth radio, but it cannot tell you
  /// if bluetooth is currently enabled, or if you have been granted the
  /// necessary permissions to use it. Please *only* use this if there is no
  /// other way to determine if a feature is supported.
  ///
  /// This data comes from Android's PackageManager.getSystemAvailableFeatures,
  /// and many of the common feature strings to look for are available in
  /// PackageManager's public documentation:
  /// https://developer.android.com/reference/android/content/pm/PackageManager
  final List<String> systemFeatures;

  /// `true` if the application is running on a low-RAM device, `false` otherwise.
  final bool isLowRamDevice;

  /// Total physical RAM size of the device in megabytes
  ///
  /// https://developer.android.com/reference/android/app/ActivityManager.MemoryInfo#totalMem
  final int physicalRamSize;

  /// Current unallocated RAM size of the device in megabytes
  ///
  /// https://developer.android.com/reference/android/app/ActivityManager.MemoryInfo#availMem
  final int availableRamSize;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<AndroidBuildVersion>("version", version))
      ..add(StringProperty("board", board))
      ..add(StringProperty("bootloader", bootloader))
      ..add(StringProperty("brand", brand))
      ..add(StringProperty("device", device))
      ..add(StringProperty("display", display))
      ..add(StringProperty("fingerprint", fingerprint))
      ..add(StringProperty("hardware", hardware))
      ..add(StringProperty("host", host))
      ..add(StringProperty("id", id))
      ..add(StringProperty("manufacturer", manufacturer))
      ..add(StringProperty("model", model))
      ..add(StringProperty("product", product))
      ..add(StringProperty("name", name, defaultValue: ""))
      ..add(
        IterableProperty<String>(
          "supported32BitAbis",
          supported32BitAbis,
          defaultValue: const [],
        ),
      )
      ..add(
        IterableProperty<String>(
          "supported64BitAbis",
          supported64BitAbis,
          defaultValue: const [],
        ),
      )
      ..add(
        IterableProperty<String>(
          "supportedAbis",
          supportedAbis,
          defaultValue: const [],
        ),
      )
      ..add(StringProperty("tags", tags))
      ..add(StringProperty("type", type))
      ..add(DiagnosticsProperty<bool>("isPhysicalDevice", isPhysicalDevice))
      ..add(IntProperty("freeDiskSize", freeDiskSize))
      ..add(IntProperty("totalDiskSize", totalDiskSize))
      ..add(IterableProperty<String>("systemFeatures", systemFeatures))
      ..add(DiagnosticsProperty<bool>("isLowRamDevice", isLowRamDevice))
      ..add(IntProperty("physicalRamSize", physicalRamSize))
      ..add(IntProperty("availableRamSize", availableRamSize));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is AndroidDeviceInfo &&
          version == other.version &&
          board == other.board &&
          bootloader == other.bootloader &&
          brand == other.brand &&
          device == other.device &&
          display == other.display &&
          fingerprint == other.fingerprint &&
          hardware == other.hardware &&
          host == other.host &&
          id == other.id &&
          manufacturer == other.manufacturer &&
          model == other.model &&
          product == other.product &&
          name == other.name &&
          listEquals(supported32BitAbis, other.supported32BitAbis) &&
          listEquals(supported64BitAbis, other.supported64BitAbis) &&
          listEquals(supportedAbis, other.supportedAbis) &&
          tags == other.tags &&
          type == other.type &&
          isPhysicalDevice == other.isPhysicalDevice &&
          freeDiskSize == other.freeDiskSize &&
          totalDiskSize == other.totalDiskSize &&
          listEquals(systemFeatures, other.systemFeatures) &&
          isLowRamDevice == other.isLowRamDevice &&
          physicalRamSize == other.physicalRamSize &&
          availableRamSize == other.availableRamSize;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    version,
    board,
    bootloader,
    brand,
    device,
    display,
    fingerprint,
    hardware,
    host,
    id,
    manufacturer,
    model,
    product,
    name,
    Object.hashAll(supported32BitAbis),
    Object.hashAll(supported64BitAbis),
    Object.hashAll(supportedAbis),
    tags,
    Object.hash(
      type,
      isPhysicalDevice,
      freeDiskSize,
      totalDiskSize,
      Object.hashAll(systemFeatures),
      isLowRamDevice,
      physicalRamSize,
      availableRamSize,
    ),
  );
}

/// Version values of the current Android operating system build derived from
/// `android.os.Build.VERSION`.
///
/// See: https://developer.android.com/reference/android/os/Build.VERSION.html
class AndroidBuildVersion with Diagnosticable {
  const AndroidBuildVersion({
    this.baseOS,
    required this.codename,
    required this.incremental,
    required this.previewSdkInt,
    required this.release,
    required this.sdkInt,
    this.securityPatch,
  });

  /// The base OS build the product is based on.
  /// Available only on Android M (API 23) and newer
  final String? baseOS;

  /// The current development codename, or the string "REL" if this is a release build.
  final String codename;

  /// The internal value used by the underlying source control to represent this build.
  /// Available only on Android M (API 23) and newer
  final String incremental;

  /// The developer preview revision of a pre-release SDK.
  final int? previewSdkInt;

  /// The user-visible version string.
  final String release;

  /// The user-visible SDK version of the framework.
  ///
  /// Possible values are defined in: https://developer.android.com/reference/android/os/Build.VERSION_CODES.html
  final int sdkInt;

  /// The user-visible security patch level.
  /// Available only on Android M (API 23) and newer
  final String? securityPatch;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(StringProperty("baseOS", baseOS, defaultValue: null))
      ..add(StringProperty("codename", codename))
      ..add(StringProperty("incremental", incremental))
      ..add(IntProperty("previewSdkInt", previewSdkInt, defaultValue: null))
      ..add(StringProperty("release", release))
      ..add(IntProperty("sdkInt", sdkInt))
      ..add(StringProperty("securityPatch", securityPatch, defaultValue: null));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is AndroidBuildVersion &&
          baseOS == other.baseOS &&
          codename == other.codename &&
          incremental == other.incremental &&
          previewSdkInt == other.previewSdkInt &&
          release == other.release &&
          sdkInt == other.sdkInt &&
          securityPatch == other.securityPatch;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    baseOS,
    codename,
    incremental,
    previewSdkInt,
    release,
    sdkInt,
    securityPatch,
  );
}

class DeviceInfoAndroid extends DeviceInfoPlatform {
  DeviceInfoAndroid();

  /// This information does not change from call to call. Cache it.
  AndroidDeviceInfo? _cachedAndroidDeviceInfo;

  @override
  AndroidDeviceInfo deviceInfo() =>
      _cachedAndroidDeviceInfo ??= _androidDeviceInfo();

  static void registerWith() {
    DeviceInfoPlatform.instance = DeviceInfoAndroid();
  }

  static List<String> _stringListFromJStringList(JList<JString> value) {
    final length = value.length;
    return [
      for (var i = 0; i < length; i++)
        value[i].toDartString(releaseOriginal: true),
    ];
  }

  static AndroidDeviceInfo _androidDeviceInfo() => Jni.androidApplicationContext
      .use(jb.DeviceInfoPlugin.getDeviceInfo)
      .use(_androidDeviceInfoFromNative);

  static AndroidBuildVersion _androidBuildVersionFromNative(
    jb.DeviceInfo$BuildVersion object,
  ) => AndroidBuildVersion(
    baseOS: object.getBaseOS()?.toDartString(releaseOriginal: true),
    codename: object.getCodename().toDartString(releaseOriginal: true),
    incremental: object.getIncremental().toDartString(releaseOriginal: true),
    previewSdkInt: object.getPreviewSdkInt()?.intValue(releaseOriginal: true),
    release: object.getRelease().toDartString(releaseOriginal: true),
    sdkInt: object.getSdkInt(),
    securityPatch: object.getSecurityPatch()?.toDartString(
      releaseOriginal: true,
    ),
  );

  static AndroidDeviceInfo _androidDeviceInfoFromNative(
    jb.DeviceInfo object,
  ) => AndroidDeviceInfo(
    version: object.getVersion().use(_androidBuildVersionFromNative),
    board: object.getBoard().toDartString(releaseOriginal: true),
    bootloader: object.getBootloader().toDartString(releaseOriginal: true),
    brand: object.getBrand().toDartString(releaseOriginal: true),
    device: object.getDevice().toDartString(releaseOriginal: true),
    display: object.getDisplay().toDartString(releaseOriginal: true),
    fingerprint: object.getFingerprint().toDartString(releaseOriginal: true),
    hardware: object.getHardware().toDartString(releaseOriginal: true),
    host: object.getHost().toDartString(releaseOriginal: true),
    id: object.getId().toDartString(releaseOriginal: true),
    manufacturer: object.getManufacturer().toDartString(releaseOriginal: true),
    model: object.getModel().toDartString(releaseOriginal: true),
    product: object.getProduct().toDartString(releaseOriginal: true),
    name: object.getName()?.toDartString(releaseOriginal: true) ?? "",
    supported32BitAbis:
        object.getSupported32BitAbis()?.use(_stringListFromJStringList) ??
        const [],
    supported64BitAbis:
        object.getSupported64BitAbis()?.use(_stringListFromJStringList) ??
        const [],
    supportedAbis:
        object.getSupportedAbis()?.use(_stringListFromJStringList) ?? const [],
    tags: object.getTags().toDartString(releaseOriginal: true),
    type: object.getType().toDartString(releaseOriginal: true),
    isPhysicalDevice: object.isPhysicalDevice(),
    freeDiskSize: object.getFreeDiskSize(),
    totalDiskSize: object.getTotalDiskSize(),
    systemFeatures: object.getSystemFeatures().use(_stringListFromJStringList),
    isLowRamDevice: object.isLowRamDevice(),
    physicalRamSize: object.getPhysicalRamSize(),
    availableRamSize: object.getAvailableRamSize(),
  );
}
