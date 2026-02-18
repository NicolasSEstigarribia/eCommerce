/// Thrown by [PostRemoteDataSource] when the API call fails.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error']);
}

/// Thrown by [PostLocalDataSource] when a cache operation fails.
class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}

/// Thrown by [CommentNativeDataSource] when the platform channel fails.
class PlatformChannelException implements Exception {
  final String message;
  const PlatformChannelException([this.message = 'Platform error']);
}
