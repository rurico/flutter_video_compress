part of flutter_video_compress;

class FlutterVideoCompress {
  static FlutterVideoCompress _instance;
  static const _channel = const MethodChannel('flutter_video_compress');

  factory FlutterVideoCompress() => _instance ??= FlutterVideoCompress._();

  /// Subscribe the conversion progress
  final compressProgress$ = ObservableBuilder<double>(0);

  /// get state of Compressing
  bool get isCompressing => _isCompressing;

  bool _isCompressing = false;

  int _totalTime = 0;

  FlutterVideoCompress._() {
    _channel.setMethodCallHandler(_handleCallback);
  }

  Future<void> _handleCallback(MethodCall call) async {
    switch (call.method) {
      case 'updateProgressTotalTime':
        _totalTime = call.arguments;
        break;
      case 'updateProgressTime':
        final progress = (call.arguments as int) / _totalTime * 100;
        _updateProgressState(progress);
        break;
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
      print('''FlutterVideoCompress Error: 
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

    final newPath = await _invoke<String>('getThumbnailWithFile', {
      'path': path,
      'quality': quality,
      'position': position,
    });

    final file = File(newPath);

    return file;
  }

  /// get media information from [path]
  /// 
  /// ## example
  /// ```dart
  /// final info = await _flutterVideoCompress.getMediaInfo(file.path);
  /// print(info.toJson());
  /// ```
  Future<MediaInfo> getMediaInfo(String path) async {
    assert(path != null);
    final jsonStr = await _invoke<String>('getMediaInfo', {'path': path});
    final jsonMap = json.decode(jsonStr);
    return MediaInfo.fromJson(jsonMap);
  }

  /// compress video from [path]
  /// 
  /// you can choose its quality by [quality],
  /// determine whether to delete his source file by [deleteOrigin]
  /// 
  /// ## example
  /// ```dart
  /// final MediaInfo info = await _flutterVideoCompress.startCompress(
  ///   file.path,
  ///   deleteOrigin: true,
  /// );
  /// print(info.toJson());
  /// ```
  Future<MediaInfo> startCompress(
    String path, {
    VideoQuality quality = VideoQuality.LowQuality,
    bool deleteOrigin = false,
  }) async {
    assert(path != null);
    if (_isCompressing) {
      throw StateError('''FlutterVideoCompress Error: 
      Method: startCompress
      Already have a compression process, you need to wait for the process to finish''');
    }
    _isCompressing = true;
    final jsonStr = await _invoke<String>('startCompress', {
      'path': path,
      'quality': quality.index,
      'deleteOrigin': deleteOrigin,
    });
    _totalTime = 0;
    _isCompressing = false;
    final jsonMap = json.decode(jsonStr);
    return MediaInfo.fromJson(jsonMap);
  }

  /// stop compressing the file that is currently being compressed. 
  /// If there is no compression process, nothing will happen.
  /// 
  /// ## example
  /// ```dart
  /// await _flutterVideoCompress.stopCompress();
  /// ```
  Future<void> stopCompress() async {
    await _invoke<void>('stopCompress');
  }
}
