import 'dart:convert';

import 'package:ecommerce/core/barrel_core.dart';
import 'package:ecommerce/data/barrel_data.dart';
import 'package:ecommerce/domain/barrel_domain.dart';
import 'package:flutter/services.dart';

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
