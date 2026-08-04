class Env {
  Env._();

  /// Flask AI backend. Override with `--dart-define=API_BASE_URL=...` to point
  /// at a local server (e.g. http://192.168.1.35:5000) without editing source.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://svar-ai-flask.onrender.com',
  );
}
