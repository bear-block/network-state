#import <Foundation/Foundation.h>
#import <Network/Network.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkStateManager : NSObject

@property (nonatomic, strong, readonly) NWPathMonitor *monitor;
@property (nonatomic, assign, readonly) dispatch_queue_t monitorQueue;

- (instancetype)init;
- (void)startMonitoring;
- (void)stopMonitoring;
- (NSDictionary *)getCurrentNetworkState;
- (BOOL)isNetworkTypeAvailable:(NSString *)type;
- (NSInteger)getNetworkStrength;
- (BOOL)isNetworkExpensive;
- (BOOL)isNetworkMetered;
- (void)forceRefresh;

@end

NS_ASSUME_NONNULL_END
