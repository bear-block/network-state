require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "NetworkState"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/bear-block/network-state.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,cpp}"
  s.private_header_files = "ios/**/*.h"

  # iOS dependencies
  s.frameworks = "Network"
  
  # React Native dependency
  s.dependency "React-Core"

  # New Architecture / Codegen dependencies
  if ENV['RCT_NEW_ARCH_ENABLED'] == '1'
    # Enable new-arch compile flag
    s.compiler_flags = "$(inherited) -DRCT_NEW_ARCH_ENABLED=1"
    # Pull in React-Codegen and the generated spec pod for this module
    s.dependency "React-Codegen"
    # Ensure headers for codegen are visible
    s.pod_target_xcconfig = {
      "HEADER_SEARCH_PATHS" => [
        '"$(PODS_ROOT)/Headers/Public/React-Codegen"',
        '"$(PODS_CONFIGURATION_BUILD_DIR)/React-Codegen/React_Codegen.framework/Headers"'
      ].join(' ')
    }
  end

  install_modules_dependencies(s)
end
