# Modern Network State Library

A high-performance React Native library for tracking network state using modern Android APIs (API 29+) and iOS NWPathMonitor (iOS 12+). This library provides accurate network state information by leveraging the latest platform APIs instead of deprecated methods used by older libraries.

## 🚀 Features

- **Modern Android APIs**: Uses Android 10+ (API 29+) Network Capabilities API for accurate network detection
- **Modern iOS APIs**: Uses iOS 12+ NWPathMonitor and Network framework for reliable network tracking
- **Real-time monitoring**: Listen to network state changes in real-time on both platforms
- **Comprehensive network info**: Get detailed information about WiFi, cellular, Ethernet, Bluetooth, and VPN connections (Android: WIFI_AWARE, LOWPAN support)
- **Network capabilities**: Access detailed network capabilities and transport information
- **React Hook**: Easy-to-use React Hook for React Native apps
- **TypeScript support**: Full TypeScript support with comprehensive type definitions
- **Performance optimized**: Efficient network state tracking with minimal battery impact
- **Cross-platform**: Consistent API across Android and iOS
- **Background/Foreground handling**: Automatic network state refresh when app returns to foreground

## 📱 Why This Library?

Traditional network state libraries like `@react-native-community/netinfo` or `expo-network` often use deprecated Android APIs that can provide inaccurate information, especially on newer Android versions. This library:

- **Android**: Uses `NetworkCapabilities` API (Android 10+) for accurate network type detection
- **iOS**: Uses `NWPathMonitor` (iOS 12+) for reliable network state monitoring
- **Real-time updates**: Implements comprehensive network callbacks for both platforms
- **Modern permissions**: Handles platform-specific permission requirements properly
- **Background/Foreground lifecycle**: Automatically refreshes network state when app returns to foreground
- **Provides detailed network information** that older APIs cannot access

## 📋 Requirements

- React Native 0.71+
- **Android**: Android 10+ (API level 29+)
- **iOS**: iOS 12.0+

## 🛠 Installation

```bash
npm install @bear-block/network-state
# or
yarn add @bear-block/network-state
```

### Setup

**No manual setup required!** The library automatically handles all configuration through React Native autolinking.

#### Android
- ✅ Permissions are automatically added to your app
- ✅ Requires Android 10+ (API 29+)
- ✅ Works with both Old and New Architecture

#### iOS  
- ✅ Frameworks are automatically linked
- ✅ Requires iOS 12.0+
- ✅ Works with both Old and New Architecture

### Permissions

The library automatically adds the necessary permissions and frameworks:

#### Android (Auto-added)
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (Auto-linked)
- `Network.framework` - For NWPathMonitor and network state detection
- `SystemConfiguration.framework` - For WiFi SSID detection  
- `CoreTelephony.framework` - For cellular network information

## 📖 Usage

### Basic Usage

```typescript
import { useNetworkState, NetworkType } from '@bear-block/network-state';

function MyComponent() {
  const { networkState, isListening, startListening, stopListening } = useNetworkState();

  useEffect(() => {
    if (networkState) {
      console.log('Network type:', networkState.type);
      console.log('Is connected:', networkState.isConnected);
      console.log('Internet reachable:', networkState.isInternetReachable);
    }
  }, [networkState]);

  return (
    <View>
      <Text>Network: {networkState?.type || 'Unknown'}</Text>
      <Text>Connected: {networkState?.isConnected ? 'Yes' : 'No'}</Text>
      <Button title="Start Listening" onPress={startListening} />
      <Button title="Stop Listening" onPress={stopListening} />
    </View>
  );
}
```

### Advanced Usage

```typescript
import { useNetworkState, NetworkType } from '@bear-block/network-state';

function AdvancedComponent() {
  const {
    networkState: current,
    isNetworkTypeAvailable,
    getNetworkStrength,
    isNetworkExpensive,
    isNetworkMetered,
    getWifiDetails,
    getNetworkCapabilities
  } = useNetworkState({ autoStart: true });

  const checkNetworkCapabilities = async () => {
    // Check if WiFi is available
    const wifiAvailable = await isNetworkTypeAvailable(NetworkType.WIFI);
    
    // Get network strength
    const strength = await getNetworkStrength();
    
    // Check if network is expensive (mobile data)
    const expensive = await isNetworkExpensive();
    
    // Get WiFi details
    const wifiDetails = await getWifiDetails();
    if (wifiDetails) {
      console.log('SSID:', wifiDetails.ssid);
      console.log('Signal strength:', wifiDetails.strength);
      console.log('Frequency:', wifiDetails.frequency);
    }
    
    // Get network capabilities
    const capabilities = await getNetworkCapabilities();
    if (capabilities) {
      console.log('Has WiFi transport:', capabilities.hasTransportWifi);
      console.log('Has internet capability:', capabilities.hasCapabilityInternet);
    }
  };

  return (
    <View>
      {/* Your UI components */}
    </View>
  );
}
```

### Direct API Usage

```typescript
import { networkState, NetworkType } from '@bear-block/network-state';

// Get current network state
const state = await networkState.getNetworkState();

// Check specific network types
const wifiConnected = await networkState.isConnectedToWifi();
const cellularConnected = await networkState.isConnectedToCellular();

// Start/stop listening
networkState.startListening();
networkState.stopListening();
```

## 🔧 API Reference

### useNetworkState Hook

```typescript
const {
  networkState,           // Current network state
  isListening,           // Whether listening is active
  startListening,        // Start listening to changes
  stopListening,         // Stop listening to changes
  refresh,               // Manually refresh state
  isNetworkTypeAvailable, // Check if network type is available
  getNetworkStrength,    // Get network signal strength
  isNetworkExpensive,    // Check if network is expensive
  isNetworkMetered,      // Check if network is metered
  isConnectedToWifi,     // Check WiFi connection
  isConnectedToCellular, // Check cellular connection
  isInternetReachable,   // Check internet reachability
  getWifiDetails,        // Get WiFi details
  getNetworkCapabilities // Get network capabilities
} = useNetworkState(options);
```

### NetworkState Interface

```typescript
interface NetworkState {
  isConnected: boolean;
  isInternetReachable: boolean;
  type: NetworkType;
  isExpensive: boolean;
  isMetered: boolean;
  details?: NetworkDetails;
}

interface NetworkDetails {
  ssid?: string;           // WiFi network name
  bssid?: string;          // WiFi BSSID (Android only)
  strength?: number;        // Signal strength
  frequency?: number;       // WiFi frequency (MHz, Android only)
  linkSpeed?: number;       // WiFi link speed (Android only)
  capabilities: NetworkCapabilities;
}
```

### NetworkType Enum

```typescript
enum NetworkType {
  NONE = 'none',
  UNKNOWN = 'unknown',
  WIFI = 'wifi',                    // Both platforms
  CELLULAR = 'cellular',            // Both platforms
  ETHERNET = 'ethernet',            // Both platforms
  BLUETOOTH = 'bluetooth',          // Both platforms
  VPN = 'vpn',                      // Both platforms
  WIFI_AWARE = 'wifi_aware',        // Android only (API 26+)
  LOWPAN = 'lowpan'                 // Android only (API 27+)
}
```

## 🧪 Testing

Run the example app to test all features:

```bash
cd example
yarn install
yarn android  # or yarn ios
```

### **Background/Foreground Testing**
1. **Start the app** and observe current network state
2. **Put app in background** (home button)
3. **Change network** (WiFi ↔ Cellular)
4. **Return to app** - network state should automatically refresh
5. **Check logs** for automatic refresh events

The example app includes AppState monitoring to demonstrate background/foreground handling.

## 🔄 Background/Foreground Handling

The library automatically handles app lifecycle changes to ensure network state accuracy:

### **Automatic State Refresh**
- ✅ **Background → Foreground**: Automatically refreshes network state when app returns to foreground
- ✅ **Network Changes in Background**: Native callbacks continue working in background
- ✅ **State Consistency**: UI always shows current network state when app becomes active
- ✅ **Zero Configuration**: Works automatically without any setup

### **How It Works**
1. **App goes to background**: Network monitoring continues at native level
2. **Network changes in background**: Native callbacks detect changes
3. **App returns to foreground**: `AppState` listener triggers automatic refresh
4. **State updates**: Both native and React state are refreshed automatically

### **Example Usage**
```typescript
const { networkState, isListening } = useNetworkState({ autoStart: true });

// No additional code needed - background/foreground handling is automatic!
// When user returns to app, network state will be automatically refreshed
```

## 🔍 How It Works

### Android Implementation

1. **Network Capabilities API**: Uses `NetworkCapabilities` to detect network type and capabilities
2. **Network Callbacks**: Implements `ConnectivityManager.NetworkCallback` for real-time updates
3. **Modern Permissions**: Handles Android 10+ permission requirements properly
4. **Efficient Monitoring**: Only listens when needed and provides accurate state information
5. **App Lifecycle**: Handles background/foreground transitions with automatic state refresh

### iOS Implementation

1. **NWPathMonitor**: Uses `NWPathMonitor` for real-time network state monitoring
2. **Network Framework**: Leverages iOS 12+ Network framework for reliable detection
3. **Interface Detection**: Detects WiFi, Cellular, Ethernet, and other interface types
4. **Event Emission**: Emits network state changes to React Native via events
5. **App Lifecycle**: Handles background/foreground transitions with automatic state refresh

### Key Differences from Other Libraries

| Feature | This Library | @react-native-community/netinfo | expo-network |
|---------|--------------|--------------------------------|--------------|
| **Android API** | Network Capabilities (API 29+) | Mixed old/new APIs | Mixed old/new APIs |
| **iOS API** | NWPathMonitor (iOS 12+) | NWPathMonitor | NWPathMonitor |
| **Accuracy** | High (modern APIs) | Medium (deprecated APIs) | Medium (deprecated APIs) |
| **Real-time updates** | Yes | Yes | Yes |
| **Background/Foreground** | ✅ Automatic refresh | ❌ Manual handling | ❌ Manual handling |
| **Network capabilities** | Full | Limited | Limited |
| **WiFi details** | Complete | Basic | Basic |
| **Android 10+ support** | Native | Partial | Partial |
| **iOS 12+ support** | Native | Yes | Yes |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the limitations of existing network state libraries
- Built with modern Android and iOS development best practices
- Designed for React Native developers who need accurate network information

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/bear-block/network-state/issues) page
2. Create a new issue with detailed information
3. Include your React Native version and platform details

---

**Note**: This library is specifically designed for Android 10+ and iOS 12+ to provide the most accurate network state information. For older versions, consider using `@react-native-community/netinfo` as a fallback.
