import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface NetworkState {
  isConnected: boolean;
  isInternetReachable: boolean;
  type: NetworkType;
  isExpensive: boolean;
  isMetered: boolean;
  details?: NetworkDetails;
}

export interface NetworkDetails {
  ssid?: string;
  bssid?: string;
  strength?: number;
  frequency?: number;
  linkSpeed?: number;
  capabilities?: NetworkCapabilities;
}

export interface NetworkCapabilities {
  hasTransportWifi?: boolean;
  hasTransportCellular?: boolean;
  hasTransportEthernet?: boolean;
  hasTransportBluetooth?: boolean;
  hasTransportVpn?: boolean;
  hasCapabilityInternet?: boolean;
  hasCapabilityValidated?: boolean;
  hasCapabilityCaptivePortal?: boolean;
  hasCapabilityNotRestricted?: boolean;
  hasCapabilityTrusted?: boolean;
  hasCapabilityNotMetered?: boolean;
  hasCapabilityNotRoaming?: boolean;
  hasCapabilityForLocal?: boolean;
  hasCapabilityManaged?: boolean;
  hasCapabilityNotSuspended?: boolean;
  hasCapabilityNotVpn?: boolean;
  hasCapabilityNotCellular?: boolean;
  hasCapabilityNotWifi?: boolean;
  hasCapabilityNotEthernet?: boolean;
  hasCapabilityNotBluetooth?: boolean;
}

export enum NetworkType {
  NONE = 'none',
  UNKNOWN = 'unknown',
  WIFI = 'wifi',
  CELLULAR = 'cellular',
  ETHERNET = 'ethernet',
  BLUETOOTH = 'bluetooth',
  VPN = 'vpn',
  WIFI_AWARE = 'wifi_aware',
  LOWPAN = 'lowpan',
}

export interface Spec extends TurboModule {
  // Required for NativeEventEmitter on iOS
  addListener(eventType: string): void;
  removeListeners(count: number): void;

  // Get current network state
  getNetworkState(): Promise<NetworkState>;

  // Start listening to network changes
  startNetworkStateListener(): void;

  // Stop listening to network changes
  stopNetworkStateListener(): void;

  // Check if specific network type is available
  isNetworkTypeAvailable(type: NetworkType): Promise<boolean>;

  // Get network strength (for WiFi/Cellular)
  getNetworkStrength(): Promise<number>;

  // Check if network is expensive (mobile data)
  isNetworkExpensive(): Promise<boolean>;

  // Check if network is metered
  isNetworkMetered(): Promise<boolean>;

  // Force refresh network state
  forceRefresh(): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NetworkState');
