import 'dart:async';
import 'dart:convert';
import 'dart:io';

// #region agent log
void debugAgentLog(
  String location,
  String message,
  Map<String, dynamic> data, {
  String hypothesisId = '',
  String runId = 'pre-fix',
}) {
  final payload = jsonEncode({
    'sessionId': 'e91091',
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'location': location,
    'message': message,
    'data': data,
    'hypothesisId': hypothesisId,
    'runId': runId,
  });
  try {
    File('/Users/tarunsingh/svar_rework/.cursor/debug-e91091.log').writeAsStringSync(
      '$payload\n',
      mode: FileMode.append,
    );
  } catch (_) {
    unawaited(_postDebugLog(payload));
  }
}

Future<void> _postDebugLog(String payload) async {
  try {
    final client = HttpClient();
    final req = await client.postUrl(Uri.parse(
      'http://127.0.0.1:7869/ingest/5bb2bbb2-3f4c-45b3-8d61-cfcc30071a75',
    ));
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('X-Debug-Session-Id', 'e91091');
    req.write(payload);
    await req.close();
    client.close();
  } catch (_) {}
}
// #endregion
