# frozen_string_literal: true
require "simplecov"
SimpleCov.start { add_filter "/spec/" } if ENV["COVERAGE"]

require "dotenv"
Dotenv.load

require "lluminary"
require "pry-byebug"

RSpec.configure do |config|
  config.before(:each) { Lluminary.reset_configuration }
end
