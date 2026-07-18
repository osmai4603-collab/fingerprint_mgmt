import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';

class BiometricDevicesRepositoryImpl implements BiometricDevicesRepository {
  final ApiClient _apiClient;

  BiometricDevicesRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<BiometricDeviceEntity>>> get() async {
    try {
      final list = await _apiClient.getPosts(ApiEndpoints.devices);
      final devices = list.map((e) => BiometricDeviceModel.fromMap(e)).toList();
      return Right(devices);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, BiometricDeviceEntity>> create(
    BiometricDeviceEntity entity,
  ) async {
    try {
      final data = await _apiClient.createPost(
        endPoint: ApiEndpoints.devices,
        data: BiometricDeviceModel.fromEntity(entity).toMap(removeId: true),
      );
      if (data == null) {
        throw Exception('Data Can Not Be Null to Create Post.');
      }
      return Right(BiometricDeviceModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(BiometricDeviceEntity entity) async {
    try {
      await _apiClient.updatePost(
        endPoint: ApiEndpoints.device(entity.id),
        data: BiometricDeviceModel.fromEntity(entity).toMap(removeId: true),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await _apiClient.deletePost(endPoint: ApiEndpoints.device(id));
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> pingDevice(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.deviceStatus(id));
      final data = response.data as Map<String, dynamic>;
      return Right(data['is_online'] as bool? ?? false);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DeviceUser>>> getDeviceUsers(int deviceId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.deviceUsers(deviceId));
      final list = response.data as List<dynamic>;
      final users = list
          .map((e) => DeviceUser.fromMap(e as Map<String, dynamic>))
          .toList();
      return Right(users);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setDeviceUser(
    int deviceId,
    DeviceUser user,
  ) async {
    try {
      await _apiClient.post(
        ApiEndpoints.deviceUsers(deviceId),
        data: user.toMap(),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeviceUser(
    int deviceId,
    int uid,
    String userId,
  ) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.deviceUserDelete(deviceId, uid),
        queryParameters: {'user_id': userId},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DeviceFingerprint>>> getDeviceTemplates(
    int deviceId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.deviceTemplates(deviceId),
      );
      final list = response.data as List<dynamic>;
      final templates = list
          .map((e) => DeviceFingerprint.fromMap(e as Map<String, dynamic>))
          .toList();
      return Right(templates);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDeviceTemplates(
    int deviceId,
    DeviceUser user,
    List<DeviceFingerprint> templates,
  ) async {
    try {
      await _apiClient.post(
        ApiEndpoints.deviceTemplates(deviceId),
        data: {
          'user': user.toMap(),
          'templates': templates.map((t) => t.toMap()).toList(),
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeviceTemplate(
    int deviceId,
    int uid,
    int tempId,
    String userId,
  ) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.deviceTemplateDelete(deviceId, uid),
        queryParameters: {'temp_id': tempId, 'user_id': userId},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, dynamic>> executeDeviceCommand(
    int deviceId,
    String command, [
    Map<String, dynamic>? kwargs,
  ]) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.deviceCommand(deviceId),
        data: {
          'command': command,
          if (kwargs != null && kwargs.isNotEmpty) 'kwargs': kwargs,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Right(data['result']);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, BiometricDeviceEntity>> getById(int id) async {
    try {
      final data = await _apiClient.getSinglePost(ApiEndpoints.devices);
      if (data == null) {
        throw Exception('No Biometric Device By Id: $id');
      }
      return Right(BiometricDeviceModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
