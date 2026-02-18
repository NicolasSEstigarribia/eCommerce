import 'package:ecommerce/domain/barrel_domain.dart';

abstract class PostRemoteDataSource {
  Future<List<Post>> getPosts();
}
