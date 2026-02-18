import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/comment_model.dart';

abstract class CommentNativeDataSource {
  Future<List<CommentModel>> getComments(int postId);
}

class CommentNativeDataSourceImpl implements CommentNativeDataSource {
  final MethodChannel _channel = const MethodChannel(
    'com.example.ecommerce/comments',
  );

  @override
  Future<List<CommentModel>> getComments(int postId) async {
    try {
      final String? result = await _channel.invokeMethod(
        AppConstants.getCommentsMethod,
        {'postId': postId},
      );
      if (result == null) return [];
      final List<dynamic> decoded = json.decode(result);
      return decoded.map((e) => CommentModel.fromJson(e)).toList();
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.message ?? 'Unknown platform error');
    }
  }
}
