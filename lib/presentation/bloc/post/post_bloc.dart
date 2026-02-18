import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/post_repository.dart';
import 'post_event.dart';
import 'post_state.dart';

export 'post_event.dart';
export 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repository;

  PostBloc({required this.repository}) : super(const PostInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<SearchPosts>(_onSearchPosts);
    on<ToggleLikePost>(_onToggleLikePost);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostState> emit) async {
    emit(const PostLoading());
    final result = await repository.getPosts();
    result.fold(
      (failure) => emit(PostError(failure.message)),
      (posts) => emit(PostLoaded.initial(posts)),
    );
  }

  void _onSearchPosts(SearchPosts event, Emitter<PostState> emit) {
    final current = state;
    if (current is! PostLoaded) return;

    if (event.query.isEmpty) {
      emit(current.copyWithFilter(current.posts));
    } else {
      final query = event.query.toLowerCase();
      final filtered = current.posts
          .where((p) => p.title.toLowerCase().contains(query))
          .toList();
      emit(current.copyWithFilter(filtered));
    }
  }

  Future<void> _onToggleLikePost(
    ToggleLikePost event,
    Emitter<PostState> emit,
  ) async {
    final current = state;
    if (current is! PostLoaded) return;

    final result = await repository.toggleLike(event.postId);
    result.fold(
      (failure) => emit(PostError(failure.message)),
      (_) => emit(current.copyWithUpdatedLike(event.postId)),
    );
  }
}
