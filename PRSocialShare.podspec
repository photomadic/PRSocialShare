Pod::Spec.new do |s|
  s.name             = "PRSocialShare"
  s.summary          = "Social sharing workflow for users on shared devices such as kiosks"
  s.version          = "0.2.0"

  s.homepage         = "https://github.com/praxent/PRSocialShare"
  s.license          = "MIT"
  s.author           = { "Joel Costa" => "joel.costa@praxent.com", "Albert Martin" => "albert@bethel.io" }

  s.source           = { :git => "https://github.com/praxent/PRSocialShare.git", :tag => s.version.to_s }

  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.dependency "FBSDKLoginKit", "~> 4.9.1"
  s.dependency "FBSDKShareKit", "~> 4.9.1"
  s.dependency "TwitterKit"

  s.source_files = "Classes/*.{swift}"
end
