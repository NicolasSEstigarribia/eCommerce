import 'package:dartz/dartz.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/core/error/failures.dart';
import 'package:ecommerce/data/repositories/post_repository_impl.dart';
import 'package:ecommerce/domain/barrel_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock implements PostRemoteDataSource {}

class MockLocalDataSource extends Mock implements PostLocalDataSource {}

class MockNativeDataSource extends Mock implements CommentNativeDataSource {}

void main() {
  late PostRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNativeDataSource mockNativeDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNativeDataSource = MockNativeDataSource();
    repository = PostRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      nativeDataSource: mockNativeDataSource,
    );
  });

  const tPost = Post(id: 1, userId: 1, title: 'Test Title', body: 'Test Body');
  final tPosts = [tPost];
  final tLikedIds = [1];
  final tPostsLiked = [tPost.copyWith(isLiked: true)];

  group('getPosts', () {
    test(
      'should return posts with correct liked status when remote and local succeed',
      () async {
        when(
          () => mockRemoteDataSource.getPosts(),
        ).thenAnswer((_) async => tPosts);
        when(
          () => mockLocalDataSource.getLikedPostIds(),
        ).thenAnswer((_) async => tLikedIds);

        final result = await repository.getPosts();

        verify(() => mockRemoteDataSource.getPosts());
        verify(() => mockLocalDataSource.getLikedPostIds());
        expect(result.isRight(), isTrue);
        expect(result.getOrElse(() => []), equals(tPostsLiked));
      },
    );

    test(
      'should return ServerFailure when remote data source throws ServerException',
      () async {
        when(
          () => mockRemoteDataSource.getPosts(),
        ).thenThrow(const ServerException());

        final result = await repository.getPosts(retries: 0);

        verify(() => mockRemoteDataSource.getPosts());
        expect(result, equals(const Left(ServerFailure('Server error'))));
      },
    );
  });

  group('toggleLike', () {
    test('should return Right(null) when toggle like succeeds', () async {
      when(
        () => mockLocalDataSource.toggleLike(any()),
      ).thenAnswer((_) async => {});

      final result = await repository.toggleLike(1);

      verify(() => mockLocalDataSource.toggleLike(1));
      expect(result, equals(const Right(null)));
    });

    test(
      'should return CacheFailure when toggle like throws CacheException',
      () async {
        when(
          () => mockLocalDataSource.toggleLike(any()),
        ).thenThrow(const CacheException());

        final result = await repository.toggleLike(1);

        expect(result, equals(const Left(CacheFailure('Cache error'))));
      },
    );
  });
}
