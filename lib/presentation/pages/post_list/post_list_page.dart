import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/barrel_bloc.dart';
import '../post_detail/post_detail_page.dart';
import '../../common_widgets/error_view.dart';
import 'widgets/post_list_item.dart';
import 'dart:async';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PostBloc>().add(SearchPosts(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          return switch (state) {
            PostLoading() => const Center(child: CircularProgressIndicator()),
            PostLoaded(:final filteredPosts) when filteredPosts.isEmpty =>
              const Center(child: Text('No posts found.')),
            PostLoaded(:final filteredPosts) => ListView.separated(
              itemCount: filteredPosts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return PostListItem(
                  post: post,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(post: post),
                    ),
                  ),
                );
              },
            ),
            PostError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<PostBloc>().add(const LoadPosts()),
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
