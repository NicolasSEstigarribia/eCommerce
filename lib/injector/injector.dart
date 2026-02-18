import 'package:dio/dio.dart';
import 'package:ecommerce/data/barrel_data.dart';
import 'package:ecommerce/domain/barrel_domain.dart';
import 'package:ecommerce/presentation/bloc/barrel_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
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

  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PostLocalDataSource>(
    () => PostLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<CommentNativeDataSource>(
    () => CommentNativeDataSourceImpl(),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      nativeDataSource: sl(),
    ),
  );

  sl.registerFactory(() => PostBloc(repository: sl()));
  sl.registerFactory(() => CommentBloc(repository: sl()));
}
