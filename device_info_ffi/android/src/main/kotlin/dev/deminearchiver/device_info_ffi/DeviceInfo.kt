package dev.deminearchiver.device_info_ffi

import androidx.annotation.Keep

@Suppress("unused")
@Keep
class DeviceInfo(
  val board: String,
  val bootloader: String,
  val brand: String,
  val device: String,
  val display: String,
  val fingerprint: String,
  val hardware: String,
  val host: String,
  val id: String,
  val manufacturer: String,
  val model: String,
  val product: String,
  val name: String?,
  val supported32BitAbis: List<String>?,
  val supported64BitAbis: List<String>?,
  val supportedAbis: List<String>?,
  val tags: String,
  val type: String,
  val isPhysicalDevice: Boolean,
  val systemFeatures: List<String>,
  val freeDiskSize: Long,
  val totalDiskSize: Long,
  val version: BuildVersion,
  val isLowRamDevice: Boolean,
  val physicalRamSize: Long,
  val availableRamSize: Long,
) {
  @Keep
  class BuildVersion(
    val baseOS: String?,
    val previewSdkInt: Int?,
    val securityPatch: String?,
    val codename: String,
    val incremental: String,
    val release: String,
    val sdkInt: Int,
  )
}
