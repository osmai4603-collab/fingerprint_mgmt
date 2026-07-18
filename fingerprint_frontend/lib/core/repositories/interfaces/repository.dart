import 'package:dartz/dartz.dart';
import 'package:fingerprint_frontend/core/shared/entities/entity.dart';
import 'package:fingerprint_frontend/core/shared/errors/failure.dart';

abstract class Repository<E extends Entity, Id> {
  Future<Either<Failure, E>> create(E entity);
  Future<Either<Failure, void>> update(E entity);
  Future<Either<Failure, void>> delete(Id id);

  Future<Either<Failure, List<E>>> get();
  Future<Either<Failure, E>> getById(Id id);
}
