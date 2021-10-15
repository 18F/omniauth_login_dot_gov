
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/login_dot_gov/version'

Gem::Specification.new do |s|
  s.name = 'omniauth_login_dot_gov'
  s.version = OmniAuth::LoginDotGov::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Jonathan Hooper <jonathan.hooper@gsa.gov>']
  s.email = 'hello@login.gov'
  s.homepage = 'http://github.com/18F/omniauth_login_dot_gov'
  s.summary = 'Login.gov OmniAuth strategy'
  s.description = 'An OmniAuth strategy for using OIDC to authenticate with Login.gov'
  s.date = Time.now.utc.strftime('%Y-%m-%d')
  s.files = Dir.glob('app/**/*') + Dir.glob('lib/**/*') + [
    'LICENSE.md',
    'README.md',
    'Gemfile',
    'ominauth_login_dot_gov.gemspec',
  ]
  s.license = 'LICENSE'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'faraday', '~> 0.17'
  s.add_dependency 'json-jwt', '~> 1.11'
  s.add_dependency 'jwt', '~> 2.2'
  s.add_dependency 'multi_json', '~> 1.14'
  s.add_dependency 'omniauth', '~> 2.0'

  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'webmock'
end
