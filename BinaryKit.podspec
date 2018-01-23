#
# Be sure to run `pod lib lint BinaryKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BinaryKit'
  s.version          = '2.0.0'
  s.summary          = 'Access bits and bytes directly in Swift.'

  s.description      = <<-DESC
0️⃣1️⃣ Access bits and bytes from binary data in Swift.
                       DESC

  s.homepage         = 'https://github.com/Cosmo/BinaryKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Devran Ünal' => 'me@devranuenal.com' }
  s.source           = { :git => 'https://github.com/Cosmo/BinaryKit', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Sources/*.swift'

end
