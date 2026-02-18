import 'package:ecommerce/core/constants/app_constants.dart';
import 'package:ecommerce/core/error/exceptions.dart';
import 'package:ecommerce/data/datasources/post_local_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late PostLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = PostLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLikedPostIds', () {
    test(
      'should return List<int> from SharedPreferences when there are liked posts',
      () async {
        when(
          () => mockSharedPreferences.getStringList(any()),
        ).thenReturn(['1', '2', '3']);

        final result = await dataSource.getLikedPostIds();

        verify(
          () => mockSharedPreferences.getStringList(AppConstants.likedPostsKey),
        );
        expect(result, equals([1, 2, 3]));
      },
    );

    test('should return an empty list when there are no liked posts', () async {
      when(() => mockSharedPreferences.getStringList(any())).thenReturn(null);

      final result = await dataSource.getLikedPostIds();

      expect(result, equals([]));
    });

    test('should throw CacheException when SharedPreferences throws', () async {
      when(
        () => mockSharedPreferences.getStringList(any()),
      ).thenThrow(Exception());

      expect(
        () => dataSource.getLikedPostIds(),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('toggleLike', () {
    test('should add postId to list if it was not already liked', () async {
      when(() => mockSharedPreferences.getStringList(any())).thenReturn(['1']);
      when(
        () => mockSharedPreferences.setStringList(any(), any()),
      ).thenAnswer((_) async => true);

      await dataSource.toggleLike(2);

      verify(
        () => mockSharedPreferences.setStringList(AppConstants.likedPostsKey, [
          '1',
          '2',
        ]),
      );
    });

    test('should remove postId from list if it was already liked', () async {
      when(
        () => mockSharedPreferences.getStringList(any()),
      ).thenReturn(['1', '2']);
      when(
        () => mockSharedPreferences.setStringList(any(), any()),
      ).thenAnswer((_) async => true);

      await dataSource.toggleLike(2);

      verify(
        () => mockSharedPreferences.setStringList(AppConstants.likedPostsKey, [
          '1',
        ]),
      );
    });
  });
}
