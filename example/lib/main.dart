import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;

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

  MediaInfo _originalVideoInfo = MediaInfo(path: '');
  MediaInfo _compressedVideoInfo = MediaInfo(path: '');

  StreamController<bool> _loadingStreamCtrl = StreamController<bool>.broadcast();

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

  Future<void> runFlutterVideoCompressMethods(
      BuildContext context, File videoFile) async {
    _loadingStreamCtrl.sink.add(true);

    var _startDateTime = DateTime.now();
    print('[Compressing Video] start');
    await _flutterVideoCompress
        .startCompress(videoFile.path,
            quality: VideoQuality.DefaultQuality, deleteOrigin: false)
        .then((MediaInfo compressedVideoInfo) async {
      print(
          '[Compressing Video] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

      _startDateTime = DateTime.now();
      print('[Getting Thumbnail BytesList] start');
      await _flutterVideoCompress
          .getThumbnail(videoFile.path, quality: 50)
          .then((Uint8List thumbnailUint8ListImage) async {
        print(
            '[Getting Thumbnail BytesList] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

        _startDateTime = DateTime.now();
        print('[Getting Thumbnail File] start');
        await _flutterVideoCompress
            .getThumbnailWithFile(videoFile.path, quality: 50)
            .then((File thumbnailFile) async {
          print(
              '[Getting Thumbnail File] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

          _startDateTime = DateTime.now();
          print('[Getting Gif File] start');
          await _flutterVideoCompress
              .convertVideoToGif(videoFile.path, startTime: 0, endTime: 5)
              .then((File gifFile) async {
            print(
                '[Getting Gif File] done! ${DateTime.now().difference(_startDateTime).inSeconds}s');

            await _flutterVideoCompress
                .getMediaInfo(videoFile.path)
                .then((MediaInfo videoInfo) async {
              setState(() {
                _thumbnailUint8ListImage =
                    Image.memory(thumbnailUint8ListImage);
                _thumbnailFileImage = Image.file(thumbnailFile);
                _gifFileImage = Image.file(gifFile);
                _originalVideoInfo = videoInfo;
                _compressedVideoInfo = compressedVideoInfo;
              });
            });
          });
        });
      });
    });

    _loadingStreamCtrl.sink.add(false);
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
                        await ImagePicker.pickVideo(source: ImageSource.camera)
                            .then((File videoFile) async {
                          runFlutterVideoCompressMethods(context, videoFile);
                        runFlutterVideoCompressMethods(context, videoFile);                  
                          runFlutterVideoCompressMethods(context, videoFile);
                        });
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
                        await ImagePicker.pickVideo(source: ImageSource.gallery)
                            .then((File videoFile) async {
                          runFlutterVideoCompressMethods(context, videoFile);
                        });
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
                      child: Text(
                          'path: ${_originalVideoInfo.path}\nduration: ${_originalVideoInfo.duration} microseconds\nsize: ${_originalVideoInfo.filesize} bytes\nsize: ${_originalVideoInfo.width} x ${_originalVideoInfo.height}\ncompression cancelled: ${_originalVideoInfo.isCancel}\nauthor: ${_originalVideoInfo.author}')),
                  Divider(),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Text('Compressed video')),
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                          'path: ${_compressedVideoInfo.path}\nduration: ${_compressedVideoInfo.duration} microseconds\nsize: ${_compressedVideoInfo.filesize} bytes\nsize: ${_compressedVideoInfo.width} x ${_compressedVideoInfo.height}\ncompression cancelled: ${_originalVideoInfo.isCancel}\nauthor: ${_originalVideoInfo.author}')),
                  Divider(),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Text('Thumbnail image from file')),
                  _thumbnailFileImage != null
                      ? _thumbnailFileImage
                      : Container(),
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
                        CircularProgressIndicator(), 
                              CircularProgressIndicator(),
                              Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text('Compressing...'))
                            ]),
                      );
                    }
                    return Container();
                  })
            ],
          )),
    );
  }
}
