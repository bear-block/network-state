#import "NetworkState.h"
#import "NetworkStateManager.h"

@interface NetworkState () <NetworkStateListener>
@property (nonatomic, strong) NetworkStateManager *networkStateManager;
@end

@implementation NetworkState
RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

- (instancetype)init {
    if (self = [super init]) {
        _networkStateManager = [[NetworkStateManager alloc] init];
        [_networkStateManager addListener:self];
    }
    return self;
}

- (void)onNetworkStateChanged:(id)networkState {
    if ([networkState isKindOfClass:[NetworkStateModel class]]) {
        [self sendNetworkStateEvent:(NetworkStateModel *)networkState];
    }
}

- (void)sendNetworkStateEvent:(NetworkStateModel *)networkState {
    NSDictionary *eventData = [networkState toDictionary];
    [self sendEventWithName:@"networkStateChanged" body:eventData];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"networkStateChanged"];
}

// MARK: - NativeNetworkStateSpec Implementation

RCT_EXPORT_METHOD(getNetworkState:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    @try {
        NetworkStateModel *networkState = [self.networkStateManager getCurrentNetworkState];
        NSDictionary *result = [networkState toDictionary];
        resolve(result);
    } @catch (NSException *exception) {
        reject(@"NETWORK_STATE_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(startNetworkStateListener) {
    // NetworkStateManager automatically starts listening in init
}

RCT_EXPORT_METHOD(stopNetworkStateListener) {
    [self.networkStateManager removeListener:self];
}

RCT_EXPORT_METHOD(isNetworkTypeAvailable:(NSString *)type
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    @try {
        BOOL isAvailable = [self.networkStateManager isNetworkTypeAvailable:type];
        resolve(@(isAvailable));
    } @catch (NSException *exception) {
        reject(@"NETWORK_TYPE_CHECK_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(getNetworkStrength:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    @try {
        NSInteger strength = [self.networkStateManager getNetworkStrength];
        resolve(@(strength));
    } @catch (NSException *exception) {
        reject(@"NETWORK_STRENGTH_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(isNetworkExpensive:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    @try {
        BOOL isExpensive = [self.networkStateManager isNetworkExpensive];
        resolve(@(isExpensive));
    } @catch (NSException *exception) {
        reject(@"NETWORK_EXPENSIVE_ERROR", exception.reason, nil);
    }
}

RCT_EXPORT_METHOD(isNetworkMetered:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
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

// MARK: - TurboModule Support

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeNetworkStateSpecJSI>(params);
}

@end
