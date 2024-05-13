package top.jawa0919.paused_secret

import android.Manifest
import android.app.Activity
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.PermissionChecker

class ScreenshotObserver(
    private var activity: Activity,
    private var onScreenshot: () -> Unit,
) : ContentObserver(Handler(Looper.getMainLooper())) {
    private val TAG = "ScreenshotObserver"
    private lateinit var callback: Activity.ScreenCaptureCallback
    private var isRun = false

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            callback = Activity.ScreenCaptureCallback { if (isRun) onScreenshot() }
        }
    }

    fun start() {
        isRun = true
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Log.d(TAG, "start: registerScreenCaptureCallback")
            activity.registerScreenCaptureCallback(activity.mainExecutor, callback)
        } else {
            Log.d(TAG, "start: registerContentObserver")
            activity.contentResolver.registerContentObserver(uriEx, true, this)
        }
    }

    fun stop() {
        isRun = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Log.d(TAG, "stop: unregisterScreenCaptureCallback")
            activity.unregisterScreenCaptureCallback(callback)
        } else {
            Log.d(TAG, "stop: unregisterContentObserver")
            activity.contentResolver.unregisterContentObserver(this)
        }
    }

    private val uriEx = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
    private val uriChangeSet = hashSetOf<Uri>()

    override fun onChange(selfChange: Boolean, uri: Uri?, flags: Int) {
        Log.d(TAG, "onChange: $selfChange $uri $flags")
        if (uri == null) return
        if (uri == uriEx) return
        if (!isHavePermission()) return
        if (uriChangeSet.contains(uri)) return
        uriChangeSet.add(uri)
        val path = findUriData(activity, uri)
        if (path.isEmpty()) return
        Log.d(TAG, "onChange path: $path")
        if (isScreenshotPath(path)) {
            if (isRun) onScreenshot()
        }
    }

    private fun isHavePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val status = ActivityCompat.checkSelfPermission(
                activity,
                Manifest.permission.READ_MEDIA_IMAGES,
            )
            status == PermissionChecker.PERMISSION_GRANTED
        } else {
            val status = ActivityCompat.checkSelfPermission(
                activity,
                Manifest.permission.READ_EXTERNAL_STORAGE,
            )
            status == PermissionChecker.PERMISSION_GRANTED
        }
    }

    private fun findUriData(context: Activity, uri: Uri): String {
        var cursor: Cursor? = null
        try {
            cursor = context.contentResolver.query(
                uri, arrayOf(MediaStore.Images.ImageColumns.DATA), null, null, null
            )
            if (cursor != null && cursor.moveToFirst()) {
                return cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.ImageColumns.DATA))
            }
        } catch (exception: Exception) {
            Log.e(TAG, "getDataColumn: ", exception)
        } finally {
            cursor?.close()
        }
        return ""
    }

    private fun isScreenshotPath(path: String): Boolean {
        path.lowercase().let {
            val nameList = arrayOf(
                "screenshot",
                "screen_shot",
                "screen-shot",
                "screen shot",
                "screencapture",
                "screen_capture",
                "screen-capture",
                "screen capture",
                "screencap",
                "screen_cap",
                "screen-cap",
                "screen cap",
                "snap",
                "截屏"
            )
            for (name in nameList) {
                if (it.contains(name)) {
                    return true
                }
            }
            return false
        }
    }
}