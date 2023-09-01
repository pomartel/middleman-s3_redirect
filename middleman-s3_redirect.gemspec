# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "middleman-s3_redirect"
  gem.version       = "4.0.0"
  gem.authors       = ["Frederic Jean", "Junya Ogura"]
  gem.email         = ["fred@fredjean.net"]
  gem.description   = %q{Generates redirects via S3 API.}
  gem.summary       = %q{Nothing to see here... Move along.}
  gem.homepage      = "https://github.com/fredjean/middleman-s3_redirect"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  gem.add_runtime_dependency 'middleman-core', '>= 3.0.0'
  gem.add_runtime_dependency 'fog-aws', '>= 0.1.1'
  gem.add_runtime_dependency 'parallel'

  gem.add_development_dependency 'rake'
end
