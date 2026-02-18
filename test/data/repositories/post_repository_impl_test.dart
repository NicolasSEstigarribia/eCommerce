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

  const tPostModel = Post(
    id: 1,
    userId: 1,
    title: 'Test Title',
    body: 'Test Body',
  );

  final tPostModels = [tPostModel];
  final tLikedIds = [1];
  final tPosts = [tPostModel.copyWith(isLiked: true)];

  group('getPosts', () {
    test(
      'should return posts with correct liked status when call to remote and local are successful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getPosts(),
        ).thenAnswer((_) async => tPostModels);
        when(
          () => mockLocalDataSource.getLikedPostIds(),
        ).thenAnswer((_) async => tLikedIds);
        // act
        final result = await repository.getPosts();
        // assert
        verify(() => mockRemoteDataSource.getPosts());
        verify(() => mockLocalDataSource.getLikedPostIds());
        expect(result.isRight(), isTrue);
        expect(result.getOrElse(() => []), equals(tPosts));
      },
    );

    test(
      'should return ServerFailure when call to remote data source is unsuccessful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getPosts(),
        ).thenThrow(const ServerException());
        // act
        final result = await repository.getPosts();
        // assert
        verify(() => mockRemoteDataSource.getPosts());
        expect(result, equals(const Left(ServerFailure('Server error'))));
      },
    );
  });

  group('toggleLike', () {
    test('should call local data source to toggle like', () async {
      // arrange
      when(
        () => mockLocalDataSource.toggleLike(any()),
      ).thenAnswer((_) async => {});
      // act
      final result = await repository.toggleLike(1);
      // assert
      verify(() => mockLocalDataSource.toggleLike(1));
      expect(result, equals(const Right(null)));
    });

    test('should return CacheFailure when toggle like fails', () async {
      // arrange
      when(
        () => mockLocalDataSource.toggleLike(any()),
      ).thenThrow(const CacheException());
      // act
      final result = await repository.toggleLike(1);
      // assert
      expect(result, equals(const Left(CacheFailure('Cache error'))));
    });
  });
}
