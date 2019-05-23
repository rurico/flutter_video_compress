# flutter_video_compress

Compressed video generates a new path, keep the source video or delete it. provide get video information or get thumbnail of the video file.

<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_video_compress"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_video_compress.svg"></a>
  <img alt="license" src="https://img.shields.io/github/license/TenkaiRuri/flutter_video_compress.svg">
  <a href="https://github.com/TenkaiRuri/flutter_video_compress"><img alt="github stars" src="https://img.shields.io/github/stars/TenkaiRuri/flutter_video_compress.svg?style=social&label=Stars"></a>
</p>

## IOS adding use_frameworks for swift plugin
`ios/Podfile` file add **use_frameworks!**
```ruby
target 'Runner' do
  use_frameworks! # <- add this line
```

## Methods
|function|parameter|description|return|
|--|--|--|--|
|getThumbnail|`String [path]`, `int [quality]`(1-100), `int [position]`|get thumbnail from [path]|`[Future<Uint8List>]`|
|getThumbnailWithFile|`String [path]`, `int [quality]`(1-100), `int [position]`|get thumbnail from [path]|`[Future<File>]`|
|getMediaInfo|`String [path]`|get media information from [path]|`[Future<MediaInfo>]`|
|startCompress|`String [path]`, `VideoQuality [quality]` ,`bool [deleteOrigin]`|compress video from [path]|`[Future<File>]`|
|stopCompress|none|stop compressing the file that is currently being compressed.|`[Future<void>]`|

## Subscriptions
|subscription|description|stream|
|--|--|--|
|compressProgress$|Subscribe the conversion progress|`double [progress]`|

## Usage
**Installing**
add flutter_video_compress as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  flutter_video_compress: ^0.3.x
```

**Creating instance.**
```dart
FlutterVideoCompress _flutterVideoCompress = FlutterVideoCompress();
```

**Get a video file thumbnail**
```dart
final uint8list = await _flutterVideoCompress.getThumbnail(
  file.path,
  quality: 50,
);
```

**Get a video file thumbnail with file**
```dart
final file = await _flutterVideoCompress.getThumbnailWithFile(
  file.path,
  quality: 50,
);
```

**get media information**
```dart
final info = await _flutterVideoCompress.getMediaInfo(file.path);
print(info.toJson());
```

**Compress a Video**
```dart
final MediaInfo info = await _flutterVideoCompress.startCompress(
  file.path,
  deleteOrigin: true,
);
print(info.toJson());
```

**Stop Compress**
```dart
await _flutterVideoCompress.stopCompress()
```

**Subscription process processing stream**
```dart
class ... extends State<MyApp> {
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
}
```

*Notice!* Android will print InterruptedException, but does not affect the use

## example
```dart
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
      File file = await ImagePicker.pickVideo(source: ImageSource.camera);
      if (file?.path != null) {
        final info = await _flutterVideoCompress.getMediaInfo(file.path);
        print(info.toJson());
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
```

## Notice

If you find that the size of the apk is significantly increased after importing the plugin, it may be due to the following reasons:

* `x86` folder is included in you apk (`./assets`)

* This Package only use `ffmpeg` without `ffprobe`,but the `ffprobe` still in you apk (`asssets/arm` or `assets/x86`)

add this config in `build.gradle`:
* __Do not use__ `ignoreAssetsPattern "!x86"` in debug mode, the simulator will. crash

 ```gradle
android {
  ...
	
    // to build apk with unnecessary dependence, you might use this config blow
   aaptOptions {
        ignoreAssetsPattern "!x86:!*ffprobe"
   }
   
   buildTypes {
   ...
   
   }
```
[look up for detail](https://github.com/bravobit/FFmpeg-Android/wiki/Reduce-APK-File-Size#exclude-architecture)