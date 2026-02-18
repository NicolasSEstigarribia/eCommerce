abstract class AppConstants {
  // MethodChannel name — must match Android (Kotlin) and iOS (Swift)
  static const String commentsChannel = 'com.example.ecommerce/comments';
  static const String getCommentsMethod = 'getComments';

  // API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // SharedPreferences keys
  static const String likedPostsKey = 'LIKED_POSTS';
}
