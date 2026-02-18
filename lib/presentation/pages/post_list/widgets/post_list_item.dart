import 'package:flutter/material.dart';
import '../../../../domain/entities/post.dart';

class PostListItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostListItem({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        post.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          post.isLiked ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(post.isLiked),
          color: post.isLiked ? Colors.red : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
