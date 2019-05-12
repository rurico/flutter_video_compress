import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

part 'compress_result.dart';

class FlutterVideoCompress {
  static const MethodChannel _channel =
      const MethodChannel('flutter_video_compress');

  Future<T> _invoke<T>(String fnName, [Map<String, dynamic> params]) async {
    T result;
    try {
      result = params != null
          ? await _channel.invokeMethod(fnName, params)
          : await _channel.invokeMethod(fnName);
    } catch (e) {
      print('''FlutterVideoCompress Error: 
      Method: $fnName
      $e''');
    }
    return result;
  }

  /// get video thumbnail
  ///
  /// [path] is the file uri that you want to get the thumbnail.
  /// [quality] is the thumbnail quality.
  Future<Uint8List> getThumbnail({String path, int quality = 100}) async {
    assert(path != null);
    assert(quality > 1 || quality < 100);

    return await _invoke<Uint8List>('getThumbnail', {
      'path': path,
      'quality': quality,
    });
  }

  /// compress video return new path
  ///
  /// [path] is the file uri that you want to compress video.
  /// The [deleteOrigin] parameter determines whether you delete the source file.
  Future<CompressResult> startCompress(
      {String path, bool deleteOrigin = false}) async {
    assert(path != null);
    final resultPath = await _invoke<String>('startCompress', {
      'path': path,
      'deleteOrigin': deleteOrigin,
    });
    if (resultPath == null) {
      throw StateError('''FlutterVideoCompress Error: 
      Method: startCompress
      Already have a compression process, you need to wait for the process to finish''');
    }
    final isCancel = resultPath.contains('flutter_video_compress');
    return CompressResult(path: resultPath, isCancel: !isCancel);
  }

  /// Stop the video being compressed
  Future<void> stopCompress() async {
    await _invoke<void>('stopCompress');
  }
}
