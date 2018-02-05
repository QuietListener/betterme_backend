ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all test_resources in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all test_resources here...
end
