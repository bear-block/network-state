#import "NetworkStateManager.h"
#import <Network/Network.h>

/**
 * Lightweight capability model attached to NetworkStateModel
 */
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

// No-op for NWPathMonitor-only implementation
- (void)updateFromReachability:(int)unused {}

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

/**
 * Network details (strength/frequency/linkSpeed).
 * iOS does not expose these via public APIs; keep placeholders.
 */
@implementation NetworkDetails

- (instancetype)init {
    if (self = [super init]) {
        _strength = -1;
        _frequency = -1;
        _linkSpeed = -1;
    }
    return self;
}

// No-op for NWPathMonitor-only implementation
- (void)updateFromReachability:(int)unused {}

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
    // Compose details and nest capabilities under details to match JS types
    NSMutableDictionary *detailsDict = [[_details toDictionary] mutableCopy];
    if (!detailsDict) { detailsDict = [NSMutableDictionary dictionary]; }
    detailsDict[@"capabilities"] = [_capabilities toDictionary];
    result[@"details"] = detailsDict;
    return result;
}

@end

@implementation NetworkStateManager {
    NetworkStateModel *_currentNetworkState;
    NSMutableArray<id<NetworkStateListener>> *_listeners;
    nw_path_monitor_t _pathMonitor;
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
        if (_pathMonitor) {
            nw_path_monitor_cancel(_pathMonitor);
            _pathMonitor = NULL;
        }
    } @catch (NSException *exception) {
        NSLog(@"NetworkStateManager dealloc error: %@", exception.reason);
    }
}

// Set up NWPathMonitor (iOS 12+)
- (void)setupReachability {
    @try {
        _pathMonitor = nw_path_monitor_create();
        nw_path_monitor_set_queue(_pathMonitor, dispatch_get_main_queue());
        __weak NetworkStateManager *weakSelf = self;
        nw_path_monitor_set_update_handler(_pathMonitor, ^(nw_path_t  _Nonnull path) {
            NetworkStateManager *strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf updateNetworkStateFromPath:path];
        });
        nw_path_monitor_start(_pathMonitor);
    } @catch (NSException *exception) {
        NSLog(@"NetworkStateManager setupReachability error: %@", exception.reason);
    }
}

// Update current state based on NWPath
- (void)updateNetworkStateFromPath:(nw_path_t)path API_AVAILABLE(ios(12.0)) {
    @try {
        nw_path_status_t status = nw_path_get_status(path);
        BOOL isSatisfied = (status == nw_path_status_satisfied);
        BOOL usesWifi = nw_path_uses_interface_type(path, nw_interface_type_wifi);
        BOOL usesCell = nw_path_uses_interface_type(path, nw_interface_type_cellular);
        BOOL usesEthernet = nw_path_uses_interface_type(path, nw_interface_type_wired);
        BOOL usesOther = nw_path_uses_interface_type(path, nw_interface_type_other);

        _currentNetworkState.isConnected = isSatisfied;
        _currentNetworkState.isInternetReachable = isSatisfied;
        _currentNetworkState.isExpensive = usesCell;
        _currentNetworkState.isMetered = usesCell;
        if (usesWifi) {
            _currentNetworkState.type = @"wifi";
        } else if (usesCell) {
            _currentNetworkState.type = @"cellular";
        } else if (usesEthernet) {
            _currentNetworkState.type = @"ethernet";
        } else if (usesOther) {
            _currentNetworkState.type = @"unknown";
        } else {
            _currentNetworkState.type = isSatisfied ? @"unknown" : @"none";
        }

        // Capabilities
        [_currentNetworkState.capabilities setHasTransportWifi:usesWifi];
        [_currentNetworkState.capabilities setHasTransportCellular:usesCell];
        [_currentNetworkState.capabilities setHasTransportEthernet:usesEthernet];
        [_currentNetworkState.capabilities setHasTransportBluetooth:NO];
        [_currentNetworkState.capabilities setHasTransportVpn:NO];
        [_currentNetworkState.capabilities setHasCapabilityInternet:isSatisfied];
        [_currentNetworkState.capabilities setHasCapabilityValidated:isSatisfied];
        [_currentNetworkState.capabilities setHasCapabilityCaptivePortal:NO];

        // Notify listeners
        if (_listeners) {
            for (id<NetworkStateListener> listener in _listeners) {
                if (listener && [listener respondsToSelector:@selector(onNetworkStateChanged:)]) {
                    [listener onNetworkStateChanged:_currentNetworkState];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"NetworkStateManager updateNetworkStateFromPath error: %@", exception.reason);
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
    if ([typeString isEqualToString:@"wifi"]) {
        return _currentNetworkState.capabilities.hasTransportWifi;
    } else if ([typeString isEqualToString:@"cellular"]) {
        return _currentNetworkState.capabilities.hasTransportCellular;
    } else if ([typeString isEqualToString:@"ethernet"]) {
        return _currentNetworkState.capabilities.hasTransportEthernet;
    } else if ([typeString isEqualToString:@"bluetooth"]) {
        return _currentNetworkState.capabilities.hasTransportBluetooth;
    } else if ([typeString isEqualToString:@"vpn"]) {
        return _currentNetworkState.capabilities.hasTransportVpn;
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
    // Restart monitor to force an immediate update callback
    if (_pathMonitor) {
        nw_path_monitor_cancel(_pathMonitor);
        _pathMonitor = NULL;
    }
    [self setupReachability];
}

@end
