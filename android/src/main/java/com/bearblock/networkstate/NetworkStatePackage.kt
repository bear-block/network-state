package com.bearblock.networkstate

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider
import java.util.HashMap

class NetworkStatePackage : BaseReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return if (name == NetworkStateModule.NAME) {
      NetworkStateModule(reactContext)
    } else {
      null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
      moduleInfos[NetworkStateModule.NAME] = ReactModuleInfo(
        NetworkStateModule.NAME,
        NetworkStateModule.NAME,
        false,  // canOverrideExistingModule
        false,  // needsEagerInit
        false,  // isCxxModule
        BuildConfig.IS_NEW_ARCHITECTURE_ENABLED // isTurboModule only when new arch is enabled
      )
      moduleInfos
    }
  }
}
