Pod::Spec.new do |s|
  s.name             = "PRSocialShare"
  s.summary          = "Social sharing workflow for users on shared devices such as kiosks"
  s.version          = "0.1.0"

  s.homepage         = "https://github.com/praxent/PRSocialShare"
  s.license          = "MIT"
  s.author           = { "Albert Martin" => "albert@bethel.io" }
  s.source           = { :git => "https://github.com/praxent/PRSocialShare.git", :tag => s.version.to_s }

  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source_files = "Pod/Classes/**/*"
  s.resource_bundles = {
    "PRSocialShare" => ["Pod/Assets/*.png"]
  }

  s.frameworks = "UIKit"

  s.dependency "FBSDKLoginKit", "~> 4.9.1"
  s.dependency "FBSDKShareKit", "~> 4.9.1"

  s.source_files = "*.{swift}"
end
