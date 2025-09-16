import NetworkState from './NativeNetworkState';
import { NetworkType } from './NativeNetworkState';
import type {
  NetworkState as NetworkStateType,
  NetworkDetails,
  NetworkCapabilities,
} from './NativeNetworkState';
import { useNetworkState } from './useNetworkState';

// Export types
export type {
  NetworkState as NetworkStateType,
  NetworkDetails,
  NetworkCapabilities,
};

// Export enum values and hook
export { NetworkType, useNetworkState };

/**
 * High-level API wrapping native module with convenient helpers.
 * Platform: Android & iOS (unless otherwise noted in method JSDoc).
 */
export class ModernNetworkState {
  private static instance: ModernNetworkState;
  private isListening = false;

  private constructor() {}

  static getInstance(): ModernNetworkState {
    if (!ModernNetworkState.instance) {
      ModernNetworkState.instance = new ModernNetworkState();
    }
    return ModernNetworkState.instance;
  }

  /** Get current network state (Android & iOS) */
  async getNetworkState(): Promise<NetworkStateType> {
    return await NetworkState.getNetworkState();
  }

  /** Start listening to network state changes (Android & iOS) */
  startListening(): void {
    if (!this.isListening) {
      NetworkState.startNetworkStateListener();
      this.isListening = true;
    }
  }

  /** Stop listening to network state changes (Android & iOS) */
  stopListening(): void {
    if (this.isListening) {
      NetworkState.stopNetworkStateListener();
      this.isListening = false;
    }
  }

  /** Check if specific network type is available (Android & iOS; type coverage varies) */
  async isNetworkTypeAvailable(type: NetworkType): Promise<boolean> {
    return await NetworkState.isNetworkTypeAvailable(type);
  }

  /** Get network strength (Android returns RSSI; iOS may return -1) */
  async getNetworkStrength(): Promise<number> {
    return await NetworkState.getNetworkStrength();
  }

  /** Check if network is expensive (typically true on cellular) */
  async isNetworkExpensive(): Promise<boolean> {
    return await NetworkState.isNetworkExpensive();
  }

  /** Check if network is metered (typically true on cellular) */
  async isNetworkMetered(): Promise<boolean> {
    return await NetworkState.isNetworkMetered();
  }

  /** Check if currently connected to WiFi (Android & iOS) */
  async isConnectedToWifi(): Promise<boolean> {
    const state = await this.getNetworkState();
    return state.type === NetworkType.WIFI && state.isConnected;
  }

  /** Check if currently connected to cellular (Android & iOS) */
  async isConnectedToCellular(): Promise<boolean> {
    const state = await this.getNetworkState();
    return state.type === NetworkType.CELLULAR && state.isConnected;
  }

  /** Check if internet is reachable (Android & iOS) */
  async isInternetReachable(): Promise<boolean> {
    const state = await this.getNetworkState();
    return state.isInternetReachable;
  }

  /** Get WiFi details if connected (Android; iOS may return null) */
  async getWifiDetails(): Promise<NetworkDetails | null> {
    const state = await this.getNetworkState();
    if (state.type === NetworkType.WIFI && state.details) {
      return state.details;
    }
    return null;
  }

  /** Get network capabilities (Android & iOS; fields coverage varies) */
  async getNetworkCapabilities(): Promise<NetworkCapabilities | null> {
    const state = await this.getNetworkState();
    return state.details?.capabilities || null;
  }

  /** Force refresh network state - useful when app comes to foreground (Android & iOS) */
  forceRefresh(): void {
    NetworkState.forceRefresh();
  }
}

// Export singleton instance
export const networkState = ModernNetworkState.getInstance();

// Export individual functions for convenience
export const getNetworkState = () => networkState.getNetworkState();
export const startNetworkStateListener = () => networkState.startListening();
export const stopNetworkStateListener = () => networkState.stopListening();
export const isNetworkTypeAvailable = (type: NetworkType) =>
  networkState.isNetworkTypeAvailable(type);
export const getNetworkStrength = () => networkState.getNetworkStrength();
export const isNetworkExpensive = () => networkState.isNetworkExpensive();
export const isNetworkMetered = () => networkState.isNetworkMetered();
export const isConnectedToWifi = () => networkState.isConnectedToWifi();
export const isConnectedToCellular = () => networkState.isConnectedToCellular();
export const isInternetReachable = () => networkState.isInternetReachable();
export const getWifiDetails = () => networkState.getWifiDetails();
export const getNetworkCapabilities = () =>
  networkState.getNetworkCapabilities();
export const forceRefresh = () => networkState.forceRefresh();

// Default export
export default ModernNetworkState;
