import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

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
  Future<Uint8List> getThumbnail({String path, int quality = 100}) async {
    assert(path != null);
    assert(quality > 1 || quality < 100);

    return await _invoke<Uint8List>('getThumbnail', {'path': path, 'quality': quality});
  }

  /// compress video return new path
  Future<String> compressVideo({String path, bool deleteOrigin = false}) async {
    assert(path != null);
    return await _invoke<String>(
        'compressVideo', {'path': path, 'deleteOrigin': deleteOrigin});
  }
}
