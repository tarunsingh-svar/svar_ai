package com.svar.ai

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build

object AudioRoutingHelper {
    fun configureForRecording(context: Context): Map<String, Any?> {
        val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        am.mode = AudioManager.MODE_IN_COMMUNICATION

        var bluetoothScoStarted = false
        if (am.isBluetoothScoAvailableOffCall) {
            try {
                am.startBluetoothSco()
                am.isBluetoothScoOn = true
                bluetoothScoStarted = true
            } catch (_: Exception) {
                bluetoothScoStarted = false
            }
        }

        val info = getAudioRouteInfo(context).toMutableMap()
        info["bluetoothScoStarted"] = bluetoothScoStarted
        return info
    }

    fun resetAfterRecording(context: Context) {
        val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        try {
            am.stopBluetoothSco()
            am.isBluetoothScoOn = false
        } catch (_: Exception) {
        }
        am.mode = AudioManager.MODE_NORMAL
        am.isSpeakerphoneOn = false
    }

    fun getAudioRouteInfo(context: Context): Map<String, Any?> {
        val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val info = mutableMapOf<String, Any?>(
            "mode" to am.mode,
            "bluetoothScoOn" to am.isBluetoothScoOn,
            "speakerphoneOn" to am.isSpeakerphoneOn,
            "wiredHeadsetOn" to am.isWiredHeadsetOn,
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val inputs = am.getDevices(AudioManager.GET_DEVICES_INPUTS)
            info["inputDevices"] = inputs.map { device ->
                mapOf(
                    "type" to deviceTypeName(device.type),
                    "productName" to device.productName?.toString(),
                )
            }
        }

        return info
    }

    private fun deviceTypeName(type: Int): String = when (type) {
        AudioDeviceInfo.TYPE_BUILTIN_MIC -> "builtin_mic"
        AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> "bluetooth_sco"
        AudioDeviceInfo.TYPE_WIRED_HEADSET -> "wired_headset"
        AudioDeviceInfo.TYPE_USB_HEADSET -> "usb_headset"
        AudioDeviceInfo.TYPE_USB_DEVICE -> "usb_device"
        AudioDeviceInfo.TYPE_BLE_HEADSET -> "ble_headset"
        else -> "type_$type"
    }
}
