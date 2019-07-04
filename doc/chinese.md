<!-- Copyright (c) 2019 Amami Ruri -->

<img align="right" src="https://raw.githubusercontent.com/TenkaiRuri/flutter_video_compress/master/doc/images/logo.svg?sanitize=true" height="180px" style="pointer-events: none;cursor: default;">

# flutter_video_compress

压缩视频生成新路径，选择保留源视频或删除它。从视频路径获取视频缩略图并提供视频信息。方便的处理压缩视频。考虑减少应用程序大小不在IOS中使用FFmpeg

<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_video_compress"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_video_compress.svg"></a>
  <img alt="license" src="https://img.shields.io/github/license/TenkaiRuri/flutter_video_compress.svg">
  <img alt="android min Sdk Version" src="https://img.shields.io/badge/android-16-success.svg?logo=android">
  <img alt="ios min target" src="https://img.shields.io/badge/ios-8-lightgrey.svg?logo=apple">
</p>

<div align="center">
  <img height="500px" alt="flutter compress video" style="pointer-events: none;cursor: default;" src="https://github.com/TenkaiRuri/flutter_video_compress/raw/master/doc/images/preview.gif"/>
</div>

## 语言
[简体中文](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/chinese.md#flutter_video_compress) [日本語](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/japanese.md#flutter_video_compress) [English](https://github.com/TenkaiRuri/flutter_video_compress#flutter_video_compress)

## 用户指南

**安装**
添加[flutter_video_compress](https://pub.dartlang.org/packages/flutter_video_compress)到你的pubspec.yaml文件中.
```yaml
dependencies:
  flutter_video_compress: ^0.3.x
```

**创建一个实例**
```dart
final _flutterVideoCompress = FlutterVideoCompress();
```

**获取缩略图**
```dart
final uint8list = await _flutterVideoCompress.getThumbnail(
  file.path,
  quality: 50, // 默认(100)
  position: -1 // 默认(-1)
);
```

**获取缩略图文件**
```dart
final thumbnailFile = await _flutterVideoCompress.getThumbnailWithFile(
  file.path,
  quality: 50, // 默认(100)
  position: -1 // 默认(-1)
);
```

**转换视频为gif**
```dart
final file = await _flutterVideoCompress.convertVideoToGif(
  videoFile.path,
  startTime: 0, // 默认(0)
  duration: 5, // 默认(-1)
  // endTime: -1 // 默认(-1)
);
debugPrint(file.path);
```

**获取媒体信息**
> 现在支持持视频

```dart
final info = await _flutterVideoCompress.getMediaInfo(file.path);
debugPrint(info.toJson().toString());
```

**压缩视频**
> 移动端平台及web平台视频格式是兼容的

```dart
final info = await _flutterVideoCompress.compressVideo(
  file.path,
  quality: VideoQuality.DefaultQuality, // 默认(VideoQuality.DefaultQuality)
  deleteOrigin: false, // 默认(false)
);
debugPrint(info.toJson().toString());
```

**检查压缩状态**
```dart
_flutterVideoCompress.isCompressing
```

**停止压缩**
> Android 会打印 InterruptedException 错误, 但是不会影响使用

```dart
await _flutterVideoCompress.cancelCompression()
```

**删除所有缓存文件**
> 删除这个插件生成的所有文件，我想你应该知道你在做什么

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
      debugPrint('progress: $progress');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.unsubscribe();
  }
}
```

## 方法
|Functions|Parameters|Description|Returns|
|--|--|--|--|
|getThumbnail|String `path`[视频路径], int `quality`(1-100)[缩略图质量], int `position`[通过位置（时间）获取是缩略图]|从`path`获取缩略图|`Future<Uint8List>`|
|getThumbnailWithFile|String `path`[视频路径], int `quality`(1-100)[缩略图质量], int `position`[通过位置（时间）获取是缩略图]|从`path`获取缩略图文件`path`|`Future<File>`|
|convertVideoToGif|String `path`[视频路径], int `startTime`(from 0 start)[转换视频为gif的开始时间], int `endTime`[转换视频为gif的结束时间], int `duration`[从开始时间转换视频为gif的持续时间]|从`path`将视频转换为gif|`Future<File>`|
|getMediaInfo|String `path`[视频路径]|从`path`获取到视频的媒体信息|`Future<MediaInfo>`|
|compressVideo|String `path`[视频路径], VideoQuality `quality`[压缩视频质量], bool `deleteOrigin`[是否删除源视频文件], int `startTime`[压缩视频的开始时间], int `duration`[压缩视频的持续时间], bool `includeAudio`[是否包含音频], int `frameRate`[压缩视频帧率]|从`path`压缩视频|`Future<MediaInfo>`|
|cancelCompression|`none`|取消压缩|`Future<void>`|
|deleteAllCache|`none`|删除位于'flutter_video_compress'的所有文件|`Future<bool>`|

## 订阅流
|Subscriptions|Description|Stream|
|--|--|--|
|compressProgress$|订阅压缩状态流|double `progress`|

## 注意
如果你的程序在使用这个插件后体积明显增大，可以使用下面的方法优化你的体积

* 将`x86`相关文件排除 (`./assets`)

* 这个库不使用`ffprobe`，只使用`ffmpeg`，但你的应用中仍然有`ffprobe`，你需要排除他 (`asssets/arm` or `assets/x86`)

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
[详情](https://github.com/bravobit/FFmpeg-Android/wiki/Reduce-APK-File-Size#exclude-architecture)

## 问题列表

如果你的APP未开启`AndroidX`，你需要将下面代码添加到你的`android/build.gradle`文件里。
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

如果你的程序不支持swift，你需要在`ios/Podfile`文件加入下例代码。
```ruby
target 'Runner' do
  use_frameworks! # <--- add this
  ...
end
```

[详情](https://github.com/flutter/flutter/issues/16049#issuecomment-382629492)

如果你的程序从未使用过swift的插件，你或许会遇到下面的报错，这时候你需要添加下例代码`ios/Podfile`。
> The 'Pods-Runner' target has transitive dependencies that include static binaries

```ruby
pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
```

**如果上述方法不管用，你可以去报错的仓库提issue，理由是 不能支持swift(Can't support swift)**

[详情](https://github.com/flutter/flutter/issues/16049#issue-309580132)

如果遇到`Regift`报错你可能需要将你的配置文件改成这样

> - `Regift` does not specify a Swift version and none of the targets (`Runner`) integrating it have the `SWIFT_VERSION` attribute set. Please contact the author or set the `SWIFT_VERSION` attribute in at least one of the targets that integrate this pod.

```ruby
pre_install do |installer|
  installer.analysis_result.specifications.each do |s|
      if s.name == 'Regift'
        s.swift_version = '4.0'
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
```

## 贡献指南

欢迎每一个贡献
<!-- 首先请查看[贡献指南](contributing.md)。 -->