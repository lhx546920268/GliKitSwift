#
#  Be sure to run `pod spec lint GliKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "GliKitSwift"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of GliKitSwift."

  spec.description  = <<-DESC
                        这是一个描述
                   DESC

  spec.homepage     = "http://EXAMPLE/GliKitSwift"
  spec.license      = "MIT"

  spec.author             = "luohaixiong"

  spec.platform     = :ios, "10.0"

  spec.source = { :git => "https://github.com/lhx546920268/GliKitSwift.git", :tag => "v#{spec.version}" }
  spec.source_files  = "GliKitSwift/**/*.{swift}"
  spec.dependency 'SnapKit', '~> 5.0.1'
  spec.dependency 'Kingfisher', '~> 5.15.6'
  spec.dependency 'Alamofire', '~> 5.2.2'
  spec.dependency 'KeychainAccess', '~> 4.2.1'
end
