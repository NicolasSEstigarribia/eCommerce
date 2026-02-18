import 'package:dio/dio.dart';
import 'package:ecommerce/core/barrel_core.dart';
import 'package:ecommerce/data/models/post_model.dart';
import 'package:ecommerce/domain/barrel_domain.dart';

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Post>> getPosts() async {
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
