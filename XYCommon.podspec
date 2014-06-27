

Pod::Spec.new do |s|

  s.name         = "XYCommon"
  s.version      = "0.0.1"
  s.summary      = "self use common libs."

  s.homepage     = "https://github.com/yxyontheway/XYCommon"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "MIT"
    
  s.author       = { "杨 逍宇" => "yangxiaoyuontheway@gmail.com" }
  
  s.platform     = :ios
  s.requires_arc = true
  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"

  s.source  = { :git => "https://github.com/yxyontheway/XYCommon.git", :tag => "0.0.1" }

  s.source_files  = "XYCommon/XYCommon/class/*.{h,m}"

  s.subspec 'categories' do |categories|     
    categories.source_files = 'XYCommon/XYCommon/class/categories'
  end
  s.subspec 'XYdao' do |dao|     
    dao.source_files = 'XYCommon/XYCommon/class/XYdao'
  end
  s.subspec 'XYNetworking' do |networking|     
    networking.source_files = 'XYCommon/XYCommon/class/XYNetworking'
  end 
     
  s.framework  = 'UIKit', 'QuartzCore', 'CFNetwork', 'AVFoundation', 'CoreFoundation', 'CoreGraphics'

end