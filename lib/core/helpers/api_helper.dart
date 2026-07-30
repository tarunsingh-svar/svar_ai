import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/env.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    lineLength: 150,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

class ApiHelper {
  late final Dio _dio;

  ApiHelper() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Every endpoint except the health check requires the caller's
          // Supabase access token. Refresh first if it is close to expiring,
          // otherwise a long recording can finish uploading against a token
          // that expired mid-flight.
          final token = await _accessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          logger.i(
            '➡️ REQUEST\n'
            'URL: ${options.baseUrl}${options.path}\n'
            'Method: ${options.method}\n'
            'Query: ${options.queryParameters}\n'
            'Data: ${options.data}',
          );
          options.extra['startTime'] = DateTime.now();
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final start = response.requestOptions.extra['startTime'] as DateTime?;
          final duration = start != null
              ? DateTime.now().difference(start)
              : null;

          logger.i(
            '✅ RESPONSE\n'
            'Status: ${response.statusCode}\n'
            'Time: ${duration?.inMilliseconds} ms\n'
            'Data: ${response.data}',
          );

          return handler.next(response);
        },
        onError: (e, handler) {
          final req = e.requestOptions;
          final start = req.extra['startTime'] as DateTime?;
          final dur = start != null ? DateTime.now().difference(start) : null;

          logger.e(
            '❌ ERROR\n '
            'URL: ${req.baseUrl}${req.path}\n'
            'Status: ${e.response?.statusCode}\n'
            'Time: ${dur?.inMilliseconds} ms\n'
            'Error: ${e.message}\n'
            'Response: ${e.response?.data}',
          );

          return handler.next(e);
        },
      ),
    );
  }

  static Future<String?> _accessToken() async {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    if (session == null) return null;

    final expiresAt = session.expiresAt;
    final expiringSoon = expiresAt != null &&
        DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
                .difference(DateTime.now())
                .inSeconds <
            60;

    if (session.isExpired || expiringSoon) {
      try {
        final refreshed = await auth.refreshSession();
        return refreshed.session?.accessToken ?? session.accessToken;
      } catch (e) {
        logger.e('Token refresh failed: $e');
      }
    }

    return session.accessToken;
  }

  void _logRequest(RequestOptions options) {
    final isFormData = options.data is FormData;
    dynamic dataLog;

    if (isFormData) {
      final form = options.data as FormData;

      List<String> fields = form.fields
          .map((f) => "📝 ${f.key}: ${f.value}")
          .toList();

      List<String> files = form.files
          .map((f) => "📎 ${f.key}: ${f.value.filename}")
          .toList();

      dataLog = [
        if (fields.isNotEmpty) "Fields:\n${fields.join("\n")}",
        if (files.isNotEmpty) "Files:\n${files.join("\n")}",
      ].where((e) => e.isNotEmpty).join("\n");
    } else {
      dataLog = options.data;
    }

    logger.i("""
    📤 HTTP REQUEST
    ➡️ URL: ${options.uri}
    ➡️ Method: ${options.method}
    ➡️ Query: ${options.queryParameters}
    ➡️ Data:
    $dataLog
    """);
  }

  Future<Response?> sendRequest({
    required String endpoint,
    Map<String, dynamic>? query,
    dynamic data, // ✅ Accepts FormData too
    String method = 'GET',
    Duration? receiveTimeout,
  }) async {
    try {
      Response response;
      final options = receiveTimeout == null
          ? null
          : Options(
              sendTimeout: receiveTimeout,
              receiveTimeout: receiveTimeout,
            );

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            endpoint,
            data: data,
            queryParameters: query,
            options: options,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            endpoint,
            data: data,
            queryParameters: query,
            options: options,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            endpoint,
            data: data,
            queryParameters: query,
            options: options,
          );
          break;
        default:
          response = await _dio.get(
            endpoint,
            queryParameters: query,
            options: options,
          );
      }

      return response;
    } on DioException catch (e) {
      logger.e("Dio Error -> ${e.message}");
      return e.response;
    } catch (e) {
      logger.e("Other Error -> $e");
      return null;
    }
  }
}
