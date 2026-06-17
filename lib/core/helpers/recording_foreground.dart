import 'dart:io';

import 'package:flutter/services.dart';

import 'debug_agent_log.dart';

class RecordingForeground {
  static const _channel = MethodChannel('com.svar.ai/recording_foreground');

  static Future<void> start() async {
    if (!Platform.isAndroid) return;
    try {
      final routeInfo = await _channel.invokeMethod<Map>('start');
      // #region agent log
      debugAgentLog(
        'recording_foreground.dart:start',
        'audio route configured',
        {
          'routeInfo': routeInfo?.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        },
        hypothesisId: 'K',
        runId: 'post-fix-3',
      );
      // #endregion
    } catch (e) {
      // #region agent log
      debugAgentLog(
        'recording_foreground.dart:start',
        'audio route configure failed',
        {'error': e.toString()},
        hypothesisId: 'K',
        runId: 'post-fix-3',
      );
      // #endregion
    }
  }

  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {}
  }
}
