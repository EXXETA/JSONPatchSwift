#
# Be sure to run `pod lib lint JSONPatchSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JSONPatchSwift'
  s.version          = '2.0'
  s.summary          = 'A RFC 6902 compliant implementation of JSONPatch in Swift'
  s.description      = <<-DESC
JSONPatchSwift is an implementation of JSONPatch (RFC 6902) in pure Swift.
                       DESC

  s.homepage     = "https://www.github.com/EXXETA/JSONPatchSwift"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE.txt" }
  s.author       = { "Dominic Frei" => "dominic@dominicfrei.com", "Sebastian Schmidt" => "sebastian.schmidt2@exxeta.com", "Peer Becker" => "peer.becker@exxeta.com", "Maximilian Alexander" => "mbalex99@gmail.com" }
  s.source           = { :git => 'https://github.com/mbalex99/JSONPatchSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'JSONPatchSwift/Classes/**/*'
  s.dependency 'SwiftyJSON', '~> 3.1.4'
end
