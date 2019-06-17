#
# Be sure to run `pod lib lint APPaginator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'APPaginator'
  s.version          = '0.1.4'
  s.summary          = 'APPaginbatoe is a simple way to load and display paginable content.'
  s.homepage         = 'https://github.com/AlekseyPakAA/APPaginator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AlekseyPakAA' => 'aleksey.pakaa@gmail.com' }
  s.source           = { :git => 'https://github.com/AlekseyPakAA/APPaginator.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'

  s.source_files = 'APPaginator/Classes/**/*'
  s.swift_version = '5.0'
  # s.resource_bundles = {
  #   'APPaginator' => ['APPaginator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
