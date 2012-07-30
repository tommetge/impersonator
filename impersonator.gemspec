require File.expand_path('../lib/impersonator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tom Metge"]
  gem.email         = ["tom@metge.us"]
  gem.description   = %q{Markov-backed IRC personality}
  gem.summary       = %q{A Cinch-based IRC bot using markov chains to impersonate}
  gem.homepage      = "https://github.com/tommetge/impersonator"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "impersonator"
  gem.require_paths = ["lib"]
  gem.version       = Impersonator::VERSION
end
