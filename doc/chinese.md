# flutter_video_compress

在新路径生成新压缩文件，保持源文件或者删除它，提供获取视频信息或者缩略图的函数

<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_video_compress"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_video_compress.svg"></a>
  <img alt="license" src="https://img.shields.io/github/license/TenkaiRuri/flutter_video_compress.svg">
</p>

## 语言
[简体中文](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/chinese.md) [日本語](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/japanese.md) [english](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/README.md)

## 在Android上运行前
如果你的程序没有启用`AndroidX`，你需要将下列代码添加到你的`android/build.gradle`文件中最后一行

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

## 在IOS上运行前
如果你的APP支持或者没有开启swift，你需要将下面代码添加到`ios/Podfile`中。[详情](https://github.com/flutter/flutter/issues/16049#issuecomment-382629492)

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

## 方法
|function|parameter|description|return|
|--|--|--|--|
|getThumbnail|String `[path]`, int `[quality]`(1-100), int `[position]`|从`[path]`获取缩略图|`[Future<Uint8List>]`|
|getThumbnailWithFile|String `[path]`, int `[quality]`(1-100), int `[position]`|从`[path]`获取缩略图文件|`[Future<File>]`|
|convertVideoToGif|String `[path]`, int `[startTime]`(从0开始), int `[endTime]`, int `[duration]`|将视频转换为gif|`[Future<File>]`|
|getMediaInfo|String `[path]`|从`[path]`获取媒体信息|`[Future<MediaInfo>]`|
|compressVideo|String `[path]`, VideoQuality `[quality]`, bool `[deleteOrigin]`, int `[startTime]`, int `[duration]`, bool `[includeAudio]`, bool `[frameRate]`|在`[path]`生成视频压缩文件|`[Future<MediaInfo>]`|
|cancelCompression|`[none]`|停止正在压缩的视频|`[Future<void>]`|
|deleteAllCache|`[none]`|删除缓存，请不要在这个插件的文件夹中放置其他东西，将会被清除|`[Future<void>]`|

## Subscriptions
|subscription|description|stream|
|--|--|--|
|compressProgress$|订阅转换流(stream)|double `[progress]`|

## 用户指南

**安装**
添加 [flutter_video_compress](https://pub.dartlang.org/packages/flutter_video_compress) 在你的pubspec.yaml依赖中.
```yaml
dependencies:
  flutter_video_compress: ^0.3.x
```

**创建一个实例**
```dart
final _flutterVideoCompress = FlutterVideoCompress();
```

**从视频文件获得缩略图**
```dart
final uint8list = await _flutterVideoCompress.getThumbnail(
  file.path,
  quality: 50,
);
```

**从视频文件获得缩略图文件**
```dart
final thumbnailFile = await _flutterVideoCompress.getThumbnailWithFile(
  file.path,
  quality: 50,
);
```

**将视频转换为gif**
```dart
final file = await _flutterVideoCompress.convertVideoToGif(
  videoFile.path,
  startTime: 0,
  duration: 5,
);
print(file.path);
```

**获取媒体信息**
> 目前只支持视频

```dart
final info = await _flutterVideoCompress.getMediaInfo(file.path);
print(info.toJson());
```

**压缩视频**
> 移动端平台及web平台视频格式是兼容的

```dart
final info = await _flutterVideoCompress.compressVideo(
  file.path,
  deleteOrigin: true,
);
print(info.toJson());
```

**检查是否处于压缩状态**
```dart
_flutterVideoCompress.isCompressing
```

**停止压缩**
> Android 会打印 InterruptedException 错误, 但是不会影响使用

```dart
await _flutterVideoCompress.cancelCompression()
```

**删除所有缓存文件**
> 删除缓存，请不要在这个插件的文件夹中放置其他东西，将会被清除

```dart
await _flutterVideoCompress.deleteAllCache()
```

**订阅转换流**
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

## 注意事项
如果你的程序在用了插件后大幅增加体积，你可以采取下面的方式缩减APP体积:

* 将`x86`相关文件排除 (`./assets`)

* 这个库不使用`ffprobe`，只使用`ffmpeg`，但你的应用程序中仍然有`ffprobe`，你需要排除他 (`asssets/arm` or `assets/x86`)

将此配置添加到`build.gradle`文件中
**不要在Android模拟器**上使用**`ignoreAssetsPattern'！X86'`，将会崩溃

 ```gradle
android {
  ...
  
  // 减小应用程序大小的配置
  aaptOptions {
      ignoreAssetsPattern "!x86:!*ffprobe"
  }
   
  buildTypes {
  ...

  }
```
[详情说明](https://github.com/bravobit/FFmpeg-Android/wiki/Reduce-APK-File-Size#exclude-architecture)