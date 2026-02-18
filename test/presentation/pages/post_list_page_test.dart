import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce/core/error/failures.dart';
import 'package:ecommerce/domain/entities/post.dart';
import 'package:ecommerce/domain/repositories/post_repository.dart';
import 'package:ecommerce/presentation/bloc/post/post_bloc.dart';
import 'package:ecommerce/presentation/pages/post_list/post_list_page.dart';
import 'package:ecommerce/presentation/pages/post_list/widgets/post_list_item.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepository;

  const tPosts = [
    Post(id: 1, userId: 1, title: 'First Post', body: 'Body of first post'),
    Post(id: 2, userId: 1, title: 'Second Post', body: 'Body of second post'),
  ];

  setUp(() {
    mockRepository = MockPostRepository();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider(
        create: (_) =>
            PostBloc(repository: mockRepository)..add(const LoadPosts()),
        child: const PostListPage(),
      ),
    );
  }

  group('PostListPage', () {
    testWidgets('shows loading indicator while fetching posts', (tester) async {
      // arrange — use a Completer that never resolves to stay in loading state
      when(
        () => mockRepository.getPosts(),
      ).thenAnswer((_) => Completer<Either<Failure, List<Post>>>().future);
      // act
      await tester.pumpWidget(buildSubject());
      await tester.pump(); // process the LoadPosts event
      // assert — BLoC emits PostLoading, so spinner is visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows list of posts when loaded successfully', (tester) async {
      // arrange
      when(
        () => mockRepository.getPosts(),
      ).thenAnswer((_) async => const Right(tPosts));
      // act
      await tester.pumpWidget(buildSubject());
      await tester.pump(); // trigger BLoC state change
      // assert
      expect(find.byType(PostListItem), findsNWidgets(2));
      expect(find.text('First Post'), findsOneWidget);
      expect(find.text('Second Post'), findsOneWidget);
    });

    testWidgets('shows error view when loading fails', (tester) async {
      // arrange
      when(() => mockRepository.getPosts()).thenAnswer(
        (_) async => const Left(
          // ignore: prefer_const_constructors
          ServerFailure('Network error'),
        ),
      );
      // act
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      // assert
      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows search field in app bar', (tester) async {
      // arrange
      when(
        () => mockRepository.getPosts(),
      ).thenAnswer((_) async => const Right(tPosts));
      // act
      await tester.pumpWidget(buildSubject());
      await tester.pump();
      // assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search posts...'), findsOneWidget);
    });
  });

  group('PostListItem', () {
    testWidgets('shows filled heart icon when post is liked', (tester) async {
      const likedPost = Post(
        id: 1,
        userId: 1,
        title: 'Liked Post',
        body: 'Body',
        isLiked: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostListItem(post: likedPost, onTap: () {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows outline heart icon when post is not liked', (
      tester,
    ) async {
      const unlikedPost = Post(
        id: 1,
        userId: 1,
        title: 'Unliked Post',
        body: 'Body',
        isLiked: false,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostListItem(post: unlikedPost, onTap: () {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });
}
