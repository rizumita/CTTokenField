Pod::Spec.new do |s|
  s.name         = "CTTokenField"
  s.version      = "0.0.2"
  s.summary      = "CTTokenField is a token filed component for iOS."
  s.homepage     = "https://github.com/rizumita/CTTokenField"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Ryoichi Izumita" => "r.izumita@caph.jp" }
  s.source       = { :git => "https://github.com/rizumita/CTTokenField.git", :tag => "0.0.2" }
  s.platform     = :ios, '6.0'
  s.source_files = 'CTTokenField/*.{h,m}'
  s.requires_arc = true
end
