<!-- Copyright (c) 2019 Amami Ruri -->

<img align="right" src="https://raw.githubusercontent.com/TenkaiRuri/flutter_video_compress/master/doc/images/logo.svg?sanitize=true" height="180px" style="pointer-events: none;cursor: default;">

# flutter_video_compress
新しいパスで圧縮ビデオを生成します。ソースビデオを保持するか、パラメータで削除するかを選択します。ビデオのサムネイルを取得し、ビデオ情報を提供します。圧縮ビデオを扱うのが簡単です。アプリケーションサイズを縮小の考えIOSはFFmpegを使用しません。

<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_video_compress"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_video_compress.svg"></a>
  <img alt="license" src="https://img.shields.io/github/license/TenkaiRuri/flutter_video_compress.svg">
  <img alt="android min Sdk Version" src="https://img.shields.io/badge/android-16-success.svg?logo=android">
  <img alt="ios min target" src="https://img.shields.io/badge/ios-8-lightgrey.svg?logo=apple">
</p>

<div align="center">
  <img height="500px" alt="flutter compress video" style="pointer-events: none;cursor: default;" src="https://github.com/TenkaiRuri/flutter_video_compress/raw/master/doc/images/preview.gif"/>
</div>

## ランゲージ
[日本語](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/japanese.md#flutter_video_compress) [English](https://github.com/TenkaiRuri/flutter_video_compress#flutter_video_compress) [简体中文](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/chinese.md#flutter_video_compress)

## 使用方法

**インストール**
pubspec.yamlファイルに依存ライブラリーとして[flutter_video_compress](https://pub.dartlang.org/packages/flutter_video_compress)を追加します。

```yaml
dependencies:
  flutter_video_compress: ^0.3.x
```

**インスタンスを作成**
```dart
final _flutterVideoCompress = FlutterVideoCompress();
```

**ビデオファイルでサムネイルを取得する**
```dart
final uint8list = await _flutterVideoCompress.getThumbnail(
  file.path,
  quality: 50, // default(100)
  position: -1 // default(-1)
);
```

**ビデオファイルでサムネイルファイルを取得する**
```dart
final thumbnailFile = await _flutterVideoCompress.getThumbnailWithFile(
  file.path,
  quality: 50, // default(100)
  position: -1 // default(-1)
);
```

**ビデオをGIFに変換する**
```dart
final file = await _flutterVideoCompress.convertVideoToGif(
  videoFile.path,
  startTime: 0, // default(0)
  duration: 5, // default(-1)
  // endTime: -1 // default(-1)
);
debugPrint(file.path);
```

**メディア情報を入手する**
> 現在はビデオのみをサポートしています

```dart
final info = await _flutterVideoCompress.getMediaInfo(file.path);
debugPrint(info.toJson().toString());
```

**ビデオを圧縮する**
> 圧縮後のアンドロイドおよびウェブとIOSの互換性ある

```dart
final info = await _flutterVideoCompress.compressVideo(
  file.path,
  quality: VideoQuality.DefaultQuality, // default(VideoQuality.DefaultQuality)
  deleteOrigin: false, // default(false)
);
debugPrint(info.toJson().toString());
```

**圧縮の状態を確認する**
```dart
_flutterVideoCompress.isCompressing
```

**圧縮を停止する**
> アンドロイドはInterruptedExceptionを出力します、使用には影響しません

```dart
await _flutterVideoCompress.cancelCompression()
```

**すべてのキャッシュファイルを削除する**
> このプラグインによって生成されたすべてのファイルを削除します、何をしているか知っておくべきだと思います。

```dart
await _flutterVideoCompress.deleteAllCache()
```

**変換の進行状況をサブスクリプションする**
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

## メソッド
|Functions|Parameters|Description|Returns|
|--|--|--|--|
|getThumbnail|String `path`[ビデオのパス], int `quality`(1-100)[サムネイルの品質], int `position`[ビデオ位置からサムネイルを取得します]|動画の`path`からサムネイルを取得します|`Future<Uint8List>`|
|getThumbnailWithFile|String `path`[ビデオのパス], int `quality`(1-100)[サムネイルの品質], int `position`[ビデオ位置からサムネイルを取得します]|動画の`path`からサムネイルファイルを取得します|`Future<File>`|
|convertVideoToGif|String `path`[ビデオのパス], int `startTime`(from 0 start)[ビデオをgifに変換するの始まり時間], int `endTime`[動画をgifに変換するの終了時間], int `duration`[始まり時間から動画の期間]|動画を`path`からgifに変換します|`Future<File>`|
|getMediaInfo|String `path`[ビデオのパス]|ビデオの`path`から情報を取得します|`Future<MediaInfo>`|
|compressVideo|String `path`[ビデオのパス], VideoQuality `quality`[圧縮ビデオ品質], bool `deleteOrigin`[元の動画を削除する], int `startTime`[圧縮ビデオの開始時間], int `duration`[始まり時間から動画の期間], bool `includeAudio`[圧縮ビデオに音声を含める], int `frameRate`[圧縮ビデオフレームレート]|`path`からビデオを圧縮する|`Future<MediaInfo>`|
|cancelCompression|`none`|圧縮をキャンセル|`Future<void>`|
|deleteAllCache|`none`|'flutter_video_compress'によって生成されたすべてのファイルを削除すると、 'flutter_video_compress'にあるすべてのファイルが削除されます|`Future<bool>`|

## サブスクリプション
|Subscriptions|Description|Stream|
|--|--|--|
|compressProgress$|変換の進行状況をサブスクリプションする|double `progress`|

## お知らせ
プラグインをインポートした後にアプリケーションのサイズが大幅に増加していることがわかった場合は、以下の処理方法が考えられます。

* `x86`関連ファイルを排除する (`./assets`)

このライブラリは `ffprobe`を使わず、` ffmpeg`だけを使いますが、あなたのアプリケーションにはまだ `ffprobe`があるので、あなたはそれを除外する必要があります。

* このライブラリーは `ffprobe`を使用なし、`ffmpeg`だけを使いします、だけどアプリケーションにはまだ `ffprobe`があるので、それを除外する必要があります (`asssets/arm` or `assets/x86`)

この設定を`build.gradle`ファイルに追加してください
アンドロイドエミュレータで `ignoreAssetsPattern "!x86"`を**使わないでください**、クラッシュします

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
[詳細説明](https://github.com/bravobit/FFmpeg-Android/wiki/Reduce-APK-File-Size#exclude-architecture)

アプリケーションが`AndroidX`に対応していない場合は、`android￥build.gradle`ファイルの最後の行に以下のコードを追加する必要があります。```groovy
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

アプリケーションがswiftをサポートしていない場合は、`ios￥Podfile`に以下のコードを追加する必要があります
```ruby
target 'Runner' do
  use_frameworks! # <--- add this
  ...
end
```

[詳細説明](https://github.com/flutter/flutter/issues/16049#issuecomment-382629492)


アプリケーションがswiftをサポートしていない場合は、`ios￥Podfile`に以下のコードを追加する必要があります
> The 'Pods-Runner' target has transitive dependencies that include static binaries
```ruby
pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
```
[詳細説明](https://github.com/flutter/flutter/issues/16049#issue-309580132)

`Regift`のエラーを表示するなら
```ruby
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
```

## TODO
- [ ] IOSコードをObjective-Cにリファクタリングする

## 貢献ガイドライン

貢献はいつでも歓迎です！
<!-- [貢献ガイドライン]を読んでください(contributing.md) -->