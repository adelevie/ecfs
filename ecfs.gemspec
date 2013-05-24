# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecfs/version'

Gem::Specification.new do |spec|
  spec.name          = "ecfs"
  spec.version       = ECFS::VERSION
  spec.authors       = ["Alan deLevie"]
  spec.email         = ["adelevie@gmail.com"]
  spec.description   = %q{ECFS provides a set of utilities for scraping FCC rulemakings}
  spec.summary       = %q{ECFS helps you obtain comments and other filings from the FCC's Electronic Comment Filing System}
  spec.homepage      = "http://github.com/adelevie/ecfs"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock", "1.9.0"

  spec.add_dependency "pdf-reader"
  spec.add_dependency "pry"
  spec.add_dependency "mechanize"
  spec.add_dependency "spreadsheet"
end
