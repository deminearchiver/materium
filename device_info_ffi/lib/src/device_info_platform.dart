import 'package:device_info_ffi/device_info_ffi.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class DeviceInfoPlatform extends PlatformInterface {
  DeviceInfoPlatform() : super(token: _token);

  BaseDeviceInfo? deviceInfo() {
    throw UnimplementedError("deviceInfo() has not been implemented.");
  }

  static final Object _token = Object();

  static DeviceInfoPlatform _instance = DeviceInfoDefault();

  static DeviceInfoPlatform get instance => _instance;

  static set instance(DeviceInfoPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }
}
