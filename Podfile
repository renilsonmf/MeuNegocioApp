# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'MeuNegocio' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'FirebaseAuth', '11.15.0'
  pod 'FirebaseFirestore', '11.15.0'
  pod 'Firebase/Analytics', '11.15.0'
  pod 'Firebase/RemoteConfig', '11.15.0'
  pod 'lottie-ios'

  target 'MeuNegocioTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MeuNegocioUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end

end
