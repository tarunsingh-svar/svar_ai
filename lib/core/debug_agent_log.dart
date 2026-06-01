import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

// #region agent log
const _debugLogPath =
    '/Users/tarunsingh/svar_rework/.cursor/debug-c9760c.log';
const _ingestUrl =
    'http://127.0.0.1:7869/ingest/5bb2bbb2-3f4c-45b3-8d61-cfcc30071a75';

final _ingestDio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
  ),
);

void agentDebugLog({
  required String location,
  required String message,
  required String hypothesisId,
  Map<String, dynamic>? data,
  String runId = 'pre-fix',
}) {
  final payload = <String, dynamic>{
    'sessionId': 'c9760c',
    'runId': runId,
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data ?? <String, dynamic>{},
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  try {
    File(_debugLogPath).writeAsStringSync(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
    );
  } catch (_) {}

  Future.microtask(() async {
    try {
      await _ingestDio.post(
        _ingestUrl,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': 'c9760c',
          },
        ),
      );
    } catch (_) {}
  });
}
// #endregion
