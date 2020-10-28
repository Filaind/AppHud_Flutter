#import "ApphudFlutterPlugin.h"
#if __has_include(<apphud_flutter/apphud_flutter-Swift.h>)
#import <apphud_flutter/apphud_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apphud_flutter-Swift.h"
#endif

@implementation ApphudFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApphudFlutterPlugin registerWithRegistrar:registrar];
}
@end
