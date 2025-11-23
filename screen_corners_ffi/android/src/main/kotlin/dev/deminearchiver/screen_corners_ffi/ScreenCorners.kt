package dev.deminearchiver.screen_corners_ffi

import android.app.Activity
import android.os.Build
import android.view.RoundedCorner
import androidx.annotation.Keep

@Keep
data class ScreenCorners(
  val topLeft: Double? = null,
  val topRight: Double? = null,
  val bottomLeft: Double? = null,
  val bottomRight: Double? = null,
) {
  @Keep
  companion object {
    @JvmStatic
    fun fromActivity(activity: Activity): ScreenCorners {
      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
        return ScreenCorners()
      }
      val view = activity.window.decorView.rootView
      val insets = view.rootWindowInsets
      val topLeft = insets?.getRoundedCorner(RoundedCorner.POSITION_TOP_LEFT)?.radius?.toDouble()
      val topRight = insets?.getRoundedCorner(RoundedCorner.POSITION_TOP_RIGHT)?.radius?.toDouble()
      val bottomLeft = insets?.getRoundedCorner(RoundedCorner.POSITION_BOTTOM_LEFT)?.radius?.toDouble()
      val bottomRight = insets?.getRoundedCorner(RoundedCorner.POSITION_BOTTOM_RIGHT)?.radius?.toDouble()
      return ScreenCorners(
        topLeft = topLeft,
        topRight = topRight,
        bottomLeft = bottomLeft,
        bottomRight = bottomRight,
      )
    }
  }
}
