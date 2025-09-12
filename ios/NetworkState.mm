#import "NetworkState.h"
#import "NetworkStateManager.h"
#import <Network/Network.h>

@interface NetworkState ()
@property (nonatomic, strong) NetworkStateManager *networkStateManager;
@property (nonatomic, assign) BOOL hasListeners;
@end

@implementation NetworkState

RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkStateManager = [[NetworkStateManager alloc] init];
        _hasListeners = NO;
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"networkStateChanged"];
}

- (void)startObserving {
    self.hasListeners = YES;
}

- (void)stopObserving {
    self.hasListeners = NO;
}

RCT_EXPORT_METHOD(getNetworkState:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSDictionary *networkState = [self.networkStateManager getCurrentNetworkState];
        resolve(networkState);
    } @catch (NSException *exception) {
        reject(@"NETWORK_STATE_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(startNetworkStateListener) {
    __weak NetworkState *weakSelf = self;
    weakSelf.networkStateManager.monitor.pathUpdateHandler = ^(NWPath *path) {
        if (weakSelf.hasListeners) {
            NSDictionary *state = [weakSelf.networkStateManager getCurrentNetworkState];
            [weakSelf sendEventWithName:@"networkStateChanged" body:state];
        }
    };
    // Use startWithQueue: in Obj-C
    [weakSelf.networkStateManager.monitor startWithQueue:weakSelf.networkStateManager.monitorQueue];
}

RCT_EXPORT_METHOD(stopNetworkStateListener) {
    [self.networkStateManager stopMonitoring];
}

RCT_EXPORT_METHOD(isNetworkTypeAvailable:(NSString *)type
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        BOOL isAvailable = [self.networkStateManager isNetworkTypeAvailable:type];
        resolve(@(isAvailable));
    } @catch (NSException *exception) {
        reject(@"NETWORK_TYPE_CHECK_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(getNetworkStrength:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSInteger strength = [self.networkStateManager getNetworkStrength];
        resolve(@(strength));
    } @catch (NSException *exception) {
        reject(@"NETWORK_STRENGTH_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(isNetworkExpensive:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        BOOL isExpensive = [self.networkStateManager isNetworkExpensive];
        resolve(@(isExpensive));
    } @catch (NSException *exception) {
        reject(@"NETWORK_EXPENSIVE_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(isNetworkMetered:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        BOOL isMetered = [self.networkStateManager isNetworkMetered];
        resolve(@(isMetered));
    } @catch (NSException *exception) {
        reject(@"NETWORK_METERED_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(forceRefresh) {
    [self.networkStateManager forceRefresh];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeNetworkStateSpecJSI>(params);
}

@end
