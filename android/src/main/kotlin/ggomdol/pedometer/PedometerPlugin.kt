package ggomdol.pedometer

import android.annotation.SuppressLint
import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.fitness.FitnessLocal
import com.google.android.gms.fitness.data.LocalDataType
import com.google.android.gms.fitness.request.LocalDataReadRequest
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.concurrent.TimeUnit

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
        val endTime = LocalDateTime.now().atZone(ZoneId.systemDefault())
        val startTime = endTime.minusDays(7).withHour(0).withMinute(0).withSecond(0)
        val readRequest = LocalDataReadRequest.Builder()
                .aggregate(LocalDataType.TYPE_STEP_COUNT_DELTA)
                .bucketByTime(1, TimeUnit.DAYS)
                .setTimeRange(startTime.toEpochSecond(), endTime.toEpochSecond(), TimeUnit.SECONDS)
                .build()

        activity?.let {
            FitnessLocal.getLocalRecordingClient(it).readData(readRequest)
                .addOnSuccessListener { response ->
                    val resultArray = mutableMapOf<String, Int>();

                    for (dataSet in response.buckets.flatMap { it.dataSets }) {
                        for (dp in dataSet.dataPoints) {
                            val time = Instant.ofEpochMilli(dp.getStartTime(TimeUnit.MILLISECONDS)).atZone(ZoneId.systemDefault()).toLocalDateTime()
                            val timeText = DateTimeFormatter.ofPattern("yyyy-MM-dd").format(time)

                            for (field in dp.dataType.fields) {
                                val stepCount = dp.getValue((field)).asInt()
                                resultArray[timeText] = stepCount
                            }
                        }
                    }

                    stepCountMethodCannel.invokeMethod(
                        method_channel_pedometer_step_count,
                        resultArray
                    )
                }
                .addOnFailureListener { e ->
                    Log.w(TAG, "There was an error reading data", e)
                }
        }
    }

    @SuppressLint("MissingPermission")
    private fun subscribe() {
        activity?.let {
            FitnessLocal.getLocalRecordingClient(it).subscribe(LocalDataType.TYPE_STEP_COUNT_DELTA)
                .addOnSuccessListener { Log.d(TAG, "succeed subscribe") }
                .addOnFailureListener { e -> Log.e(TAG, "failed subscribe : ${e.message}") }
        }
    }

    private fun unSubscribe() {
        activity?.let {
            FitnessLocal.getLocalRecordingClient(it).unsubscribe(LocalDataType.TYPE_STEP_COUNT_DELTA)
                .addOnSuccessListener { Log.d(TAG, "succeed unSubscribe") }
                .addOnFailureListener { e -> Log.e(TAG, "failed unSubscribe : ${e.message}") }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onDetachedFromActivity() {}
}
