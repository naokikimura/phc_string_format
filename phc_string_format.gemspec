
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "phc_string_format/version"

Gem::Specification.new do |spec|
  spec.name          = "phc_string_format"
  spec.version       = PhcStringFormat::VERSION
  spec.authors       = ["naokikimura"]
  spec.email         = ["n.kimura.cap@gmail.com"]

  spec.summary       = %q{PHC string format implemented by Ruby.}
  spec.homepage      = "https://github.com/naokikimura/phc_string_format"
  spec.license       = "MIT"

  spec.metadata      = {
    "bug_tracker_uri" => "https://github.com/naokikimura/phc_string_format/issues",
    "source_code_uri" => "https://github.com/naokikimura/phc_string_format.git"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug", "~> 3.6"
end
