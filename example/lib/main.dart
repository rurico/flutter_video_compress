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
  FlutterVideoCompress _flutterVideoCompress = FlutterVideoCompress();
  Uint8List _image;
  File _imageFile;
  Subscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        _flutterVideoCompress.compressProgress$.subscribe((progress) {
      print('progress: $progress');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }

  Future<void> _videoPicker() async {
    if (mounted) {
      File file = await ImagePicker.pickVideo(source: ImageSource.camera);
      if (file?.path != null) {
        final thumbnail = await _flutterVideoCompress.getThumbnail(
          file.path,
          quality: 50,
          position: -1,
        );

        setState(() {
          _image = thumbnail;
        });

        final resultFile = await _flutterVideoCompress.getThumbnailWithFile(
          file.path,
          quality: 50,
          position: -1,
        );
        print(resultFile.path);

        assert(resultFile.existsSync());

        print('file Exists: ${resultFile.existsSync()}');

        final MediaInfo info = await _flutterVideoCompress.startCompress(
          file.path,
          deleteOrigin: true,
        );
        print(info.toJson());
      }
    }
  }

  Future<void> _stopCompress() async {
    await _flutterVideoCompress.stopCompress();
  }

  Future<void> _getMediaInfo() async {
    if (mounted) {
      File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
      if (file?.path != null) {
        final info = await _flutterVideoCompress.getMediaInfo(file.path);
        print(info.toJson());
      }
    }
  }

  Future<void> _convertVideoToGif() async {
    if (mounted) {
      File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
      if (file?.path != null) {
        var info = await _flutterVideoCompress.convertVideoToGif(file.path,
            startTime: 0, duration: 5);

        print(info.path);
        setState(() {
          _imageFile = info;
        });
      }
    }
  }

  List<Widget> _builColumnChildren() {
    // dart 2.3 before
    // final _list = <Widget>[
    //   FlatButton(child: Text('take video'), onPressed: _videoPicker),
    //   FlatButton(child: Text('stop compress'), onPressed: _stopCompress),
    // ];
    // if (_image != null) {
    //   _list.add(Flexible(child: Image.memory(_image)));
    // }
    // return _list;

    // dart 2.3
    final _list = [
      FlatButton(child: Text('take video'), onPressed: _videoPicker),
      FlatButton(child: Text('stop compress'), onPressed: _stopCompress),
      FlatButton(child: Text('getMediaInfo'), onPressed: _getMediaInfo),
      FlatButton(
          child: Text('convert video to gif'), onPressed: _convertVideoToGif),
      if (_imageFile != null)
        Flexible(child: Image.file(_imageFile))
      else
        if (_image != null) Flexible(child: Image.memory(_image))
    ];
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _builColumnChildren(),
        ),
      ),
    );
  }
}
