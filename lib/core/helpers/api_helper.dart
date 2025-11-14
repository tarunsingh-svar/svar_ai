import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
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
        onRequest: (options, handler) {
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
  }) async {
    try {
      Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            endpoint,
            data: data,
            queryParameters: query,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            endpoint,
            data: data,
            queryParameters: query,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            endpoint,
            data: data,
            queryParameters: query,
          );
          break;
        default:
          response = await _dio.get(endpoint, queryParameters: query);
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
