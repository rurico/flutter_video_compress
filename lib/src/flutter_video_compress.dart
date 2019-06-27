part of flutter_video_compress;

class FlutterVideoCompress {
  static const _channel = const MethodChannel('flutter_video_compress');

  factory FlutterVideoCompress() => FlutterVideoCompress._();

  /// Subscribe the conversion progress
  final compressProgress$ = ObservableBuilder<double>();

  /// get is Compressing state
  bool get isCompressing => _isCompressing;

  bool _isCompressing = false;

  FlutterVideoCompress._() {
    _channel.setMethodCallHandler(_handleCallback);
  }

  Future<void> _handleCallback(MethodCall call) async {
    switch (call.method) {
      case 'updateProgress':
        final progress = double.tryParse(call.arguments);
        _updateProgressState(progress);
        break;
    }
  }

  void _updateProgressState(double state) {
    if (state != null) {
      compressProgress$.next(state);
    }
  }

  Future<T> _invoke<T>(String name, [Map<String, dynamic> params]) async {
    T result;
    try {
      result = params != null
          ? await _channel.invokeMethod(name, params)
          : await _channel.invokeMethod(name);
    } on PlatformException catch (e) {
      debugPrint('''FlutterVideoCompress Error: 
      Method: $name
      $e''');
    }
    return result;
  }

  /// get thumbnail from [path]
  ///
  /// get thumbnail from [path] return [Future<Uint8List>],
  /// quality can be controlled by [quality] from 1 to 100,
  /// select the position unit in the video by [position] is seconds, don't worry about crossing the boundary
  ///
  /// ## example
  /// ```dart
  /// final uint8list = await _flutterVideoCompress.getThumbnail(
  ///   file.path,
  ///   quality: 50,
  /// );
  /// ```
  Future<Uint8List> getThumbnail(
    String path, {
    int quality = 100,
    int position = -1,
  }) async {
    assert(path != null);
    assert(quality > 1 || quality < 100);

    return await _invoke<Uint8List>('getThumbnail', {
      'path': path,
      'quality': quality,
      'position': position,
    });
  }

  /// get thumbnail file from [path] return [Future<File>]
  ///
  /// quality can be controlled by [quality] from 1 to 100,
  /// select the position unit in the video by [position] is seconds, don't worry about crossing the boundary
  ///
  /// ## example
  /// ```dart
  /// final file = await _flutterVideoCompress.getThumbnailWithFile(
  ///   file.path,
  ///   quality: 50,
  /// );
  /// ```
  Future<File> getThumbnailWithFile(
    String path, {
    int quality = 100,
    int position = -1,
  }) async {
    assert(path != null);
    assert(quality > 1 || quality < 100);

    final filePath = await _invoke<String>('getThumbnailWithFile', {
      'path': path,
      'quality': quality,
      'position': position,
    });

    final file = File(filePath);

    return file;
  }

  /// converts provided video to a gif. Video is cut starting from [startTime]
  /// for the provided [duration] or until [endTime] if set. Either [endTime] or
  /// [duration] has to be set where if both set, [endTime] has priority. [endTime]
  /// has to be greater than [startTime] in order for this method to work.
  /// All time variables should be in seconds. Take care of about [duration]
  /// of the video since the plugin doesn't check if [startTime] is within the
  /// length of the provided video.
  ///
  /// ## example
  /// ```dart
  /// final file = await _flutterVideoCompress.convertVideoToGif(
  ///   videoFile.path,
  ///   startTime: 0,
  ///   duration: 5,
  /// );
  /// debugPrint(file.path);
  /// ```
  Future<File> convertVideoToGif(
    String path, {
    int startTime = 0,
    int endTime = -1,
    int duration = -1, // When you do not know the end time
  }) async {
    assert(path != null);
    if (endTime > 0) {
      assert(startTime <= endTime);
    }
    final filePath = await _invoke<String>('convertVideoToGif', {
      'path': path,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration
    });

    final file = File(filePath);

    return file;
  }

  /// get media information from [path]
  ///
  /// get media information from [path] return [Future<MediaInfo>]
  ///
  /// ## example
  /// ```dart
  /// final info = await _flutterVideoCompress.getMediaInfo(file.path);
  /// debugPrint(info.toJson());
  /// ```
  Future<MediaInfo> getMediaInfo(String path) async {
    assert(path != null);
    final jsonStr = await _invoke<String>('getMediaInfo', {'path': path});
    final jsonMap = json.decode(jsonStr);
    return MediaInfo.fromJson(jsonMap);
  }

  /// compress video from [path]
  /// compress video from [path] return [Future<MediaInfo>]
  ///
  /// you can choose its quality by [quality],
  /// determine whether to delete his source file by [deleteOrigin]
  ///
  /// ## example
  /// ```dart
  /// final info = await _flutterVideoCompress.compressVideo(
  ///   file.path,
  ///   deleteOrigin: true,
  /// );
  /// debugPrint(info.toJson());
  /// ```
  Future<MediaInfo> compressVideo(
    String path, {
    VideoQuality quality = VideoQuality.DefaultQuality,
    bool deleteOrigin = false,
    int startTime,
    int duration,
    bool includeAudio,
    int frameRate,
  }) async {
    assert(path != null);
    if (_isCompressing) {
      throw StateError('''FlutterVideoCompress Error: 
      Method: compressVideo
      Already have a compression process, you need to wait for the process to finish or stop it''');
    }
    _isCompressing = true;
    if (compressProgress$._notSubscribed) {
      debugPrint('''FlutterVideoCompress: You can try to subscribe to the 
      compressProgress\$ stream to know the compressing state.''');
    }
    final jsonStr = await _invoke<String>('compressVideo', {
      'path': path,
      'quality': quality.index,
      'deleteOrigin': deleteOrigin,
      'startTime': startTime,
      'duration': duration,
      'includeAudio': includeAudio,
      'frameRate': frameRate,
    });
    _isCompressing = false;
    final jsonMap = json.decode(jsonStr);
    return MediaInfo.fromJson(jsonMap);
  }

  /// stop compressing the file that is currently being compressed.
  /// If there is no compression process, nothing will happen.
  ///
  /// ## example
  /// ```dart
  /// await _flutterVideoCompress.cancelCompression();
  /// ```
  Future<void> cancelCompression() async {
    await _invoke<void>('cancelCompression');
  }

  /// delete the cache folder, please do not put other things 
  /// in the folder of this plugin, it will be cleared
  Future<void> deleteAllCache() async {
    await _invoke<void>('deleteAllCache');
  }
}
