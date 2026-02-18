import 'package:dio/dio.dart';
import 'package:ecommerce/core/constants/app_constants.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/data/datasources/post_remote_data_source_impl.dart';
import 'package:ecommerce/data/models/post_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late PostRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = PostRemoteDataSourceImpl(dio: mockDio);
  });

  const tPostModel = PostModel(
    id: 1,
    userId: 1,
    title: 'Test Title',
    body: 'Test Body',
  );
  final tPostModelList = [tPostModel];
  final tResponseData = [
    {'id': 1, 'userId': 1, 'title': 'Test Title', 'body': 'Test Body'},
  ];

  group('getPosts', () {
    test('should perform a GET request on /posts URL', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '${AppConstants.baseUrl}/posts'),
        ),
      );

      await dataSource.getPosts();

      verify(() => mockDio.get('${AppConstants.baseUrl}/posts')).called(1);
    });

    test(
      'should return List<PostModel> when the response code is 200',
      () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '${AppConstants.baseUrl}/posts',
            ),
          ),
        );

        final result = await dataSource.getPosts();

        expect(result, equals(tPostModelList));
      },
    );

    test(
      'should throw ServerException when the response code is 404',
      () async {
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: '${AppConstants.baseUrl}/posts',
            ),
            response: Response(
              requestOptions: RequestOptions(
                path: '${AppConstants.baseUrl}/posts',
              ),
              statusCode: 404,
            ),
          ),
        );

        expect(() => dataSource.getPosts(), throwsA(isA<ServerException>()));
      },
    );
  });
}
