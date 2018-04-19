Pod::Spec.new do |s|
  s.name         = "DDPhotoPicker-AV"
  s.version      = "1.0.0"
  s.summary      = "take photo in program"
  s.homepage     = "https://github.com/chenddcoder/DDPhotoPicker"
  s.license      = "MIT"
  s.author             = { "chenddcoder" => "chenddcoder@foxmail.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/chenddcoder/DDPhotoPicker.git", :tag => "1.0.0" }
  s.source_files  = "DDPhotoPicker/DDPhotoPicker/Classes/*.{h,m}"
  s.requires_arc = true
end
