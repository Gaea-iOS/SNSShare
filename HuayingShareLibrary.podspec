#
# Be sure to run `pod lib lint HuayingShareLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HuayingShareLibrary'
  s.version          = '0.1.0'
  s.summary          = 'ShareOperation for HuayingShareLibrary.'
  s.description      = 'ShareOperation'
  s.homepage         = 'https://github.com/lzc1104/HuayingShareLibrary'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lzc1104' => '527004184@QQ.COM' }
  s.source           = { :git => 'https://github.com/lzc1104/HuayingShareLibrary.git', :tag => s.version.to_s }


  s.ios.deployment_target = '8.0'

  s.source_files = 'HuayingShareLibrary/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HuayingShareLibrary' => ['HuayingShareLibrary/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit'
  s.dependency 'MonkeyKing' ,'~> 1.3.0'
  s.dependency 'SDWebImage'
end
