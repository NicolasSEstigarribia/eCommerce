import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce/core/error/failures.dart';
import 'package:ecommerce/domain/entities/post.dart';
import 'package:ecommerce/domain/repositories/post_repository.dart';
import 'package:ecommerce/presentation/bloc/post/post_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late PostBloc bloc;
  late MockPostRepository mockPostRepository;

  setUp(() {
    mockPostRepository = MockPostRepository();
    bloc = PostBloc(repository: mockPostRepository);
  });

  tearDown(() {
    bloc.close();
  });

  const tPosts = [
    Post(id: 1, userId: 1, title: 'Title 1', body: 'Body 1'),
    Post(id: 2, userId: 1, title: 'Title 2', body: 'Body 2'),
  ];

  group('PostBloc', () {
    test('initial state should be PostInitial', () {
      expect(bloc.state, equals(const PostInitial()));
    });

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostLoaded] when LoadPosts is added and repository returns success',
      build: () {
        when(
          () => mockPostRepository.getPosts(),
        ).thenAnswer((_) async => const Right(tPosts));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPosts()),
      expect: () => [const PostLoading(), PostLoaded.initial(tPosts)],
      verify: (_) {
        verify(() => mockPostRepository.getPosts()).called(1);
      },
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostError] when LoadPosts is added and repository returns failure',
      build: () {
        when(
          () => mockPostRepository.getPosts(),
        ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadPosts()),
      expect: () => [const PostLoading(), const PostError('Server error')],
    );

    blocTest<PostBloc, PostState>(
      'should emit PostLoaded with filtered posts when SearchPosts is added',
      build: () => bloc,
      seed: () => PostLoaded.initial(tPosts),
      act: (bloc) => bloc.add(const SearchPosts('1')),
      expect: () => [
        PostLoaded(posts: tPosts, filteredPosts: [tPosts[0]]),
      ],
    );

    blocTest<PostBloc, PostState>(
      'should emit PostLoaded with updated like when ToggleLikePost is added and repository returns success',
      build: () {
        when(
          () => mockPostRepository.toggleLike(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => PostLoaded.initial(tPosts),
      act: (bloc) => bloc.add(const ToggleLikePost(1)),
      expect: () => [PostLoaded.initial(tPosts).copyWithUpdatedLike(1)],
    );
  });
}
