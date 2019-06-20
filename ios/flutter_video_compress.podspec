#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_video_compress'
  s.version          = '0.3.0'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/TenkaiRuri/flutter_video_compress'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FlutterVideoCompress Team' => 'babichan@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Regift'
  s.preserve_paths = 'Regift.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework Regift' }
  s.vendored_frameworks = 'Regift.framework'

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
end

