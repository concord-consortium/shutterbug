# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shutterbug'

Gem::Specification.new do |spec|
  spec.name          = "shutterbug"
  spec.version       = Shutterbug::VERSION
  spec.authors       = ["Noah Paessel"]
  spec.email         = ["knowuh@gmail.com"]

  spec.description   = %q{
    A rack utility that will create and save images (pngs)
    for a part of your web page's current dom. These images
    become available as public '.png' resources in the rack application.
    Currently shutterbug supports HTML, SVG and Canvas elements.
  }

  spec.summary       = %q{ use Shutterbug::Rackapp }
  spec.homepage      = "http://github.com/concord-consortium/shutterbug"
  spec.license       = "MIT, Simplified BSD, Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rack-cors"
  spec.add_development_dependency "guard-rack"
  spec.add_development_dependency "rack-test"

  spec.add_dependency "rack"
  spec.add_dependency "fog"

end
