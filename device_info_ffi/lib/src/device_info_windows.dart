import 'dart:ffi';
import 'dart:developer' as developer;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:win32/win32.dart';
import 'package:win32_registry/win32_registry.dart';

/// Object encapsulating WINDOWS device information.
class WindowsDeviceInfo with Diagnosticable implements BaseDeviceInfo {
  /// Constructs a [WindowsDeviceInfo].
  const WindowsDeviceInfo({
    required this.computerName,
    required this.numberOfCores,
    required this.systemMemoryInMegabytes,
    required this.userName,
    required this.majorVersion,
    required this.minorVersion,
    required this.buildNumber,
    required this.platformId,
    required this.csdVersion,
    required this.servicePackMajor,
    required this.servicePackMinor,
    required this.suitMask,
    required this.productType,
    required this.reserved,
    required this.buildLab,
    required this.buildLabEx,
    required this.digitalProductId,
    required this.displayVersion,
    required this.editionId,
    required this.installDate,
    required this.productId,
    required this.productName,
    required this.registeredOwner,
    required this.releaseId,
    required this.deviceId,
  });

  /// The computer's fully-qualified DNS name, where available.
  final String computerName;

  /// Number of CPU cores on the local machine
  final int numberOfCores;

  /// The physically installed memory in the computer.
  /// This may not be the same as available memory.
  final int systemMemoryInMegabytes;

  final String userName;

  /// The major version number of the operating system.
  /// For example, for Windows 2000, the major version number is five.
  /// For more information, see the table in Remarks.
  /// https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/ns-wdm-_osversioninfoexw#remarks
  final int majorVersion;

  /// The minor version number of the operating system.
  /// For example, for Windows 2000, the minor version number is zero.
  /// For more information, see the table in Remarks.
  /// https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/ns-wdm-_osversioninfoexw#remarks
  final int minorVersion;

  /// The build number of the operating system.
  /// For example:
  /// - `22000` or greater for Windows 11.
  /// - `10240` or greator for Windows 10.
  final int buildNumber;

  /// The operating system platform. For Win32 on NT-based operating systems,
  /// RtlGetVersion returns the value `VER_PLATFORM_WIN32_NT`.
  final int platformId;

  /// The service-pack version string.
  ///
  /// This member contains a string, such as "Service Pack 3", which indicates
  /// the latest service pack installed on the system.
  final String csdVersion;

  /// The major version number of the latest service pack installed on the system.
  /// For example, for Service Pack 3, the major version number is three. If no
  /// service pack has been installed, the value is zero.
  final int servicePackMajor;

  /// The minor version number of the latest service pack installed on the
  /// system. For example, for Service Pack 3, the minor version number is zero.
  final int servicePackMinor;

  /// The product suites available on the system.
  final int suitMask;

  /// The product type. This member contains additional information about the
  /// system.
  final int productType;

  /// Reserved for future use.
  final int reserved;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\BuildLab` registry key. For example:
  /// `22000.co_release.210604-1628`.
  final String buildLab;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\BuildLabEx` registry key. For example:
  /// `22000.1.amd64fre.co_release.210604-1628`.
  final String buildLabEx;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\DigitalProductId` registry key.
  final Uint8List digitalProductId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\DisplayVersion` registry key. For example: `21H2`.
  final String displayVersion;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\EditionID` registry key.
  final String editionId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\InstallDate` registry key.
  final DateTime installDate;

  /// Displayed as "Product ID" in Windows Settings. Value of the
  /// `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ProductId` registry key. For example:
  /// `00000-00000-0000-AAAAA`.
  final String productId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ProductName` registry key. For example: `Windows 10 Home
  /// Single Language`.
  final String productName;

  /// Value of the `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\RegisteredOwner` registry key. For example: `Microsoft
  /// Corporation`.
  final String registeredOwner;

  /// Value of the `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ReleaseId` registry key. For example: `1903`.
  final String releaseId;

  /// Displayed as "Device ID" in Windows Settings. Value of
  /// `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SQMClient\MachineId` registry key.
  final String deviceId;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(StringProperty("computerName", computerName))
      ..add(IntProperty("numberOfCores", numberOfCores))
      ..add(IntProperty("systemMemoryInMegabytes", systemMemoryInMegabytes))
      ..add(StringProperty("userName", userName))
      ..add(IntProperty("majorVersion", majorVersion))
      ..add(IntProperty("minorVersion", minorVersion))
      ..add(IntProperty("buildNumber", buildNumber))
      ..add(IntProperty("platformId", platformId))
      ..add(StringProperty("csdVersion", csdVersion))
      ..add(IntProperty("servicePackMajor", servicePackMajor))
      ..add(IntProperty("servicePackMinor", servicePackMinor))
      ..add(IntProperty("suitMask", suitMask))
      ..add(IntProperty("productType", productType))
      ..add(IntProperty("reserved", reserved))
      ..add(StringProperty("buildLab", buildLab))
      ..add(StringProperty("buildLabEx", buildLabEx))
      ..add(IterableProperty("digitalProductId", digitalProductId))
      ..add(StringProperty("displayVersion", displayVersion))
      ..add(StringProperty("editionId", editionId))
      ..add(DiagnosticsProperty<DateTime>("installDate", installDate))
      ..add(StringProperty("productId", productId))
      ..add(StringProperty("productName", productName))
      ..add(StringProperty("registeredOwner", registeredOwner))
      ..add(StringProperty("releaseId", releaseId))
      ..add(StringProperty("deviceId", deviceId));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is WindowsDeviceInfo &&
          computerName == other.computerName &&
          numberOfCores == other.numberOfCores &&
          systemMemoryInMegabytes == other.systemMemoryInMegabytes &&
          userName == other.userName &&
          majorVersion == other.majorVersion &&
          minorVersion == other.minorVersion &&
          buildNumber == other.buildNumber &&
          platformId == other.platformId &&
          csdVersion == other.csdVersion &&
          servicePackMajor == other.servicePackMajor &&
          servicePackMinor == other.servicePackMinor &&
          suitMask == other.suitMask &&
          productType == other.productType &&
          reserved == other.reserved &&
          buildLab == other.buildLab &&
          buildLabEx == other.buildLabEx &&
          listEquals(digitalProductId, other.digitalProductId) &&
          displayVersion == other.displayVersion &&
          editionId == other.editionId &&
          installDate == other.installDate &&
          productId == other.productId &&
          productName == other.productName &&
          registeredOwner == other.registeredOwner &&
          releaseId == other.releaseId &&
          deviceId == other.deviceId;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    computerName,
    numberOfCores,
    systemMemoryInMegabytes,
    userName,
    majorVersion,
    minorVersion,
    buildNumber,
    platformId,
    csdVersion,
    servicePackMajor,
    servicePackMinor,
    suitMask,
    productType,
    reserved,
    buildLab,
    buildLabEx,
    Object.hashAll(digitalProductId),
    displayVersion,
    Object.hash(
      editionId,
      installDate,
      productId,
      productName,
      registeredOwner,
      releaseId,
      deviceId,
    ),
  );
}

typedef _RtlGetVersion = void Function(Pointer<OSVERSIONINFOEX>);

class DeviceInfoWindows extends DeviceInfoPlatform {
  DeviceInfoWindows();

  WindowsDeviceInfo? _cachedWindowsDeviceInfo;

  @override
  WindowsDeviceInfo deviceInfo() => _cachedWindowsDeviceInfo ??= _getInfo();

  final _RtlGetVersion _rtlGetVersion = DynamicLibrary.open("ntdll.dll")
      .lookupFunction<
        Void Function(Pointer<OSVERSIONINFOEX>),
        void Function(Pointer<OSVERSIONINFOEX>)
      >("RtlGetVersion");

  WindowsDeviceInfo _getInfo() {
    final systemInfo = calloc<SYSTEM_INFO>();
    final osVersionInfo = calloc<OSVERSIONINFOEX>()
      ..ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFOEX>();

    try {
      final currentVersionKey = Registry.openPath(
        RegistryHive.localMachine,
        path: r"SOFTWARE\Microsoft\Windows NT\CurrentVersion",
      );
      final buildLab = currentVersionKey.getStringValue("BuildLab") ?? "";
      final buildLabEx = currentVersionKey.getStringValue("BuildLabEx") ?? "";
      final digitalProductId =
          currentVersionKey.getBinaryValue("DigitalProductId") ??
          Uint8List.fromList([]);
      final displayVersion =
          currentVersionKey.getStringValue("DisplayVersion") ?? "";
      final editionId = currentVersionKey.getStringValue("EditionID") ?? "";
      final installDate = DateTime.fromMillisecondsSinceEpoch(
        1000 * (currentVersionKey.getIntValue("InstallDate") ?? 0),
      );
      final productId = currentVersionKey.getStringValue("ProductID") ?? "";
      var productName = currentVersionKey.getStringValue("ProductName") ?? "";
      final registeredOwner =
          currentVersionKey.getStringValue("RegisteredOwner") ?? "";
      final releaseId = currentVersionKey.getStringValue("ReleaseId") ?? "";

      final sqmClientKey = Registry.openPath(
        RegistryHive.localMachine,
        path: r"SOFTWARE\Microsoft\SQMClient",
      );
      final machineId = sqmClientKey.getStringValue("MachineId") ?? "";

      GetSystemInfo(systemInfo);

      // Use `RtlGetVersion` from `ntdll.dll` to get the Windows version.
      _rtlGetVersion(osVersionInfo);

      // Handle [productName] for Windows 11 separately (as per Raymond Chen"s comment).
      // https://stackoverflow.com/questions/69460588/how-can-i-find-the-windows-product-name-in-windows-11
      if (osVersionInfo.ref.dwBuildNumber >= 22000) {
        productName = productName.replaceAll("10", "11");
      }
      final data = WindowsDeviceInfo(
        numberOfCores: systemInfo.ref.dwNumberOfProcessors,
        computerName: _getComputerName(),
        systemMemoryInMegabytes: getSystemMemoryInMegabytes(),
        userName: _getUserName(),
        majorVersion: osVersionInfo.ref.dwMajorVersion,
        minorVersion: osVersionInfo.ref.dwMinorVersion,
        buildNumber: osVersionInfo.ref.dwBuildNumber,
        platformId: osVersionInfo.ref.dwPlatformId,
        csdVersion: osVersionInfo.ref.szCSDVersion,
        servicePackMajor: osVersionInfo.ref.wServicePackMajor,
        servicePackMinor: osVersionInfo.ref.wServicePackMinor,
        suitMask: osVersionInfo.ref.wSuiteMask,
        productType: osVersionInfo.ref.wProductType,
        reserved: osVersionInfo.ref.wReserved,
        buildLab: buildLab,
        buildLabEx: buildLabEx,
        digitalProductId: digitalProductId,
        displayVersion: displayVersion,
        editionId: editionId,
        installDate: installDate,
        productId: productId,
        productName: productName,
        registeredOwner: registeredOwner,
        releaseId: releaseId,
        deviceId: machineId,
      );
      return data;
    } finally {
      free(systemInfo);
      free(osVersionInfo);
    }
  }

  int getSystemMemoryInMegabytes() {
    final memoryInKilobytes = calloc<ULONGLONG>();
    try {
      final result = GetPhysicallyInstalledSystemMemory(memoryInKilobytes);
      if (result != 0) {
        return memoryInKilobytes.value ~/ 1024;
      } else {
        developer.log("Failed to get system memory", error: GetLastError());
        return 0;
      }
    } finally {
      free(memoryInKilobytes);
    }
  }

  String _getComputerName() {
    // We call this a first time to get the length of the string in characters,
    // so we can allocate sufficient memory.
    final nSize = calloc<DWORD>();
    GetComputerNameEx(ComputerNameDnsFullyQualified, nullptr, nSize);

    // Now allocate memory for a native string and call this a second time.
    final lpBuffer = wsalloc(nSize.value);
    try {
      final result = GetComputerNameEx(
        ComputerNameDnsFullyQualified,
        lpBuffer,
        nSize,
      );

      if (result != 0) {
        return lpBuffer.toDartString();
      } else {
        developer.log("Failed to get computer name", error: GetLastError());
        return "";
      }
    } finally {
      free(lpBuffer);
      free(nSize);
    }
  }

  String _getUserName() {
    const maxLength = 256; // defined as UNLEN in Lmcons.h
    final lpBuffer = wsalloc(maxLength + 1); // allow for terminating null
    final pcbBuffer = calloc<DWORD>()..value = maxLength + 1;
    try {
      final result = GetUserName(lpBuffer, pcbBuffer);
      if (result != 0) {
        return lpBuffer.toDartString();
      } else {
        developer.log("Failed to get user name", error: GetLastError());
        return "";
      }
    } finally {
      free(pcbBuffer);
      free(lpBuffer);
    }
  }

  static void registerWith() {
    DeviceInfoPlatform.instance = DeviceInfoWindows();
  }
}
