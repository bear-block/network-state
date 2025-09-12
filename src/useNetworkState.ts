import { useState, useEffect, useCallback } from 'react';
import {
  DeviceEventEmitter,
  AppState,
  type AppStateStatus,
} from 'react-native';
import { networkState, NetworkType } from './index';
import type {
  NetworkState as NetworkStateType,
  NetworkDetails,
  NetworkCapabilities,
} from './NativeNetworkState';

export interface UseNetworkStateOptions {
  /**
   * Whether to start listening automatically when the hook mounts
   * @default true
   */
  autoStart?: boolean;
}

export interface UseNetworkStateReturn {
  /**
   * Current network state
   */
  networkState: NetworkStateType | null;

  /**
   * Whether the hook is currently listening to network changes
   */
  isListening: boolean;

  /**
   * Start listening to network state changes
   */
  startListening: () => void;

  /**
   * Stop listening to network state changes
   */
  stopListening: () => void;

  /**
   * Refresh network state manually
   */
  refresh: () => Promise<void>;

  /**
   * Check if specific network type is available
   */
  isNetworkTypeAvailable: (type: NetworkType) => Promise<boolean>;

  /**
   * Get network strength
   */
  getNetworkStrength: () => Promise<number>;

  /**
   * Check if network is expensive
   */
  isNetworkExpensive: () => Promise<boolean>;

  /**
   * Check if network is metered
   */
  isNetworkMetered: () => Promise<boolean>;

  /**
   * Check if connected to WiFi
   */
  isConnectedToWifi: () => Promise<boolean>;

  /**
   * Check if connected to cellular
   */
  isConnectedToCellular: () => Promise<boolean>;

  /**
   * Check if internet is reachable
   */
  isInternetReachable: () => Promise<boolean>;

  /**
   * Get WiFi details
   */
  getWifiDetails: () => Promise<NetworkDetails | null>;

  /**
   * Get network capabilities
   */
  getNetworkCapabilities: () => Promise<NetworkCapabilities | null>;
}

/**
 * React Hook for tracking network state
 *
 * @param options Configuration options
 * @returns Network state and utility functions
 *
 * @example
 * ```tsx
 * const { networkState, isListening, startListening, stopListening } = useNetworkState();
 *
 * useEffect(() => {
 *   if (networkState) {
 *     console.log('Network type:', networkState.type);
 *     console.log('Is connected:', networkState.isConnected);
 *   }
 * }, [networkState]);
 * ```
 */
export function useNetworkState(
  options: UseNetworkStateOptions = {}
): UseNetworkStateReturn {
  const { autoStart = true } = options;

  const [networkStateData, setNetworkStateData] =
    useState<NetworkStateType | null>(null);
  const [isListening, setIsListening] = useState(false);

  const refresh = useCallback(async () => {
    try {
      const state = await networkState.getNetworkState();
      setNetworkStateData(state);
    } catch (error) {
      console.error('Failed to refresh network state:', error);
    }
  }, []);

  const startListening = useCallback(() => {
    if (!isListening) {
      networkState.startListening();
      setIsListening(true);

      // Listen to network state changes
      const subscription = DeviceEventEmitter.addListener(
        'networkStateChanged',
        (state: NetworkStateType) => {
          setNetworkStateData(state);
        }
      );

      // Store subscription for cleanup
      (networkState as any)._subscription = subscription;
    }
  }, [isListening]);

  const stopListening = useCallback(() => {
    if (isListening) {
      networkState.stopListening();
      setIsListening(false);

      // Remove subscription
      if ((networkState as any)._subscription) {
        (networkState as any)._subscription.remove();
        (networkState as any)._subscription = null;
      }
    }
  }, [isListening]);

  // Handle app state changes (background/foreground)
  useEffect(() => {
    const handleAppStateChange = (nextAppState: AppStateStatus) => {
      if (nextAppState === 'active' && isListening) {
        // App came to foreground, force refresh network state
        networkState.forceRefresh();
        // Also refresh local state
        refresh();
      }
    };

    const subscription = AppState.addEventListener(
      'change',
      handleAppStateChange
    );

    return () => {
      subscription?.remove();
    };
  }, [isListening, refresh]);

  useEffect(() => {
    if (autoStart) {
      startListening();
    }

    // Initial network state
    refresh();

    return () => {
      if (isListening) {
        stopListening();
      }
    };
  }, [autoStart, startListening, stopListening, refresh, isListening]);

  return {
    networkState: networkStateData,
    isListening,
    startListening,
    stopListening,
    refresh,
    isNetworkTypeAvailable:
      networkState.isNetworkTypeAvailable.bind(networkState),
    getNetworkStrength: networkState.getNetworkStrength.bind(networkState),
    isNetworkExpensive: networkState.isNetworkExpensive.bind(networkState),
    isNetworkMetered: networkState.isNetworkMetered.bind(networkState),
    isConnectedToWifi: networkState.isConnectedToWifi.bind(networkState),
    isConnectedToCellular:
      networkState.isConnectedToCellular.bind(networkState),
    isInternetReachable: networkState.isInternetReachable.bind(networkState),
    getWifiDetails: networkState.getWifiDetails.bind(networkState),
    getNetworkCapabilities:
      networkState.getNetworkCapabilities.bind(networkState),
  };
}

export default useNetworkState;
