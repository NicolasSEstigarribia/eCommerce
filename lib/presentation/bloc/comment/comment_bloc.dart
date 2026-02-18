import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/post_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

export 'comment_event.dart';
export 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final PostRepository repository;

  CommentBloc({required this.repository}) : super(const CommentInitial()) {
    on<LoadComments>(_onLoadComments);
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(const CommentLoading());
    final result = await repository.getComments(event.postId);
    result.fold(
      (failure) => emit(CommentError(failure.message)),
      (comments) => emit(CommentLoaded(comments)),
    );
  }
}
