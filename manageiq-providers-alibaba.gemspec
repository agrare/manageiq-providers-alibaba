# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'manageiq/providers/alibaba/version'

Gem::Specification.new do |spec|
  spec.name          = "manageiq-providers-alibaba"
  spec.version       = ManageIQ::Providers::Alibaba::VERSION
  spec.authors       = ["ManageIQ Authors"]

  spec.summary       = "ManageIQ plugin for the Alibaba provider."
  spec.description   = "ManageIQ plugin for the Alibaba provider."
  spec.homepage      = "https://github.com/ManageIQ/manageiq-providers-alibaba"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aliyunsdkcore", "~> 0.0.16"
  spec.add_development_dependency "simplecov"
end
