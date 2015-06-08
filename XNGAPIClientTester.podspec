Pod::Spec.new do |s|
  s.name = 'XNGAPIClientTester'
  s.version = '0.2.0'
  s.license = 'MIT'
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.summary = 'The client tester for the XINGAPIClient'
  s.author  = {
    'XING iOS Team' => 'iphonedev@xing.com'
  }
  s.source = {
    :git => 'https://github.com/xing/XNGAPIClientTester.git',
    :tag => s.version.to_s
  }
  s.source_files = '*.{h,m}'
  s.requires_arc = true
  s.homepage = 'https://www.xing.com'
  s.dependency 'OHHTTPStubs'
  s.dependency 'Expecta'
  s.dependency 'XNGAPIClient'
end
