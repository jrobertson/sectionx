Gem::Specification.new do |s|
  s.name = 'sectionx'
  s.version = '0.4.2'
  s.summary = 'Makes it convenient to store and retrieve hierarchical data ' + 
      'in an XML format known as SectionX'
  s.authors = ['James Robertson']
  s.files = Dir['lib/sectionx.rb']
  s.add_runtime_dependency('line-tree', '~> 0.7', '>=0.7.0')
  s.add_runtime_dependency('rexle-builder', '~> 0.3', '>=0.3.13')
  s.add_runtime_dependency('rxfhelper', '~> 0.8', '>=0.8.7')
  s.add_runtime_dependency('recordx', '~> 0.5', '>=0.5.3')
  s.signing_key = '../privatekeys/sectionx.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/sectionx'
end
