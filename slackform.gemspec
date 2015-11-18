lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slackform/version'

Gem::Specification.new do |spec|
  spec.name          = "slackform"
  spec.version       = Slackform::VERSION
  spec.authors       = ["MarsBased"]
  spec.email         = ["hello@marsbased.com"]

  spec.summary       = "Invite new members to a Slack team from Typeform answers."
  spec.description   = "Slackform is a command line tool to automatically invite new members to a Slack team from the answers of a Typeform."
  spec.homepage      = "https://github.com/MarsBased/slackform"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ["slackform"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", '~> 0'
  spec.add_development_dependency "pry", '~> 0'

  spec.add_dependency "httparty", "~> 0.13.7"
  spec.add_dependency "thor", "~> 0.19.1"
end
