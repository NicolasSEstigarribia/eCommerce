abstract class PostLocalDataSource {
  Future<List<int>> getLikedPostIds();
  Future<void> toggleLike(int postId);
}
