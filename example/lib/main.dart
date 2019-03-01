import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_vedio_compress/flutter_vedio_compress.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterVedioCompress _flutterVedioCompress;
  Uint8List _image;

  @override
  void initState() {
    _flutterVedioCompress = FlutterVedioCompress();
  }

  Future<void> _videoPicker() async {
    File file = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (file != null && mounted) {
      _image = await _flutterVedioCompress
          .getThumbnail(path: file.path, quality: 50)
          .whenComplete(() {
        setState(() {});
      });
      final String newPath = await _flutterVedioCompress.compressVedio(
          path: file.path, deleteOrigin: true);
      print(newPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _list = <Widget>[
      FlatButton(child: Text('take vedio'), onPressed: _videoPicker),
    ];
    if (_image != null) {
      _list.add(Flexible(child: Center(child: Image.memory(_image))));
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(children: _list),
      ),
    );
  }
}
