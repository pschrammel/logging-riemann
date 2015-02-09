# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


Gem::Specification.new do |spec|
  spec.name = "logging-riemann"
  spec.version = "0.0.2" #Logging::Riemann::VERSION
  spec.authors = ["Peter Schrammel"]
  spec.email = ["peter.schrammel@preisanalytics.de"]
  spec.summary = %q{Logs to riemann}
  spec.description = %q{Logs to riemann}
  spec.homepage = ""
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "logging", "~> 1.8.1"
  spec.add_dependency "riemann-client", ">= 0.2.5"
end
