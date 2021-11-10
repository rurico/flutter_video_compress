<!-- Copyright (c) 2019 Amami Ruri -->

<img align="right" src="https://raw.githubusercontent.com/TenkaiRuri/flutter_video_compress/master/doc/images/logo.svg?sanitize=true" height="180px" style="pointer-events: none;cursor: default;">

# flutter_video_compress

压缩视频并保存至新目录位置(可选择压缩后删除源文件). 获取视频缩略图及视频属性. 轻松处理压缩视频. (考虑到应用大小, 不在 IOS 中使用 FFmpeg 组件)

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
添加[flutter_video_compress](https://pub.dartlang.org/packages/flutter_video_compress)到`pubspec.yaml`:
```yaml
dependencies:
  flutter_video_compress: ^0.3.x
```

**创建一个 FlutterVideoCompress 实例**
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

**视频转 Gif**
```dart
final file = await _flutterVideoCompress.convertVideoToGif(
  videoFile.path,
  startTime: 0, // 默认(0)
  duration: 5, // 默认(-1)
  // endTime: -1 // 默认(-1)
);
debugPrint(file.path);
```

**获取音视频信息**
> 现在支持视频

```dart
final info = await _flutterVideoCompress.getMediaInfo(file.path);
debugPrint(info.toJson().toString());
```

**压缩视频**
> 同时兼容移动端和Web端

```dart
final info = await _flutterVideoCompress.compressVideo(
  file.path,
  quality: VideoQuality.DefaultQuality, // 默认(VideoQuality.DefaultQuality)
  deleteOrigin: false, // 默认(false)
);
debugPrint(info.toJson().toString());
```

**获取压缩状态**
```dart
_flutterVideoCompress.isCompressing
```

**停止压缩**
> Android 会报 `InterruptedException` , 但不影响使用

```dart
await _flutterVideoCompress.cancelCompression()
```

**清理缓存**
> 清理插件生成的所有缓存文件

```dart
await _flutterVideoCompress.deleteAllCache()
```

**监听转换流**
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

## 监听流
|Subscriptions|Description|Stream|
|--|--|--|
|compressProgress$|监听压缩状态流|double `progress`|

## 注意
如果你的程序在使用这个插件后体积明显增大，可以使用下面的方法进行优化:

* 将`x86`相关文件排除 (`./assets`)

* 这个库不使用`ffprobe`，只使用`ffmpeg`，但你的应用中包含`ffprobe`，进行排除 (`asssets/arm` or `assets/x86`)

将此配置添加到`build.gradle`文件中
**请不要在Android模拟器**上使用**`ignoreAssetsPattern'！X86'`，会崩溃!

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

如果你的程序从未使用过swift的插件，你或许会遇到下面的报错，这时候你需要添加如下代码`ios/Podfile`。
> The 'Pods-Runner' target has transitive dependencies that include static binaries

```ruby
pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
```

**若上述方法无效，你可以去报错的仓库提issue，理由是 不能支持swift(Can't support swift)**

[详情](https://github.com/flutter/flutter/issues/16049#issue-309580132)

如果遇到`Regift`报错你可能需要将你的配置文件调整为

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

## 翻译
[HarrisonQI](https://github.com/HarrisonQi) 协助翻译了此 README
