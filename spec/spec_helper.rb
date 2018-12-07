require 'pry-byebug'
require 'webmock'
require 'webmock/rspec'

require 'omniauth_login_dot_gov'

RSpec.configure do |config|
  # see more settings at spec/rails_helper.rb
  config.raise_errors_for_deprecations!
  config.order = :random
  config.color = true

  # allows you to run only the failures from the previous run:
  # rspec --only-failures
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'

  # Skip user_flow specs in default tasks
  config.filter_run_excluding user_flow: true
end

WebMock.disable_net_connect!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].sort.each { |file| require file }
