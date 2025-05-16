# frozen_string_literal: true

require_relative "lluminary/version"
require_relative "lluminary/result"
require_relative "lluminary/task"
# require base model first
require_relative "lluminary/models/base"
# automatically require all models first
Dir[File.join(__dir__, "lluminary/models/**/*.rb")].each { |file| require file }
# require base provider first
require_relative "lluminary/providers/base"
# then require all other providers
Dir[File.join(__dir__, "lluminary/providers/*.rb")].each do |file|
  require file unless file.end_with?("base.rb")
end
require_relative "lluminary/config"

# Lluminary is a framework for building and running LLM-powered tasks.
# It provides a structured way to define tasks, their inputs and outputs,
# and handles the interaction with various LLM providers.
#
# @example Creating a simple task
#   class MyTask < Lluminary::Task
#     def run
#       # Task implementation
#     end
#   end
module Lluminary
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def reset_configuration
      @config = Config.new
    end
  end
end
