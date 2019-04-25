import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterVideoCompress _flutterVideoCompress = FlutterVideoCompress();
  Uint8List _image;

  Future<void> _videoPicker() async {
    File file = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (file != null && mounted) {
      _image = await _flutterVideoCompress
          .getThumbnail(path: file.path, quality: 50)
          .whenComplete(() {
        setState(() {});
      });
      final String newPath = await _flutterVideoCompress.compressVideo(
          path: file.path, deleteOrigin: true);
      print(newPath);
    }
  }

  List<Widget> _builColumnChildren() {
    // dart 2.3 before
    final _list = <Widget>[
      FlatButton(child: Text('take video'), onPressed: _videoPicker)
    ];
    if (_image != null) {
      _list.add(Flexible(child: Image.memory(_image)));
    }
    return _list;

    // dart 2.3
    // final _list =  [
    //   FlatButton(child: Text('take video'), onPressed: _videoPicker),
    //   if(_image != null) Flexible(child: Image.memory(_image))
    // ];
    // return _list;
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
