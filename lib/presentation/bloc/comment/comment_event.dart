import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();
  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentEvent {
  final int postId;
  const LoadComments(this.postId);

  @override
  List<Object?> get props => [postId];
}
