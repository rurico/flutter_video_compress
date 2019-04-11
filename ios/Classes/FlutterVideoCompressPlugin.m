#import "FlutterVideoCompressPlugin.h"
#import <flutter_video_compress/flutter_video_compress-Swift.h>

@implementation FlutterVideoCompressPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVideoCompressPlugin registerWithRegistrar:registrar];
}
@end
