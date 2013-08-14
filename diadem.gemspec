# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'diadem/version'

Gem::Specification.new do |spec|
  spec.name          = "diadem"
  spec.version       = Diadem::VERSION
  spec.authors       = ["John Prince"]
  spec.email         = ["jtprince@gmail.com"]
  spec.description   = %q{Dynamic isotope analysis for mass spectrometry isotope experiments.  Calculates and visualizes varying isotope ratios and allows the user fine control over incorporation rates.}
  spec.summary       = %q{Dynamic isotope analysis for mass spectrometry isotope experiments}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
