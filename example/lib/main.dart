import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterVideoCompress = FlutterVideoCompress();
  Subscription _subscription;

  Image _thumbnailUint8ListImage;
  Image _thumbnailFileImage;
  Image _gifFileImage;

  VideoPlayerController _controller;

  MediaInfo _originalVideoInfo = MediaInfo(path: '');
  MediaInfo _compressedVideoInfo = MediaInfo(path: '');
  MediaInfo _videoPreviewInfo = MediaInfo(path: '');

  final _loadingStreamCtrl = StreamController<bool>.broadcast();

  @override
  void initState() {
    super.initState();
    _subscription =
        _flutterVideoCompress.compressProgress$.subscribe((progress) {
      //debugPrint('[Compressing Progress] $progress %');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
    _loadingStreamCtrl.close();
  }

  Future<void> runFlutterVideoCompressMethods(File videoFile) async {
    _loadingStreamCtrl.sink.add(true);

    var _startDateTime = DateTime.now();
    print('[Compressing Video] start');
    final compressedVideoInfo = await _flutterVideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false,
    );
    print(
        '[Compressing Video] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

    _startDateTime = DateTime.now();
    print('[Getting Thumbnail BytesList] start');
    final thumbnailUint8ListImage =
        await _flutterVideoCompress.getThumbnail(videoFile.path, quality: 50);
    print(
        '[Getting Thumbnail BytesList] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

    _startDateTime = DateTime.now();
    print('[Getting Thumbnail File] start');
    final thumbnailFile = await _flutterVideoCompress
        .getThumbnailWithFile(videoFile.path, quality: 50);
    print(
        '[Getting Thumbnail File] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

    _startDateTime = DateTime.now();
    print('[Getting Gif File] start');
    final gifFile = await _flutterVideoCompress
        .convertVideoToGif(videoFile.path, startTime: 0, duration: 5);
    print(
        '[Getting Gif File] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

    final videoInfo = await _flutterVideoCompress.getMediaInfo(videoFile.path);
    _startDateTime = DateTime.now();
    print('[Compressing video preview] started');
    final videoPreviewInfo = await _flutterVideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.DefaultQuality,
      includeAudio: false,
      startTime: 0,
      duration: 5,
      frameRate: 24,
    );
    if (_videoPreviewInfo != null && _videoPreviewInfo.file != null) {
      _controller = VideoPlayerController.file(_videoPreviewInfo.file);
    }
    print(
        '[Compressing video preview] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');
    setState(() {
      _thumbnailUint8ListImage = Image.memory(thumbnailUint8ListImage);
      _thumbnailFileImage = Image.file(thumbnailFile);
      _gifFileImage = Image.file(gifFile);
      _originalVideoInfo = videoInfo;
      _compressedVideoInfo = compressedVideoInfo;
      _videoPreviewInfo = videoPreviewInfo;
    });
    _loadingStreamCtrl.sink.add(false);
  }

  String infoConvert(MediaInfo info) {
    return 'path: ${info.path}\n'
        'duration: ${info.duration} microseconds\n'
        'size: ${info.filesize} bytes\n'
        'size: ${info.width} x ${info.height}\n'
        'orientation: ${info.orientation}°\n'
        'compression cancelled: ${info.isCancel}\n'
        'author: ${info.author}';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Video Compress Example')),
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text(
                      'Take video from camera with Image Picker',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.grey[800],
                    onPressed: () async {
                      final videoFile = await ImagePicker.pickVideo(
                          source: ImageSource.camera);
                      if (videoFile != null) {
                        runFlutterVideoCompressMethods(videoFile);
                      }
                    },
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Text(
                      'Take video from gallery with Image Picker',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.grey[800],
                    onPressed: () async {
                      final videoFile = await ImagePicker.pickVideo(
                          source: ImageSource.gallery);
                      if (videoFile != null) {
                        runFlutterVideoCompressMethods(videoFile);
                      }
                    },
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Text('Original video')),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(8.0),
                    child: Text(infoConvert(_originalVideoInfo))),
                Divider(),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Text('Compressed video')),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(8.0),
                    child: Text(infoConvert(_compressedVideoInfo))),
                Divider(),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Text('Thumbnail image from file')),
                _thumbnailFileImage != null ? _thumbnailFileImage : Container(),
                Divider(),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Text('Thumbnail image from bytes list')),
                _thumbnailUint8ListImage != null
                    ? _thumbnailUint8ListImage
                    : Container(),
                Divider(),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Text('Gif image from original video')),
                _gifFileImage != null ? _gifFileImage : Container(),
                Divider(),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Text('Video preview')),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(8.0),
                    child: Text(infoConvert(_videoPreviewInfo))),
                _videoPreviewInfo != null &&
                        _videoPreviewInfo.file != null &&
                        _controller != null
                    ? GestureDetector(
                        onTap: () {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        },
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      )
                    : Container(),
                Divider(),
              ],
            ),
            StreamBuilder<bool>(
              stream: _loadingStreamCtrl.stream,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data == true) {
                  return Container(
                    color: Colors.black54,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CircularProgressIndicator(),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Text('Compressing...'),
                        )
                      ],
                    ),
                  );
                }
                return Container();
              },
            )
          ],
        ),
      ),
    );
  }
}
