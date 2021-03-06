#
# Be sure to run `pod lib lint SpotHTTP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SpotHTTP'
  s.version          = '0.1.5'
  s.summary          = 'SpotHTTP - Based on AFNetworking.'
  s.description      = <<-DESC
SpotHTTP - Based on AFNetworking, too!.
                       DESC

  s.homepage         = 'https://github.com/yclzone/SpotHTTP'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yclzone' => 'yclzone@gmail.com' }
  s.source           = { :git => 'https://github.com/yclzone/SpotHTTP.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SpotHTTP/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SpotHTTP' => ['SpotHTTP/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 3.0'
  s.dependency 'HYFoundation'
end
