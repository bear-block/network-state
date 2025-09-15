#import <NetworkStateSpec/NetworkStateSpec.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface NetworkState : RCTEventEmitter <RCTBridgeModule, NativeNetworkStateSpec>

@end
