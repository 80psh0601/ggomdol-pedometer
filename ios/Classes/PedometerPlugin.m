#import "PedometerPlugin.h"
#if __has_include(<ggomdol_pedometer/ggomdol_pedometer-Swift.h>)
#import <ggomdol_pedometer/ggomdol_pedometer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ggomdol_pedometer-Swift.h"
#endif

@implementation PedometerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPedometerPlugin registerWithRegistrar:registrar];
}
@end
