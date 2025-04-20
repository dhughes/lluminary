# frozen_string_literal: true
require "dotenv"
Dotenv.load

require "lluminary"
require "pry-byebug"

RSpec.configure do |config|
  config.before(:each) { Lluminary.reset_configuration }
end
