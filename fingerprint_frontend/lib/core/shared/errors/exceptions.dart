/// Shared exceptions for server/local/database/not found errors.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class LocalDatabaseException implements Exception {
  final String message;
  const LocalDatabaseException(this.message);

  @override
  String toString() => 'LocalDatabaseException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}
