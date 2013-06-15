Pod::Spec.new do |s|
  s.name         = "RDataKit"
  s.version      = "0.0.1"
  s.summary      = "RDataKit is a toolkit to handle restful API and CoreData Objects."
  s.description  = <<-DESC
                    #What is it?
  
                    * Lightweight ORM FX over CoreData
                    * Restful API handling
                    
                    Have fun!
                   DESC
  s.homepage     = "https://github.com/RobinQu/RDataKit"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "RobinQu" => "robinqu@gmail.com" }
  s.source       = { :git => "https://github.com/RobinQu/RDataKit.git", :tag => "0.0.1"}


  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'

  s.source_files = 'RDataKit', 'RDataKit/**/*.{h,m}'
  s.exclude_files = 'RDataKit/Exclude'

  s.public_header_files = 'RDataKit/**/*.h'

  s.frameworks = 'CoreData', 'SystemConfiguration'

  s.requires_arc = true

  s.dependency 'AFNetworking', '~> 1.3.0'
  s.dependency 'Inflections', '~>1.0.0'
  
  
  s.prefix_header_contents = <<-EOS
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
    #import "RDataKitCommons.h"
  EOS
end
