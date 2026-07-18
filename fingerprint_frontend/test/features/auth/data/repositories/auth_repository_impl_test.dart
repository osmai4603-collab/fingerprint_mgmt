import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/auth_repository_impl.dart';
import 'package:fingerprint_frontend/features/auth/domain/entities/auth_user_info.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockResponse extends Mock implements Response {}

void main() {
  late ApiClient mockApiClient;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = AuthRepositoryImpl(mockApiClient);
  });

  group('login', () {
    final loginData = {
      'message': 'Login successful',
      'accessToken': 'test-token-uuid',
      'refreshToken': 'refresh-token-uuid',
      'user': {
        'id': 1,
        'username': 'admin',
        'role': 'admin',
      },
    };

    test('returns AuthUserInfo on successful login', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn(loginData);
      when(() => mockApiClient.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenAnswer((_) async => response);
      final result = await repository.login('admin', 'admin123');

      expect(result, isA<Right<Failure, AuthUserInfo>>());
      result.fold(
        (_) => fail('Expected Right'),
        (user) {
          expect(user.id, 1);
          expect(user.username, 'admin');
          expect(user.role.name, 'admin');
          expect(user.token, 'test-token-uuid');
        },
      );
    });

    test('returns ServerFailure on 403 Forbidden', () async {
      when(() => mockApiClient.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 403,
            data: {'error': 'Invalid credentials or inactive account'},
          ),
        ),
      );

      final result = await repository.login('wrong', 'wrong');

      expect(result, isA<Left<Failure, AuthUserInfo>>());
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (_) => fail('Expected Left'),
      );
    });

    test('returns ServerFailure on DioException without statusCode', () async {
      when(() => mockApiClient.post(
            '/auth/login',
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      );

      final result = await repository.login('admin', 'admin123');

      expect(result, isA<Left<Failure, AuthUserInfo>>());
    });
  });

  group('logout', () {
    test('calls logout endpoint', () async {
      when(() => mockApiClient.post('/auth/logout'))
          .thenAnswer((_) async => MockResponse());

      final result = await repository.logout();

      expect(result, const Right<Failure, void>(null));
      verify(() => mockApiClient.post('/auth/logout')).called(1);
    });

    test('still succeeds even if logout endpoint fails', () async {
      when(() => mockApiClient.post('/auth/logout'))
          .thenThrow(Exception('Network error'));

      final result = await repository.logout();

      expect(result, const Right<Failure, void>(null));
    });
  });

}
