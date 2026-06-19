import 'dart:io';

import 'package:flutter/services.dart';

class RecordingForeground {
  static const _channel = MethodChannel('com.svar.ai/recording_foreground');

  static Future<void> start() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('start');
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {}
  }
}
