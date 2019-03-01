#import "FlutterVedioCompressPlugin.h"
#import <flutter_vedio_compress/flutter_vedio_compress-Swift.h>

@implementation FlutterVedioCompressPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVedioCompressPlugin registerWithRegistrar:registrar];
}
@end
