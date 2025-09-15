#import "NetworkStateManager.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation NetworkCapabilities

- (instancetype)init {
    if (self = [super init]) {
        _hasTransportWifi = NO;
        _hasTransportCellular = NO;
        _hasTransportEthernet = NO;
        _hasTransportBluetooth = NO;
        _hasTransportVpn = NO;
        _hasCapabilityInternet = NO;
        _hasCapabilityValidated = NO;
        _hasCapabilityCaptivePortal = NO;
    }
    return self;
}

- (void)updateFromReachability:(SCNetworkReachabilityFlags)flags {
    // Transport capabilities based on reachability flags
    _hasTransportWifi = (flags & kSCNetworkReachabilityFlagsIsWWAN) == 0 && (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    _hasTransportCellular = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;
    _hasTransportEthernet = NO; // SystemConfiguration doesn't distinguish ethernet
    _hasTransportBluetooth = NO; // SystemConfiguration doesn't distinguish bluetooth
    _hasTransportVpn = NO; // SystemConfiguration doesn't distinguish VPN
    
    // Network capabilities
    _hasCapabilityInternet = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    _hasCapabilityValidated = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    _hasCapabilityCaptivePortal = NO; // SystemConfiguration doesn't detect captive portals
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"hasTransportWifi"] = @(_hasTransportWifi);
    result[@"hasTransportCellular"] = @(_hasTransportCellular);
    result[@"hasTransportEthernet"] = @(_hasTransportEthernet);
    result[@"hasTransportBluetooth"] = @(_hasTransportBluetooth);
    result[@"hasTransportVpn"] = @(_hasTransportVpn);
    result[@"hasCapabilityInternet"] = @(_hasCapabilityInternet);
    result[@"hasCapabilityValidated"] = @(_hasCapabilityValidated);
    result[@"hasCapabilityCaptivePortal"] = @(_hasCapabilityCaptivePortal);
    return result;
}

@end

@implementation NetworkDetails

- (instancetype)init {
    if (self = [super init]) {
        _strength = -1;
        _frequency = -1;
        _linkSpeed = -1;
    }
    return self;
}

- (void)updateFromReachability:(SCNetworkReachabilityFlags)flags {
    // SystemConfiguration doesn't provide detailed network information
    _strength = -1;
    _frequency = -1;
    _linkSpeed = -1;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"strength"] = @(_strength);
    result[@"frequency"] = @(_frequency);
    result[@"linkSpeed"] = @(_linkSpeed);
    return result;
}

@end

@implementation NetworkStateModel

- (instancetype)init {
    if (self = [super init]) {
        _isConnected = NO;
        _isInternetReachable = NO;
        _isExpensive = NO;
        _isMetered = NO;
        _type = @"unknown";
        _capabilities = [[NetworkCapabilities alloc] init];
        _details = [[NetworkDetails alloc] init];
    }
    return self;
}

- (void)updateFromReachability:(SCNetworkReachabilityFlags)flags {
    _isConnected = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    _isInternetReachable = (flags & kSCNetworkReachabilityFlagsReachable) != 0;
    _isExpensive = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;
    _isMetered = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;
    
    // Determine network type
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        _type = @"cellular";
    } else if ((flags & kSCNetworkReachabilityFlagsReachable) != 0) {
        _type = @"wifi";
    } else {
        _type = @"unknown";
    }
    
    // Update capabilities and details
    [_capabilities updateFromReachability:flags];
    [_details updateFromReachability:flags];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"isConnected"] = @(_isConnected);
    result[@"isInternetReachable"] = @(_isInternetReachable);
    result[@"isExpensive"] = @(_isExpensive);
    result[@"isMetered"] = @(_isMetered);
    result[@"type"] = _type;
    result[@"capabilities"] = [_capabilities toDictionary];
    result[@"details"] = [_details toDictionary];
    return result;
}

@end

@implementation NetworkStateManager {
    SCNetworkReachabilityRef _reachability;
    NetworkStateModel *_currentNetworkState;
    NSMutableArray<id<NetworkStateListener>> *_listeners;
}

- (instancetype)init {
    if (self = [super init]) {
        _currentNetworkState = [[NetworkStateModel alloc] init];
        _listeners = [NSMutableArray array];
        [self setupReachability];
    }
    return self;
}

- (void)dealloc {
    @try {
        if (_reachability) {
            SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            CFRelease(_reachability);
            _reachability = NULL;
        }
    } @catch (NSException *exception) {
        NSLog(@"NetworkStateManager dealloc error: %@", exception.reason);
    }
}

- (void)setupReachability {
    @try {
        // Create reachability for general internet connectivity
        _reachability = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com");
        
        if (_reachability) {
            SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
            SCNetworkReachabilitySetCallback(_reachability, reachabilityCallback, &context);
            SCNetworkReachabilityScheduleWithRunLoop(_reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            
            // Get initial state
            SCNetworkReachabilityFlags flags;
            if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
                [self updateNetworkState:flags];
            }
        } else {
            NSLog(@"NetworkStateManager: Failed to create reachability");
        }
    } @catch (NSException *exception) {
        NSLog(@"NetworkStateManager setupReachability error: %@", exception.reason);
    }
}

static void reachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    if (info == NULL) return;
    
    @try {
        NetworkStateManager *manager = (__bridge NetworkStateManager *)info;
        if (manager) {
            [manager updateNetworkState:flags];
        }
    } @catch (NSException *exception) {
        NSLog(@"NetworkStateManager reachability callback error: %@", exception.reason);
    }
}

- (void)updateNetworkState:(SCNetworkReachabilityFlags)flags {
    @try {
        if (_currentNetworkState) {
            [_currentNetworkState updateFromReachability:flags];
        }
        
        // Notify listeners
        if (_listeners) {
            for (id<NetworkStateListener> listener in _listeners) {
                if (listener && [listener respondsToSelector:@selector(onNetworkStateChanged:)]) {
                    [listener onNetworkStateChanged:_currentNetworkState];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"NetworkStateManager updateNetworkState error: %@", exception.reason);
    }
}

- (void)addListener:(id<NetworkStateListener>)listener {
    if (listener && ![_listeners containsObject:listener]) {
        [_listeners addObject:listener];
    }
}

- (void)removeListener:(id<NetworkStateListener>)listener {
    [_listeners removeObject:listener];
}

- (NetworkStateModel *)getCurrentNetworkState {
    return _currentNetworkState;
}

- (BOOL)isNetworkTypeAvailable:(NSString *)typeString {
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(_reachability, &flags)) {
        return NO;
    }
    
    if ([typeString isEqualToString:@"wifi"]) {
        return (flags & kSCNetworkReachabilityFlagsReachable) != 0 && (flags & kSCNetworkReachabilityFlagsIsWWAN) == 0;
    } else if ([typeString isEqualToString:@"cellular"]) {
        return (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;
    } else if ([typeString isEqualToString:@"ethernet"]) {
        return NO; // SystemConfiguration doesn't distinguish ethernet
    } else if ([typeString isEqualToString:@"bluetooth"]) {
        return NO; // SystemConfiguration doesn't distinguish bluetooth
    } else if ([typeString isEqualToString:@"vpn"]) {
        return NO; // SystemConfiguration doesn't distinguish VPN
    }
    
    return NO;
}

- (NSInteger)getNetworkStrength {
    // SystemConfiguration doesn't provide network strength
    return -1;
}

- (BOOL)isNetworkExpensive {
    return _currentNetworkState.isExpensive;
}

- (BOOL)isNetworkMetered {
    return _currentNetworkState.isMetered;
}

- (void)forceRefresh {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachability, &flags)) {
        [self updateNetworkState:flags];
    }
}

@end