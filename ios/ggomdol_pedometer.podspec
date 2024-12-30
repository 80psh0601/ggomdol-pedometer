#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pedometer.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ggomdol_pedometer'
  s.version          = '1.0.0'
  s.summary          = 'Pedometer and Step Detection for Android and iOS'
  s.description      = <<-DESC
Pedometer and Step Detection for Android and iOS
                       DESC
  s.homepage         = 'https://www.blogger.com/blog/posts/1010401266234926162'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'GGOMDOL' => 'psh800601@hotmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
