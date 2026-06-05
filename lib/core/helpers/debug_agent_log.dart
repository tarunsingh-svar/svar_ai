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
  try {
    final payload = jsonEncode({
      'sessionId': '9f5357',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'location': location,
      'message': message,
      'data': data,
      'hypothesisId': hypothesisId,
      'runId': runId,
    });
    File('/Users/tarunsingh/svar_rework/.cursor/debug-9f5357.log').writeAsStringSync(
      '$payload\n',
      mode: FileMode.append,
    );
  } catch (_) {}
}
// #endregion
