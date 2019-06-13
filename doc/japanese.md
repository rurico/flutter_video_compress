# flutter_video_compress

新しいパスに圧縮ビデオを生成し、ソースビデオを削除しまたは保つ。同時にビデオの情報を提供します。

<p align="left">
  <a href="https://pub.dartlang.org/packages/flutter_video_compress"><img alt="pub version" src="https://img.shields.io/pub/v/flutter_video_compress.svg"></a>
  <img alt="license" src="https://img.shields.io/github/license/TenkaiRuri/flutter_video_compress.svg">
</p>

## ランゲージ
[日本語](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/japanese.md) [english](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/README.md) [简体中文](https://github.com/TenkaiRuri/flutter_video_compress/blob/master/doc/chinese.md)

## アンドロイドを使用する前にの準備仕事
アプリケーションが`アンドロイドエクス(AndroidX)`機能が有効ない場合は、 `android￥build.gradle`ファイルの最後の行に以下のコードを追加する必要があります。

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

## IOSを使用する前にの準備仕事
アプリケーションがswiftをサポートしていない場合は、 `ios￥Podfile`に以下のコードを追加する必要があります

[詳細説明](https://github.com/flutter/flutter/issues/16049#issuecomment-382629492)

```ruby
target 'Runner' do
  use_frameworks! # <- add this line
```

## メソッド
|function|parameter|description|return|
|--|--|--|--|
|getThumbnail|String `[path]`, int `[quality]`(1-100), int `[position]`|`[path]`からサムネイルを取得します|`[Future<Uint8List>]`|
|getThumbnailWithFile|String `[path]`, int `[quality]`(1-100), int `[position]`|`[path]`からサムネイルのファイルを取得します|`[Future<File>]`|
|getMediaInfo|String `[path]`|`[path]`からビデオの情報を取得します|`[Future<MediaInfo>]`|
|startCompress|String `[path]`, VideoQuality `[quality]` ,bool `[deleteOrigin]`|`[path]`でビデオを圧縮する|`[Future<MediaInfo>]`|
|stopCompress|`[none]`|圧縮中のファイルを停止します|`[Future<void>]`|

## サブスクリプション
|subscription|description|stream|
|--|--|--|
|compressProgress$|変換の進行状況をサブスクリプションする|double `[progress]`|

## 使用方法

**インストール**
pubspec.yamlファイルに依存ライブラリーとして[flutter_video_compress](https://pub.dartlang.org/packages/flutter_video_compress)を追加します。

```yaml
dependencies:
  flutter_video_compress: ^0.3.x
```

**インスタンスを作成**
```dart
FlutterVideoCompress _flutterVideoCompress = FlutterVideoCompress();
```

**ビデオファイルでサムネイルを取得する**
```dart
final uint8list = await _flutterVideoCompress.getThumbnail(
  file.path,
  quality: 50,
);
```

**ビデオファイルでサムネイルファイルを取得する**
```dart
final thumbnailFile = await _flutterVideoCompress.getThumbnailWithFile(
  file.path,
  quality: 50,
);
```

**メディア情報を入手する**
> 現在はビデオのみをサポートしています

```dart
final info = await _flutterVideoCompress.getMediaInfo(file.path);
print(info.toJson());
```

**ビデオを圧縮する**
> 圧縮後のアンドロイドおよびウェブとIOSの互換性ある

```dart
final info = await _flutterVideoCompress.startCompress(
  file.path,
  deleteOrigin: true,
);
print(info.toJson());
```

**圧縮の状態を確認する**
```dart
_flutterVideoCompress.isCompressing
```

**圧縮を停止**
> アンドロイドはInterruptedExceptionを出力します、使用には影響しません

```dart
await _flutterVideoCompress.stopCompress()
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
	
    // アプリケーションのサイズを縮小する
   aaptOptions {
        ignoreAssetsPattern "!x86:!*ffprobe"
   }
   
   buildTypes {
   ...
   
   }
```
[詳細説明](https://github.com/bravobit/FFmpeg-Android/wiki/Reduce-APK-File-Size#exclude-architecture)