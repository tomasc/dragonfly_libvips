# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dragonfly_libvips/version"

Gem::Specification.new do |spec|
  spec.name          = "dragonfly_libvips"
  spec.version       = DragonflyLibvips::VERSION
  spec.authors       = ["Tomas Celizna"]
  spec.email         = ["tomas.celizna@gmail.com"]

  spec.summary       = "Dragonfly analysers and processors for libvips image processing library."
  spec.homepage      = "https://github.com/tomasc/dragonfly_libvips"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dragonfly", "~> 1.0"
  spec.add_dependency "ruby-vips", "~> 2.0", ">= 2.0.16"

  spec.add_development_dependency "bundler" # , '~> 2.0'
  spec.add_development_dependency "rb-readline"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "lefthook"
  spec.add_development_dependency "rubocop-rails_config"
end
