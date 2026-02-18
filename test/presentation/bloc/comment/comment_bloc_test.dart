import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce/core/error/failures.dart';
import 'package:ecommerce/domain/entities/comment.dart';
import 'package:ecommerce/domain/repositories/post_repository.dart';
import 'package:ecommerce/presentation/bloc/comment/comment_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late CommentBloc bloc;
  late MockPostRepository mockPostRepository;

  setUp(() {
    mockPostRepository = MockPostRepository();
    bloc = CommentBloc(repository: mockPostRepository);
  });

  tearDown(() {
    bloc.close();
  });

  const tComments = [
    Comment(
      id: 1,
      postId: 1,
      name: 'Name 1',
      email: 'email1@test.com',
      body: 'Body 1',
    ),
  ];

  group('CommentBloc', () {
    test('initial state should be CommentInitial', () {
      expect(bloc.state, equals(const CommentInitial()));
    });

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentLoading, CommentLoaded] when LoadComments is added and repository returns success',
      build: () {
        when(
          () => mockPostRepository.getComments(any()),
        ).thenAnswer((_) async => const Right(tComments));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadComments(1)),
      expect: () => [const CommentLoading(), const CommentLoaded(tComments)],
      verify: (_) {
        verify(() => mockPostRepository.getComments(1)).called(1);
      },
    );

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentLoading, CommentError] when LoadComments is added and repository returns failure',
      build: () {
        when(() => mockPostRepository.getComments(any())).thenAnswer(
          (_) async => const Left(PlatformFailure('Platform error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadComments(1)),
      expect: () => [
        const CommentLoading(),
        const CommentError('Platform error'),
      ],
    );
  });
}
