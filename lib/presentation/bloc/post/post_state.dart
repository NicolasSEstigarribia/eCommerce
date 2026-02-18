import 'package:equatable/equatable.dart';
import '../../../domain/entities/post.dart';

abstract class PostState extends Equatable {
  const PostState();
  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostLoaded extends PostState {
  final List<Post> posts;
  final List<Post> filteredPosts;

  const PostLoaded({required this.posts, required this.filteredPosts});

  factory PostLoaded.initial(List<Post> posts) =>
      PostLoaded(posts: posts, filteredPosts: posts);

  PostLoaded copyWithFilter(List<Post> filtered) =>
      PostLoaded(posts: posts, filteredPosts: filtered);

  PostLoaded copyWithUpdatedLike(int postId) {
    Post toggle(Post p) => p.id == postId ? p.copyWith(isLiked: !p.isLiked) : p;
    return PostLoaded(
      posts: posts.map(toggle).toList(),
      filteredPosts: filteredPosts.map(toggle).toList(),
    );
  }

  @override
  List<Object?> get props => [posts, filteredPosts];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}
