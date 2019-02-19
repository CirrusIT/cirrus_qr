#import "CirrusQrPlugin.h"
#import <cirrus_qr/cirrus_qr-Swift.h>

@implementation CirrusQrPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCirrusQrPlugin registerWithRegistrar:registrar];
}
@end
