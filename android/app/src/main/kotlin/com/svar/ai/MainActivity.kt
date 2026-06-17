package com.svar.ai

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.svar.ai/recording_foreground"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val routeInfo = AudioRoutingHelper.configureForRecording(this)
                        startRecordingForegroundService()
                        result.success(routeInfo)
                    }
                    "stop" -> {
                        AudioRoutingHelper.resetAfterRecording(this)
                        stopRecordingForegroundService()
                        result.success(null)
                    }
                    "getAudioRouteInfo" -> {
                        result.success(AudioRoutingHelper.getAudioRouteInfo(this))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startRecordingForegroundService() {
        val intent = Intent(this, RecordingForegroundService::class.java).apply {
            action = RecordingForegroundService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopRecordingForegroundService() {
        val intent = Intent(this, RecordingForegroundService::class.java).apply {
            action = RecordingForegroundService.ACTION_STOP
        }
        startService(intent)
    }
}
