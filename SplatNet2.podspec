Pod::Spec.new do |spec|
  spec.name         = "SplatNet2"
  spec.version      = "0.1.6"
  spec.summary      = "SplatNet2 is the framework to generate iksm_session using internal and external API."
  spec.homepage     = "https://github.com/tkgstrator/SplatNet2"
  spec.license      =  { :type => "MIT:", :file => "LICENSE.md" }
  spec.author       = { "tkgstrator" => "nasawke.am@gmail.com" }
  spec.social_media_url   = "https://twitter.com/tkgling"
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/tkgstrator/SplatNet2.git", :tag => "#{spec.version}" }
  spec.source_files = "Classes", "Sources/**/*.{swift}"
  spec.requires_arc = true
  spec.swift_version = "5"
  spec.dependency "Alamofire", "5.4.0"
  spec.dependency "SwiftyJSON", "5.0.0"
end
