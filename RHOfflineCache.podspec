#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "RHOfflineCache"
  s.version          = "0.1.0"
  s.summary          = "An offline storage cache build with RHManagedObject."
  s.homepage         = "https://github.com/chriscdn/RHOfflineCache"
  s.license          = 'MIT'
  s.author           = { "Christopher Meyer" => "chris@rhouse.ch" }
  s.source           = { :git => "https://github.com/chriscdn/RHOfflineCache.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/chriscdn'

  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'RHOfflineCache/*'
  s.dependency 'RHManagedObject'
end
