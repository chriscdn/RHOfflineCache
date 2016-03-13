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
  s.resources = 'Resources/*'
  
  s.dependency 'RHManagedObject'
  s.dependency 'AFNetworking'
  
end