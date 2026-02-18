import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/datasources/local/post_local_data_source.dart';
import '../data/datasources/native/comment_native_data_source.dart';
import '../data/datasources/remote/post_remote_data_source.dart';
import '../data/repositories/post_repository_impl.dart';
import '../domain/repositories/post_repository.dart';
import '../presentation/bloc/post/post_bloc.dart';
import '../presentation/bloc/comment/comment_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies first (they have no internal deps)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter/eCommerce-Challenge',
        },
      ),
    ),
  );

  // Data sources
  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PostLocalDataSource>(
    () => PostLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<CommentNativeDataSource>(
    () => CommentNativeDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      nativeDataSource: sl(),
    ),
  );

  // BLoCs — registered as factory so each BlocProvider gets a fresh instance
  sl.registerFactory(() => PostBloc(repository: sl()));
  sl.registerFactory(() => CommentBloc(repository: sl()));
}
