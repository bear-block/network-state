## 1.1.0

- iOS: Switch to NWPathMonitor-only, drop SystemConfiguration. iOS min 12.0.
- iOS: Proper NativeEventEmitter wiring with startObserving lifecycle.
- Android: Prevent duplicate collectors; manage coroutine Job.
- TS: Relax NetworkCapabilities fields to optional; `NetworkDetails.capabilities` optional.
- Hook: Remove circular import; use NativeEventEmitter on iOS, DeviceEventEmitter on Android.
- Docs: Update README to match new behavior and minimum OS versions.
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added
- **Modern Network State Tracking**: Complete rewrite using Android 10+ (API 29+) Network Capabilities API
- **iOS Support**: Full iOS implementation using NWPathMonitor and Network framework (iOS 12+)
- **Cross-Platform API**: Consistent network state tracking across Android and iOS
- **NetworkStateManager**: Core Android implementation for network state management
- **iOS NetworkStateManager**: Core iOS implementation using NWPathMonitor
- **Real-time Network Monitoring**: Listen to network changes using NetworkCallback (Android) and NWPathMonitor (iOS)
- **Comprehensive Network Information**: Support for WiFi, Cellular, Ethernet, Bluetooth, and VPN on both platforms
- **Network Capabilities Detection**: Full access to network transport and capability information
- **WiFi Details**: SSID, BSSID, signal strength, frequency, and link speed (platform-specific)
- **React Hook**: `useNetworkState` hook for easy React Native integration
- **TypeScript Support**: Complete type definitions and interfaces
- **Modern Platform APIs**: Uses NetworkCapabilities (Android) and NWPathMonitor (iOS) instead of deprecated methods
- **Permission Handling**: Automatic platform-specific permission management
- **Event System**: Real-time network state change events for both platforms

### Changed
- **Minimum Android Version**: Raised from API 21 to API 29 (Android 10+)
- **Minimum iOS Version**: Set to iOS 12.0 for NWPathMonitor support
- **Build Configuration**: Updated Gradle and Podspec configuration for modern development
- **Dependencies**: Added kotlinx-coroutines for efficient async operations (Android)
- **Architecture**: Complete rewrite from simple multiply function to full cross-platform network state library
- **Package Version**: Bumped to 1.0.0 for major release

### Removed
- **Legacy multiply function**: Replaced with comprehensive network state tracking
- **Old Android APIs**: Removed deprecated network detection methods
- **Basic functionality**: Upgraded to enterprise-grade cross-platform network monitoring

### Technical Details
- **Android Implementation**: 
  - Uses `ConnectivityManager.NetworkCallback` for real-time updates
  - Implements `NetworkCapabilities` for accurate network type detection
  - Leverages `NetworkRequest.Builder` for network monitoring
  - Handles Android 10+ permission requirements properly
  
- **iOS Implementation**:
  - Uses `NWPathMonitor` for real-time network state monitoring
  - Leverages iOS 12+ Network framework for reliable detection
  - Implements `CNCopyCurrentNetworkInfo` for WiFi SSID detection
  - Uses `getifaddrs` for IP address detection
  
- **React Native Integration**:
  - TurboModule implementation for high performance
  - Event emission for real-time network state changes
  - Comprehensive TypeScript interfaces
  - React Hook for easy component integration
  - Cross-platform event handling

- **Performance Optimizations**:
  - Efficient network state caching
  - Minimal battery impact
  - Smart listener management
  - Coroutine-based async operations (Android)
  - GCD-based async operations (iOS)

## [0.1.0] - 2024-12-19

### Added
- Initial project setup with create-react-native-library
- Basic Android module structure
- Example app configuration
- Basic build system

### Technical Details
- Basic TurboModule implementation
- Simple multiply function for testing
- Android and iOS project templates
- Development workflow setup

---

### Breaking Changes
- **Package Purpose**: Changed from math utility to cross-platform network state tracking
- **API Surface**: Complete API redesign
- **Platform Requirements**: 
  - Android: Now requires Android 10+ (API 29+)
  - iOS: Now requires iOS 12.0+
- **Dependencies**: Added new platform-specific dependencies
- **Permissions**: Requires additional platform-specific permissions

### New Requirements
- **Android**: Android 10+ (API level 29+)
- **iOS**: iOS 12.0+
- React Native 0.71+
- Additional platform-specific permissions (automatically added)
- Kotlin coroutines support (Android)
- Network framework support (iOS)

---

## Future Roadmap

### Planned Features
- **Enhanced iOS Support**: More detailed iOS network information
- **Network Quality Metrics**: Bandwidth and latency measurements
- **Network History**: Track network changes over time
- **Offline Detection**: Better offline state handling
- **Network Security**: VPN and security status detection
- **Performance Metrics**: Network performance analytics
- **Web Support**: React Native Web compatibility

### Technical Improvements
- **Performance Monitoring**: Network performance tracking
- **Battery Optimization**: Enhanced power management
- **Testing Suite**: Comprehensive unit and integration tests
- **Documentation**: API reference and examples
- **Platform-Specific Optimizations**: Better performance on each platform
