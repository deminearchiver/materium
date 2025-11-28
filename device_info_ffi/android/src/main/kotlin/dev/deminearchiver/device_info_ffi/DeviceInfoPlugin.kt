package dev.deminearchiver.device_info_ffi

import android.app.ActivityManager
import android.app.ActivityManager.MemoryInfo
import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import androidx.annotation.Keep
import dev.deminearchiver.device_info_ffi.DeviceInfo.BuildVersion

@Suppress("unused")
@Keep
object DeviceInfoPlugin {
  @JvmStatic
  fun getDeviceInfo(context: Context): DeviceInfo {
    val name = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) Settings.Global.getString(
      context.contentResolver,
      Settings.Global.DEVICE_NAME
    ) ?: "" else null

    val (
      supported32BitAbis,
      supported64BitAbis,
      supportedAbis
    ) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) Triple(
      listOf(*Build.SUPPORTED_32_BIT_ABIS),
      listOf(*Build.SUPPORTED_64_BIT_ABIS),
      listOf(*Build.SUPPORTED_ABIS)
    ) else Triple(null, null, null)

    val statFs = StatFs(Environment.getDataDirectory().path)

    val (
      baseOS,
      previewSdkInt,
      securityPatch,
    ) = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) Triple(
      Build.VERSION.BASE_OS,
      Build.VERSION.PREVIEW_SDK_INT,
      Build.VERSION.SECURITY_PATCH,
    ) else Triple(null, null, null)

    val memoryInfo = getMemoryInfo(context)

    return DeviceInfo(
      board = Build.BOARD,
      bootloader = Build.BOOTLOADER,
      brand = Build.BRAND,
      device = Build.DEVICE,
      display = Build.DISPLAY,
      fingerprint = Build.FINGERPRINT,
      hardware = Build.HARDWARE,
      host = Build.HOST,
      id = Build.ID,
      manufacturer = Build.MANUFACTURER,
      model = Build.MODEL,
      product = Build.PRODUCT,
      name = name,
      supported32BitAbis = supported32BitAbis,
      supported64BitAbis = supported64BitAbis,
      supportedAbis = supportedAbis,
      tags = Build.TAGS,
      type = Build.TYPE,
      isPhysicalDevice = !isEmulator,
      systemFeatures = getSystemFeatures(context),
      freeDiskSize = statFs.freeBytes,
      totalDiskSize = statFs.totalBytes,
      version = BuildVersion(
        baseOS = baseOS,
        previewSdkInt = previewSdkInt,
        securityPatch = securityPatch,
        codename = Build.VERSION.CODENAME,
        incremental = Build.VERSION.INCREMENTAL,
        release = Build.VERSION.RELEASE,
        sdkInt = Build.VERSION.SDK_INT
      ),
      isLowRamDevice = memoryInfo.lowMemory,
      physicalRamSize = memoryInfo.totalMem / 1048576L, // Mb
      availableRamSize = memoryInfo.availMem / 1048576L // Mb
    )
  }

  private fun getSystemFeatures(context: Context) =
    context.packageManager.systemAvailableFeatures
      .filterNot { featureInfo -> featureInfo.name == null }
      .map { featureInfo -> featureInfo.name }

  private fun getMemoryInfo(context: Context): MemoryInfo {
    val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val memoryInfo = MemoryInfo()
    activityManager.getMemoryInfo(memoryInfo)
    return memoryInfo
  }

  /**
   * A simple emulator-detection based on the flutter tools detection logic and a couple of legacy
   * detection systems
   */
  private val isEmulator
    get() = ((Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
      || Build.FINGERPRINT.startsWith("generic")
      || Build.FINGERPRINT.startsWith("unknown")
      || Build.HARDWARE.contains("goldfish")
      || Build.HARDWARE.contains("ranchu")
      || Build.MODEL.contains("google_sdk")
      || Build.MODEL.contains("Emulator")
      || Build.MODEL.contains("Android SDK built for x86")
      || Build.MANUFACTURER.contains("Genymotion")
      || Build.PRODUCT.contains("sdk")
      || Build.PRODUCT.contains("vbox86p")
      || Build.PRODUCT.contains("emulator")
      || Build.PRODUCT.contains("simulator"))
}
