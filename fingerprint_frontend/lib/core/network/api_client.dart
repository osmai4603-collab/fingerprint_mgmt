import 'package:dio/dio.dart';
import 'package:fingerprint_frontend/core/services/debug_fingerprint.dart';
import '../services/user_session.dart';

class ApiClient {
  final Dio _dio;
  final UserSession _userSession;
  final String _baseUrl = 'http://localhost:8000';

  ApiClient(this._dio, this._userSession) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.followRedirects = true;
    _dio.options.maxRedirects = 5;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _userSession.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 307 redirects manually for requests with bodies
          if (e.response?.statusCode == 307) {
            final redirectUrl = e.response?.headers.value('location');
            if (redirectUrl != null) {
              try {
                final opts = e.requestOptions;
                final redirectResponse = await _dio.request(
                  redirectUrl,
                  options: Options(method: opts.method, headers: opts.headers),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(redirectResponse);
              } catch (_) {
                // Fall through to default error handling
              }
            }
          }

          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('/auth/login') &&
              !e.requestOptions.path.contains('/auth/refresh')) {
            final refreshToken = _userSession.refreshToken;
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
                final response = await refreshDio.post(
                  '/api/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['token'];
                  final newRefreshToken = response.data['refreshToken'];

                  _userSession.updateTokens(newAccessToken, newRefreshToken);

                  // Retry the original request
                  final opts = e.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';

                  final retryResponse = await _dio.request(
                    opts.path,
                    options: Options(
                      method: opts.method,
                      headers: opts.headers,
                    ),
                    data: opts.data,
                    queryParameters: opts.queryParameters,
                  );
                  return handler.resolve(retryResponse);
                }
              } catch (refreshError) {
                // Refresh failed, clear tokens so user can login again
                _userSession.clearSession();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>?> createPost({
    required String endPoint,
    required Map<String, dynamic> data,
  }) async {
    logPrint(title: 'CREATE POST: ', data: data);
    final response = await _dio.post<Map<String, dynamic>>(
      endPoint,
      data: data,
    );
    logPrint(title: 'Result Post: ', data: response.data ?? {});
    return response.data;
  }

  Future<Map<String, dynamic>?> updatePost({
    required String endPoint,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      endPoint,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(endpoint, queryParameters: queryParameters);
  }

  Future<List<Map<String, dynamic>>> getPosts(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    logPrint(title: 'GetPosts: $endpoint', data: {});
    final result = await _dio.get<List<dynamic>>(
      endpoint,
      queryParameters: queryParameters,
    );
    final map = (result.data ?? [])
        .map((data) => data as Map<String, dynamic>)
        .toList();
    logsPrints(title: 'Result Of $endpoint, Length: ${map.length}', list: map);
    return map;
  }

  Future<Map<String, dynamic>?> getSinglePost(String endpoint) async {
    final result = await _dio.get<Map<String, dynamic>>(endpoint);
    return result.data;
  }

  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<void> deletePost({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    await _dio.delete(endPoint, queryParameters: queryParameters);
  }

  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }
}
