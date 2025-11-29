import 'package:device_info_ffi/device_info_ffi.dart';

abstract final class DeviceInfo {
  static BaseDeviceInfo? get deviceInfo =>
      DeviceInfoPlatform.instance.deviceInfo();

  static AndroidDeviceInfo? get androidInfo => switch (deviceInfo) {
    final AndroidDeviceInfo value => value,
    _ => null,
  };

  static LinuxDeviceInfo? get linuxInfo => switch (deviceInfo) {
    final LinuxDeviceInfo value => value,
    _ => null,
  };

  static WindowsDeviceInfo? get windowsInfo => switch (deviceInfo) {
    final WindowsDeviceInfo value => value,
    _ => null,
  };
}
