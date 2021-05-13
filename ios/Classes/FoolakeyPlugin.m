#import "FlutterPoolakeyPlugin.h"
#if __has_include(<foolakey/foolakey-Swift.h>)
#import <foolakey/foolakey-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "foolakey-Swift.h"
#endif

@implementation FoolakeyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFoolakeyPlugin registerWithRegistrar:registrar];
}
@end
