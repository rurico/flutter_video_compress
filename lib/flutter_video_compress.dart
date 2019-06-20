/// Compressed video generates a new path, keep the source video or delete it.
/// provide get video information or get thumbnail of the video file.

library flutter_video_compress;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'src/flutter_video_compress.dart';
part 'src/video_quality.dart';
part 'src/observable_builder.dart';
part 'model/media_info.dart';
