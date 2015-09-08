# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday_csrf/version'

Gem::Specification.new do |spec|
  spec.name          = "faraday_csrf"
  spec.version       = FaradayCsrf::VERSION
  spec.authors       = ["unmanbearpig"]
  spec.email         = ["unmanbearpig@gmail.com"]

  spec.summary       = %q{Faraday middleware that automatically adds CSRF tokens to requests}
  spec.homepage      = 'https://github.com/unmanbearpig/faraday_csrf'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "faraday"
  spec.add_dependency "nokogiri"


  spec.add_development_dependency "bundler", "> 1.9"
  spec.add_development_dependency "rake", "~> 10.4.2"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "rspec-expectations", "~> 3.3.1"
  spec.add_development_dependency "webmock", "~> 1.21"
  spec.add_development_dependency "vcr", "~> 2.9"
  spec.add_development_dependency "faraday-cookie_jar", "~> 0.0.6"
end
