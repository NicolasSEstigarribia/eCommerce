import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/post.dart';
import '../bloc/post/post_bloc.dart';
import '../bloc/comment/comment_bloc.dart';
import '../widgets/comment_item.dart';
import '../widgets/error_view.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(LoadComments(widget.post.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          BlocBuilder<PostBloc, PostState>(
            buildWhen: (prev, curr) => curr is PostLoaded,
            builder: (context, state) {
              final isLiked = state is PostLoaded
                  ? (state.posts
                        .firstWhere(
                          (p) => p.id == widget.post.id,
                          orElse: () => widget.post,
                        )
                        .isLiked)
                  : widget.post.isLiked;

              return IconButton(
                tooltip: isLiked ? 'Unlike' : 'Like',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isLiked),
                    color: isLiked ? Colors.red : null,
                  ),
                ),
                onPressed: () => context.read<PostBloc>().add(
                  ToggleLikePost(widget.post.id),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              widget.post.body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Text(
              'Comments',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) => switch (state) {
                CommentLoading() => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                CommentLoaded(:final comments) when comments.isEmpty =>
                  const Text('No comments available.'),
                CommentLoaded(:final comments) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (_, i) => CommentItem(comment: comments[i]),
                ),
                CommentError(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context.read<CommentBloc>().add(
                    LoadComments(widget.post.id),
                  ),
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }
}
