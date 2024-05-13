package top.jawa0919.paused_secret

import android.app.Activity
import android.os.Build
import android.view.WindowManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PausedSecretPlugin */
class PausedSecretPlugin : FlutterPlugin, ActivityAware, MethodCallHandler, StreamHandler {
    private val TAG = "PausedSecretPlugin"
    private lateinit var mc: MethodChannel
    private lateinit var ec: EventChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        mc = MethodChannel(flutterPluginBinding.binaryMessenger, "paused_secret.MethodChannel")
        mc.setMethodCallHandler(this)
        ec = EventChannel(flutterPluginBinding.binaryMessenger, "paused_secret.EventChannel")
        ec.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        mc.setMethodCallHandler(null)
        ec.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        setup(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        tearDown()
    }

    private var activity: Activity? = null
    private fun setup(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    private fun tearDown() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "disableScreenshot") {
            val disable = call.argument<Boolean>("disable") == true
            activity?.let {
                if (disable) {
                    it.window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE,
                    )
                } else {
                    it.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
            } ?: run {
                result.success("")
            }
        } else if (call.method == "pausedSecret") {
            val secret = call.argument<Boolean>("secret") == true
            activity?.let {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    it.setRecentsScreenshotEnabled(!secret)
                }
            } ?: run {
                result.success("")
            }
        } else {
            result.notImplemented()
        }
    }

    private var eventSink: EventChannel.EventSink? = null
    private var screenshotObserver: ScreenshotObserver? = null
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
        if (arguments == "onScreenshot") {
            activity?.let {
                if (screenshotObserver == null) {
                    screenshotObserver = ScreenshotObserver(it) {
                        this.eventSink?.success(hashMapOf("key" to "onScreenshot"))
                    }
                }
                screenshotObserver?.start()
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        if (arguments == "onScreenshot") {
            screenshotObserver?.stop()
            screenshotObserver = null
        }
        this.eventSink = null
    }
}
