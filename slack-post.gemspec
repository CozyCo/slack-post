# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack/post/version'

Gem::Specification.new do |spec|
	spec.name          = "slack-post"
	spec.version       = Slack::Post::VERSION
	spec.authors       = ["John Bragg"]
	spec.email         = ["remotezygote@gmail.com"]
	spec.description   = 'Pretty simple really. It posts to slack fer ya.'
	spec.summary       = "It's for posting messages to your slack."
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler", "~> 2.0"
	spec.add_development_dependency "rake"
	spec.add_dependency 'yajl-ruby'
end
