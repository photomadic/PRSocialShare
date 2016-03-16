Pod::Spec.new do |s|
  s.name             = "PRSocialShare"
  s.summary          = "Social sharing workflow for users on shared devices such as kiosks"
  s.version          = "0.3.0"

  s.homepage         = "https://github.com/praxent/PRSocialShare"
  s.license          = "MIT"
  s.author           = { "Joel Costa" => "joel.costa@praxent.com", "Albert Martin" => "albert@bethel.io" }

  s.source           = { :git => "https://github.com/praxent/PRSocialShare.git", :tag => "v0.3.0" }

  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.dependency "FBSDKCoreKit", "~> 4.10.0"
  s.dependency "FBSDKLoginKit", "~> 4.10.0"
  s.dependency "FBSDKShareKit", "~> 4.10.0"
  s.dependency "TwitterKit", "~> 1.14.6"

  s.source_files = "PRSocialShare/Classes/*.{swift}"
end
