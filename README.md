# flutter_video_compress

Compressed video generates a new path, you can choose to keep the source video or delete it, and provide a function to get a thumbnail of the video file.

<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_video_compress"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_video_compress.svg"></a>
  <img alt="license" src="https://img.shields.io/github/license/TenkaiRuri/flutter_video_compress.svg">
  <a href="https://github.com/TenkaiRuri/flutter_video_compress"><img alt="github stars" src="https://img.shields.io/github/stars/TenkaiRuri/flutter_video_compress.svg?style=social&label=Stars"></a>
</p>

## Methods
|Function|Parameter|Description|Return|
|--|--|--|--|
|getThumbnail|`String path`, `int quality`|Return a `thumbnail` of the video from the input file uri|`Uint8List` bitmap|
|compressVideo|`String path`, `bool deleteOrigin`|Compress the video file and return a `new path`|`String` path|

## Usage
**Creating instance.**
```dart
FlutterVideoCompress _flutterVideoCompress = FlutterVideoCompress();
```

**Get a video file thumbnail**
```dart
final Uint8List _image = await _flutterVideoCompress
  .getThumbnail(path: file.path, quality: 50)
```

**Compress a Video**
```dart
final String newPath = await _flutterVideoCompress
  .compressVideo(path: file.path, deleteOrigin: true);
  
print(newPath);
```