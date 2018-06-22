#
# Be sure to run `pod lib lint HuayingShareLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HuayingShareLibrary'
  s.version          = '0.2.0'
  s.summary          = 'ShareOperation for HuayingShareLibrary.'
  s.description      = 'ShareOperation'
  s.homepage         = 'https://github.com/lzc1104/HuayingShareLibrary'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lzc1104' => '527004184@QQ.COM' }
  s.source           = { :git => 'https://github.com/lzc1104/HuayingShareLibrary.git', :tag => s.version.to_s }


  s.ios.deployment_target = '8.0'

  s.source_files = 'HuayingShareLibrary/Classes/**/*'
  s.vendored_libraries = 'HuayingShareLibrary/Classes/libWeiboSDK/libWeiboSDK.a'
  s.prepare_command = './install.sh'
  # s.resource_bundles = {

  #   'HuayingShareLibrary' => ['HuayingShareLibrary/Assets/*.png']
  # }
  s.resource     = 'HuayingShareLibrary/Classes/libWeiboSDK/WeiboSDK.bundle'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-all_load' }
  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks   = 'Photos', 'ImageIO', 'SystemConfiguration', 'CoreText', 'QuartzCore', 'Security', 'UIKit', 'Foundation', 'CoreGraphics','CoreTelephony'
  s.libraries = 'sqlite3', 'z'
  s.dependency 'MonkeyKing' ,'~> 1.4.0'
  s.dependency 'SDWebImage'
end
