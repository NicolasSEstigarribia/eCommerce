import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local/post_local_data_source.dart';
import '../datasources/native/comment_native_data_source.dart';
import '../datasources/remote/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;
  final CommentNativeDataSource nativeDataSource;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.nativeDataSource,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      final posts = await remoteDataSource.getPosts();
      final likedIds = await localDataSource.getLikedPostIds();
      final updatedPosts = posts
          .map((post) => post.copyWith(isLiked: likedIds.contains(post.id)))
          .toList();
      return Right(updatedPosts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(int postId) async {
    try {
      final comments = await nativeDataSource.getComments(postId);
      return Right(comments);
    } on PlatformChannelException catch (e) {
      return Left(PlatformFailure(e.message));
    } on PlatformException catch (e) {
      return Left(PlatformFailure(e.message ?? 'Unknown platform error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(int postId) async {
    try {
      await localDataSource.toggleLike(postId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
