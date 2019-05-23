import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_video_compress');

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
