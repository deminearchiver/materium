import 'package:device_info_ffi/device_info_ffi_platform_interface.dart';

class DeviceInfoDefault extends DeviceInfoPlatform {
  DeviceInfoDefault();

  @override
  BaseDeviceInfo? deviceInfo() => null;
}
