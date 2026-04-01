import 'package:dio/dio.dart';

/// Result wrapper — every API call returns [DoResult<T>].
sealed class DoResult<T> {
  const DoResult();
}

/// Successful response.
final class DoSuccess<T> extends DoResult<T> {
  const DoSuccess(this.data);
  final T data;
}

/// Failed response with [message] and optional [statusCode].
final class DoError<T> extends DoResult<T> {
  const DoError(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

/// Dio-based HTTP client — configure once, use everywhere.
///
/// Setup:
/// ```dart
/// Do.api.baseUrl = 'https://api.example.com';
/// Do.api.headers['Authorization'] = 'Bearer $token';
/// ```
///
/// Usage:
/// ```dart
/// final result = await Do.api.get<Map>('/users/1');
/// switch (result) {
///   case DoSuccess(:final data) => print(data),
///   case DoError(:final message) => print(message),
/// }
/// ```
class DoApi {
  DoApi({String? baseUrl, Map<String, dynamic>? headers}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      headers: headers ?? {},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  late final Dio _dio;

  /// Update base URL after construction.
  set baseUrl(String url) => _dio.options.baseUrl = url;

  /// Access/modify default headers.
  Map<String, dynamic> get headers => _dio.options.headers;

  /// Add a Dio interceptor (e.g. for logging, auth refresh).
  void addInterceptor(Interceptor interceptor) =>
      _dio.interceptors.add(interceptor);

  /// GET request.
  Future<DoResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic)? fromJson,
  }) =>
      _request<T>(() => _dio.get(path, queryParameters: query),
          fromJson: fromJson);

  /// POST request.
  Future<DoResult<T>> post<T>(
    String path, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) =>
      _request<T>(() => _dio.post(path, data: body), fromJson: fromJson);

  /// PUT request.
  Future<DoResult<T>> put<T>(
    String path, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) =>
      _request<T>(() => _dio.put(path, data: body), fromJson: fromJson);

  /// PATCH request.
  Future<DoResult<T>> patch<T>(
    String path, {
    Object? body,
    T Function(dynamic)? fromJson,
  }) =>
      _request<T>(() => _dio.patch(path, data: body), fromJson: fromJson);

  /// DELETE request.
  Future<DoResult<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromJson,
  }) =>
      _request<T>(() => _dio.delete(path), fromJson: fromJson);

  Future<DoResult<T>> _request<T>(
    Future<Response> Function() call, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await call();
      final raw = response.data;
      final data = fromJson != null ? fromJson(raw) : raw as T;
      return DoSuccess<T>(data);
    } on DioException catch (e) {
      return DoError<T>(
        e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return DoError<T>(e.toString());
    }
  }
}
