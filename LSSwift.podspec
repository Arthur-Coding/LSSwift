Pod::Spec.new do |s|

    s.name         = "LSSwift"
    s.version      = "1.1.2"
    s.summary      = "LSSwift"
    s.description  = "LSSwift"

    s.homepage     = "https://github.com/Arthur-Coding/"
    s.license      = "MIT"
    s.author       = { "ArthurShuai" => "zhixingui_liushuai@163com" }

    s.platform     = :ios, "9.0"
    s.requires_arc = true
	s.swift_version = "4.2"

    s.source       = { :git => "https://github.com/Arthur-Coding/LSSwift.git", :tag => "#{s.version}" }
    s.source_files = '**/*.swift'
    s.frameworks = 'UIKit','Foundation'

end
