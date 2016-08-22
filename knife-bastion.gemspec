# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-bastion/version'

Gem::Specification.new do |spec|
  spec.name          = "knife-bastion"
  spec.version       = Knife::Bastion::VERSION
  spec.authors       = ["Dmytro Shteflyuk"]
  spec.email         = ["dmytro@eligible.com"]

  spec.summary       = %q{Access Chef securely via bastion server.}
  spec.description   = %q{Protect your Chef server by restricting direct access to Chef HTTPS port to be only accessible from your internal network.}
  spec.homepage      = "https://github.com/eligible/knife-bastion"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'chef'
  spec.add_runtime_dependency 'highline'
  spec.add_runtime_dependency 'socksify'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
