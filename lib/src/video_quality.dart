part of flutter_video_compress;

class VideoQuality<int> extends Enum<int> {
  const VideoQuality(int val) : super(val);
}

const VideoQuality DEFAULT_QUALITY = const VideoQuality(-1);
const VideoQuality RES_128 = const VideoQuality(0);
const VideoQuality RES_320 = const VideoQuality(1);
const VideoQuality RES_640 = const VideoQuality(2);
const VideoQuality RES_1080 = const VideoQuality(3);

abstract class Enum<T> {
  final T _value;

  const Enum(this._value);

  T get value => _value;
}
