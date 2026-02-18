import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await dio.get('${AppConstants.baseUrl}/posts');
      return (response.data as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.statusCode != null
            ? 'Server responded with ${e.response!.statusCode}'
            : 'Network error: ${e.message}',
      );
    }
  }
}
