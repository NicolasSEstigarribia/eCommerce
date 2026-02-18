import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injector/injector.dart' as injector;
import 'presentation/bloc/post/post_bloc.dart';
import 'presentation/bloc/comment/comment_bloc.dart';
import 'presentation/pages/post_list/post_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await injector.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => injector.sl<PostBloc>()..add(const LoadPosts()),
        ),
        BlocProvider(create: (_) => injector.sl<CommentBloc>()),
      ],
      child: MaterialApp(
        title: 'eCommerce Challenge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5C6BC0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false),
        ),
        home: const PostListPage(),
      ),
    );
  }
}
