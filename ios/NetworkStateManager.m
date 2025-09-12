#import "NetworkStateManager.h"
#import <Network/Network.h>

@implementation NetworkStateManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _monitor = [[NWPathMonitor alloc] init];
        _monitorQueue = dispatch_queue_create("com.bearblock.networkstate.monitor", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)startMonitoring {
    __weak typeof(self) weakSelf = self;
    self.monitor.pathUpdateHandler = ^(NWPath *path) {
        [weakSelf handlePathUpdate:path];
    };
    // For Obj-C, use startWithQueue:
    [self.monitor startWithQueue:self.monitorQueue];
}

- (void)stopMonitoring {
    [self.monitor cancel];
}

- (void)handlePathUpdate:(NWPath *)path {
    // This will be called by the main NetworkState module
    // to emit events to React Native
}

- (NSDictionary *)getCurrentNetworkState {
    NWPath *currentPath = self.monitor.currentPath;
    BOOL isConnected = currentPath.status == NWPathStatusSatisfied;
    
    if (!isConnected) {
        return @{
            @"type": @"none",
            @"isConnected": @(isConnected),
            @"isInternetReachable": @(isConnected),
            @"isExpensive": @(NO),
            @"isMetered": @(NO)
        };
    }
    
    // Determine network type
    NSString *networkType = [self getNetworkType:currentPath];
    
    // Check if it's expensive (cellular data)
    BOOL isExpensive = [currentPath usesInterfaceType:NWInterfaceTypeCellular];
    
    // Check if it's metered (cellular data is typically metered)
    BOOL isMetered = isExpensive;
    
    // Get detailed network information
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    NSMutableDictionary *capabilities = [NSMutableDictionary dictionary];
    
    // Network transport capabilities
    capabilities[@"hasTransportWifi"] = @([currentPath usesInterfaceType:NWInterfaceTypeWifi]);
    capabilities[@"hasTransportCellular"] = @([currentPath usesInterfaceType:NWInterfaceTypeCellular]);
    capabilities[@"hasTransportEthernet"] = @([currentPath usesInterfaceType:NWInterfaceTypeWiredEthernet]);
    capabilities[@"hasTransportBluetooth"] = @([currentPath usesInterfaceType:NWInterfaceTypeLoopback]); // Bluetooth not directly supported by NWPath
    capabilities[@"hasTransportVpn"] = @(NO); // VPN detection requires additional work
    
    // Network capabilities
    capabilities[@"hasCapabilityInternet"] = @(isConnected);
    capabilities[@"hasCapabilityValidated"] = @(currentPath.status == NWPathStatusSatisfied);
    capabilities[@"hasCapabilityCaptivePortal"] = @(NO); // Would need additional detection
    capabilities[@"hasCapabilityNotRestricted"] = @(YES);
    capabilities[@"hasCapabilityTrusted"] = @(YES);
    capabilities[@"hasCapabilityNotMetered"] = @(!isMetered);
    capabilities[@"hasCapabilityNotRoaming"] = @(YES); // Would need carrier info
    capabilities[@"hasCapabilityForLocal"] = @(YES);
    capabilities[@"hasCapabilityManaged"] = @(NO);
    capabilities[@"hasCapabilityNotSuspended"] = @(YES);
    capabilities[@"hasCapabilityNotVpn"] = @(YES);
    capabilities[@"hasCapabilityNotCellular"] = @(![currentPath usesInterfaceType:NWInterfaceTypeCellular]);
    capabilities[@"hasCapabilityNotWifi"] = @(![currentPath usesInterfaceType:NWInterfaceTypeWifi]);
    capabilities[@"hasCapabilityNotEthernet"] = @(![currentPath usesInterfaceType:NWInterfaceTypeWiredEthernet]);
    capabilities[@"hasCapabilityNotBluetooth"] = @(YES);
    
    details[@"capabilities"] = capabilities;
    
    // iOS does not expose SSID/signal strength without special entitlements; omit.
    
    return @{
        @"type": networkType,
        @"isConnected": @(isConnected),
        @"isInternetReachable": @(isConnected),
        @"isExpensive": @(isExpensive),
        @"isMetered": @(isMetered),
        @"details": details
    };
}

- (NSString *)getNetworkType:(NWPath *)path {
    if ([path usesInterfaceType:NWInterfaceTypeWifi]) {
        return @"wifi";
    } else if ([path usesInterfaceType:NWInterfaceTypeCellular]) {
        return @"cellular";
    } else if ([path usesInterfaceType:NWInterfaceTypeWiredEthernet]) {
        return @"ethernet";
    } else if ([path usesInterfaceType:NWInterfaceTypeLoopback]) {
        return @"bluetooth"; // Loopback might be used for Bluetooth in some cases
    } else {
        return @"unknown";
    }
}

// Omitted private helpers not used by public API

- (BOOL)isNetworkTypeAvailable:(NSString *)type {
    NWPath *currentPath = self.monitor.currentPath;
    
    if ([type isEqualToString:@"wifi"]) {
        return [currentPath usesInterfaceType:NWInterfaceTypeWifi];
    } else if ([type isEqualToString:@"cellular"]) {
        return [currentPath usesInterfaceType:NWInterfaceTypeCellular];
    } else if ([type isEqualToString:@"ethernet"]) {
        return [currentPath usesInterfaceType:NWInterfaceTypeWiredEthernet];
    } else if ([type isEqualToString:@"bluetooth"]) {
        return [currentPath usesInterfaceType:NWInterfaceTypeLoopback];
    }
    
    return NO;
}

- (NSInteger)getNetworkStrength {
    NWPath *currentPath = self.monitor.currentPath;
    
    if ([currentPath usesInterfaceType:NWInterfaceTypeWifi]) {
        // WiFi signal strength requires private API access
        // For now, return a default value
        return -1;
    } else if ([currentPath usesInterfaceType:NWInterfaceTypeCellular]) {
        // Cellular signal strength requires private API access
        // For now, return a default value
        return -1;
    }
    
    return -1;
}

- (BOOL)isNetworkExpensive {
    NWPath *currentPath = self.monitor.currentPath;
    return [currentPath usesInterfaceType:NWInterfaceTypeCellular];
}

- (BOOL)isNetworkMetered {
    NWPath *currentPath = self.monitor.currentPath;
    return [currentPath usesInterfaceType:NWInterfaceTypeCellular];
}

- (void)forceRefresh {
    // Force update network state - useful when app comes to foreground
    [self handlePathUpdate:self.monitor.currentPath];
}

@end
