# flutter_video_compress

Compressed video generates a new path, keep the source video or delete it. provide get video information or get thumbnail of the video file.

<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_video_compress"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_video_compress.svg"></a>
  <img alt="license" src="https://img.shields.io/github/license/TenkaiRuri/flutter_video_compress.svg">
</p>

## languages
[english](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/README.md) [简体中文](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/chinese.md) [日本語](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/japanese.md) 

## Before Android installation
If your program not enabled `AndroidX`, you will need to add the following code to the last line of the `android/build.gradle` file.
```groovy
rootProject.allprojects {
    subprojects {
        project.configurations.all {
            resolutionStrategy.eachDependency { details ->
                if (details.requested.group == 'androidx.core' && !details.requested.name.contains('androidx')) {
                    details.useVersion "1.0.1"
                }
            }
        }
    }
}
```

## Before IOS installation
If your program not support swift, you need to add the following code in `ios/Podfile`.[detail](https://github.com/flutter/flutter/issues/16049#issuecomment-382629492)

```ruby
target 'Runner' do
  use_frameworks! # <--- add this
  ...
end

# -----insert code start-----
pre_install do |installer|
  installer.analysis_result.specifications.each do |s|
      if s.name == 'Regift'
        s.swift_version = '4.0'
    # elsif s.name == 'other-Plugin'
    #   s.swift_version = '5.0'
    # else
    #   s.swift_version = '4.0'
      end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
# -----insert code end-----
```

## Methods
|function|parameter|description|return|
|--|--|--|--|
|getThumbnail|String `[path]`, int `[quality]`(1-100), int `[position]`|get thumbnail from `[path]`|`[Future<Uint8List>]`|
|getThumbnailWithFile|String `[path]`, int `[quality]`(1-100), int `[position]`|get thumbnail file from `[path]`|`[Future<File>]`|
|convertVideoToGif|String `[path]`, int `[startTime]`(from 0 start), int `[endTime]`, int `[duration]`|converts provided video to a gif|`[Future<File>]`|
|getMediaInfo|String `[path]`|get media information from `[path]`|`[Future<MediaInfo>]`|
|startCompress|String `[path]`, VideoQuality `[quality]` ,bool `[deleteOrigin]`|compress video at `[path]`|`[Future<MediaInfo>]`|
|stopCompress|`[none]`|stop compressing the file that is currently being compressed.|`[Future<void>]`|

## Subscriptions
|subscription|description|stream|
|--|--|--|
|compressProgress$|Subscribe the conversion progress steam|double `[progress]`|

## Usage

**Installing**
add [flutter_video_compress](https://pub.dartlang.org/packages/flutter_video_compress) as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  flutter_video_compress: ^0.3.x
```

**Creating instance.**
```dart
final _flutterVideoCompress = FlutterVideoCompress();
```

**Get thumbnail by video file**
```dart
final uint8list = await _flutterVideoCompress.getThumbnail(
  file.path,
  quality: 50,
);
```

**Get thumbnail file by video file**
```dart
final thumbnailFile = await _flutterVideoCompress.getThumbnailWithFile(
  file.path,
  quality: 50,
);
```

**Converts provided video to a gif.**
```dart
final file = await _flutterVideoCompress.convertVideoToGif(
  videoFile.path,
  startTime: 0,
  duration: 5,
);
print(file.path);
```

**Get media information**
> Currently only supports video

```dart
final info = await _flutterVideoCompress.getMediaInfo(file.path);
print(info.toJson());
```

**Compression Video**
> Compatible with ios in Android and web after compression

```dart
final info = await _flutterVideoCompress.startCompress(
  file.path,
  deleteOrigin: true,
);
print(info.toJson());
```

**Check Compressing state**
```dart
_flutterVideoCompress.isCompressing
```

**Stop compression**
> Android will print InterruptedException, but does not affect the use

```dart
await _flutterVideoCompress.stopCompress()
```

**Subscribe the conversion progress steam**
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

## Notice

If you find that the size of the apk is significantly increased after importing the plugin, it may be due to the following reasons:

* exclude `x86` related files (`./assets`)

* This library does not use `ffprobe`, only uses` ffmpeg`, but the application still has `ffprobe`, so it needs to be excluded (`asssets/arm` or `assets/x86`)

add this config in `build.gradle`:
* __Do not use__ `ignoreAssetsPattern "!x86"` in debug mode, will crash on the simulator

 ```gradle
android {
  ...
	
    // Reduce your application size with this configuration
   aaptOptions {
        ignoreAssetsPattern "!x86:!*ffprobe"
   }
   
   buildTypes {
   ...
   
   }
```
[look up for detail](https://github.com/bravobit/FFmpeg-Android/wiki/Reduce-APK-File-Size#exclude-architecture)