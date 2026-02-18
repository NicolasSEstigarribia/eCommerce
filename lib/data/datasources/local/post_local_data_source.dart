import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';

abstract class PostLocalDataSource {
  Future<List<int>> getLikedPostIds();
  Future<void> toggleLike(int postId);
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final SharedPreferences sharedPreferences;

  PostLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<int>> getLikedPostIds() async {
    try {
      final stored = sharedPreferences.getStringList(
        AppConstants.likedPostsKey,
      );
      return stored?.map(int.parse).toList() ?? [];
    } catch (_) {
      throw const CacheException('Failed to read liked posts');
    }
  }

  @override
  Future<void> toggleLike(int postId) async {
    try {
      final likedIds = await getLikedPostIds();
      if (likedIds.contains(postId)) {
        likedIds.remove(postId);
      } else {
        likedIds.add(postId);
      }
      await sharedPreferences.setStringList(
        AppConstants.likedPostsKey,
        likedIds.map((id) => id.toString()).toList(),
      );
    } catch (_) {
      throw const CacheException('Failed to toggle like');
    }
  }
}
