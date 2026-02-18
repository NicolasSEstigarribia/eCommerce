import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/post.dart';
import '../entities/comment.dart';

abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getPosts();
  Future<Either<Failure, List<Comment>>> getComments(int postId);
  Future<Either<Failure, void>> toggleLike(int postId);
}
