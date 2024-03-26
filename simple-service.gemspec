# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple-service/version'

Gem::Specification.new do |spec|
  spec.name          = "simple-service"
  spec.version       = SimpleService::VERSION
  spec.authors       = ["LeadSimple Engineering"]
  spec.email         = ["engineering@leadsimple.com"]
  spec.summary       = 'A simple implementation of the service-object pattern'
  spec.homepage      = "https://github.com/LeadSimple/simple-service"
  spec.license       = "MIT"
  spec.files         = `find *`.split("\n").uniq.sort.select { |f| !f.empty? }
  spec.test_files    = spec.files.grep(/^spec/)
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0"

  spec.add_development_dependency "bundler", ">= 1.12"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency 'rspec', '~> 3.6'
end
