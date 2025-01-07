package ggomdol.pedometer

import android.annotation.SuppressLint
import android.app.Activity
import androidx.annotation.NonNull
import ggomdol.lib.pedometer.PedometerLib
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** PedometerPlugin */
class PedometerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var stepCountMethodCannel: MethodChannel
    private var activity: Activity? =  null

    companion object {
        private val TAG = "PedometerPlugin"

        private val method_channel_pedometer_step_count = "pedometer_step_count"
        private val method_channel_pedometer_on = "pedometer_on"
        private val method_channel_pedometer_off = "pedometer_off"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        stepCountMethodCannel = MethodChannel(flutterPluginBinding.binaryMessenger, "ggomdol.pedometer/PedometerPlugin");
        stepCountMethodCannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            method_channel_pedometer_step_count -> readStepCount()
            method_channel_pedometer_on -> subscribe()
            method_channel_pedometer_off -> unSubscribe()
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        stepCountMethodCannel.setMethodCallHandler(null)
    }

    private fun readStepCount() {
        PedometerLib.readStepCountBridge(activity, object: PedometerLib.OnResult{
            override fun onSuccess(dateAndSteps: Map<String, Int>) {
                stepCountMethodCannel.invokeMethod(method_channel_pedometer_step_count, dateAndSteps)
            }
        })
    }

    @SuppressLint("MissingPermission")
    private fun subscribe() = PedometerLib.subscribeBridge(activity)
    private fun unSubscribe() = PedometerLib.unSubscribeBridge(activity)

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onDetachedFromActivity() {}
}
