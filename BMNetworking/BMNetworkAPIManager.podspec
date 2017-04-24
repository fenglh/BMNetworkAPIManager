

Pod::Spec.new do |s|


  s.name         = "BMNetworkAPIManager"
  s.version      = "1.1.8"
  s.summary      = "网络层框架,集成afnetworking3.0功能."
  s.description  = <<-DESC
                      网络层框架,集成afnetworking3.0;自带分页、缓存等功能.
                   DESC

  s.homepage     = "https://github.com/aa335418265/BMNetworkAPIManager"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "itx" => "335418265@qq.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/aa335418265/BMNetworkAPIManager.git", :tag => "1.1.8" }
  s.source_files  = "Classes", "BMNetworking/BMNetworkCenter/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.ios.deployment_target = '8.0'
  s.dependency "AFNetworking"
  s.dependency "RealReachability"

end
