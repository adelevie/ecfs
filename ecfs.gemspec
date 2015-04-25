# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecfs/version'

Gem::Specification.new do |spec|
  spec.name          = "ecfs"
  spec.version       = ECFS::VERSION
  spec.authors       = ["Alan deLevie"]
  spec.email         = ["adelevie@gmail.com"]

  spec.summary       = %q{Scraper for the FCC's Electronic Comment Filing System}
  spec.description   = %q{Provides Ruby-based access to the FCC's Electronic Comment Filing System}
  spec.homepage      = "https://github.com/adelevie/ecfs"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_dependency "nokogiri"
  spec.add_dependency "pry"
  spec.add_dependency "unirest"
  spec.add_dependency "rubyzip"
  spec.add_dependency "open_uri_redirections"

  spec.add_development_dependency "webmock"
  spec.add_development_dependency "bundler"#, "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
end
