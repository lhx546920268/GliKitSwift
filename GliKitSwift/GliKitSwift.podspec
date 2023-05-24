#
#  Be sure to run `pod spec lint GliKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "GliKitSwift"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of GliKitSwift."

  spec.description  = <<-DESC
                        这是一个描述
                   DESC

  spec.homepage     = "http://EXAMPLE/GliKitSwift"
  spec.license      = "MIT"

  spec.author             = "luohaixiong"

  spec.platform     = :ios, "12.0"

  spec.source = { :git => "https://github.com/lhx546920268/GliKitSwift.git", :tag => "v#{spec.version}" }
  spec.source_files  = "GliKitSwift/**/*.{swift}"
  spec.dependency 'SnapKit', '~> 5.6.0'
  spec.dependency 'Kingfisher', '~> 7.6.2'
  spec.dependency 'Alamofire', '~> 5.7.0'
  spec.dependency 'KeychainAccess', '~> 4.2.2'
end
