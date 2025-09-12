#import <Foundation/Foundation.h>
#import <React/RCTEventEmitter.h>

#if RCT_NEW_ARCH_ENABLED
#import <NetworkStateSpec/NetworkStateSpec.h>
@interface NetworkState : RCTEventEmitter <NativeNetworkStateSpec>
#else
@interface NetworkState : RCTEventEmitter
#endif

@end
