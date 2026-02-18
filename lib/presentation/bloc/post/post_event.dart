import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object?> get props => [];
}

class LoadPosts extends PostEvent {
  const LoadPosts();
}

class SearchPosts extends PostEvent {
  final String query;
  const SearchPosts(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleLikePost extends PostEvent {
  final int postId;
  const ToggleLikePost(this.postId);

  @override
  List<Object?> get props => [postId];
}
