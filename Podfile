# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

use_frameworks!

def alamofire_pod
  pod 'Alamofire', '~> 5.4.1'
end

def ios_pods
  alamofire_pod
  pod 'SnapKit', '~> 5.0.1'
  pod 'CRRefresh', '~> 1.1.3'
  pod 'NVActivityIndicatorView', '~> 5.1.1'
  pod 'NotificationBannerSwift', '3.0.6'
  pod 'AcknowList', '2.0.0-beta.1'
end

###

target 'DoroDoroAPI' do
  alamofire_pod
end

target 'DoroDoroWatchAPI' do
  alamofire_pod
end

target 'DoroDoroTVAPI' do
  alamofire_pod
end

target 'DoroDoro' do
  ios_pods
end

target 'DoroDoroWatch Extension' do
  alamofire_pod
end

target 'DoroDoroTV' do
  alamofire_pod
  pod 'SnapKit', '~> 5.0.1'
  pod 'NVActivityIndicatorView', '~> 5.1.1'
  pod 'AcknowList', '2.0.0-beta.1'
end

target 'DoroDoroUITests' do
  ios_pods
end
