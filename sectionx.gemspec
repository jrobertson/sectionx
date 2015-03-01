Gem::Specification.new do |s|
  s.name = 'sectionx'
  s.version = '0.4.0'
  s.summary = 'Makes it convenient to store and retrieve hierarchical data in an XML format known as SectionX'
  s.authors = ['James Robertson']
  s.files = Dir['lib/**/*.rb']
  s.add_runtime_dependency('line-tree', '~> 0.5', '>=0.5.3')
  s.add_runtime_dependency('rexle-builder', '~> 0.2', '>=0.2.1')
  s.add_runtime_dependency('rxfhelper', '~> 0.2', '>=0.2.1')
  s.add_runtime_dependency('recordx', '~> 0.1', '>=0.1.16')
  s.signing_key = '../privatekeys/sectionx.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/sectionx'
end
