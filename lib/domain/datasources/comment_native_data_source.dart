import 'package:ecommerce/domain/barrel_domain.dart';

abstract class CommentNativeDataSource {
  Future<List<Comment>> getComments(int postId);
}
