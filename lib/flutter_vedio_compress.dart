import 'dart:async';

import 'dart:typed_data';
import 'package:flutter/services.dart';

/// VedioCompress helper
class FlutterVedioCompress {
  static const MethodChannel _channel =
      const MethodChannel('flutter_vedio_compress');

  /// get vedio thumbnail
  Future<Uint8List> getThumbnail({String path, int quality = 100}) async {
    assert(path != null);
    assert(quality > 1 || quality < 100);
    final params = {'path': path, 'quality': quality};
    return await _channel.invokeMethod('getThumbnail', params);
  }

  /// compress vedio return new path
  Future<String> compressVedio({String path, bool deleteOrigin = false}) async {
    assert(path != null);
    final params = {'path': path, 'deleteOrigin': deleteOrigin};
    return await _channel.invokeMethod('compressVedio', params);
  }
}
