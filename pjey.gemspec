# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pjey/version'

Gem::Specification.new do |spec|
  spec.name          = "pjey"
  spec.version       = Jekyll::Pjey::VERSION
  spec.authors       = ["Frank Cieslik"]
  spec.email         = ["frank.cieslik@gmail.com"]
  spec.summary       = %q{A multi purpose pagination Jekyll.}
  spec.homepage      = "https://github.com/sss-io/pjey"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).grep(%r{(lib/)})
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ENV['JEKYLL_VERSION'] ? "~> #{ENV['JEKYLL_VERSION']}" : ">= 3.0"
  spec.add_dependency "bundler", "~> 1.5"
  spec.add_dependency "rake"
  spec.add_dependency "rspec"
end